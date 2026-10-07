# Norwii capture report

Created 2026-09-29T14:14:23, kernel 7.2.7-200.fc44.x86_64.

## Input devices

- `/dev/input/event18` Norwii BLE Presenter Dongle (3243:0382, usb)
  - key: BTN_LEFT, BTN_RIGHT, BTN_MIDDLE, BTN_SIDE, BTN_EXTRA
  - rel: REL_X, REL_Y, REL_WHEEL, REL_WHEEL_HI_RES
  - msc: MSC_SCAN
- `/dev/input/event19` Norwii BLE Presenter Dongle Keyboard (3243:0382, usb)
  - key: KEY_ESC, KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9, KEY_0, KEY_MINUS, KEY_EQUAL, KEY_BACKSPACE, KEY_TAB, KEY_Q, KEY_W, KEY_E, KEY_R, KEY_T, KEY_Y, KEY_U, KEY_I, KEY_O, KEY_P, KEY_LEFTBRACE, KEY_RIGHTBRACE, KEY_ENTER, KEY_LEFTCTRL, KEY_A, KEY_S, KEY_D, KEY_F, KEY_G, KEY_H, KEY_J, KEY_K, KEY_L, KEY_SEMICOLON, KEY_APOSTROPHE, KEY_GRAVE, KEY_LEFTSHIFT, KEY_BACKSLASH, KEY_Z, KEY_X, KEY_C, KEY_V, KEY_B, KEY_N, KEY_M, KEY_COMMA, KEY_DOT, KEY_SLASH, KEY_RIGHTSHIFT, KEY_KPASTERISK, KEY_LEFTALT, KEY_SPACE, KEY_CAPSLOCK, KEY_F1, KEY_F2, KEY_F3, KEY_F4, KEY_F5, KEY_F6, KEY_F7, KEY_F8, KEY_F9, KEY_F10, KEY_NUMLOCK, KEY_SCROLLLOCK, KEY_KP7, KEY_KP8, KEY_KP9, KEY_KPMINUS, KEY_KP4, KEY_KP5, KEY_KP6, KEY_KPPLUS, KEY_KP1, KEY_KP2, KEY_KP3, KEY_KP0, KEY_KPDOT, KEY_ZENKAKUHANKAKU, KEY_102ND, KEY_F11, KEY_F12, KEY_RO, KEY_KATAKANA, KEY_HIRAGANA, KEY_HENKAN, KEY_KATAKANAHIRAGANA, KEY_MUHENKAN, KEY_KPJPCOMMA, KEY_KPENTER, KEY_RIGHTCTRL, KEY_KPSLASH, KEY_SYSRQ, KEY_RIGHTALT, KEY_HOME, KEY_UP, KEY_PAGEUP, KEY_LEFT, KEY_RIGHT, KEY_END, KEY_DOWN, KEY_PAGEDOWN, KEY_INSERT, KEY_DELETE, KEY_MUTE, KEY_VOLUMEDOWN, KEY_VOLUMEUP, KEY_POWER, KEY_KPEQUAL, KEY_PAUSE, KEY_KPCOMMA, KEY_HANGEUL, KEY_HANJA, KEY_YEN, KEY_LEFTMETA, KEY_RIGHTMETA, KEY_COMPOSE, KEY_STOP, KEY_AGAIN, KEY_PROPS, KEY_UNDO, KEY_FRONT, KEY_COPY, KEY_OPEN, KEY_PASTE, KEY_FIND, KEY_CUT, KEY_HELP, KEY_CALC, KEY_FILE, KEY_WWW, KEY_BOOKMARKS, KEY_BACK, KEY_FORWARD, KEY_EJECTCD, KEY_NEXTSONG, KEY_PLAYPAUSE, KEY_PREVIOUSSONG, KEY_STOPCD, KEY_RECORD, KEY_REWIND, KEY_REFRESH, KEY_KPLEFTPAREN, KEY_KPRIGHTPAREN, KEY_F13, KEY_F14, KEY_F15, KEY_F16, KEY_F17, KEY_F18, KEY_F19, KEY_F20, KEY_F21, KEY_F22, KEY_F23, KEY_F24, KEY_PLAY, KEY_FASTFORWARD, KEY_UNKNOWN, KEY_PROGRAM, KEY_CHANNELUP, KEY_CHANNELDOWN
  - msc: MSC_SCAN
