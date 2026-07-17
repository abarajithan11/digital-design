"""Shared helpers for host-side digital-design Python tools."""

from __future__ import annotations

import argparse

import serial
from serial.tools import list_ports


_FPGA_USB_ID = (0x0403, 0x6010)


def add_port_argument(parser: argparse.ArgumentParser) -> None:
    """Add the common optional FPGA serial-port argument to a CLI parser."""
    parser.add_argument(
        "--port",
        metavar="PORT",
        help=(
            "FPGA serial port, for example COM5, /dev/ttyUSB1, or "
            "/dev/cu.usbserial-110; omitted when the FPGA UART is detected automatically"
        ),
    )


def _ports():
    """Return every detected serial port in stable, human-readable order."""
    return sorted(list_ports.comports(), key=lambda info: info.device.casefold())


def _port_listing(ports=None) -> str:
    """Format detected ports for selection and error messages."""
    ports = _ports() if ports is None else ports
    lines = ["Detected serial ports:"]
    if not ports:
        lines.append("  (none)")
        return "\n".join(lines)

    for info in ports:
        details = []
        if info.description and info.description != "n/a":
            details.append(info.description)
        if info.hwid and info.hwid != "n/a":
            details.append(info.hwid)
        suffix = f" - {'; '.join(details)}" if details else ""
        lines.append(f"  {info.device}{suffix}")
    return "\n".join(lines)


def _auto_fpga_port(ports) -> str | None:
    """Select interface 1/B (UART) of one attached Tang Nano debugger."""
    fpga_ports = [info for info in ports if (info.vid, info.pid) == _FPGA_USB_ID]
    boards = {info.serial_number for info in fpga_ports if info.serial_number}
    if not fpga_ports or len(boards) > 1:
        return None

    # Windows/Linux may expose the USB interface number; macOS does not.
    markers = ("mi_01", ":1.1", "interface 1", "interface b", "channel b")
    uart_ports = []
    for info in fpga_ports:
        details = " ".join(
            str(value or "") for value in (info.hwid, info.location, info.interface)
        ).casefold()
        if any(marker in details for marker in markers):
            uart_ports.append(info)

    if len(uart_ports) == 1:
        return uart_ports[0].device
    if len(fpga_ports) <= 2:
        return sorted(fpga_ports)[-1].device
    return None


def find_port(requested: str | None) -> str:
    """Resolve a requested port, or auto-select the FPGA UART."""
    ports = _ports()
    if requested is None:
        detected = _auto_fpga_port(ports)
        if detected is not None:
            return detected
        if len(ports) == 1:
            return ports[0].device
        reason = (
            "No serial ports were found."
            if not ports
            else "More than one serial port was found; select one with --port."
        )
        raise SystemExit(f"{reason}\n{_port_listing(ports)}")

    match = next(
        (info.device for info in ports if info.device.casefold() == requested.casefold()),
        None,
    )
    if match is None:
        raise SystemExit(
            f"Serial port {requested!r} was not found.\n{_port_listing(ports)}"
        )
    return match


def open_serial(requested: str | None, baud: int, **kwargs) -> serial.Serial:
    """Open the selected port and include all detected ports in any error."""
    port = find_port(requested)
    print(f"Using serial port {port}.")
    kwargs.setdefault("exclusive", True)
    try:
        return serial.Serial(port, baud, **kwargs)
    except (OSError, serial.SerialException) as error:
        raise SystemExit(
            f"Could not open serial port {port!r}: {error}\n{_port_listing()}"
        ) from None
