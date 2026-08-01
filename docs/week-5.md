# Week 5 – System-level Design

## Lecture 1

- Two coding styles - `_next, _reg` of all registers seperately
- AXI Stream (`ready`/`valid` flow control)
  - Converting a pipleined module to AXI Stream with `cen = !(m_valid && !m_ready)`
  - Problem - `ready` must be combinational to freeze the module. Long combinational path when multiple modules chained
  - Solution: Skid Buffer
    - State machine, waveform...etc.
- Latency and Throughput
- SystemVerilog Gotchas
- **Activity**: Find ALL Bugs in piplined `a*x + b`. Fixes:
  - `<=` in `always_ff`, `=` in `always_comb`
  - Never drive same signal from two `always` blocks
  - Delay `b` to match latency of `a * x`
  - `$signed()` on every operand
  - Spelling mistake in port name creates a new wire implicitly
  - Arithmetic shift, not logical
  - Latch inference when skipping `else`, `case default`
  - Avoid driving/reading signals at the edge on testbenches
- UART
  - Protocol
  - TX
  - RX

[Open slides in new tab](https://1drv.ms/p/c/154152893557b712/IQRlpLddyATgRbXDM2_TXZWNAZoXhNNzMv5wYF1a8moRYnk)

<iframe src="https://1drv.ms/p/c/154152893557b712/IQRlpLddyATgRbXDM2_TXZWNAZoXhNNzMv5wYF1a8moRYnk?em=2&amp;wdAr=1.7777777777777777" width="900px" height="534px" frameborder="0" title="PowerPoint Viewer">This is an embedded <a target="_blank" href="https://office.com">Microsoft Office</a> presentation, powered by <a target="_blank" href="https://office.com/webapps">Office</a>.</iframe>


## Lecture 2

- Incremental CPU Design (7 opcodes, 40-lines of SV)
  1. Memory module
  2. Fetching instructions (PC)
  3. Load data: `LOAD`
  4. Store data: `STORE`
  5. ALU operations: `MOV, ADD, SUB, MUL`
  6. Jump instruction: `JNZ`
- Try programs:
  - Sum first N numbers
  - Fibonacci sequence
  - Factorial

[Open slides in new tab](https://1drv.ms/p/c/154152893557b712/IQTdED6uPnueQL_ecNWi8xLlAcyAozIoX2MgeAd5mYeB7rE)

<iframe src="https://1drv.ms/p/c/154152893557b712/IQTdED6uPnueQL_ecNWi8xLlAcyAozIoX2MgeAd5mYeB7rE?em=2&amp;wdAr=1.7777777777777777" width="900px" height="534px" frameborder="0" title="PowerPoint Viewer">This is an embedded <a target="_blank" href="https://office.com">Microsoft Office</a> presentation, powered by <a target="_blank" href="https://office.com/webapps">Office</a>.</iframe>

## Discussion

- Presentations from students who did optimizations
- Review for Final Exam