- `/dev/input/event20` Norwii BLE Presenter Dongle (3243:0382, usb)
  - abs: ABS_MISC

## Buttons

### mouse
Note: nothing, i had closed i believe projecteur, it had the mouse symbol on it, it is the top button.

| Gesture | ms | Event | Device |
| --- | --- | --- | --- |
| tap | 0 | MSC_SCAN 589825 | /dev/input/event18 |
| tap | 0 | BTN_LEFT press | /dev/input/event18 |
| tap | 49 | MSC_SCAN 589825 | /dev/input/event18 |
| tap | 49 | BTN_LEFT release | /dev/input/event18 |
| long | 0 | REL_X motion: 46 events, total -97 | /dev/input/event18 |
| long | 0 | REL_Y motion: 57 events, total -72 | /dev/input/event18 |
| double | 0 | MSC_SCAN 589825 | /dev/input/event18 |
| double | 0 | BTN_LEFT press | /dev/input/event18 |
| double | 20 | MSC_SCAN 589825 | /dev/input/event18 |
| double | 20 | BTN_LEFT release | /dev/input/event18 |
| double | 50 | MSC_SCAN 589825 | /dev/input/event18 |
| double | 50 | BTN_LEFT press | /dev/input/event18 |
| double | 80 | MSC_SCAN 589825 | /dev/input/event18 |
| double | 80 | BTN_LEFT release | /dev/input/event18 |

### left arrow
Note: did nto do a thing because projecteur is closed, normally goes back slides.

| Gesture | ms | Event | Device |
| --- | --- | --- | --- |
| tap | 0 | MSC_SCAN 458832 | /dev/input/event19 |
| tap | 0 | KEY_LEFT press | /dev/input/event19 |
| tap | 40 | MSC_SCAN 458832 | /dev/input/event19 |
| tap | 40 | KEY_LEFT release | /dev/input/event19 |
| long | 0 | MSC_SCAN 458979 | /dev/input/event19 |
| long | 0 | KEY_LEFTMETA press | /dev/input/event19 |
| long | 0 | MSC_SCAN 458792 | /dev/input/event19 |
| long | 0 | KEY_ENTER press | /dev/input/event19 |
| long | 10 | MSC_SCAN 458979 | /dev/input/event19 |
| long | 10 | KEY_LEFTMETA release | /dev/input/event19 |
| long | 10 | MSC_SCAN 458792 | /dev/input/event19 |
| long | 10 | KEY_ENTER release | /dev/input/event19 |
| long | 40 | MSC_SCAN 458978 | /dev/input/event19 |
| long | 40 | KEY_LEFTALT press | /dev/input/event19 |
| long | 40 | MSC_SCAN 458979 | /dev/input/event19 |
| long | 40 | KEY_LEFTMETA press | /dev/input/event19 |
| long | 40 | MSC_SCAN 458771 | /dev/input/event19 |
| long | 40 | KEY_P press | /dev/input/event19 |
| long | 50 | MSC_SCAN 458978 | /dev/input/event19 |
| long | 50 | KEY_LEFTALT release | /dev/input/event19 |
| long | 50 | MSC_SCAN 458979 | /dev/input/event19 |
| long | 50 | KEY_LEFTMETA release | /dev/input/event19 |
| long | 50 | MSC_SCAN 458771 | /dev/input/event19 |
| long | 50 | KEY_P release | /dev/input/event19 |
| long | 80 | MSC_SCAN 458977 | /dev/input/event19 |
| long | 80 | KEY_LEFTSHIFT press | /dev/input/event19 |
| long | 80 | MSC_SCAN 458814 | /dev/input/event19 |
| long | 80 | KEY_F5 press | /dev/input/event19 |
| long | 90 | MSC_SCAN 458977 | /dev/input/event19 |
| long | 90 | KEY_LEFTSHIFT release | /dev/input/event19 |
| long | 90 | MSC_SCAN 458814 | /dev/input/event19 |
| long | 90 | KEY_F5 release | /dev/input/event19 |
| double | 0 | MSC_SCAN 458832 | /dev/input/event19 |
| double | 0 | KEY_LEFT press | /dev/input/event19 |
| double | 40 | MSC_SCAN 458832 | /dev/input/event19 |
| double | 40 | KEY_LEFT release | /dev/input/event19 |
| double | 230 | MSC_SCAN 458832 | /dev/input/event19 |
| double | 230 | KEY_LEFT press | /dev/input/event19 |
| double | 270 | MSC_SCAN 458832 | /dev/input/event19 |
| double | 270 | KEY_LEFT release | /dev/input/event19 |

