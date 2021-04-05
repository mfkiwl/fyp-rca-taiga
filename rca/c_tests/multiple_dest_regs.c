#include "board_support.h"
#include <stdio.h>

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

    int src_reg_port1 = 0x00000000;
    int src_reg_port2 = 0x00000001;
    int src_reg_port3 = 0x00000002;
    int src_reg_port4 = 0x00000003;
    int src_reg_port5 = 0x00000004;

    int dst_reg_port1 = 0x00000008;
    int dst_reg_port2 = 0x00000009;
    int dst_reg_port3 = 0x0000000A;
    int dst_reg_port4 = 0x0000000B;
    int dst_reg_port5 = 0x0000000C;

    int reg1 = 0x00000005;
    int reg2 = 0x00000006;
    int reg3 = 0x00000007;
    int reg4 = 0x0000001C;
    int reg5 = 0x0000001D;
    

    int result;
    int rd1, rd2, rd3, rd4, rd5;   

    //Loads 70,32,51,12,81 into registers t0-t4, sets RCA0's source and dest register addresses to that of  t0-t4, runs RCA0
    asm volatile (
    "li %1, 0;"
    "rcac %0, %1, %11;"
    "li %1, 1;"
    "rcac %0, %1, %12;"
    "li %1, 2;"
    "rcac %0, %1, %13;"
    "li %1, 3;"
    "rcac %0, %1, %14;"
    "li %1, 4;"
    "rcac %0, %1, %15;"

    "li %1, 8;"
    "rcac %0, %1, %15;"
    "li %1, 9;"
    "rcac %0, %1, %14;"
    "li %1, 10;"
    "rcac %0, %1, %13;"
    "li %1, 11;"
    "rcac %0, %1, %12;"
    "li %1, 12;"
    "rcac %0, %1, %11;"

    "li %1, 70;"
    "li %2, 32;"
    "li %3, 51;"
    "li %4, 12;"
    "li %5, 81;"
    "add %2, %2, zero;"
    "rcau %0, %0, %0;"
    "add %6, t0, zero;"
    "add %7, t1, zero;"
    "add %8, t2, zero;"
    "add %9, t3, zero;"
    "add %10, t4, zero;"
        :"=r"(result), "+r"(t0Val), "+r"(t1Val), "+r"(t2Val), "+r"(t3Val), "+r"(t4Val), "=r"(rd1), "=r"(rd2), "=r"(rd3), "=r"(rd4), "=r"(rd5)      /* output */
        :"r"(reg1), "r"(reg2), "r"(reg3), "r"(reg4), "r"(reg5) /* input */
        :     /* clobbered register */
        );  
    //Numbers should be printed out in same order: 70, 32, 51, 12, 81
    printf("rd1: %d\n", rd1);
    printf("rd2: %d\n", rd2);
    printf("rd3: %d\n", rd3);
    printf("rd4: %d\n", rd4);
    printf("rd5: %d\n", rd5);

    asm volatile (
    "li %1, 0;"
    "rcac %0, %1, %11;"
    "li %1, 1;"
    "rcac %0, %1, %12;"
    "li %1, 2;"
    "rcac %0, %1, %13;"
    "li %1, 3;"
    "rcac %0, %1, %14;"
    "li %1, 4;"
    "rcac %0, %1, %15;"

    "li %1, 8;"
    "rcac %0, %1, %11;"
    "li %1, 9;"
    "rcac %0, %1, %12;"
    "li %1, 10;"
    "rcac %0, %1, %13;"
    "li %1, 11;"
    "rcac %0, %1, %14;"
    "li %1, 12;"
    "rcac %0, %1, %15;"

    "li %1, 65;"
    "li %2, 200;"
    "li %3, 512;"
    "li %4, 1456;"
    "li %5, 0;"
    "add %2, %2, zero;"
    "rcau %0, %0, %0;"
    "add %6, t0, zero;"
    "add %7, t1, zero;"
    "add %8, t2, zero;"
    "add %9, t3, zero;"
    "add %10, t4, zero;"
        :"=r"(result), "+r"(t0Val), "+r"(t1Val), "+r"(t2Val), "+r"(t3Val), "+r"(t4Val), "=r"(rd1), "=r"(rd2), "=r"(rd3), "=r"(rd4), "=r"(rd5)      /* output */
        :"r"(reg1), "r"(reg2), "r"(reg3), "r"(reg4), "r"(reg5) /* input */
        :     /* clobbered register */
        );  
    
    //Numbers will be printed out in reverse order
    printf("Second run\n");
    printf("rd1: %d\n", rd1);
    printf("rd2: %d\n", rd2);
    printf("rd3: %d\n", rd3);
    printf("rd4: %d\n", rd4);
    printf("rd5: %d\n", rd5);
    //Records cycle and instruction counts
    //Prints summary stats for the application
    end_profiling ();

    return 0;
}