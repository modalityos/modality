# Default Wallpapers: design brief

**Kind:** illustration · **Artifact:** https://claude.ai/artifact/QSqpbhHkprD1XQqtS8pzTY

## Purpose
The picture behind everything: the Greeter's background and the desktop wallpaper every new user starts with. Much of the macOS-like feel comes from it, so it has to look rich and calm on its own and still read well blurred behind frosted glass.

## Decisions
- **Style:** **Silk** is the default: large translucent folds of colour crossing the frame, soft-edged, overlapping where they meet. Two extra built-in wallpapers ship with it: **Aurora** (soft colour fields melting into each other) and **Dunes** (layered abstract hills under a glowing sky). The first draft, Ribbons, is set aside. Inspired by modern macOS abstract wallpapers, never copied: no Apple artwork, nothing mistakable for it.
- **Colours:** the Foundations' wallpaper family, blue to violet to peach, made richer and deeper. `wallpaper-1` to `wallpaper-3` in the Foundations are updated to the final art's three key colours.
- **Light and dark:** the same composition in two moods: airy daylight pastels for light, deep night tones for dark. The theme setting picks which shows.
- **Ownership:** drawn for ModalityOS and released CC0-1.0, with a `LICENSE` beside the files.

## Terms
- **Greeter**: The login screen the user sees before a Session starts: password entry, user and Session choice.
- **Foundations**: The base set of Tokens that the Shell, the Greeter and every App share.
- **Token**: A named visual value, such as a colour, corner radius, spacing step, font, shadow or motion curve, that every piece of the UI takes its look from.
- **Defaults**: The ModalityOS settings every machine starts with, shipped with the OS and never edited in place.

## What to design
- **Silk, light and dark:** the default wallpaper in daylight pastels and in night tones.
- **Aurora, light and dark:** extra built-in wallpaper.
- **Dunes, light and dark:** extra built-in wallpaper.
- **In context:** Silk, in each theme, behind the Greeter's frosted password field and clock, to judge it under glass.

## Canvas and sizes
An SVG master per wallpaper and theme at 3840 × 2160, composed so it also crops to 16:10. PNG exports of each at 3840 × 2160 and 3840 × 2400.

## Content
Mood: calm, spacious, quietly luminous. No text, logos, figures or recognisable objects. Keep the centre band, where the Greeter's clock and users sit, low in contrast so text over it stays legible.

## Reuse
- The Foundations' `wallpaper-1` to `wallpaper-3` hues and `SceneLogin` (`design/greeter-login/refs/scene-login.html`) as the current gradient it replaces.
- `refs/make-concepts.py`: the script that draws Silk, Aurora and Dunes (`python3 make-concepts.py <out-dir>`); change it to iterate the art. `refs/make-wallpaper.py` draws the set-aside Ribbons.

## Constraints
- `text-primary` over every point of the centre band holds 4.5:1 in its theme.
- SVG uses only shapes, gradients and blur filters; no embedded images.

## Out of scope
- Photographic wallpapers, more extras beyond Aurora and Dunes, per-user wallpaper at login.

## Hand back
- [ ] Silk: light and dark SVG masters, PNGs at 3840 × 2160 and 3840 × 2400
- [ ] Aurora: light and dark SVG masters, PNGs at 3840 × 2160 and 3840 × 2400
- [ ] Dunes: light and dark SVG masters, PNGs at 3840 × 2160 and 3840 × 2400
- [x] Silk shown under the Greeter's glass, both themes
- [x] Silk's three key colours per theme, for `wallpaper-1` to `wallpaper-3`
- [x] Contrast of `text-primary` over the centre band passing for every wallpaper and theme
