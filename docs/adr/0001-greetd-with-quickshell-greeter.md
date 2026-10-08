# greetd with our own Quickshell Greeter, hosted in Cage

Login uses greetd, with a Greeter we write in Quickshell running inside the Cage kiosk compositor, rather than SDDM or another display manager. greetd only authenticates and starts the chosen Session, so the Greeter's UI is entirely ours and can share QML components, fonts and look with the Shell and the lock screen; SDDM themes run inside SDDM's own greeter API and can't easily reuse our modules.

## Consequences

- We build what a display manager normally gives us: user listing, Session listing from `wayland-sessions`, failure states and multi-monitor handling.
- Cage has no layer-shell, so the Greeter is a single `FloatingWindow`. Cage runs with `-m last`: the Greeter shows on one output and the others stay blank, because `-m extend` would stretch one window across every output and put a centred login on the seam between monitors. Per-monitor layout waits for a heavier Greeter compositor, which can replace Cage later without changing greetd or the Greeter's role.
- KWin is a Session compositor only. Hosting the Greeter in KWin was considered and rejected: it would tie the login to one Session compositor, and no greetd setup running KWin as a Greeter compositor is known to work.
