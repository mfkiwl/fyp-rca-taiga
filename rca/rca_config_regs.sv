import taiga_config::*;
import riscv_types::*;
import taiga_types::*;
import rca_config::*;

module rca_config_regs (
    input clk,
    input rst,

    //Read interface
    input [$clog2(NUM_RCAS)-1:-0] rca_sel_r,
    
    output [4:0] rca_src_reg_addrs [NUM_READ_PORTS],
    output [4:0] rca_dest_reg_addrs [NUM_WRITE_PORTS],

    //Write interface
    input [$clog2(NUM_RCAS)-1:-0] rca_sel_w,
    input [$clog2(NUM_READ_PORTS)-1:0] src_port_sel,
    input [$clog2(NUM_WRITE_PORTS)-1:0] dest_port_sel,
    input src_dest_port, //0 for src_addr reg, 1 for dest_addr_reg
    input [4:0] reg_addr
);

    logic [4:0] src_reg_addrs [NUM_READ_PORTS] [NUM_RCAS]; 
    logic [4:0] dest_reg_addrs [NUM_READ_PORTS] [NUM_RCAS];      


    initial begin
        src_reg_addrs <= '{default: '0};
        dest_reg_addrs <= '{default: '0};
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            src_reg_addrs <= '{default: '0};
            dest_reg_addrs <= '{default: '0};
        end
        else begin
            if (src_dest_port == 0) src_reg_addrs[rca_sel_w][src_port_sel] <= reg_addr;
            else dest_reg_addrs[rca_sel_w][dest_port_sel] <= reg_addr;
        end
    end

    always @(posedge clk) begin
        rca_src_reg_addrs <= src_reg_addrs[rca_sel_r];
        rca_dest_reg_addrs <= dest_reg_addrs[rca_sel_r];
    end    
    
endmodule