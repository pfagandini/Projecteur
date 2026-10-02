# Norwii presenter notes

This fork targets the Norwii N95s BLE (USB receiver `3243:0382`, Bluetooth
`3243:03a2`) on KDE Plasma (Wayland), for PDF, Quarto (reveal.js HTML) and,
less often, PowerPoint or LibreOffice Impress.

## Step 1: record what the buttons really send

The Norwii manual describes what buttons do on Windows or macOS. What matters
here is what Linux actually receives, so the button map is built from a
capture of your own unit, not from the manual.

1. Quit Projecteur (it grabs the presenter, so nothing else sees its events).
2. Plug in the receiver, or connect over Bluetooth.
3. Run the guided capture from the repository root:

   ```sh
   sudo python3 tools/norwii-capture.py --list   # check the device is found
   sudo python3 tools/norwii-capture.py          # guided capture
   ```

4. For every physical button, type a name (for example `page-up`, `page-down`,
   `laser`, `mouse`, `highlight`), then do a tap, a long press (about
   2 seconds) and a double press when asked. Add a note when the button does
   something visible on its own (LED, laser, pointer movement).
5. The tool writes `norwii-capture.json` and `norwii-capture.md`. Share the
   JSON file (or commit it under `doc/captures/`).

If you have time, repeat the capture once over the USB receiver and once over
Bluetooth: the two links may report different keys.

`sudo python3 tools/norwii-capture.py --monitor` prints raw events live, which
is handy for quick checks. The tool only needs Python 3, no extra modules.

## Button map (N95s BLE, USB receiver)

From `doc/captures/n95s-ble-usb.md`. The presenter detects tap and long
press itself and then sends ready made shortcuts, most of them PowerPoint
slide show shortcuts. A double press is not detected by the presenter: it
arrives as two separate taps.

The receiver shows up as three input devices: a mouse (buttons and motion),
a keyboard (all shortcuts) and a third one reporting only `ABS_MISC`, which
sent nothing during the capture.

| Button | Tap | Long press |
| --- | --- | --- |
| Mouse (top) | Left click | Pointer motion while held, no button press |
| Left | `Left` | `Meta+Enter`, `Alt+Meta+P`, `Shift+F5` in a row (start slide show; `Shift+F5` is PowerPoint "from current slide"). Every other hold sends a lone `Esc` instead (end slide show), as seen in the field on 2026-10-02 |
| Right | `Right` | `B` (black screen) |
| Laser | Nothing reaches the computer: the physical laser turns on | `Ctrl+L` (PowerPoint laser pointer), pointer motion while held, `Ctrl+A` (PowerPoint arrow) on release |
| Side up | `Ctrl+P` (PowerPoint pen), left button down, pointer motion, left button up, `Ctrl+A` | Same sequence; the pen starts after about 0.85 s of motion |
| Side down | `E` (PowerPoint erase ink) | Nothing received |

Consequences outside PowerPoint: in a browser (Quarto / reveal.js) `Ctrl+L`
focuses the address bar, `Ctrl+P` opens the print dialog and `Ctrl+A`
selects everything, so Projecteur has to swallow these shortcuts and turn
them into its own actions.

### Real laser and virtual laser

Double press the laser button to switch it between two modes. The switch
happens inside the presenter and sends nothing to the computer:

- Presentation mode: a long press sends `Ctrl+L`, pointer motion and `Ctrl+A`.
  Projecteur turns this into its virtual laser (dot or spotlight).
- Physical laser mode: holding the button shines the real laser. Nothing
  reaches the computer, so Projecteur stays out of the way.

Projecteur cannot tell which of the two modes the presenter is in.

Still to confirm: the side down tap capture also contains 1.6 s of pointer
motion before `E`, and its long press sent nothing. Bluetooth not captured
yet.

## Gestures and actions

Projecteur recognizes the shortcut bursts above as gestures. Each gesture is
bound to an action. Arrow taps and the mouse button are not gestures: they
pass through unchanged (and can still be remapped in Preferences, Devices).

| Gesture | Default action |
| --- | --- |
| `laser-hold` | `laser-dot`: laser dot only, while held |
| `side-up-hold` | `mouse`: drop `Ctrl+P` / `Ctrl+A`, keep the click and drag |
| `side-down-tap` | `zoom-area`: toggle the zoom area |
| `left-hold` | `laser-mode-dot`: make `laser-hold` show the laser dot |
| `right-hold` | `laser-mode-spotlight`: make `laser-hold` show the spotlight |

Available actions:

| Action | Hold gesture | Tap gesture |
| --- | --- | --- |
| `ignore` | Nothing | Nothing |
| `pass-through` | Send the original shortcuts to the application | Same |
| `mouse` | Drop the shortcuts, keep pointer motion and clicks | Nothing |
| `laser-dot` | Laser dot while held | Toggle the laser dot |
| `zoom-area` | Zoom area while held | Toggle the zoom area |
| `spotlight` | Spotlight (configured look) while held | Toggle the spotlight |
| `laser-mode-dot` | | Set `laser-hold` to `laser-dot` |
| `laser-mode-spotlight` | | Set `laser-hold` to `spotlight` |

Until the settings page exists, change them in `~/.config/projecteurrc`,
then restart Projecteur:

```ini
[Norwii]
laser-hold=laser-dot
side-down-tap=zoom-area
```

The overlay modes can also be triggered without the presenter, for example
from a global shortcut: `projecteur -c spot=laser`, `projecteur -c spot=zoom`,
`projecteur -c spot=off`.
