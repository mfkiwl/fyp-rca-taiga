import riscv_types::*;
import taiga_types::*;

module testAdder(
    input [XLEN-1:0] a,
    input [XLEN-1:0] b,
    output [XLEN-1:0] sum,
    output  carry
);

    assign {carry, sum} = a+b;
    
endmodule

module taiga_testAdder(
    unit_issue_interface.unit taiga_issue_if,
    unit_writeback_interface.unit taiga_wb_if,
    input clk,
    input rst,
    input adder_inputs_t adder_inputs
);

    assign taiga_issue_if.ready = 1'b1;

    id_t id;
    logic new_issue;
    always @ (posedge clk or posedge rst) begin
        if (rst == 1'b1) begin
            id <= '0;
            new_issue <= '0;
        end
        else begin
            if (taiga_issue_if.new_issue == 1'b1) begin
                id <= taiga_issue_if.instruction_id;
                new_issue <= 1'b1;
            end
        end
    end

    logic carry; 
    testAdder adder(adder_inputs.rs1, adder_inputs.rs2, taiga_wb_if.rd, carry);

    assign taiga_wb_if.id = id;

    always @ (posedge clk or posedge rst) begin
        if (rst == 1'b1) begin
            taiga_wb_if.done = '0;
        end
        else begin
            if (new_issue == 1'b1) begin
                if (taiga_wb_if.ack == 1'b1) taiga_wb_if.done = 1'b1;
                else taiga_wb_if.done = 1'b0;
            end
        end
    end
    
endmodule