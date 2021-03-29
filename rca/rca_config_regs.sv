import taiga_config::*;
import riscv_types::*;
import taiga_types::*;
import rca_config::*;

module rca_config_regs (
    input clk,
    input rst,

    //Read interface
    input [$clog2(NUM_RCAS)-1:-0] rca_sel,
    
    output logic [4:0] [NUM_READ_PORTS-1:0] rca_src_reg_addrs,
    output logic [4:0] [NUM_WRITE_PORTS-1:0] rca_dest_reg_addrs,

    //Write interface
    input wr_en,
    input [$clog2(NUM_READ_PORTS)-1:0]  w_port_sel,
    input w_src_dest_port, //0 for src_addr reg, 1 for dest_addr_reg
    input [4:0] w_reg_addr
);

    logic [4:0] [NUM_READ_PORTS-1:0] src_reg_addrs [NUM_RCAS]; 
    logic [4:0] [NUM_READ_PORTS-1:0] dest_reg_addrs [NUM_RCAS];      


    initial begin
        src_reg_addrs = '{default: '0};
        dest_reg_addrs = '{default: '0};
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            src_reg_addrs <= '{default: '0};
            dest_reg_addrs <= '{default: '0};
        end
        else if (wr_en) begin
            if (w_src_dest_port == 0) src_reg_addrs[rca_sel][w_port_sel] <= w_reg_addr;
            else dest_reg_addrs[rca_sel][w_port_sel] <= w_reg_addr;
        end
    end

    always_comb begin
        rca_src_reg_addrs = src_reg_addrs[rca_sel];
        rca_dest_reg_addrs = dest_reg_addrs[rca_sel];
    end    
    
endmodule