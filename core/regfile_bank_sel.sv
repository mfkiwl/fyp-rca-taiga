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


module regfile_bank_sel
    import taiga_config::*;
    import riscv_types::*;
    import taiga_types::*;
    #(
        parameter READ_PORTS = REGFILE_READ_PORTS,
        parameter LOG2_WRITE_PORTS = LOG2_COMMIT_PORTS,
        parameter WRITE_PORTS = COMMIT_PORTS
    )
    (
        input logic clk,
        input logic rst,

        //Register file
        input rs_addr_t [READ_PORTS-1:0] rs_addr,
        output logic [LOG2_WRITE_PORTS-1:0] rs_sel [READ_PORTS],

        //Writeback
        input logic[4:0] rd_addr [WRITE_PORTS],
        input rd_retired [WRITE_PORTS]

    );
    //////////////////////////////////////////
    typedef logic [LOG2_WRITE_PORTS-1:0] sel_bank_t [32] ;
    sel_bank_t sel_bank [WRITE_PORTS];

    logic [LOG2_WRITE_PORTS-1:0] new_bank_sel [WRITE_PORTS];
    genvar i;
    ////////////////////////////////////////////////////
    //Implementation

    ////////////////////////////////////////////////////
    //New Entry Determination
    //New entry is the current port index XORed with the content of all other write ports
    //existing memory contents
    always_comb begin
        for (int i = 0; i < WRITE_PORTS; i++) begin
            new_bank_sel[i] = LOG2_WRITE_PORTS'(i);
            for (int j = 0; j < WRITE_PORTS; j++) begin
                if (j != i) new_bank_sel[i] ^= sel_bank[j][rd_addr[i]];
            end
        end
    end

    ////////////////////////////////////////////////////
    //Memory Blocks
    generate for (i = 0; i < WRITE_PORTS; i++) begin
        initial sel_bank[i] = '{default: 0};
        always_ff @ (posedge clk) begin
            if (rd_retired[i])
                sel_bank[i][rd_addr[i]] <= new_bank_sel[i];
        end
    end endgenerate

    ////////////////////////////////////////////////////
    //Outputs
    always_comb begin
        for (int i = 0; i < READ_PORTS; i++) begin
            rs_sel[i] = 0;
            for (int j = 0; j < WRITE_PORTS; j++) begin
                rs_sel[i] ^= sel_bank[j][rs_addr[i]];
            end
        end
    end

    ////////////////////////////////////////////////////
    //End of Implementation
    ////////////////////////////////////////////////////

    ////////////////////////////////////////////////////
    //Assertions

endmodule
