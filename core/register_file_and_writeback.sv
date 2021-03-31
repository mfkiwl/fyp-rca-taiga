/*
 * Copyright © 2020 Eric Matthews,  Lesley Shannon
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Initial code developed under the supervision of Dr. Lesley Shannon,
 * Reconfigurable Computing Lab, Simon Fraser University.
 *
 * Author(s):
 *             Eric Matthews <ematthew@sfu.ca>
 */

module register_file_and_writeback
    import taiga_config::*;
    import riscv_types::*;
    import taiga_types::*;
    (
        input logic clk,
        input logic rst,

        //Issue interface
        input issue_packet_t issue,
        input logic alu_issued,
        output logic [31:0] rs_data [REGFILE_READ_PORTS],
        //ID Metadata
        output id_t ids_retiring [COMMIT_PORTS],
        output logic retired [COMMIT_PORTS],

        output id_t rca_id_retiring,
        output logic rca_retired,


        input logic [4:0] retired_rd_addr [COMMIT_PORTS],
        input id_t id_for_rd [COMMIT_PORTS],

        input logic [4:0] rca_retired_rd_addrs [NUM_WRITE_PORTS],
        input id_t rca_id_for_rds,

        //Writeback
        unit_writeback_interface.wb unit_wb[NUM_WB_UNITS],
        writeback_store_interface.wb wb_store,

        rca_writeback_interface.wb rca_wb,

        //Trace signals
        output logic tr_rs1_forwarding_needed,
        output logic tr_rs2_forwarding_needed,
        output logic tr_rs1_and_rs2_forwarding_needed
    );

    //Register File
    typedef logic [XLEN-1:0] register_file_t [32];
    register_file_t register_file [COMMIT_PORTS]; //AV:name of this variable is same as name of register file module
    logic [LOG2_COMMIT_PORTS-1:0] rs_sel [REGFILE_READ_PORTS];

    //Writeback
    logic alu_selected;
    logic unit_ack [NUM_WB_UNITS];
    //aliases for write-back-interface signals
    id_t unit_instruction_id [NUM_WB_UNITS];
    logic unit_done [NUM_WB_UNITS];
    typedef logic [XLEN-1:0] unit_rd_t [NUM_WB_UNITS];
    unit_rd_t unit_rd [COMMIT_PORTS];
    //Per-ID muxes for commit buffer
    logic [$clog2(NUM_WB_UNITS)-1:0] retiring_unit_select [COMMIT_PORTS];
    logic [31:0] retiring_data [COMMIT_PORTS];

    typedef logic [31:0] rs_data_set_t [REGFILE_READ_PORTS];
    rs_data_set_t rs_data_set [COMMIT_PORTS];

    //RCA Register File
    logic [$clog2(NUM_WRITE_PORTS)-1:0] rca_rs_sel [REGFILE_READ_PORTS];

    //RCA Commit Logic
    logic rca_unit_ack;
    id_t rca_unit_instr_id;
    logic rca_unit_done;
    logic [XLEN-1:0] rca_unit_rds [NUM_WRITE_PORTS];
    logic [XLEN-1:0] rca_retiring_data [NUM_WRITE_PORTS];

    rs_data_set_t rca_rs_data_set [NUM_WRITE_PORTS];


    genvar i, j;
    ////////////////////////////////////////////////////
    //Implementation
    //Re-assigning interface inputs to array types so that they can be dynamically indexed
    generate for (i=0; i< NUM_WB_UNITS; i++) begin : wb_interfaces_to_arrays_g
        assign unit_instruction_id[i] = unit_wb[i].id;
        assign unit_done[i] = unit_wb[i].done;
        assign unit_wb[i].ack = unit_ack[i];
    end endgenerate

    assign rca_unit_instr_id = rca_wb.id;
    assign rca_unit_done = rca_wb.done;
    assign rca_wb.ack = rca_unit_ack;

    //As units are selected for commit ports based on their unit ID,
    //for each additional commit port one unit can be skipped for the commit mux
    generate for (i = 0; i < COMMIT_PORTS; i++) begin
        initial unit_rd[i] = '{default: '0};
        for (j=i; j< NUM_WB_UNITS; j++) begin
            assign unit_rd[i][j] = unit_wb[j].rd;
        end
    end endgenerate

    //RCA assign rds to retiring data
    generate for (i = 0; i < NUM_WRITE_PORTS; i++) begin
        assign rca_unit_rds[i] = rca_wb.rd[i];
    end endgenerate

    ////////////////////////////////////////////////////
    //Unit select for register file
    //Iterating through all commit ports:
    //   Search for complete units (in fixed unit order)
    //   Assign to a commit port, mask that unit and commit port
    always_comb begin
        unit_ack = '{default: 0};
        retired = '{default: 0};

        unit_ack[0] = alu_issued;
        retired[0] = alu_issued;
        ids_retiring[0] = unit_instruction_id[ALU_UNIT_WB_ID];
        retiring_data[0] = unit_rd[0][ALU_UNIT_WB_ID];

        for (int i = 1; i < COMMIT_PORTS; i++) begin
            retiring_unit_select[i] = WB_UNITS_WIDTH'(i);
            for (int j = i; j < NUM_WB_UNITS; j++) begin //Unit index i will always be handled by commit port i or lower, so can be skipped when checking higher commit port indicies
                if (unit_done[j] & ~unit_ack[j] & ~retired[i]) begin
                    retiring_unit_select[i] = WB_UNITS_WIDTH'(j);
                    unit_ack[j] = 1;
                    retired[i] = 1;
                end
            end

            //ID and data muxes
            ids_retiring[i] = unit_instruction_id[retiring_unit_select[i]];
            retiring_data[i] = unit_rd[i][retiring_unit_select[i]];
        end
        //Late cycle abort for when ALU is not issued to
        //alu_selected = (retiring_unit_select[0] == ALU_UNIT_WB_ID);
        //if (alu_selected) retired[0] &= alu_issued;
    end

    //RCA Unit Ack logic
    always_comb begin
        rca_unit_ack = 0;
        rca_retired = 0;

        if(rca_unit_done & ~rca_unit_ack & ~rca_retired) begin
            rca_unit_ack = 1;
            rca_retired = 1;             
        end

        rca_id_retiring = rca_unit_instr_id;
        rca_retiring_data = rca_unit_rds;
    end

    ////////////////////////////////////////////////////
    //Register Files
    //Implemented in seperate module as there is not universal tool support for inferring
    //arrays of memory blocks.
    generate for (i = 0; i < COMMIT_PORTS; i++) begin
        register_file #(.NUM_READ_PORTS(REGFILE_READ_PORTS)) register_file_blocks (
            .clk, .rst,
            .rd_addr(retired_rd_addr[i]),
            .new_data(retiring_data[i]),
            .commit(update_lvt[i] & (|retired_rd_addr[i])),
            .read_addr(issue.rs_addr),
            .data(rs_data_set[i])
        );
    end endgenerate

    //Additional Register files for RCA write ports
    generate for (i = 0; i < NUM_WRITE_PORTS; i++) begin
        register_file #(.NUM_READ_PORTS(REGFILE_READ_PORTS)) register_file_blocks_rca (
            .clk, .rst,
            .rd_addr(rca_retired_rd_addrs[i]),
            .new_data(rca_retiring_data[i]),
            .commit(rca_update_lvt[i] & (|rca_retired_rd_addrs[i])),
            .read_addr(issue.rs_addr),
            .data(rca_rs_data_set[i])
        );
    end endgenerate

    ////////////////////////////////////////////////////
    //Register File LVT

    //Only update lvt if the retiring instrucion is the most recently issued
    //write to a given register.  This check allows multiple oustanding writes
    //to the same register.  As instructions can complete out-of-order, only
    //the most recently issued write to any given register will be committed
    logic update_lvt [COMMIT_PORTS];
    always_comb begin
        update_lvt[0] = retired[0];// & (alu_selected ? alu_issued : (id_for_rd[0] == ids_retiring[0]));
        for (int i = 1; i < COMMIT_PORTS; i++)
            update_lvt[i] = retired[i] & (id_for_rd[i] == ids_retiring[i]) & ~(retired[0] & retired_rd_addr[0] == retired_rd_addr[i]);
    end

    regfile_bank_sel regfile_lvt (
        .clk, .rst,
        .rs_addr(issue.rs_addr),
        .rs_sel,
        .rd_addr(retired_rd_addr),
        .rd_retired(update_lvt)
    );

    //LVTs for additional RCA Write Ports
    logic rca_update_lvt [NUM_WRITE_PORTS];
    always_comb begin
        for(int i = 0; i < NUM_WRITE_PORTS; i++) 
            rca_update_lvt[i] = rca_retired & (rca_id_for_rds == rca_id_retiring) & ~(retired[0] & retired_rd_addr[0] == rca_retired_rd_addrs[i]);
    end

    regfile_bank_sel #(.WRITE_PORTS(NUM_WRITE_PORTS), .LOG2_WRITE_PORTS($clog2(NUM_WRITE_PORTS))) rca_regfile_lvt (
        .clk, .rst,
        .rs_addr(issue.rs_addr),
        .rs_sel(rca_rs_sel),
        .rd_addr(rca_retired_rd_addrs),
        .rd_retired(rca_update_lvt)
    );

    //Separate LVT to select between RCA Reg file and normal reg file
    localparam TOTAL_WRITE_PORTS = COMMIT_PORTS + NUM_WRITE_PORTS;
    logic [4:0] all_retired_rd_addrs [TOTAL_WRITE_PORTS]; 
    logic all_update_lvts [TOTAL_WRITE_PORTS];

    always_comb begin
        for(int i = 0; i < COMMIT_PORTS; i++)
            all_retired_rd_addrs[i] = retired_rd_addr[i];
    end

    always_comb begin
        for(int i = COMMIT_PORTS; i < TOTAL_WRITE_PORTS; i++)
            all_retired_rd_addrs[i] = rca_retired_rd_addrs[i - COMMIT_PORTS];
    end

    always_comb begin
        for(int i = 0; i < COMMIT_PORTS; i++)
            all_update_lvts[i] = update_lvt[i];
    end

    always_comb begin
        for(int i = COMMIT_PORTS; i < TOTAL_WRITE_PORTS; i++)
            all_update_lvts[i] = rca_update_lvt[i - COMMIT_PORTS];
    end

    logic [$clog2(TOTAL_WRITE_PORTS)-1:0] norm_rca_sel [REGFILE_READ_PORTS];
    regfile_bank_sel #(.WRITE_PORTS(TOTAL_WRITE_PORTS), .LOG2_WRITE_PORTS($clog2(TOTAL_WRITE_PORTS))) norm_rca_lvt
    (
        .clk, .rst,
        .rs_addr(issue.rs_addr),
        .rs_sel(norm_rca_sel),
        .rd_addr(all_retired_rd_addrs),
        .rd_retired(all_update_lvts)
    );

    logic norm_rca_regfile_sel [REGFILE_READ_PORTS]; //0 if normal register file should be used, 1 if RCA register file should be used
    always_comb begin
        for(int i = 0; i < REGFILE_READ_PORTS; i++) begin
            if(norm_rca_sel[i] < $clog2(TOTAL_WRITE_PORTS)'(COMMIT_PORTS)) norm_rca_regfile_sel[i] = 0;
            else norm_rca_regfile_sel[i] = 1;
        end
    end

    ////////////////////////////////////////////////////
    //Register File Muxing
    always_comb begin
        for (int i = 0; i < REGFILE_READ_PORTS; i++) begin
            rs_data[i] = (norm_rca_regfile_sel[i] == 1'b1) ? rca_rs_data_set[rca_rs_sel[i]][i] : rs_data_set[rs_sel[i]][i];
        end
    end

    //RCA unit will handle Load/Stores internally => no changes made to this 
    ////////////////////////////////////////////////////
    //Store Forwarding Support
    logic [31:0] commit_regs [COMMIT_PORTS-1];
    logic [$clog2(COMMIT_PORTS)-1:0] store_reg_sel;
    logic [$clog2(COMMIT_PORTS)-1:0] store_reg_sel_r;

    generate for (i = 1; i < COMMIT_PORTS; i++) begin
        always_ff @ (posedge clk) begin
            if (wb_store.possibly_waiting & retired[i] & (wb_store.id_needed == ids_retiring[i]))
                commit_regs[i-1] <= retiring_data[i];
        end
    end endgenerate

    logic [COMMIT_PORTS-1:0] store_id_match;
    always_comb begin
        store_id_match = 0;
        for (int i = 1; i < COMMIT_PORTS; i++) begin
            if (wb_store.waiting & retired[i] & (wb_store.id_needed == ids_retiring[i]))
                store_id_match[i] = 1;
        end

        store_reg_sel = 0;
        for (int i = 2; i < COMMIT_PORTS; i++) begin
            if (retired[i] & (wb_store.id_needed == ids_retiring[i]))
                store_reg_sel = ($clog2(COMMIT_PORTS))'(i-1);
        end
    end

    always_ff @ (posedge clk) begin
        if (|store_id_match)
            store_reg_sel_r <= store_reg_sel;
    end

    always_ff @ (posedge clk) begin
        if (rst | wb_store.ack)
            wb_store.id_done <= 0;
        else if (|store_id_match)
            wb_store.id_done <= 1;
    end
    assign wb_store.data = commit_regs[store_reg_sel_r];



    ////////////////////////////////////////////////////
    //End of Implementation
    ////////////////////////////////////////////////////

    ////////////////////////////////////////////////////
    //Assertions

endmodule
