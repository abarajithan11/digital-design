# Acronyms from Lectures

## Lecture 1 

* **RTL**: Register-Transfer Level; a hardware-design abstraction describing data movement between registers and the logic operating on it.
* **FIR**: Finite Impulse Response; a type of digital filter applied to signals like audio, to extract low/high/mid frequencies.
* **CPU**: Central Processing Unit; the primary general-purpose processor in a computer.
* **MOS**: Metal-Oxide-Semiconductor; the transistor technology underlying modern integrated circuits.
* **PMOS**: P-channel MOS transistor; commonly used in CMOS pull-up networks.
* **NMOS**: N-channel MOS transistor; commonly used in CMOS pull-down networks.
* **CMOS**: Complementary Metal-Oxide-Semiconductor; a circuit technology combining PMOS and NMOS transistors.
* **EUV**: Extreme Ultraviolet lithography; a chip-fabrication technique using very short-wavelength light.
* **ASIC**: Application-Specific Integrated Circuit; a chip designed for a particular application.
* **CAD**: Computer-Aided Design; software-assisted design and analysis.
* **GDS2**: Graphic Data System II, usually written **GDSII**; a file format used to represent the physical layout of a chip. This file is sent to the foundry (e.g. TSMC). They will create the masks (stencil) using this and will fabricate the chip using the masks.
* **LEF**: Library Exchange Format; a file format describing the physical abstractions of cells and routing layers.
* **HDL**: Hardware Description Language; a language used to describe digital hardware, such as SystemVerilog.
* **ALU**: Arithmetic and Logic Unit; the CPU component that performs arithmetic (add, multiply...etc.) and logical (and, or, not) operations.
* **PDK**: Process Design Kit; a collection of standard cells (Lego blocks) given by the foundry (e.g. TSMC). The synthesis tool creates the design you define in high level (using SystemVerilog RTL) using the standard cells (Lego blocks) available in the PDK you give. These cells are then placed and routed to create the GDS2 file.
* **TSMC**: Taiwan Semiconductor Manufacturing Company; a major semiconductor foundry.
* **ASAP7**: An educational predictive 7-nanometre process design kit.
* **EDA**: Electronic Design Automation; software and algorithms used to design, verify, and implement electronic circuits.
* **ASML**: A company that manufactures advanced semiconductor lithography equipment.
* **P&R**: Place and Route; positioning circuit cells and connecting them with physical wires.
* **IC**: Integrated Circuit; an electronic circuit fabricated on a semiconductor die.
* **VDD**: The positive power-supply voltage in a MOS circuit; commonly represents logic 1.
* **GND**: Ground; the circuit’s zero-volt reference, commonly representing logic 0.
