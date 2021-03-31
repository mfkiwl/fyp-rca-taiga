import riscv_types::*;
import taiga_types::*;

module rca_unit(
    unit_issue_interface.unit issue,
    // unit_writeback_interface.unit wb,
    input clk,
    input rst,
    input rca_inputs_t rca_inputs,
    output rca_config_t rca_config_regs_op,
    rca_writeback_interface.unit rca_wb
);
    logic rca_config_instr_r;
    always_ff @(posedge clk) rca_config_instr_r <= rca_inputs.rca_config_instr;

    rca_config_regs rca_config_regfile(
        .clk(clk),
        .rst(rst),
        .rca_sel(rca_inputs.rca_sel),
        .rca_src_reg_addrs(rca_config_regs_op.rca_src_reg_addrs),
        .rca_dest_reg_addrs(rca_config_regs_op.rca_dest_reg_addrs),

        .wr_en(rca_config_instr_r && issue.new_request),
        .w_port_sel(rca_inputs.w_port_sel),
        .w_src_dest_port(rca_inputs.w_src_dest_port),
        .w_reg_addr(rca_inputs.w_reg_addr)
    );

    //stub module for later implementation of RCAs
    assign issue.ready = 1'b1;
    
    always_ff @(posedge clk) begin
        if (rca_inputs.rca_config_instr && issue.new_request) begin
            // wb.done <= 1;
            // wb.id <= issue.id;
            // wb.rd <= rca_inputs.rs1;

            rca_wb.id <= issue.id;
            rca_wb.done <= 1;
            for(int i = 0; i < NUM_WRITE_PORTS; i++)
                rca_wb.rd[i] <= 0;
        end
        else if (~rca_inputs.rca_config_instr && issue.new_request) begin
            // wb.done <= 1;
            // wb.id <= issue.id;
            // wb.rd <= rca_inputs.rs1 + rca_inputs.rs2 + rca_inputs.rs3 + rca_inputs.rs4 + rca_inputs.rs5; 

            rca_wb.done <= 1
            rca_wb.id <= issue.id;
            //Reverse input register order - just for testing
            rca_wb.rd[0] <= rca_inputs.rs5;
            rca_wb.rd[1] <= rca_inputs.rs4;
            rca_wb.rd[2] <= rca_inputs.rs3;
            rca_wb.rd[3] <= rca_inputs.rs2;
            rca_wb.rd[4] <= rca_inputs.rs1;
        end
        else begin 
            // wb.done <= 0;
            // wb.rd <= 0;
            // wb.id <= 0;

            rca_wb.done <= 0;
            rca_wb.id <= 0;
            for(int i = 0; i < NUM_WRITE_PORTS; i++)
                rca_wb.rd[i] <= 0;
        end
    end

    //TODO: Implement rca_wb interface, + interface for implementing an instruction without rd
    
endmodule