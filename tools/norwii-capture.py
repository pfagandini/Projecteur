#!/usr/bin/env python3
"""Record what a Norwii presenter really sends to Linux.

Guided mode (default) asks you to press each button with a tap, a long press
and a double press, and writes a JSON + Markdown report. Monitor mode prints
raw events live.

No third party modules are needed. Stop Projecteur first: it grabs the device,
so this tool would not see any events while it runs.

  sudo python3 tools/norwii-capture.py            # guided capture
  sudo python3 tools/norwii-capture.py --monitor  # raw live events
  sudo python3 tools/norwii-capture.py --list     # list matching devices
"""

import argparse
import datetime
import fcntl
import glob
import json
import os
import re
import select
import struct
import sys
import time

NORWII_VENDOR = 0x3243

EV_FMT = "@llHHi"  # struct input_event: timeval, type, code, value
EV_SIZE = struct.calcsize(EV_FMT)
EVIOCGRAB = 0x40044590  # _IOW('E', 0x90, int)

EV_SYN, EV_KEY, EV_REL, EV_ABS, EV_MSC = 0x00, 0x01, 0x02, 0x03, 0x04
EV_TYPE_NAMES = {EV_SYN: "EV_SYN", EV_KEY: "EV_KEY", EV_REL: "EV_REL",
                 EV_ABS: "EV_ABS", EV_MSC: "EV_MSC"}
KEY_VALUE_NAMES = {0: "release", 1: "press", 2: "repeat"}

# Seconds of silence that end one gesture capture.
IDLE_END = 1.5


# Names that only mark the start of a code range; the real key name is preferred.
RANGE_MARKERS = {"BTN_MISC", "BTN_MOUSE", "BTN_JOYSTICK", "BTN_GAMEPAD", "BTN_DIGI",
                 "BTN_WHEEL", "BTN_TRIGGER_HAPPY", "KEY_MIN_INTERESTING"}


def load_code_names():
    """Map (type, code) to names using the kernel header when it is installed."""
    names = {}
    header = "/usr/include/linux/input-event-codes.h"
    prefixes = {"KEY_": EV_KEY, "BTN_": EV_KEY, "REL_": EV_REL, "ABS_": EV_ABS, "MSC_": EV_MSC}
    try:
        with open(header) as f:
            for line in f:
                m = re.match(r"#define\s+((KEY|BTN|REL|ABS|MSC)_\w+)\s+(0x[0-9a-fA-F]+|\d+)\b", line)
                if not m:
                    continue
                name, prefix, value = m.group(1), m.group(2) + "_", int(m.group(3), 0)
                if name.endswith(("_MAX", "_CNT")) or name in RANGE_MARKERS:
                    continue
                # Keep the first name defined for a code (aliases come later).
                names.setdefault((prefixes[prefix], value), name)
    except OSError:
        pass
    return names


CODE_NAMES = load_code_names()


def code_name(ev_type, code):
    return CODE_NAMES.get((ev_type, code), f"{EV_TYPE_NAMES.get(ev_type, ev_type)}:{code}")


def read_sys(path):
    try:
        with open(path) as f:
            return f.read().strip()
    except OSError:
        return ""


def decode_bitmap(hexwords):
    """Decode a sysfs capability bitmap (space separated hex words, MSB first)."""
    bits = []
    words = hexwords.split()
    for i, word in enumerate(reversed(words)):
        value = int(word, 16)
        for b in range(64):
            if value & (1 << b):
                bits.append(i * 64 + b)
    return bits


