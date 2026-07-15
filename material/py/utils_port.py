"""Serial-port discovery for the Tang Nano USB debugger."""

from serial.tools import list_ports


USB_ID = (0x0403, 0x6010)


def get_uart_port():
    """Return the Tang Nano debugger's UART port."""
    ports = sorted(p for p in list_ports.comports() if (p.vid, p.pid) == USB_ID)
    if not ports:
        raise RuntimeError("Tang Nano USB debugger not found")

    boards = {p.serial_number for p in ports if p.serial_number}
    if len(boards) > 1:
        raise RuntimeError("Multiple Tang Nano USB debuggers found")

    # The debugger's first channel is JTAG; its second channel is UART.
    return ports[-1].device
