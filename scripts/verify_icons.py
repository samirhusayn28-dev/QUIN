#!/usr/bin/env python3
"""Compare a built APK's launcher icons with the source artwork.

Release builds shorten resource paths, so the caller resolves the real files
with `aapt2 dump resources` and passes them here as `density:path` pairs.

Each icon is reduced to a small block-averaged signature, then compared with the
same signature taken from the source. Block averaging keeps the check
independent of which resampling filter the icon tool used, while still failing
loudly if a mipmap is blank, the wrong picture, or the default Android robot.

Usage: verify_icons.py <source.png> <density:path> [<density:path> ...]
"""
import struct
import sys
import zlib

BUCKETS = {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}
SIG = 8             # signature is SIG x SIG blocks
MAX_MEAN_DIFF = 24  # per-channel mean absolute difference, out of 255

_passed = 0
_failed = 0


def ok(msg):
    global _passed
    _passed += 1
    print(f"  \033[32mPASS\033[0m  {msg}")


def bad(msg):
    global _failed
    _failed += 1
    print(f"  \033[31mFAIL\033[0m  {msg}")


def parse(path):
    """Return (blob, width, height, bitdepth, colortype, has_trns)."""
    blob = open(path, "rb").read()
    if blob[:8] != b"\x89PNG\r\n\x1a\n":
        raise ValueError("not a PNG")
    width, height, bitdepth, colortype, _, _, interlace = struct.unpack(
        ">IIBBBBB", blob[16:29])
    if bitdepth != 8:
        raise ValueError(f"only 8-bit PNGs are supported (got {bitdepth})")
    if interlace:
        raise ValueError("interlaced PNGs are not supported")
    return blob, width, height, colortype


def decode(path):
    """Return (width, height, rgb) with rgb a flat bytes object of w*h*3."""
    blob, width, height, colortype = parse(path)
    pos, idat, palette = 8, bytearray(), None
    while pos < len(blob):
        length = struct.unpack(">I", blob[pos:pos + 4])[0]
        ctype = blob[pos + 4:pos + 8]
        body = blob[pos + 8:pos + 8 + length]
        pos += 12 + length
        if ctype == b"IHDR":
            continue
        if ctype == b"PLTE":
            palette = [tuple(body[i:i + 3]) for i in range(0, len(body), 3)]
        elif ctype == b"IDAT":
            idat += body
        elif ctype == b"IEND":
            break

    channels = {0: 1, 2: 3, 3: 1, 4: 2, 6: 4}[colortype]
    raw = zlib.decompress(bytes(idat))
    stride = width * channels
    rgb = bytearray(width * height * 3)
    prev = bytearray(stride)
    p = 0
    for y in range(height):
        ftype = raw[p]
        p += 1
        line = bytearray(raw[p:p + stride])
        p += stride
        if ftype == 1:
            for i in range(channels, stride):
                line[i] = (line[i] + line[i - channels]) & 0xFF
        elif ftype == 2:
            for i in range(stride):
                line[i] = (line[i] + prev[i]) & 0xFF
        elif ftype == 3:
            for i in range(stride):
                left = line[i - channels] if i >= channels else 0
                line[i] = (line[i] + ((left + prev[i]) >> 1)) & 0xFF
        elif ftype == 4:
            for i in range(stride):
                a = line[i - channels] if i >= channels else 0
                b = prev[i]
                c = prev[i - channels] if i >= channels else 0
                pa, pb, pc = abs(b - c), abs(a - c), abs(a + b - 2 * c)
                pred = a if (pa <= pb and pa <= pc) else (b if pb <= pc else c)
                line[i] = (line[i] + pred) & 0xFF
        prev = line
        row = y * width
        for x in range(width):
            i = x * channels
            if colortype == 3:
                r, g, b = palette[line[i]] if palette else (0, 0, 0)
            elif colortype in (0, 4):
                r = g = b = line[i]
            else:
                r, g, b = line[i], line[i + 1], line[i + 2]
            o = (row + x) * 3
            rgb[o], rgb[o + 1], rgb[o + 2] = r, g, b
    return width, height, bytes(rgb)


def signature(width, height, rgb, n=SIG):
    sums = [[[0.0, 0.0, 0.0] for _ in range(n)] for _ in range(n)]
    counts = [[0] * n for _ in range(n)]
    for y in range(height):
        by = min(n - 1, y * n // height)
        base = y * width
        for x in range(width):
            bx = min(n - 1, x * n // width)
            o = (base + x) * 3
            s = sums[by][bx]
            s[0] += rgb[o]
            s[1] += rgb[o + 1]
            s[2] += rgb[o + 2]
            counts[by][bx] += 1
    out = []
    for by in range(n):
        for bx in range(n):
            c = counts[by][bx] or 1
            s = sums[by][bx]
            out.append((s[0] / c, s[1] / c, s[2] / c))
    return out


def mean_diff(a, b):
    total = 0.0
    for (r1, g1, b1), (r2, g2, b2) in zip(a, b):
        total += abs(r1 - r2) + abs(g1 - g2) + abs(b1 - b2)
    return total / (3 * len(a))


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        return 2
    source = sys.argv[1]

    # ---- source ----
    try:
        _, sw, sh, colortype = parse(source)
        s_colour = colortype
        sw_, sh_, s_rgb = decode(source)
    except ValueError as exc:
        bad(f"source artwork unreadable: {exc}")
        return 1
    kind = {0: "grey", 2: "RGB", 3: "palette", 4: "grey+alpha", 6: "RGBA"}[colortype]
    ok(f"source artwork {sw}x{sh} ({kind})")
    if colortype in (4, 6):
        bad("source artwork still has an alpha channel")
    else:
        ok("source artwork is fully opaque")
    s_sig = signature(sw_, sh_, s_rgb)

    # ---- apk icons ----
    seen = {}
    for arg in sys.argv[2:]:
        density, _, path = arg.partition(":")
        if density not in BUCKETS:
            bad(f"unknown density bucket '{density}'")
            continue
        want = BUCKETS[density]
        try:
            w, h, rgb = decode(path)
        except ValueError as exc:
            bad(f"mipmap-{density}: unreadable ({exc})")
            continue
        seen[density] = True
        if (w, h) != (want, want):
            bad(f"mipmap-{density} is {w}x{h}, expected {want}x{want}")
            continue
        diff = mean_diff(s_sig, signature(w, h, rgb))
        if diff <= MAX_MEAN_DIFF:
            ok(f"mipmap-{density} {w}x{h} matches the source artwork "
               f"(mean diff {diff:.1f})")
        else:
            bad(f"mipmap-{density} {w}x{h} does NOT match the source "
                f"(mean diff {diff:.1f})")

    for density in BUCKETS:
        if density not in seen:
            bad(f"mipmap-{density} is missing from the APK")

    print()
    if _failed == 0:
        print(f"\033[32mPASS ({_passed} checks)\033[0m")
        return 0
    print(f"\033[31mFAIL ({_failed} of {_passed + _failed} checks failed)\033[0m")
    return 1


if __name__ == "__main__":
    sys.exit(main())