### right arrow
Note: usually advances the slides, but i have no projecteur turned on

| Gesture | ms | Event | Device |
| --- | --- | --- | --- |
| tap | 0 | MSC_SCAN 458831 | /dev/input/event19 |
| tap | 0 | KEY_RIGHT press | /dev/input/event19 |
| tap | 40 | MSC_SCAN 458831 | /dev/input/event19 |
| tap | 40 | KEY_RIGHT release | /dev/input/event19 |
| long | 0 | MSC_SCAN 458757 | /dev/input/event19 |
| long | 0 | KEY_B press | /dev/input/event19 |
| long | 50 | MSC_SCAN 458757 | /dev/input/event19 |
| long | 50 | KEY_B release | /dev/input/event19 |
| double | 0 | MSC_SCAN 458831 | /dev/input/event19 |
| double | 0 | KEY_RIGHT press | /dev/input/event19 |
| double | 30 | MSC_SCAN 458831 | /dev/input/event19 |
| double | 30 | KEY_RIGHT release | /dev/input/event19 |
| double | 170 | MSC_SCAN 458831 | /dev/input/event19 |
| double | 170 | KEY_RIGHT press | /dev/input/event19 |
| double | 210 | MSC_SCAN 458831 | /dev/input/event19 |
| double | 210 | KEY_RIGHT release | /dev/input/event19 |

### laser/pointer
Note: it suddenly turned on the green laser (real, not virtual) had no projectour running.

| Gesture | ms | Event | Device |
| --- | --- | --- | --- |
| tap | | (nothing received) | |
| long | 0 | MSC_SCAN 458976 | /dev/input/event19 |
| long | 0 | KEY_LEFTCTRL press | /dev/input/event19 |
| long | 0 | MSC_SCAN 458767 | /dev/input/event19 |
| long | 0 | KEY_L press | /dev/input/event19 |
| long | 20 | MSC_SCAN 458976 | /dev/input/event19 |
| long | 20 | KEY_LEFTCTRL release | /dev/input/event19 |
| long | 20 | MSC_SCAN 458767 | /dev/input/event19 |
| long | 20 | KEY_L release | /dev/input/event19 |
| long | 119 | REL_X motion: 115 events, total 165 | /dev/input/event18 |
| long | 210 | REL_Y motion: 93 events, total -13 | /dev/input/event18 |
| long | 2260 | MSC_SCAN 458976 | /dev/input/event19 |
| long | 2260 | KEY_LEFTCTRL press | /dev/input/event19 |
| long | 2260 | MSC_SCAN 458756 | /dev/input/event19 |
| long | 2260 | KEY_A press | /dev/input/event19 |
| long | 2280 | MSC_SCAN 458976 | /dev/input/event19 |
| long | 2280 | KEY_LEFTCTRL release | /dev/input/event19 |
| long | 2280 | MSC_SCAN 458756 | /dev/input/event19 |
| long | 2280 | KEY_A release | /dev/input/event19 |
| double | | (nothing received) | |

### right side up

