// This file is part of Projecteur - https://github.com/jahnf/projecteur
// - See LICENSE.md and README.md
#pragma once

#include <linux/input.h>

#include <cstdint>
#include <functional>
#include <optional>
#include <set>
#include <string_view>
#include <vector>

/// Norwii presenters (tested with the N95s BLE) detect tap and long press in
/// firmware and then send PowerPoint slide show shortcuts (see doc/NORWII.md).
/// This module recognizes those shortcut bursts as gestures, so each one can be
/// bound to a configurable action instead of reaching the focused application.
namespace norwii {

constexpr uint16_t VendorId = 0x3243;

enum class Gesture {
  LaserHold,   ///< Laser button held: Ctrl+L, pointer motion, Ctrl+A on release
  SideUpHold,  ///< Side up button: Ctrl+P, left button drag, Ctrl+A
  SideDownTap, ///< Side down button: E
  RightHold,   ///< Right button held: B
  LeftHold,    ///< Left button held: Meta+Enter, Alt+Meta+P, Shift+F5
};
constexpr int GestureCount = 5;

enum class Action {
  Ignore,      ///< Swallow the shortcut, do nothing
  PassThrough, ///< Send the original shortcut to the focused application
  Mouse,       ///< Swallow the shortcut, keep only the mouse part (click and drag)
  LaserDot,    ///< Show only the laser dot
  ZoomArea,    ///< Show the zoom area
  Spotlight,   ///< Show the spotlight with the configured look
  LaserModeDot,       ///< Make the laser hold gesture show the laser dot
  LaserModeSpotlight, ///< Make the laser hold gesture show the spotlight
};

/// Hold gestures have a start and an end, tap gestures only a start.
bool isHoldGesture(Gesture g);

/// Stable identifiers, used as configuration values.
std::string_view gestureKey(Gesture g);
std::string_view actionKey(Action a);
std::optional<Action> actionFromKey(std::string_view key);
Action defaultAction(Gesture g);

/// Filters the events of a Norwii sub-device, one SYN frame at a time.
/// Only recognized gestures, slide navigation, volume keys and mouse buttons get
/// through: the presenter sends a different burst every now and then (e.g. a lone
/// Esc on every other left hold), and an unknown key must never reach the slides.
class KeyFilter
{
public:
  enum class Phase { Start, End };
  struct GestureEvent {
    Gesture gesture;
    Phase phase;
    bool operator==(const GestureEvent& o) const { return gesture == o.gesture && phase == o.phase; }
  };
  struct Result {
    std::vector<input_event> events;  ///< Events to forward, without closing SYN
    std::vector<GestureEvent> gestures;
    std::vector<uint16_t> dropped;    ///< Unknown keys that were dropped (for diagnosis)
  };
  /// Returns true if the shortcuts of a gesture must reach the application unchanged.
  using PassThroughFn = std::function<bool(Gesture)>;

  /// Filter one frame (events up to, but excluding, the SYN event).
  Result filter(const input_event* events, size_t num, const PassThroughFn& passThrough);
  void reset();

private:
  struct Pending { std::optional<input_event> scan; input_event key; };

  void flushPendingModifiers(Result& r);
  void forward(Result& r, const std::optional<input_event>& scan, const input_event& ev);

  unsigned m_modifiers = 0;
  std::optional<input_event> m_scan;       ///< MSC_SCAN waiting for its key event
  std::vector<Pending> m_pendingModifiers; ///< Modifier presses not forwarded yet
  std::set<uint16_t> m_swallowedKeys;      ///< Pressed keys whose release must be dropped
  std::optional<Gesture> m_activeHold;
  bool m_activeHoldPassed = false;
};

} // namespace norwii
