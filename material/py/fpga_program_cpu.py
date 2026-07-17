#!/usr/bin/env python3
"""Load a program into the CPU running on the Tang Nano 20K and read back its
data RAM.

    make program_fpga DESIGN=cpu_fpga     # flash the bitstream (from the host)
    python3 /path/to/digital-design/material/py/fpga_program_cpu.py --port PORT

The board_glue (fpga/tang_nano_20k/top_glue/system/cpu_fpga.sv) holds a full toy
computer: instruction RAM, data RAM, the CPU, and this UART loader/dumper.

Flow:
  1. This script packs imem + dmem into a fixed-size image and streams it in: all MEM_ROWS
     instruction words, then all MEM_ROWS data words, each word little-endian
     (low byte, high byte) - the FPGA's 16-bit UART reassembles the two bytes.
  2. User presses S1 on the board to start the CPU.  It steps at ~1 Hz; the LEDs
     show the 4-bit opcode being executed (or, while user holds S2, the low 6 bits
     of dmem[WATCH_ADDR]).
  3. After RUN_CYCLES steps the FPGA streams the whole data RAM back and we
     print it (no checking - just look at the result).

PORT is the board's serial port: /dev/ttyUSB1 in WSL/Linux, COM5 on Windows,
or /dev/tty.usbserial-* on macOS. ADDR_W and WATCH_ADDR must match the
board_glue parameters.
"""
import argparse

from utils import add_port_argument, open_serial

BAUD       = 2_000_000
ADDR_W     = 6                     # board_glue ADDR_W -> MEM_ROWS = 2**ADDR_W
WATCH_ADDR = 4                     # dmem row shown on the LEDs (S2 held)
CHUNK      = 32                    # bridge buffer size (host -> FPGA)
MEM_ROWS   = 1 << ADDR_W

parser = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
add_port_argument(parser)
args = parser.parse_args()

# ---- Opcodes (must match the cpu.sv enum order) -----------------------------
LOAD, STORE, MOVE, ADD, SUB, MUL, JNZ = range(7)


def encode(instr):
    """One instruction (a list) -> 16-bit word.
       [LOAD|STORE|JNZ, reg, addr]     -> {addr[7:0], reg[3:0], op[3:0]}
       [MOVE|ADD|SUB|MUL, rd, rs1, rs2]-> {rs2[3:0], rs1[3:0], rd[3:0], op[3:0]}
    """
    op = instr[0]
    if op in (LOAD, STORE, JNZ):
        _, reg, addr = instr
        return (addr & 0xFF) << 8 | (reg & 0xF) << 4 | op
    _, rd, rs1, rs2 = instr
    return (rs2 & 0xF) << 12 | (rs1 & 0xF) << 8 | (rd & 0xF) << 4 | op


# ---- The program: sum(1..10), leaving the result in dmem[WATCH_ADDR] --------
# (mirrors tb_cpu_sum_to_n, but stores to dmem[4] so the LEDs can show it)
dmem = [0] * MEM_ROWS
dmem[0], dmem[1], dmem[2] = 0, 1, 10

program = [
    [LOAD,  2, 0x02],       # r2 (counter) = dmem[2] = 10
    [LOAD,  1, 0x01],       # r1 (one)     = dmem[1] = 1
    [LOAD,  0, 0x00],       # r0 (sum)     = dmem[0] = 0
    [ADD,   0, 0, 2],       # r0 += r2
    [SUB,   2, 2, 1],       # r2 -= r1
    [JNZ,   2, 0x03],       # loop to imem[3] while r2 != 0
    [STORE, 0, WATCH_ADDR], # dmem[WATCH_ADDR] = r0  (= 55)
]

imem = [0] * MEM_ROWS
for i, instr in enumerate(program):
    imem[i] = encode(instr)

# ---- Pack the image: all imem words, then all dmem words (little-endian) ------
image = bytearray()
for word in imem + dmem:
    image += bytes((word & 0xFF, (word >> 8) & 0xFF))
assert len(image) == MEM_ROWS * 4

# ---- Stream it in (32-byte chunks; the FPGA consumes at line rate) ------------
with open_serial(args.port, BAUD, timeout=5) as ser:
    ser.reset_input_buffer()
    for i in range(0, len(image), CHUNK):
        ser.write(image[i:i + CHUNK])
        ser.flush()
    print(f"Loaded {len(image)} bytes ({2 * MEM_ROWS} words) into the FPGA.")

    # ---- Wait for the CPU to run and dump its data RAM back -------------------
    print("\nPress S1 on the board to run the CPU (it steps at ~1 Hz).")
    print("Hold S2 to watch dmem[%d] on the LEDs; release to watch the opcode." % WATCH_ADDR)
    print("Waiting for the data-RAM dump...\n")

    ser.timeout = 300                      # the run can take a while at 1 Hz
    dump = bytearray()
    need = MEM_ROWS * 2                     # 2 bytes per row
    while len(dump) < need:
        part = ser.read(need - len(dump))
        if not part:
            raise TimeoutError(f"dump timed out ({len(dump)}/{need} bytes)")
        dump += part

# ---- Print the returned data RAM (no checking) -------------------------------
result = [dump[2 * r] | dump[2 * r + 1] << 8 for r in range(MEM_ROWS)]
print("Data RAM after the run:")
for r in range(MEM_ROWS):
    if result[r] or r < 8:                  # show the interesting head + nonzero
        print(f"  dmem[{r:2d}] = {result[r]}")
print(f"\ndmem[{WATCH_ADDR}] = {result[WATCH_ADDR]}  (sum(1..10) should be 55)")