| Gesture | ms | Event | Device |
| --- | --- | --- | --- |
| tap | 0 | MSC_SCAN 458976 | /dev/input/event19 |
| tap | 0 | KEY_LEFTCTRL press | /dev/input/event19 |
| tap | 0 | MSC_SCAN 458771 | /dev/input/event19 |
| tap | 0 | KEY_P press | /dev/input/event19 |
| tap | 20 | MSC_SCAN 458976 | /dev/input/event19 |
| tap | 20 | KEY_LEFTCTRL release | /dev/input/event19 |
| tap | 20 | MSC_SCAN 458771 | /dev/input/event19 |
| tap | 20 | KEY_P release | /dev/input/event19 |
| tap | 21 | MSC_SCAN 589825 | /dev/input/event18 |
| tap | 21 | BTN_LEFT press | /dev/input/event18 |
| tap | 100 | REL_X motion: 2668 events, total -526 | /dev/input/event18 |
| tap | 100 | REL_Y motion: 3266 events, total -4340 | /dev/input/event18 |
| tap | 150 | MSC_SCAN 589825 | /dev/input/event18 |
| tap | 150 | BTN_LEFT release | /dev/input/event18 |
| tap | 190 | MSC_SCAN 458976 | /dev/input/event19 |
| tap | 190 | KEY_LEFTCTRL press | /dev/input/event19 |
| tap | 190 | MSC_SCAN 458756 | /dev/input/event19 |
| tap | 190 | KEY_A press | /dev/input/event19 |
| tap | 210 | MSC_SCAN 458976 | /dev/input/event19 |
| tap | 210 | KEY_LEFTCTRL release | /dev/input/event19 |
| tap | 210 | MSC_SCAN 458756 | /dev/input/event19 |
| tap | 210 | KEY_A release | /dev/input/event19 |
| tap | 10130 | MSC_SCAN 458976 | /dev/input/event19 |
| tap | 10130 | KEY_LEFTCTRL press | /dev/input/event19 |
| tap | 10130 | MSC_SCAN 458771 | /dev/input/event19 |
| tap | 10130 | KEY_P press | /dev/input/event19 |
| tap | 10150 | MSC_SCAN 458976 | /dev/input/event19 |
| tap | 10150 | KEY_LEFTCTRL release | /dev/input/event19 |
| tap | 10150 | MSC_SCAN 458771 | /dev/input/event19 |
| tap | 10150 | KEY_P release | /dev/input/event19 |
| tap | 10160 | MSC_SCAN 589825 | /dev/input/event18 |
| tap | 10160 | BTN_LEFT press | /dev/input/event18 |
| tap | 10320 | MSC_SCAN 589825 | /dev/input/event18 |
| tap | 10320 | BTN_LEFT release | /dev/input/event18 |
| tap | 10360 | MSC_SCAN 458976 | /dev/input/event19 |
| tap | 10360 | KEY_LEFTCTRL press | /dev/input/event19 |
| tap | 10360 | MSC_SCAN 458756 | /dev/input/event19 |
| tap | 10360 | KEY_A press | /dev/input/event19 |
| tap | 10380 | MSC_SCAN 458976 | /dev/input/event19 |
| tap | 10380 | KEY_LEFTCTRL release | /dev/input/event19 |
| tap | 10380 | MSC_SCAN 458756 | /dev/input/event19 |
| tap | 10380 | KEY_A release | /dev/input/event19 |
| tap | 42951 | MSC_SCAN 458976 | /dev/input/event19 |
| tap | 42951 | KEY_LEFTCTRL press | /dev/input/event19 |
| tap | 42951 | MSC_SCAN 458771 | /dev/input/event19 |
| tap | 42951 | KEY_P press | /dev/input/event19 |
| tap | 42971 | MSC_SCAN 458976 | /dev/input/event19 |
| tap | 42971 | KEY_LEFTCTRL release | /dev/input/event19 |
| tap | 42971 | MSC_SCAN 458771 | /dev/input/event19 |
| tap | 42971 | KEY_P release | /dev/input/event19 |
| tap | 42980 | MSC_SCAN 589825 | /dev/input/event18 |
| tap | 42980 | BTN_LEFT press | /dev/input/event18 |
| tap | 43311 | MSC_SCAN 589825 | /dev/input/event18 |
| tap | 43311 | BTN_LEFT release | /dev/input/event18 |
| tap | 43331 | MSC_SCAN 458976 | /dev/input/event19 |
| tap | 43331 | KEY_LEFTCTRL press | /dev/input/event19 |
| tap | 43331 | MSC_SCAN 458756 | /dev/input/event19 |
| tap | 43331 | KEY_A press | /dev/input/event19 |
| tap | 43351 | MSC_SCAN 458976 | /dev/input/event19 |
| tap | 43351 | KEY_LEFTCTRL release | /dev/input/event19 |
| tap | 43351 | MSC_SCAN 458756 | /dev/input/event19 |
| tap | 43351 | KEY_A release | /dev/input/event19 |
| tap | 57561 | MSC_SCAN 458976 | /dev/input/event19 |
| tap | 57561 | KEY_LEFTCTRL press | /dev/input/event19 |
| tap | 57561 | MSC_SCAN 458771 | /dev/input/event19 |
| tap | 57561 | KEY_P press | /dev/input/event19 |
| tap | 57581 | MSC_SCAN 458976 | /dev/input/event19 |
| tap | 57581 | KEY_LEFTCTRL release | /dev/input/event19 |
| tap | 57581 | MSC_SCAN 458771 | /dev/input/event19 |
| tap | 57581 | KEY_P release | /dev/input/event19 |
| tap | 57591 | MSC_SCAN 589825 | /dev/input/event18 |
| tap | 57591 | BTN_LEFT press | /dev/input/event18 |
| tap | 57891 | MSC_SCAN 589825 | /dev/input/event18 |
| tap | 57891 | BTN_LEFT release | /dev/input/event18 |
| tap | 57921 | MSC_SCAN 458976 | /dev/input/event19 |
| tap | 57921 | KEY_LEFTCTRL press | /dev/input/event19 |
| tap | 57921 | MSC_SCAN 458756 | /dev/input/event19 |
| tap | 57921 | KEY_A press | /dev/input/event19 |
| tap | 57941 | MSC_SCAN 458976 | /dev/input/event19 |
| tap | 57941 | KEY_LEFTCTRL release | /dev/input/event19 |
| tap | 57941 | MSC_SCAN 458756 | /dev/input/event19 |
| tap | 57941 | KEY_A release | /dev/input/event19 |
| long | 0 | REL_X motion: 364 events, total 219 | /dev/input/event18 |
| long | 10 | REL_Y motion: 363 events, total 76 | /dev/input/event18 |
| long | 850 | MSC_SCAN 458976 | /dev/input/event19 |
| long | 850 | KEY_LEFTCTRL press | /dev/input/event19 |
| long | 850 | MSC_SCAN 458771 | /dev/input/event19 |
| long | 850 | KEY_P press | /dev/input/event19 |
| long | 870 | MSC_SCAN 458976 | /dev/input/event19 |
| long | 870 | KEY_LEFTCTRL release | /dev/input/event19 |
| long | 870 | MSC_SCAN 458771 | /dev/input/event19 |
| long | 870 | KEY_P release | /dev/input/event19 |
| long | 880 | MSC_SCAN 589825 | /dev/input/event18 |
| long | 880 | BTN_LEFT press | /dev/input/event18 |
| long | 3130 | MSC_SCAN 589825 | /dev/input/event18 |
| long | 3130 | BTN_LEFT release | /dev/input/event18 |
| long | 3160 | MSC_SCAN 458976 | /dev/input/event19 |
| long | 3160 | KEY_LEFTCTRL press | /dev/input/event19 |
| long | 3160 | MSC_SCAN 458756 | /dev/input/event19 |
| long | 3160 | KEY_A press | /dev/input/event19 |
| long | 3180 | MSC_SCAN 458976 | /dev/input/event19 |
| long | 3180 | KEY_LEFTCTRL release | /dev/input/event19 |
| long | 3180 | MSC_SCAN 458756 | /dev/input/event19 |
| long | 3180 | KEY_A release | /dev/input/event19 |
| double | 0 | REL_X motion: 188 events, total 283 | /dev/input/event18 |
| double | 20 | REL_Y motion: 179 events, total 87 | /dev/input/event18 |
| double | 800 | MSC_SCAN 458976 | /dev/input/event19 |
| double | 800 | KEY_LEFTCTRL press | /dev/input/event19 |
| double | 800 | MSC_SCAN 458771 | /dev/input/event19 |
| double | 800 | KEY_P press | /dev/input/event19 |
| double | 820 | MSC_SCAN 458976 | /dev/input/event19 |
| double | 820 | KEY_LEFTCTRL release | /dev/input/event19 |
| double | 820 | MSC_SCAN 458771 | /dev/input/event19 |
| double | 820 | KEY_P release | /dev/input/event19 |
| double | 830 | MSC_SCAN 589825 | /dev/input/event18 |
| double | 830 | BTN_LEFT press | /dev/input/event18 |
| double | 950 | MSC_SCAN 589825 | /dev/input/event18 |
| double | 950 | BTN_LEFT release | /dev/input/event18 |
| double | 990 | MSC_SCAN 458976 | /dev/input/event19 |
| double | 990 | KEY_LEFTCTRL press | /dev/input/event19 |
| double | 990 | MSC_SCAN 458756 | /dev/input/event19 |
| double | 990 | KEY_A press | /dev/input/event19 |
| double | 1010 | MSC_SCAN 458976 | /dev/input/event19 |
| double | 1010 | KEY_LEFTCTRL release | /dev/input/event19 |
| double | 1010 | MSC_SCAN 458756 | /dev/input/event19 |
| double | 1010 | KEY_A release | /dev/input/event19 |
| double | 1110 | MSC_SCAN 458976 | /dev/input/event19 |
| double | 1110 | KEY_LEFTCTRL press | /dev/input/event19 |
| double | 1110 | MSC_SCAN 458771 | /dev/input/event19 |
| double | 1110 | KEY_P press | /dev/input/event19 |
| double | 1130 | MSC_SCAN 458976 | /dev/input/event19 |
| double | 1130 | KEY_LEFTCTRL release | /dev/input/event19 |
| double | 1130 | MSC_SCAN 458771 | /dev/input/event19 |
| double | 1130 | KEY_P release | /dev/input/event19 |
| double | 1140 | MSC_SCAN 589825 | /dev/input/event18 |
| double | 1140 | BTN_LEFT press | /dev/input/event18 |
| double | 1260 | MSC_SCAN 589825 | /dev/input/event18 |
| double | 1260 | BTN_LEFT release | /dev/input/event18 |
| double | 1300 | MSC_SCAN 458976 | /dev/input/event19 |
| double | 1300 | KEY_LEFTCTRL press | /dev/input/event19 |
| double | 1300 | MSC_SCAN 458756 | /dev/input/event19 |
| double | 1300 | KEY_A press | /dev/input/event19 |
| double | 1320 | MSC_SCAN 458976 | /dev/input/event19 |
| double | 1320 | KEY_LEFTCTRL release | /dev/input/event19 |
| double | 1320 | MSC_SCAN 458756 | /dev/input/event19 |
| double | 1320 | KEY_A release | /dev/input/event19 |

### right side down
Note: no projecteur running so it did nothing

| Gesture | ms | Event | Device |
| --- | --- | --- | --- |
| tap | 0 | REL_X motion: 140 events, total 90 | /dev/input/event18 |
| tap | 30 | REL_Y motion: 128 events, total -52 | /dev/input/event18 |
| tap | 1620 | MSC_SCAN 458760 | /dev/input/event19 |
| tap | 1620 | KEY_E press | /dev/input/event19 |
| tap | 1630 | MSC_SCAN 458760 | /dev/input/event19 |
| tap | 1630 | KEY_E release | /dev/input/event19 |
| long | | (nothing received) | |
| double | 0 | MSC_SCAN 458760 | /dev/input/event19 |
| double | 0 | KEY_E press | /dev/input/event19 |
| double | 9 | MSC_SCAN 458760 | /dev/input/event19 |
| double | 9 | KEY_E release | /dev/input/event19 |
| double | 279 | MSC_SCAN 458760 | /dev/input/event19 |
| double | 279 | KEY_E press | /dev/input/event19 |
| double | 289 | MSC_SCAN 458760 | /dev/input/event19 |
| double | 289 | KEY_E release | /dev/input/event19 |

