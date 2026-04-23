#!/usr/bin/env python3
"""Convert a VCD file to a WaveDrom-style SVG waveform."""

import argparse
import json
from pathlib import Path
import re

import wavedrom
from vcdvcd import VCDVCD


def _is_unknown(value: str) -> bool:
    v = value.lower()
    return "x" in v or "z" in v


def _bit_char(value: str) -> str:
    v = value.lower()
    if _is_unknown(v):
        return "x"
    return "1" if v.endswith("1") else "0"


def _bus_label(value: str) -> str:
    if _is_unknown(value):
        return "x"
    return format(int(value, 2), "x")


def _sample_values(tv, sample_times):
    idx = 0
    current = str(tv[0][1])
    out = []
    for t in sample_times:
        while idx + 1 < len(tv) and int(tv[idx + 1][0]) <= t:
            idx += 1
            current = str(tv[idx][1])
        out.append(current)
    return out


def _display_name(name: str) -> str:
    parts = name.split(".")
    if parts and re.fullmatch(r"tb_[A-Za-z0-9_]+", parts[0]):
        parts = parts[1:]
    return ".".join(parts) if parts else name


def _normalized_parts(name: str):
    parts = name.split(".")
    if parts and re.fullmatch(r"tb_[A-Za-z0-9_]+", parts[0]):
        parts = parts[1:]
    return parts


def _scope_depth(name: str) -> int:
    parts = _normalized_parts(name)
    return max(0, len(parts) - 1)


def _has_all_caps_segment(name: str) -> bool:
    for part in _normalized_parts(name):
        if re.fullmatch(r"[A-Z0-9_]*[A-Z][A-Z0-9_]*", part):
            return True
    return False


def _prefer_top_level_signals(signals):
    top_level_leaf_names = {
        parts[-1]
        for name in signals
        for parts in [_normalized_parts(name)]
        if len(parts) == 1 and parts
    }

    selected = []
    for name in signals:
        parts = _normalized_parts(name)
        if len(parts) > 1 and parts and parts[-1] in top_level_leaf_names:
            continue
        selected.append(name)
    return selected


def _encode_scalar(samples):
    wave = []
    prev = None
    for sample in samples:
        cur = _bit_char(sample)
        if prev is not None and cur == prev:
            wave.append(".")
        else:
            wave.append(cur)
        prev = cur
    return "".join(wave), []


def _encode_bus(samples):
    wave = []
    data = []
    prev = None
    for sample in samples:
        cur = _bus_label(sample)
        if prev is None:
            if cur == "x":
                wave.append("x")
            else:
                wave.append("=")
                data.append(cur)
        elif cur == prev:
            wave.append(".")
        elif cur == "x":
            wave.append("x")
        else:
            wave.append("=")
            data.append(cur)
        prev = cur
    return "".join(wave), data


