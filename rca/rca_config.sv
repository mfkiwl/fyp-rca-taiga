package rca_config
    localparam NUM_RCAS = 4;
    localparam NUM_READ_PORTS = 5;
    localparam NUM_WRITE_PORTS = 5;


    //RCA Use Instruction will be of R -type
    //funct7 specifies which RCA to use

    //RCA Config instruction will be of R-type:
    //  rs1[2:0] specifies register port
    //  rs1[3] specifies whether its a src or destination port
    // funct7 specifies which RCA is being configured
    // rs2[4:0] specifies register which the port should access

    //both instructions have same opcode, funct3 will specify whether its a config or a use instruction


endpackage