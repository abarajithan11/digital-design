"""Shared helpers for host-side digital-design Python tools."""

from __future__ import annotations

import argparse

import serial
from serial.tools import list_ports


def add_port_argument(parser: argparse.ArgumentParser) -> None:
    """Add the common optional FPGA serial-port argument to a CLI parser."""
    parser.add_argument(
        "--port",
        metavar="PORT",
        help=(
            "FPGA serial port, for example COM5, /dev/ttyUSB1, or "
            "/dev/tty.usbserial-110; omitted only when exactly one port is present"
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


def find_port(requested: str | None) -> str:
    """Resolve a requested port, or auto-select the sole detected port."""
    ports = _ports()
    if requested is None:
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
    try:
        return serial.Serial(port, baud, **kwargs)
    except (OSError, serial.SerialException) as error:
        raise SystemExit(
            f"Could not open serial port {port!r}: {error}\n{_port_listing()}"
        ) from None
