# Tang Nano 20K FPGA flow

Build and run any course design on the [Sipeed Tang Nano 20K](https://wiki.sipeed.com/tangnano20k)
(Gowin `GW2AR-18`). Open-source toolchain, all inside the course Docker image:

```
yosys (synth_gowin)  →  nextpnr-himbaechel  →  gowin_pack  →  openFPGALoader
```

## Usage — one command, any OS

Run these from the **repo root on your host** (not inside the container). Docker
is started for you; the bitstream is always built in the container, so the build
is identical on Ubuntu, macOS, and Windows:

```bash
make bitstream     DESIGN=full_adder    # build only -> build/full_adder/full_adder.fs
make program       DESIGN=up_counter    # build, then load to SRAM and run (volatile)
make program_flash DESIGN=sys_fir_filter# build, then write to flash (persists across power cycles)
```

`FPGA` defaults to `tang_nano_20k`. `DESIGN` is any name with a glue file in
`top_glue/{reference,system}/` and a flist in `design/{reference,system}/`
(every RTL design except the CPU). `make program` auto-routes the flashing step
to the least-painful path for your OS (see below).

You can also build every design at once from inside the container
(`make enter`, then `make fpga_all`).

## Layout

```
common/
  board_top.sv   FIXED wrapper: pins <-> clean active-high world (+ 108 MHz PLL). Never edited.
  board.cst      FIXED pin constraints (LEDs, buttons, UART, GPIO).
  fpga.mk        the bitstream/program targets (included by material/Makefile).
top_glue/{reference,system}/<design>.sv   one board_glue per design (the only per-design file).
design/{reference,system}/<design>.f      RTL flist per design (no testbenches).
build/<design>/                            generated bitstreams (gitignored).
```

`board_top` hands the design a clean, **active-high** world (`clk`, `rst`,
`btn[1:0]`, `led[5:0]`, `rx`/`tx`, `gpio_*`) and hides the hardware's active-low
LEDs/buttons plus button sync/debounce and power-on reset. To port a new design,
copy `top_glue/_skeleton.sv` and wire your module's ports to those signals.

## Programming the board — per-OS setup

`make program` always builds in the container, then flashes over USB. The build
is identical everywhere; only the physical USB step differs, because Docker's
access to USB differs by host. Do the one-time setup for your OS, then
`make program DESIGN=...` is the same command for everyone.

### Ubuntu / Linux — nothing to install
Docker can reach USB directly. Plug in the board (a Sipeed/BL616 USB-JTAG+UART
bridge) and run `make program DESIGN=...`. The flashing step runs inside a
short-lived root container with `/dev/bus/usb` passed through, so you don't need
udev rules or `sudo`.

### Windows 11 (WSL2) — install usbipd once, attach each session
WSL2 can't see USB until you forward it from Windows with
[usbipd-win](https://github.com/dorssel/usbipd-win):

1. **Windows, admin PowerShell, once:** `winget install usbipd`
2. **Each time you plug in the board (admin PowerShell):**
   ```powershell
   usbipd list                                    # find the board's BUSID (Sipeed / BL616)
   usbipd bind   --busid <BUSID>                  # once per device
   usbipd attach --wsl --busid <BUSID>            # attaches to your WSL distro
   ```
3. **In WSL** (same terminal you run `make` from): `make program DESIGN=...`.
   `lsusb` should list the board and `/dev/bus/usb` should exist first.

If it says *no USB device* even after attaching, the board went to a different
WSL distro than the one running Docker — re-run step 2 with
`usbipd attach --wsl --distribution <your-distro> --busid <BUSID>`, or flash from
the WSL distro that has Docker's integration enabled.

### macOS — install the flasher once
Docker Desktop **cannot** pass host USB into its VM, so the flashing step runs on
the host. Install `openFPGALoader` once:

```bash
brew install openfpgaloader
```

Then `make program DESIGN=...` builds in Docker and flashes with the host tool
automatically — same command as everyone else.

## UART designs (uart_echo, sys_fir_filter) — 2 Mbaud

The Tang Nano 20K's onboard USB-serial bridge runs the FPGA-facing UART at
**2 Mbaud**, has a **32-byte buffer**, and no hardware flow control. So the UART
designs:

* run at **108 MHz** (an `rPLL` in `board_top`; `108 = 27 x 4`) so
  `CLKS_PER_BIT = 108e6/2e6 = 54` gives exactly 2 Mbaud — `fpga.mk` selects it
  automatically for `uart_echo` and `sys_fir_filter` (other designs use the raw
  27 MHz crystal);
* buffer with a **`skid_buffer`** (2-deep elastic buffer) so the transmitter can
  backpressure the receiver and no byte is dropped;
* have the host send in **≤32-byte chunks, reading each back** (the bridge has a
  32-byte buffer and no flow control) — see `py/uart_echo.py`, `py/fir_audio.py`.

### Serial access

`usbipd` forwards both FT2232 interfaces, so WSL can use JTAG and
`/dev/ttyUSB1`. If UART writes stop reaching the FPGA after repeated JTAG
loads, power-cycle the board and reattach it with `usbipd attach --wsl`.

* **Windows:** use the native COM port, or attach the device to WSL.
* **WSL:** use `/dev/ttyUSB1` while the FT2232 is attached with usbipd.
* **Linux:** the UART is `/dev/ttyUSB1` (interface `1.1`); no usbip needed on a
  native Linux host.
* **macOS:** `/dev/tty.usbserial-*` (Docker can't reach USB on macOS anyway).

Verify `uart_echo` (loopback, no data lost):

```bash
make program DESIGN=uart_echo
python3 py/uart_echo.py         # -> PASS: echoed 4096 bytes with no loss.
```

Filter an audio file through `sys_fir_filter` and check it:

```bash
make program DESIGN=sys_fir_filter
python3 py/fir_audio.py         # data/chill_sub.wav -> FPGA -> checked vs reference
```

Both scripts have `PORT`/`INPUT`/etc. as constants at the top (default
`/dev/ttyUSB1`); edit `PORT` for a native Windows `COM*` or macOS
`/dev/tty.usbserial-*`.

> Flashing note: over usbip the default ~6 MHz JTAG is flaky ("TDO stuck at 0");
> the flow uses `--freq 1000000` (override with `OFL_FREQ=`). Native hosts are
> fine at any rate.

---

**Instructors:** the toolchain lives in the Docker image, so after pulling these
changes rebuild and republish it (`make scratch` to build locally, `make publish`
to push) before students `make fresh`.
