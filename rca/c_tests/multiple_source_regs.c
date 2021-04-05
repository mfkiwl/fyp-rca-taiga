#include "board_support.h"
#include <stdio.h>

// Test program for testing whether Taiga is sucessfully configured to allow up to 5 source registers for RCA Unit
// Must be used with riscv-opc.c and riscv-opc.h - See README for further details

//Currently RCA unit is configured to output to single rd register. It outputs the sum of all 5 source registers.

int main(void) {
    //Platform Initialization
    platform_init ();

    //Records cycle and instruction counts
    start_profiling ();

    printf("Hello world!\n");

    register int *t0Val asm("t0");
    register int *t1Val asm("t1");
    register int *t2Val asm("t2");
    register int *t3Val asm("t3");
    register int *t4Val asm("t4");

    int reg_port1 = 0x00000000;
    int reg_port2 = 0x00000001;
    int reg_port3 = 0x00000002;
    int reg_port4 = 0x00000003;
    int reg_port5 = 0x00000004;

    int reg1 = 0x00000005;
    int reg2 = 0x00000006;
    int reg3 = 0x00000007;
    int reg4 = 0x0000001C;
    int reg5 = 0x0000001D;
    

    int result;   

    //Loads 70,32,51,12,81 into registers t0-t4, sets RCA0's source register addresses to that of  t0-t4, runs RCA0
    asm volatile ("li %1, 70;li %2, 32; li %3, 51; li %4, 12; li %5, 81; rcac %6, %6, %11;rcac %7, %7, %12;rcac %8, %8, %13; rcac %9, %9, %14;rcac %10, %10, %15; add %2, %2, zero;rcau %0, %0, %0;"
        :"=r"(result), "+r"(t0Val), "+r"(t1Val), "+r"(t2Val), "+r"(t3Val), "+r"(t4Val), "+r"(reg_port1), "+r"(reg_port2), "+r"(reg_port3),"+r"(reg_port4), "+r"(reg_port5)      /* output */
        :"r"(reg1), "r"(reg2), "r"(reg3), "r"(reg4), "r"(reg5) /* input */
        :     /* clobbered register */
        );  
    
    printf("Result: %d\n", result);
    //Records cycle and instruction counts
    //Prints summary stats for the application
    end_profiling ();

    return 0;
}