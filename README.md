# RISC-V CPU
A five-stage pipeline RISC-V CPU.

## Features
* Written in Verilog HDL
* Supports RV32I (except FENCE instructions) and RV32M instruction sets
* Implements a 5-stage pipeline: Fetch, Decode, Execute, Memory, Write-back
* Uses forwarding and hazard detection to prevent data hazards
* Adopts Harvard architecture with buses separating the CPU core, peripherals, and memory
* Peripherals include Timer, UART, and GPIO
* Supports asynchronous Timer interrupts
* Successfully implemented on Intel (Altera) Cyclone IV series EP4CE10F17C8 FPGA using the Quartus platform
* Verified system correctness through ModelSim simulation

## SoC Architecture
<img src='https://github.com/Appmedia06/RISV-V-CPU/blob/main/img/SoC.drawio.png' width=500/>

## CPU Microarchitecture
<img src='https://github.com/Appmedia06/RISV-V-CPU/blob/main/img/macroArchitecture.png' width=500/>