def _apply_theme_colors(svg_path: Path) -> None:
    svg = svg_path.read_text(encoding="utf-8")

    # Use the page text color for marker fills/arcs too.
    svg = re.sub(r'(?i)(marker[^>]*style="[^"]*fill:)[^;"]+', r"\1currentColor", svg)

    # Make WaveDrom's default black strokes/fills follow the SVG's current color.
    svg = re.sub(r"(?i)(stroke\s*:\s*)#000(?:000)?", r"\1currentColor", svg)
    svg = re.sub(r'(?i)(stroke\s*=\s*")#000(?:000)?(")', r"\1currentColor\2", svg)
    svg = re.sub(r"(?i)(fill\s*:\s*)#000(?:000)?", r"\1currentColor", svg)
    svg = re.sub(r'(?i)(fill\s*=\s*")#000(?:000)?(")', r"\1currentColor\2", svg)

    # Make per-element text styling follow the page text color too.
    svg = re.sub(
        r"(<text\b[^>]*\bstyle=\")([^\"]*)(\")",
        lambda m: (
            m.group(1)
            + re.sub(r"(?i)fill\s*:\s*[^;]+;?", "fill:currentColor;", m.group(2))
            + ("; fill:currentColor" if "fill:" not in m.group(2).lower() else "")
            + m.group(3)
        ),
        svg,
    )
    svg = re.sub(r'(?i)(<text\b[^>]*\bfill=")[^"]*(")', r"\1currentColor\2", svg)
    svg = re.sub(
        r"(<tspan\b[^>]*\bstyle=\")([^\"]*)(\")",
        lambda m: (
            m.group(1)
            + re.sub(r"(?i)fill\s*:\s*[^;]+;?", "fill:currentColor;", m.group(2))
            + ("; fill:currentColor" if "fill:" not in m.group(2).lower() else "")
            + m.group(3)
        ),
        svg,
    )
    svg = re.sub(r'(?i)(<tspan\b[^>]*\bfill=")[^"]*(")', r"\1currentColor\2", svg)

    # Remove filled bus boxes so the waveform remains transparent in both themes.
    svg = re.sub(
        r'(?i)(<(?:rect|path|polygon|polyline)\b[^>]*\bfill=")#fff(?:fff)?(")',
        r"\1none\2",
        svg,
    )
    svg = re.sub(
        r'(?i)(fill\s*:\s*)#fff(?:fff)?',
        r"\1none",
        svg,
    )

    final_override = """
<style data-codex-wave-override="true"><![CDATA[
text, tspan {
  fill: currentColor !important;
  stroke: none !important;
  font-size: 8pt !important;
  font-weight: 400 !important;
}
.info, .muted, .warning, .error, .success,
.h1, .h2, .h3, .h4, .h5, .h6 {
  fill: currentColor !important;
  stroke: none !important;
  font-size: 8pt !important;
  font-weight: 400 !important;
}
.s7, .s8, .s9, .s10, .s11, .s12, .s13, .s14 {
  fill: none !important;
  fill-opacity: 0 !important;
  stroke: none !important;
}
.s15 {
  fill: currentColor !important;
}
.s16 {
  stroke: currentColor !important;
}
]]></style>
""".strip()

    svg = re.sub(
        r"<style\b[^>]*\bdata-codex-wave-override=\"true\"[^>]*>.*?</style>\s*",
        "",
        svg,
        flags=re.IGNORECASE | re.DOTALL,
    )
    svg = re.sub(r"(</svg>\s*)$", final_override + r"\n</svg>\n", svg, count=1, flags=re.IGNORECASE)

    # Strip any previously injected solid background rect.
    svg = re.sub(
        r'<rect\b[^>]*\bdata-codex-bg="white"[^>]*/>\s*',
        "",
        svg,
        flags=re.IGNORECASE,
    )

    # Strip any previous self-themed style block so the page theme can drive color.
    svg = re.sub(
        r"<style\b[^>]*\bdata-codex-theme=\"waveform\"[^>]*>.*?</style>\s*",
        "",
        svg,
        flags=re.IGNORECASE | re.DOTALL,
    )

    if "<svg" in svg and "style=" not in svg.split(">", 1)[0]:
        svg = re.sub(
            r"(<svg\b[^>]*?)>",
            r'\1 style="background: transparent; color: currentColor;">',
            svg,
            count=1,
        )
    else:
        svg = re.sub(
            r'(<svg\b[^>]*\bstyle=")([^"]*)(")',
            lambda m: (
                m.group(1)
                + (m.group(2).rstrip("; ") + "; " if m.group(2).strip() else "")
                + "background: transparent; color: currentColor"
                + m.group(3)
            ),
            svg,
            count=1,
        )

    svg_path.write_text(svg, encoding="utf-8")


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--vcd", required=True)
    ap.add_argument("--svg", required=True)
    ap.add_argument("--start", default="auto")
    ap.add_argument("--end", default="auto")
    ap.add_argument("--window", type=int, default=4096)
    # A larger sample step compresses the waveform horizontally.
    ap.add_argument("--sample-rate", type=int, default=128)
    ap.add_argument("--hscale", type=int, default=1)
    ap.add_argument("--max-signals", type=int, default=64)
    ap.add_argument("--max-depth", type=int)
    args = ap.parse_args()

    vcd = VCDVCD(args.vcd, store_tvs=True)
    signals = [s for s in vcd.signals if getattr(vcd[s], "tv", [])]
    signals = [s for s in signals if not _has_all_caps_segment(s)]
    signals = _prefer_top_level_signals(signals)
    if args.max_depth is not None:
        signals = [s for s in signals if _scope_depth(s) <= args.max_depth]
    signals = signals[: args.max_signals]
    if not signals:
        raise RuntimeError("No waveform events found in VCD")

    min_t = min(int(vcd[s].tv[0][0]) for s in signals)
    max_t = max(int(vcd[s].tv[-1][0]) for s in signals)

    start_t = min_t if args.start == "auto" else int(args.start)
    start_t = max(min_t, start_t)
    # always cap to window; if --end is explicit, honour it but still cap
    if args.end == "auto":
        end_t = min(max_t, start_t + args.window)
    else:
        end_t = min(max_t, int(args.end))
    if end_t <= start_t:
        end_t = start_t + 1

    step = max(1, int(args.sample_rate))
    sample_times = list(range(start_t, end_t + 1, step))
    if sample_times[-1] != end_t:
        sample_times.append(end_t)

    wave_signals = []
    for name in signals:
        sig = vcd[name]
        width = int(getattr(sig, "size", 1) or 1)
        tv = [(int(t), str(v)) for t, v in sig.tv]
        if not tv:
            continue
        samples = _sample_values(tv, sample_times)

        if width == 1:
            wave, data = _encode_scalar(samples)
        else:
            wave, data = _encode_bus(samples)

        entry = {"name": _display_name(name), "wave": wave}
        if data:
            entry["data"] = data
        wave_signals.append(entry)

    source = {
        "signal": wave_signals,
        "config": {"hscale": max(1, int(args.hscale))},
    }

    out = Path(args.svg)
    out.parent.mkdir(parents=True, exist_ok=True)
    svg = wavedrom.render(json.dumps(source))
    svg.saveas(str(out))
    _apply_theme_colors(out)


if __name__ == "__main__":
    main()
