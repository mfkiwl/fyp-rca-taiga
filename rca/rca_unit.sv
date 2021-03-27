import riscv_types::*;
import taiga_types::*;

module rca_unit(
    unit_issue_interface.unit issue,
    unit_writeback_interface.unit wb,
    input clk,
    input rst,
    input rca_inputs_t rca_inputs,
    output rca_config_t rca_config_regs_op
);

    rca_config_regs rca_config_regfile(
        .clk(clk),
        .rst(rst),
        .rca_sel(rca_inputs.rca_sel),
        .rca_src_reg_addrs(rca_config_regs_op.rca_src_reg_addrs),
        .rca_dest_reg_addrs(rca_config_regs_op.rca_dest_reg_addrs),

        .wr_en(rca_inputs.rca_use_config && issue.new_request),
        .w_port_sel(rca_inputs.w_port_sel),
        .w_src_dest_port(rca_inputs.w_src_dest_port),
        .w_reg_addr(rca_inputs.w_reg_addr)
    );

    //stub module for later implementation of RCAs
    assign issue.ready = 1'b1;
    
    always_ff @(posedge clk) begin
        if (rca_inputs.rca_use_config && issue.new_request) begin
            wb.done <= 1;
            wb.id <= issue.id;
        end
        else wb.done <= 0;
    end

    assign wb.rd = 0;
    
endmodule