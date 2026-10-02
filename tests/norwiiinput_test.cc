// Unit tests for the Norwii gesture filter, using the event sequences of doc/captures.
// Build with -DBUILD_NORWII_TESTS=ON, run with ctest.
#include "norwiiinput.h"
#include <cassert>
#include <cstdio>
#include <string>
using namespace norwii;
static input_event K(uint16_t c, int v){ input_event e{}; e.type=EV_KEY; e.code=c; e.value=v; return e; }
static input_event S(int v){ input_event e{}; e.type=EV_MSC; e.code=MSC_SCAN; e.value=v; return e; }
static std::string dump(const std::vector<input_event>& ev){ std::string s; for(auto&e:ev){ if(e.type==EV_KEY) s+=std::to_string(e.code)+(e.value?"+ ":"- "); } return s; }
static int fails=0;
#define CHECK(c) do{ if(!(c)){ printf("FAIL line %d: %s\n", __LINE__, #c); ++fails;} }while(0)
struct Run { KeyFilter f; std::vector<input_event> out; std::vector<KeyFilter::GestureEvent> g;
  KeyFilter::PassThroughFn pt = [](Gesture){ return false; };
  void frame(std::vector<input_event> v){ auto r=f.filter(v.data(), v.size(), pt); out.insert(out.end(), r.events.begin(), r.events.end()); g.insert(g.end(), r.gestures.begin(), r.gestures.end()); } };
int main(){
  { Run r; // laser hold: Ctrl+L, later Ctrl+A (same-frame press / release, as captured)
    r.frame({S(458976),K(KEY_LEFTCTRL,1),S(458767),K(KEY_L,1)});
    r.frame({S(458976),K(KEY_LEFTCTRL,0),S(458767),K(KEY_L,0)});
    r.frame({S(458976),K(KEY_LEFTCTRL,1),S(458756),K(KEY_A,1)});
    r.frame({S(458976),K(KEY_LEFTCTRL,0),S(458756),K(KEY_A,0)});
    CHECK(r.out.empty());
    CHECK((r.g == std::vector<KeyFilter::GestureEvent>{{Gesture::LaserHold,KeyFilter::Phase::Start},{Gesture::LaserHold,KeyFilter::Phase::End}})); }
  { Run r; // same but each key in its own frame
    r.frame({S(1),K(KEY_LEFTCTRL,1)}); r.frame({S(2),K(KEY_L,1)}); r.frame({K(KEY_LEFTCTRL,0)}); r.frame({K(KEY_L,0)});
    CHECK(r.out.empty()); CHECK(r.g.size()==1); }
  { Run r; // left hold macro: Meta+Enter, Alt+Meta+P, Shift+F5 -> one gesture, nothing forwarded
    r.frame({K(KEY_LEFTMETA,1),K(KEY_ENTER,1)}); r.frame({K(KEY_LEFTMETA,0),K(KEY_ENTER,0)});
    r.frame({K(KEY_LEFTALT,1),K(KEY_LEFTMETA,1),K(KEY_P,1)}); r.frame({K(KEY_LEFTALT,0),K(KEY_LEFTMETA,0),K(KEY_P,0)});
    r.frame({K(KEY_LEFTSHIFT,1),K(KEY_F5,1)}); r.frame({K(KEY_LEFTSHIFT,0),K(KEY_F5,0)});
    CHECK(r.out.empty());
    CHECK((r.g == std::vector<KeyFilter::GestureEvent>{{Gesture::LeftHold,KeyFilter::Phase::Start}})); }
  { Run r; // left hold, alternate form: a lone Esc is the same gesture and never reaches the slides
    r.frame({S(458761),K(KEY_ESC,1)}); r.frame({S(458761),K(KEY_ESC,0)});
    CHECK(r.out.empty());
    CHECK((r.g == std::vector<KeyFilter::GestureEvent>{{Gesture::LeftHold,KeyFilter::Phase::Start}})); }
  { Run r; // arrows pass through untouched, with scan codes
    r.frame({S(458832),K(KEY_LEFT,1)}); r.frame({S(458832),K(KEY_LEFT,0)});
    CHECK(r.out.size()==4 && r.out[0].type==EV_MSC && r.out[1].code==KEY_LEFT); CHECK(r.g.empty()); }
  { Run r; r.frame({K(KEY_E,1)}); r.frame({K(KEY_E,0)}); r.frame({K(KEY_B,1)}); r.frame({K(KEY_B,0)});
    CHECK(r.out.empty()); CHECK(r.g.size()==2 && r.g[0].gesture==Gesture::SideDownTap && r.g[1].gesture==Gesture::RightHold); }
  { Run r; // pass-through for side up: Ctrl+P ... Ctrl+A forwarded complete
    r.pt = [](Gesture g){ return g==Gesture::SideUpHold; };
    r.frame({K(KEY_LEFTCTRL,1),K(KEY_P,1)}); r.frame({K(KEY_LEFTCTRL,0),K(KEY_P,0)});
    r.frame({K(KEY_LEFTCTRL,1),K(KEY_A,1)}); r.frame({K(KEY_LEFTCTRL,0),K(KEY_A,0)});
    CHECK(dump(r.out)=="29+ 25+ 29- 25- 29+ 30+ 29- 30- "); printf("passthrough: %s\n", dump(r.out).c_str());
    CHECK(r.g.size()==2); }
  { Run r; // unknown combo Ctrl+C passes through with modifier
    r.frame({K(KEY_LEFTCTRL,1),K(KEY_C,1)}); r.frame({K(KEY_C,0),K(KEY_LEFTCTRL,0)});
    CHECK(dump(r.out)=="29+ 46+ 46- 29- "); }
  { Run r; // stray Ctrl+A without active hold is swallowed, no gesture
    r.frame({K(KEY_LEFTCTRL,1),K(KEY_A,1)}); r.frame({K(KEY_LEFTCTRL,0),K(KEY_A,0)});
    CHECK(r.out.empty()); CHECK(r.g.empty()); }
  { Run r; // lone modifier tap forwarded
    r.frame({K(KEY_LEFTSHIFT,1)}); r.frame({K(KEY_LEFTSHIFT,0)}); CHECK(dump(r.out)=="42+ 42- "); }
  for (int i=0;i<GestureCount;++i){ auto g=Gesture(i); auto k=actionKey(defaultAction(g)); CHECK(actionFromKey(k)==defaultAction(g)); CHECK(!gestureKey(g).empty()); }
  printf(fails? "%d failures\n" : "all passed\n", fails); return fails; }
