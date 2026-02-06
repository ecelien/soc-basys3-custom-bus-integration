# MicroBlaze SoC: Custom AXI/APB Peripheral Integration & Build Automation

This repository documents the design and implementation of a System-on-Chip (SoC) targeting the Xilinx Artix-7 FPGA on a Basys 3 board. The project illustrates the evolution of a system from a basic soft-core processor to a multi-peripheral architecture using custom bus implementations.

Original project worked on by: Brian, Nikodem Gazda, and Lucas Mueller.

> [!NOTE]
> **Refactored for 2025.2 & Reproducibility**
> This project has been significantly adapted from the original coursework. It now features a **fully script-driven build flow** for both hardware (Vivado Tcl) and software (Vitis Python), resolving versioning issues and ensuring the project can be consistently recreated from source.



## Project Objectives
* **Peripheral IP Integration:** Experience in integrating hardware accelerators into a processor-based system.
* **Bus Protocol Implementation:** Bridging AXI and APB communication standards.
* **Hardware/Software Co-design:** Writing C applications to control hardware blocks like RSA and Booth Multipliers.
* **System-Level Debugging:** Utilizing tools like Xilinx System ILA for real-time signal tracking.

---

## Hardware & Software Requirements
* **FPGA Board:** Digilent Basys 3 (Artix-7).
* **Tools:** Xilinx Vivado & Vitis 2025.2.
* **Communication:** USB-UART cable for board programming and serial terminal interaction.

---

## How to Run

This project uses a **Makefile-driven workflow** for ease of use. Each phase directory contains a `Makefile` that orchestrates the build process.

### Prerequisites
- **Xilinx Vivado & Vitis 2025.2**
- **GNU Make** (Standard on most Linux distros)

### Quick Start (Makefile)
Open a terminal in the desired phase directory (e.g., `phase4`):

```bash
cd phase4

# Setup Project (Fast) - Creates Vivado project & Block Design
make project

# Build Bitstream (Slow) - Runs Synthesis, Implementation, & exports XSA
make bitstream

# Build Software - compiles C code
make sw

# Program Device - downloads Bitstream & ELF (Requires Hardware)
make program

# Clean - Removes all generated files
make clean
```

### Manual Scripts (Advanced)
If you prefer running scripts directly (e.g., on Windows without Make):

1.  **Project Setup**: `cd scripts && vivado -mode batch -source recreate_project.tcl`
2.  **Bitstream**: `cd scripts && vivado -mode batch -source build_bitstream.tcl`
3.  **Software**: `cd scripts && vitis -s recreate_vitis.py`

---

## Repository Structure

The project is divided into distinct phases, each fully self-contained with its own hardware and software build scripts:

```text
.
├── phase1/           # Basic MicroBlaze SoC
├── phase2/           # AXI RSA Integration
├── phase3/           # APB Interface & AXI-APB Bridge
├── phase4/           # Custom APB Bus Implementation
│   ├── hw/           # Hardware sources and constraints
│   ├── sw/           # Software application sources
│   └── scripts/      # Build automation scripts
└── README.md
```

Each phase directory contains:
- `hw/`: Hardware source files (HDL, Constraints).
- `sw/`: Software source files (C Code).
- `scripts/`: Tcl and Python scripts to regenerate the project.

---

## Implementation Phases

### Phase 1: Basic MicroBlaze SoC
Initial setup featuring the MicroBlaze soft-core processor, local memory, and a UART peripheral. This phase confirms the base communication link between the FPGA and the computer terminal.

### Phase 2: AXI RSA Integration
Integration of a 128-bit RSA hardware accelerator packaged as an AXI peripheral.
* **Mathematical Operation:** Computes Cypher = Data^Exponent mod Modulo.
* **Functional Validation:** A C application sends test vectors to the RSA module and verifies the returned cypher value against simulation results.

### Phase 3: APB Interface & AXI-APB Bridge
Re-implementation of the RSA module using the APB protocol to explore lower-complexity bus interfaces.
* **Architecture:** Utilizes an AXI-APB Bridge to translate MicroBlaze AXI transactions into APB-compliant signals.
* **Custom Wrapper:** Development of a VHDL/Verilog wrapper to map the RSA module to the APB signal specification.

### Phase 4: Custom APB Bus Implementation
Design and implementation of a custom APB bus with one master and three slave interfaces.
* **Integrated Slaves:**
    1. RSA Accelerator
    2. Booth Multiplier
    3. Median Filter
* **System Verification:** A unified C program interfaces with all three peripherals sequentially, ensuring correct address decoding and data multiplexing on the APB bus.

---
