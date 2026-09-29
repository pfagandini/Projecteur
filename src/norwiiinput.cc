// This file is part of Projecteur - https://github.com/jahnf/projecteur
// - See LICENSE.md and README.md

#include "norwiiinput.h"

#include <algorithm>
#include <array>
#include <utility>

namespace norwii {

namespace {
  enum Modifier : unsigned { Ctrl = 1, Shift = 2, Alt = 4, Meta = 8 };

  unsigned modifierBit(uint16_t code)
  {
    switch (code) {
      case KEY_LEFTCTRL: case KEY_RIGHTCTRL: return Ctrl;
      case KEY_LEFTSHIFT: case KEY_RIGHTSHIFT: return Shift;
      case KEY_LEFTALT: case KEY_RIGHTALT: return Alt;
      case KEY_LEFTMETA: case KEY_RIGHTMETA: return Meta;
      default: return 0;
    }
  }

  // A shortcut the presenter sends, and the gesture it belongs to.
  struct Match {
    enum Kind { Start, End, Tail } kind;
    Gesture gesture = Gesture::LaserHold; // unused for End
  };

  std::optional<Match> classify(uint16_t code, unsigned mods)
  {
    if (mods == Ctrl) {
      if (code == KEY_L) { return Match{Match::Start, Gesture::LaserHold}; }
      if (code == KEY_P) { return Match{Match::Start, Gesture::SideUpHold}; }
      if (code == KEY_A) { return Match{Match::End}; }
    }
    if (mods == 0) {
      if (code == KEY_E) { return Match{Match::Start, Gesture::SideDownTap}; }
      if (code == KEY_B) { return Match{Match::Start, Gesture::RightHold}; }
    }
    if (mods == Meta && code == KEY_ENTER) { return Match{Match::Start, Gesture::LeftHold}; }
    if (mods == (Alt | Meta) && code == KEY_P) { return Match{Match::Tail, Gesture::LeftHold}; }
    if (mods == Shift && code == KEY_F5) { return Match{Match::Tail, Gesture::LeftHold}; }
    return std::nullopt;
  }

  constexpr std::array<std::pair<Gesture, std::string_view>, GestureCount> gestureKeys {{
    {Gesture::LaserHold, "laser-hold"},
    {Gesture::SideUpHold, "side-up-hold"},
    {Gesture::SideDownTap, "side-down-tap"},
    {Gesture::RightHold, "right-hold"},
    {Gesture::LeftHold, "left-hold"},
  }};

