# Tang Nano 20K FPGA flow

Build any course design for the [Sipeed Tang Nano 20K](https://wiki.sipeed.com/tangnano20k)
(Gowin `GW2AR-18`) with the open-source apicula toolchain, then program it from
Chrome. The **build runs in the container**; programming runs in the browser.

## Build the bitstream (inside the container)

The toolchain (`yosys → nextpnr-himbaechel → gowin_pack`) lives in the Docker
image, so build there:

```bash
make enter                          # into the container
make bitstream DESIGN=full_adder    # -> build/full_adder/full_adder.fs
make bitstream_all                  # (optional) build every design
```

`FPGA` defaults to `tang_nano_20k`. `DESIGN` is any name with a glue file in
`top_glue/{cpu,reference,system}/` and a shared flist in
`material/designs/{cpu,reference,systems}/`. The bitstream flow omits `tb_*` and
`vip_*` sources from that shared list before adding the design's board glue.

## Program the board (from Chrome)

See the repository's [hardware programming instructions](../../../README.md#2-program-it-via-the-web-programmer).

## Layout

```
common/
  board_top.sv   FIXED wrapper: pins <-> clean active-high world (+ 108 MHz PLL). Never edited.
  board.cst      FIXED pin constraints (LEDs, buttons, UART, GPIO).
  fpga.mk        the bitstream build target (included by material/Makefile).
top_glue/{cpu,reference,system}/<design>.sv   one board_glue per design (the only per-design file).
../../designs/{cpu,reference,systems}/<design>.f   shared RTL/simulation flist.
build/<design>/                            generated bitstreams (gitignored).
```

`board_top` hands the design a clean, **active-high** world (`clk`, `rst`,
`btn[1:0]`, `led[5:0]`, `rx`/`tx`, `gpio_*`) and hides the hardware's active-low
LEDs plus button sync/debounce and power-on reset. To port a new design,
copy `top_glue/_skeleton.sv` and wire your module's ports to those signals.
Every design receives the same **108 MHz** system clock from the `rPLL` in
`board_top` (`108 = 27 x 4`).

## UART designs (uart_echo, sys_fir_filter) — 2 Mbaud

The Tang Nano 20K's onboard USB-serial bridge runs the FPGA-facing UART at
**2 Mbaud**, has a **32-byte buffer**, and no hardware flow control. So the UART
designs:

* use `CLKS_PER_BIT = 54e6/2e6 = 27`, which gives exactly 2 Mbaud from the
  board-wide 108 MHz system clock;
* buffer with a **`skid_buffer`** (2-deep elastic buffer) so the transmitter can
  backpressure the receiver and no byte is dropped;
* have the host send in **≤32-byte chunks, reading each back** (the bridge has a
  32-byte buffer and no flow control) — see `py/uart_echo.py`, `py/fir_audio.py`.

Verify `uart_echo` after programming its `.fs` file:

```bash
cd material && python3 py/uart_echo.py    # -> PASS: echoed 4096 bytes with no loss.
```

Filter an audio file through `sys_fir_filter` and check it:

```bash
cd material && python3 py/fir_audio.py    # data/chill_sub.wav -> FPGA -> checked vs reference
```

Both scripts have `PORT`/`INPUT`/etc. as constants at the top (default
`/dev/ttyUSB1`); edit `PORT` for a native Windows `COM*` or macOS
`/dev/tty.usbserial-*`.

