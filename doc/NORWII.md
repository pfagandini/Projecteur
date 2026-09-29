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

## Button map

To be filled in from the capture.