  constexpr std::array<std::pair<Action, std::string_view>, 8> actionKeys {{
    {Action::Ignore, "ignore"},
    {Action::PassThrough, "pass-through"},
    {Action::Mouse, "mouse"},
    {Action::LaserDot, "laser-dot"},
    {Action::ZoomArea, "zoom-area"},
    {Action::Spotlight, "spotlight"},
    {Action::LaserModeDot, "laser-mode-dot"},
    {Action::LaserModeSpotlight, "laser-mode-spotlight"},
  }};
} // end anonymous namespace

// -------------------------------------------------------------------------------------------------
bool isHoldGesture(Gesture g)
{
  return g == Gesture::LaserHold || g == Gesture::SideUpHold;
}

// -------------------------------------------------------------------------------------------------
std::string_view gestureKey(Gesture g)
{
  for (const auto& [gesture, key] : gestureKeys) {
    if (gesture == g) { return key; }
  }
  return {};
}

// -------------------------------------------------------------------------------------------------
std::string_view actionKey(Action a)
{
  for (const auto& [action, key] : actionKeys) {
    if (action == a) { return key; }
  }
  return {};
}

// -------------------------------------------------------------------------------------------------
std::optional<Action> actionFromKey(std::string_view k)
{
  for (const auto& [action, key] : actionKeys) {
    if (key == k) { return action; }
  }
  return std::nullopt;
}

// -------------------------------------------------------------------------------------------------
Action defaultAction(Gesture g)
{
  switch (g) {
    case Gesture::LaserHold: return Action::LaserDot;
    case Gesture::SideUpHold: return Action::Mouse;
    case Gesture::SideDownTap: return Action::ZoomArea;
    case Gesture::RightHold: return Action::LaserModeSpotlight;
    case Gesture::LeftHold: return Action::LaserModeDot;
  }
  return Action::Ignore;
}

// -------------------------------------------------------------------------------------------------
void KeyFilter::reset()
{
  *this = KeyFilter();
}

// -------------------------------------------------------------------------------------------------
void KeyFilter::forward(Result& r, const std::optional<input_event>& scan, const input_event& ev)
{
  if (scan) { r.events.push_back(*scan); }
  r.events.push_back(ev);
}

// -------------------------------------------------------------------------------------------------
void KeyFilter::flushPendingModifiers(Result& r)
{
  for (const auto& p : m_pendingModifiers) { forward(r, p.scan, p.key); }
  m_pendingModifiers.clear();
}

// -------------------------------------------------------------------------------------------------
KeyFilter::Result KeyFilter::filter(const input_event* events, size_t num,
                                    const PassThroughFn& passThrough)
{
  Result r;
  for (size_t i = 0; i < num; ++i)
  {
    const auto& ev = events[i];

    if (ev.type == EV_MSC && ev.code == MSC_SCAN) {
      // The scan code belongs to the key event that follows it.
      if (m_scan) { r.events.push_back(*m_scan); }
      m_scan = ev;
      continue;
    }

    auto scan = std::exchange(m_scan, std::nullopt);

    if (ev.type != EV_KEY) {
      forward(r, scan, ev);
      continue;
    }

    if (const auto bit = modifierBit(ev.code))
    {
      auto pending = std::find_if(m_pendingModifiers.begin(), m_pendingModifiers.end(),
                                  [&ev](const Pending& p) { return p.key.code == ev.code; });
      if (ev.value == 1) {
        // Hold modifier presses back until we know which shortcut they are part of.
        m_modifiers |= bit;
        m_pendingModifiers.push_back({scan, ev});
      }
      else if (ev.value == 0) {
        m_modifiers &= ~bit;
        if (m_swallowedKeys.erase(ev.code)) { continue; }
        if (pending != m_pendingModifiers.end()) {
          // Modifier pressed and released on its own.
          forward(r, pending->scan, pending->key);
          m_pendingModifiers.erase(pending);
        }
        forward(r, scan, ev);
      }
      else if (pending == m_pendingModifiers.end() && !m_swallowedKeys.count(ev.code)) {
        forward(r, scan, ev); // repeat of a forwarded modifier
      }
      continue;
    }

    if (ev.value != 1)
    { // release or repeat
      if (m_swallowedKeys.count(ev.code)) {
        if (ev.value == 0) { m_swallowedKeys.erase(ev.code); }
        continue;
      }
      forward(r, scan, ev);
      continue;
    }

    const auto match = classify(ev.code, m_modifiers);
    bool swallow = false;
    if (match)
    {
      if (match->kind == Match::End) {
        // Ctrl+A closes whichever hold gesture is active; with none active it is dropped.
        swallow = !(m_activeHold && m_activeHoldPassed);
        if (m_activeHold) {
          r.gestures.push_back({*m_activeHold, Phase::End});
          m_activeHold.reset();
        }
      }
      else {
        swallow = !passThrough(match->gesture);
        if (match->kind == Match::Start) {
          r.gestures.push_back({match->gesture, Phase::Start});
          if (isHoldGesture(match->gesture)) {
            m_activeHold = match->gesture;
            m_activeHoldPassed = !swallow;
          }
        }
      }
    }

    if (swallow) {
      // Drop the shortcut including its modifiers, so e.g. a lone Meta never reaches the desktop.
      for (const auto& p : m_pendingModifiers) { m_swallowedKeys.insert(p.key.code); }
      m_pendingModifiers.clear();
      m_swallowedKeys.insert(ev.code);
    }
    else {
      flushPendingModifiers(r);
      forward(r, scan, ev);
    }
  }
  return r;
}

} // namespace norwii
