# RISC-V Traffic Light Controller on Basys 3

## Project Description
This project implements a traffic light controller based on a small RISC-V SoC on the Digilent Basys 3 FPGA board. The system uses the PicoRV32 RISC-V CPU core and memory-mapped I/O to control LEDs, buttons, timer, and seven-segment display.

## Hardware Platform
- FPGA board: Digilent Basys 3
- FPGA device: Xilinx Artix-7 xc7a35t
- Development tool: Vivado 2025.2

## RISC-V Toolchain
- xPack GNU RISC-V Embedded GCC 15.2.0

## Main Features
- PicoRV32 executes C firmware compiled into RISC-V instructions.
- CPU controls traffic light states through memory-mapped I/O.
- LED output:
  - LD0: green light
  - LD1: yellow light
  - LD2: red light
  - LD3: automatic mode indicator
- Seven-segment display shows countdown value.
- Button input can switch emergency mode.
- Timer register provides delay reference.

## Memory-Mapped I/O Address Map
| Address | Function |
|---|---|
| 0x10000000 | LED register |
| 0x10000004 | Switch register |
| 0x10000008 | Button register |
| 0x1000000C | Seven-segment display register |
| 0x10000010 | Timer counter register |

## File Structure
```text
src/
  top.v
  picorv32.v
  basys3.xdc

firmware/
  main.c
  start.S
  linker.ld
  makehex.py
  firmware.mem