def find_devices(vendor, product):
    devices = []
    for node in sorted(glob.glob("/sys/class/input/event*"), key=lambda p: int(re.sub(r"\D", "", p))):
        dev = os.path.join(node, "device")
        vid = read_sys(os.path.join(dev, "id/vendor"))
        pid = read_sys(os.path.join(dev, "id/product"))
        if not vid or int(vid, 16) != vendor:
            continue
        if product is not None and int(pid, 16) != product:
            continue
        bus = int(read_sys(os.path.join(dev, "id/bustype")) or "0", 16)
        caps = {}
        for kind, ev_type in (("key", EV_KEY), ("rel", EV_REL), ("abs", EV_ABS), ("msc", EV_MSC)):
            bits = decode_bitmap(read_sys(os.path.join(dev, "capabilities", kind)) or "0")
            if bits:
                caps[kind] = [code_name(ev_type, c) for c in bits]
        devices.append({
            "event": "/dev/input/" + os.path.basename(node),
            "name": read_sys(os.path.join(dev, "name")),
            "vendor": f"{int(vid, 16):04x}",
            "product": f"{int(pid, 16):04x}",
            "bus": {0x03: "usb", 0x05: "bluetooth"}.get(bus, f"0x{bus:02x}"),
            "phys": read_sys(os.path.join(dev, "phys")),
            "capabilities": caps,
        })
    return devices


class Reader:
    def __init__(self, devices, grab):
        self.fds = {}
        for d in devices:
            try:
                fd = os.open(d["event"], os.O_RDONLY | os.O_NONBLOCK)
            except PermissionError:
                sys.exit(f"Permission denied on {d['event']}. Run with sudo.")
            if grab:
                try:
                    fcntl.ioctl(fd, EVIOCGRAB, 1)
                except OSError as e:
                    sys.exit(f"Cannot grab {d['event']} ({e}). Is Projecteur still running? Quit it first.")
            self.fds[fd] = d["event"]

    def close(self):
        for fd in self.fds:
            try:
                fcntl.ioctl(fd, EVIOCGRAB, 0)
            except OSError:
                pass
            os.close(fd)

    def drain(self):
        while self.read(0):
            pass

    def read(self, timeout):
        """Return a list of events, waiting at most timeout seconds."""
        ready, _, _ = select.select(list(self.fds), [], [], timeout)
        events = []
        for fd in ready:
            try:
                data = os.read(fd, EV_SIZE * 64)
            except BlockingIOError:
                continue
            for off in range(0, len(data) - EV_SIZE + 1, EV_SIZE):
                sec, usec, ev_type, code, value = struct.unpack_from(EV_FMT, data, off)
                if ev_type == EV_SYN:
                    continue
                events.append({"t": sec + usec / 1e6, "dev": self.fds[fd],
                               "type": ev_type, "code": code, "value": value})
        return events


def describe(ev):
    name = code_name(ev["type"], ev["code"])
    if ev["type"] == EV_KEY:
        return f"{name} {KEY_VALUE_NAMES.get(ev['value'], ev['value'])}"
    return f"{name} {ev['value']}"


def summarize(events):
    """Collapse a capture into readable steps; motion is merged per axis."""
    if not events:
        return []
    t0 = events[0]["t"]
    steps, motion = [], {}
    for ev in events:
        if ev["type"] in (EV_REL, EV_ABS):
            key = (ev["dev"], code_name(ev["type"], ev["code"]))
            m = motion.setdefault(key, {"count": 0, "sum": 0, "first": ev["t"] - t0})
            m["count"] += 1
            m["sum"] += ev["value"]
            continue
        steps.append({"ms": round((ev["t"] - t0) * 1000), "dev": ev["dev"], "event": describe(ev)})
    for (dev, axis), m in motion.items():
        steps.append({"ms": round(m["first"] * 1000), "dev": dev,
                      "event": f"{axis} motion: {m['count']} events, total {m['sum']}"})
    steps.sort(key=lambda s: s["ms"])
    return steps


def capture_gesture(reader, first_timeout):
    reader.drain()
    events = reader.read(first_timeout)
    if not events:
        return []
    held = {(e["dev"], e["code"]) for e in events if e["type"] == EV_KEY and e["value"] == 1}
    while True:
        more = reader.read(IDLE_END)
        for e in more:
            if e["type"] == EV_KEY:
                if e["value"] == 1:
                    held.add((e["dev"], e["code"]))
                elif e["value"] == 0:
                    held.discard((e["dev"], e["code"]))
        events.extend(more)
        if not more and not held:
            return events


