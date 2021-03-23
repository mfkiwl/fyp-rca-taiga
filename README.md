# FYP
This is a fork of the Taiga core repositoty from [Taiga](https://gitlab.com/sfu-rcl/Taiga) 

The following documentation is a duplication of that given by SFU:
# Documentation and Project Setup
For up-to-date documentation, as well as an automated build environment setup, refer to [Taiga Project](https://gitlab.com/sfu-rcl/taiga-project)


# Taiga

Taiga is a 32-bit RISC-V processor designed for FPGAs supporting the Multiply/Divide and Atomic extensions (RV32IMA).  The processor is written in SystemVerilog and has been designed to be both highly extensible and highly configurable.

The pipeline has been designed to support parallel, variable-latency execution units and to readily support the inclusion of new execution units.

![Taiga Block Diagram](examples/zedboard/taiga_small.png)