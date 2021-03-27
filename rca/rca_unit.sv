import riscv_types::*;
import taiga_types::*;

module rca_unit(
    unit_issue_interface.unit taiga_issue_if,
    unit_writeback_interface.unit taiga_wb_if,
    input clk,
    input rst,
    input rca_inputs_t rca_inputs
);

    //stub module for later implementation of RCAs
    assign taiga_issue_if.ready = 1'b1;
    assign taiga_wb_if.done = taiga_issue_if.new_request;
    assign taiga_wb_if.id = taiga_issue_if.instruction_id;
    assign taiga_wb_if.rd = 0;
    
endmodule