def monitor(reader):
    print("Press buttons. Ctrl+C to stop.\n")
    t0 = None
    while True:
        for ev in reader.read(None):
            t0 = t0 or ev["t"]
            print(f"{ev['t'] - t0:9.3f}s  {ev['dev']:<20} {describe(ev)}")


GESTURES = [
    ("tap", "a short single press"),
    ("long", "press and HOLD for about 2 seconds, then release"),
    ("double", "a quick double press"),
]


def guided(reader, devices, out_prefix):
    report = {"created": datetime.datetime.now().isoformat(timespec="seconds"),
              "kernel": os.uname().release, "devices": devices, "buttons": []}
    print("Guided capture. For each button give it a name (for example: top-left,")
    print("laser, page-down, mouse). Leave the name empty when you are done.\n")
    while True:
        try:
            name = input("Button name (empty to finish): ").strip()
        except EOFError:
            break
        if not name:
            break
        entry = {"button": name, "gestures": {}}
        for gesture, how in GESTURES:
            input(f"  [{gesture}] press Enter, then do {how} ...")
            events = capture_gesture(reader, first_timeout=15)
            steps = summarize(events)
            if not steps:
                print("    nothing received (the device may not report this gesture)")
            for s in steps:
                print(f"    {s['ms']:6d} ms  {s['event']}  ({s['dev']})")
            entry["gestures"][gesture] = steps
        note = input("  Any note for this button (what it did on screen, LED, ...)? ").strip()
        if note:
            entry["note"] = note
        report["buttons"].append(entry)
        print()

    json_path, md_path = out_prefix + ".json", out_prefix + ".md"
    with open(json_path, "w") as f:
        json.dump(report, f, indent=2)
    with open(md_path, "w") as f:
        f.write(to_markdown(report))
    print(f"Wrote {json_path} and {md_path}")


def to_markdown(report):
    lines = ["# Norwii capture report", "",
             f"Created {report['created']}, kernel {report['kernel']}.", "", "## Input devices", ""]
    for d in report["devices"]:
        lines.append(f"- `{d['event']}` {d['name']} ({d['vendor']}:{d['product']}, {d['bus']})")
        for kind, codes in d["capabilities"].items():
            lines.append(f"  - {kind}: {', '.join(codes)}")
    lines += ["", "## Buttons", ""]
    for b in report["buttons"]:
        lines.append(f"### {b['button']}")
        if b.get("note"):
            lines.append(f"Note: {b['note']}")
        lines.append("")
        lines.append("| Gesture | ms | Event | Device |")
        lines.append("| --- | --- | --- | --- |")
        for gesture, steps in b["gestures"].items():
            if not steps:
                lines.append(f"| {gesture} | | (nothing received) | |")
            for s in steps:
                lines.append(f"| {gesture} | {s['ms']} | {s['event']} | {s['dev']} |")
        lines.append("")
    return "\n".join(lines) + "\n"


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--vendor", default=f"{NORWII_VENDOR:04x}", help="USB vendor id in hex (default 3243, Norwii)")
    parser.add_argument("--product", help="USB product id in hex, to pick one device")
    parser.add_argument("--list", action="store_true", help="list matching input devices and exit")
    parser.add_argument("--monitor", action="store_true", help="print raw events live")
    parser.add_argument("--no-grab", action="store_true", help="do not grab the device (presses also reach the desktop)")
    parser.add_argument("--out", default="norwii-capture", help="output file prefix for guided mode")
    args = parser.parse_args()

    devices = find_devices(int(args.vendor, 16), int(args.product, 16) if args.product else None)
    if not devices:
        sys.exit("No matching input device found. Is the presenter on and connected? Try --list with another --vendor.")
    for d in devices:
        print(f"{d['event']:<20} {d['name']}  {d['vendor']}:{d['product']} ({d['bus']})")
    print()
    if args.list:
        for d in devices:
            print(json.dumps(d, indent=2))
        return

    reader = Reader(devices, grab=not args.no_grab)
    try:
        if args.monitor:
            monitor(reader)
        else:
            guided(reader, devices, args.out)
    except KeyboardInterrupt:
        print()
    finally:
        reader.close()


if __name__ == "__main__":
    main()
