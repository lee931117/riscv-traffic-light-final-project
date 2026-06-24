# RISC-V Traffic Light Controller on Basys 3

## Project Description

This project implements a traffic light controller based on a small RISC-V SoC on the Digilent Basys 3 FPGA board. The system uses the PicoRV32 RISC-V CPU core and memory-mapped I/O to control LEDs, buttons, timer, and seven-segment display.

The main purpose of this project is to demonstrate how a RISC-V CPU executes firmware and communicates with FPGA peripherals through memory-mapped I/O.

## Hardware Platform

* FPGA board: Digilent Basys 3
* FPGA device: Xilinx Artix-7 xc7a35t
* Development tool: Vivado 2025.2

## RISC-V Toolchain

* xPack GNU RISC-V Embedded GCC 15.2.0

## Main Features

* PicoRV32 executes C firmware compiled into RISC-V instructions.
* CPU controls traffic light states through memory-mapped I/O.
* LED output:

  * LD0: green light
  * LD1: yellow light
  * LD2: red light
  * LD3: automatic mode indicator
* Seven-segment display shows countdown value.
* Button input can switch emergency mode.
* Timer register provides delay reference.
* Verilog hardware provides CPU, memory, address decoder, I/O registers, timer, and seven-segment display scanning.

## Memory-Mapped I/O Address Map

| Address    | Function                       |
| ---------- | ------------------------------ |
| 0x10000000 | LED register                   |
| 0x10000004 | Switch register                |
| 0x10000008 | Button register                |
| 0x1000000C | Seven-segment display register |
| 0x10000010 | Timer counter register         |

## File Structure

```text
.
├── top.v          # Top-level Verilog design, including PicoRV32 SoC, memory, I/O registers, timer, and 7-seg display logic
├── picorv32.v     # PicoRV32 RISC-V CPU core
├── basys3.xdc     # Basys 3 pin constraints
├── main.c         # RISC-V C firmware for traffic light control
├── start.S        # Startup assembly file
├── linker.ld      # Linker script
├── makehex.py     # Convert firmware.bin to firmware.mem / firmware.hex format
├── firmware.mem   # Memory initialization file loaded by Verilog
└── README.md
```

## How to Build Firmware

Open PowerShell and run the following commands:

```powershell
cd C:\riscv_traffic_test

riscv-none-elf-gcc -march=rv32i -mabi=ilp32 -nostdlib -T .\linker.ld .\start.S .\main.c -o .\firmware.elf

riscv-none-elf-objcopy -O binary .\firmware.elf .\firmware.bin

python .\makehex.py .\firmware.bin .\firmware.hex
```

Then copy the generated firmware file to the Vivado project memory file:

```powershell
Copy-Item .\firmware.hex "C:\riscv_vivado_test\final\final.srcs\sources_1\imports\riscv_vivado_test\firmware.mem" -Force
```

The copied file is used by Verilog through:

```verilog
$readmemh("firmware.mem", memory);
```

## How to Use in Vivado

1. Create a Vivado project for Basys 3.
2. Add `top.v` and `picorv32.v` as design sources.
3. Add `firmware.mem` as a memory file.
4. Add `basys3.xdc` as the constraint file.
5. Set `top` as the top module.
6. Run Synthesis.
7. Run Implementation.
8. Generate Bitstream.
9. Open Hardware Manager.
10. Connect the Basys 3 board.
11. Program the FPGA device with the generated `.bit` file.

## Operation

After programming the FPGA:

* Press BTNC to reset the CPU.
* The traffic light cycles through red, yellow, and green.
* The seven-segment display shows the countdown value.
* Press BTNU to enter emergency mode.
* In emergency mode, the red light flashes and the seven-segment display shows `99`.
* Press BTNU again to return to automatic mode.

## Expected Output

Normal automatic mode:

```text
LD2 red light on, seven-segment display counts down
→ LD1 yellow light on, seven-segment display counts down
→ LD0 green light on, seven-segment display counts down
→ repeat
```

Emergency mode:

```text
LD2 red light flashes
Seven-segment display shows 99
```

## External Sources

* PicoRV32 RISC-V CPU core by Clifford Wolf.
* Digilent Basys 3 constraint reference.

## Personal Contribution

The PicoRV32 CPU core is used as the RISC-V processor. The main personal contributions include:

* Integrating PicoRV32 with instruction/data memory.
* Designing memory-mapped I/O address decoding.
* Implementing LED, button, switch, timer, and seven-segment display registers.
* Writing C firmware for traffic light state control.
* Building the firmware with RISC-V GCC.
* Testing the design on the Basys 3 FPGA board.
* Debugging toolchain, Vivado synthesis, firmware memory loading, and FPGA programming issues.

## Known Issues

* The current version uses polling instead of interrupt.
* The countdown timing is adjusted for demonstration.
* The seven-segment display and LED functions are designed for Basys 3 pin mapping.
* If firmware is modified, `firmware.mem` must be updated and the bitstream must be regenerated.
