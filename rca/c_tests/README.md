# C Tests
To use these C tests, clone the [Taiga Project](https://gitlab.com/sfu-rcl/taiga-project) repository. 

Move riscv-opc.c and riscv-opc.h into tool-chain/binutils-gdb/opcodes and tool-chain/binutils-gdb/include/opcode respectively. 

Rebuild the toolchain with the instructions given in the [Adding Functional Unit](https://gitlab.com/sfu-rcl/taiga-project/-/wikis/Adding-Functional-Units-and-Respecitve-Custom-Instructions) section of the repository. 

Replace the Taiga repository in the Taiga Project repository with this one.

Copy the code in any of the C files in this folder into benchmarks/taiga-example-c-project/src/hello_word.c.

From the root of the Taiga repository, run: make run-example-c-project-verilator, and inspect the logs.