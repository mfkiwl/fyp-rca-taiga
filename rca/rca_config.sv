package rca_config;
    localparam NUM_RCAS = 4;
    localparam NUM_READ_PORTS = 5;
    localparam NUM_WRITE_PORTS = 5;


    //RCA Use Instruction will be of R -type
    //funct7 specifies which RCA to use

    //RCA CPU Register Config instruction will be of R-type:
    //  rs1[2:0] specifies port number
    //  rs1[3] specifies whether its a src or destination port
    // funct7 specifies which RCA is being configured
    // rs2[4:0] specifies register which the port should access

    //RCA Grid MUX Config instruction
    // rs1 specifies which MUX sel to change
    // rs2 specifies sel value

    // RCA IO Unit MUX Config instruction
    // rs1 specifies which MUX sel to change
    // rs2 specifies sel value

    // RCA Result MUX Config instruction
    // rs1 specifies which MUX sel to change
    // rs2 specifies sel value
    // funct7 specifies which RCA is being configured

    // RCA IO Input usage Config Instruction
    //rs1 specifies IO input usage configuration
    //funct7 specifies which rca this applies to

    //funct3 distinguishes between the 4 types of instructions
    //000 - RCA Use
    //001 - CPU Reg config
    //010 - Grid MUX config
    //011 - IO Unit MUX config
    //100 - Result MUX config
    //101 - IO Input Use config

    //RCA Grid Params
    localparam GRID_NUM_ROWS = 12;
    localparam GRID_NUM_COLS = 6;

    localparam NUM_GRID_MUXES = GRID_NUM_COLS * GRID_NUM_ROWS;

    localparam GRID_MUX_INPUTS = GRID_NUM_COLS + 2; //1 extra input to take data from module on left, 1 extra input to take data from IO unit of column

    localparam IO_UNIT_MUX_INPUTS = GRID_NUM_COLS + NUM_READ_PORTS;



endpackage