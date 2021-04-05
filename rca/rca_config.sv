package rca_config;
    localparam NUM_RCAS = 4;
    localparam NUM_READ_PORTS = 5;
    localparam NUM_WRITE_PORTS = 5;


    //RCA Use Instruction will be of R -type
    //funct7 specifies which RCA to use

    //RCA Config instruction will be of R-type:
    //  rs1[2:0] specifies port number
    //  rs1[3] specifies whether its a src or destination port
    // funct7 specifies which RCA is being configured
    // rs2[4:0] specifies register which the port should access

    //both instructions have same opcode, funct3 will specify whether its a config or a use instruction

    //RCA Grid Params
    localparam GRID_NUM_ROWS = 12;
    localparam GRID_NUM_COLS = 6;

    localparam NUM_GRID_MUXES = GRID_NUM_COLS * GRID_NUM_ROWS;

    localparam GRID_MUX_INPUTS = GRID_NUM_COLS + 2; //1 extra input to take data from module on left, 1 extra input to take data from IO unit of column

    localparam IO_UNIT_MUX_INPUTS = GRID_NUM_COLS + NUM_READ_PORTS;



endpackage