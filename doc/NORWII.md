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
| Left | `Left` | `Meta+Enter`, `Alt+Meta+P`, `Shift+F5` in a row (start slide show; `Shift+F5` is PowerPoint "from current slide") |
| Right | `Right` | `B` (black screen) |
| Laser | Nothing reaches the computer: the physical laser turns on | `Ctrl+L` (PowerPoint laser pointer), pointer motion while held, `Ctrl+A` (PowerPoint arrow) on release |
| Side up | `Ctrl+P` (PowerPoint pen), left button down, pointer motion, left button up, `Ctrl+A` | Same sequence; the pen starts after about 0.85 s of motion |
| Side down | `E` (PowerPoint erase ink) | Nothing received |

Consequences outside PowerPoint: in a browser (Quarto / reveal.js) `Ctrl+L`
focuses the address bar, `Ctrl+P` opens the print dialog and `Ctrl+A`
selects everything, so Projecteur has to swallow these shortcuts and turn
them into its own actions.

Still to confirm: the side down tap capture also contains 1.6 s of pointer
motion before `E`, and its long press sent nothing. Bluetooth not captured
yet.
