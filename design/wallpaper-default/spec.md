# Default Wallpapers: design spec

**Kind:** illustration · **Brief:** brief.md · **Artifact:** https://claude.ai/artifact/QSqpbhHkprD1XQqtS8pzTY · **Source:** handoff/ (1791541046-ed31, 2026-10-09)
**Built by:** not yet built. Implementing replaces this with the spec issue, `#<number>`; from then on the code is the source of truth.

## Tokens
| Token | Light | Dark | Code name | Note |
|---|---|---|---|---|
| `wallpaper-1` | `#6f9dff` | `#1f45c0` | `wallpaper1` | changed: was `#7fb2ff` / `#0e2a5c`. Silk's first key colour |
| `wallpaper-2` | `#a98cff` | `#5530b0` | `wallpaper2` | changed: was `#b9a4ff` / `#3a1f6b`. Silk's second key colour |
| `wallpaper-3` | `#ff9fbf` | `#a0306e` | `wallpaper3` | changed: was `#ffc3a8` / `#7a2e3a`. Silk's third key colour |
| `text-primary` | per Foundations | per Foundations | `textPrimary` | Not changed. The Token whose contrast the centre band must hold (see Contrast) |

## Raw values
The hex colours inside the SVG masters are art, not Tokens: they are painted shapes and gradients, not UI colours, so they stay raw. Their source is `refs/make-concepts.py`.

## Files
| File | Variant | Size or resolution | Use |
|---|---|---|---|
| `assets/wallpaper-silk-light.svg` | Silk, light | 3840 × 2160 master | Default wallpaper and Greeter background |
| `assets/wallpaper-silk-dark.svg` | Silk, dark | 3840 × 2160 master | Default wallpaper and Greeter background |
| `assets/wallpaper-aurora-light.svg` | Aurora, light | 3840 × 2160 master | Extra built-in wallpaper |
| `assets/wallpaper-aurora-dark.svg` | Aurora, dark | 3840 × 2160 master | Extra built-in wallpaper |
| `assets/wallpaper-dunes-light.svg` | Dunes, light | 3840 × 2160 master | Extra built-in wallpaper |
| `assets/wallpaper-dunes-dark.svg` | Dunes, dark | 3840 × 2160 master | Extra built-in wallpaper |
| `wallpaper-silk-light-3840x2160.png` | Silk, light | 3840 × 2160 | Default wallpaper and Greeter background. Rendered at packaging time from the SVG master, not committed |
| `wallpaper-silk-dark-3840x2160.png` | Silk, dark | 3840 × 2160 | Default wallpaper and Greeter background. Rendered at packaging time from the SVG master, not committed |
| `wallpaper-silk-light-3840x2400.png` | Silk, light | 3840 × 2400 | Default wallpaper and Greeter background on 16:10. Rendered at packaging time from the SVG master, not committed |
| `wallpaper-silk-dark-3840x2400.png` | Silk, dark | 3840 × 2400 | Default wallpaper and Greeter background on 16:10. Rendered at packaging time from the SVG master, not committed |
| `wallpaper-aurora-light-3840x2160.png` | Aurora, light | 3840 × 2160 | Extra built-in wallpaper. Rendered at packaging time from the SVG master, not committed |
| `wallpaper-aurora-dark-3840x2160.png` | Aurora, dark | 3840 × 2160 | Extra built-in wallpaper. Rendered at packaging time from the SVG master, not committed |
| `wallpaper-aurora-light-3840x2400.png` | Aurora, light | 3840 × 2400 | Extra built-in wallpaper on 16:10. Rendered at packaging time from the SVG master, not committed |
| `wallpaper-aurora-dark-3840x2400.png` | Aurora, dark | 3840 × 2400 | Extra built-in wallpaper on 16:10. Rendered at packaging time from the SVG master, not committed |
| `wallpaper-dunes-light-3840x2160.png` | Dunes, light | 3840 × 2160 | Extra built-in wallpaper. Rendered at packaging time from the SVG master, not committed |
| `wallpaper-dunes-dark-3840x2160.png` | Dunes, dark | 3840 × 2160 | Extra built-in wallpaper. Rendered at packaging time from the SVG master, not committed |
| `wallpaper-dunes-light-3840x2400.png` | Dunes, light | 3840 × 2400 | Extra built-in wallpaper on 16:10. Rendered at packaging time from the SVG master, not committed |
| `wallpaper-dunes-dark-3840x2400.png` | Dunes, dark | 3840 × 2400 | Extra built-in wallpaper on 16:10. Rendered at packaging time from the SVG master, not committed |
| `assets/LICENSE` | n/a | n/a | CC0-1.0 dedication for all the wallpapers; ships beside the files |

## Usage rules
- The light variant shows in the light theme, the dark variant in the dark theme. The theme setting picks which.
- Silk is the Defaults' wallpaper and the Greeter's. Aurora and Dunes are extra built-in wallpapers a user may choose.
- The Greeter blurs the wallpaper behind its glass (its frosted password field and clock).
- A 16:10 screen uses the 3840 × 2400 render. Any other aspect ratio scales the 3840 × 2160 render to cover, centred.
- `LICENSE` (CC0-1.0) ships beside the files.

## Rendering
- 16:9: `rsvg-convert -w 3840 -h 2160 <svg> -o <png>`
- 16:10: scale the 16:9 PNG to cover 3840 × 2400 and centre-crop: `magick <png> -resize 4267x2400 -gravity center -crop 3840x2400+0+0 +repage <out>`
- Silk uses `mix-blend-mode`, which `rsvg-convert` renders. A renderer without it gives a flatter result, so packaging must use `rsvg-convert`.

## Contrast
`text-primary` over the centre band (the middle 60% × 40% of the frame), measured on every render. All pass 4.5:1.

| Wallpaper | Light | Dark |
|---|---|---|
| Silk | 6.11 | 5.71 |
| Aurora | 8.22 | 6.68 |
| Dunes | 7.69 | 5.28 |

## Changes from the brief

- Silk's SVG masters use `mix-blend-mode` (multiply in light, screen in dark) where the folds cross, beyond the brief's "shapes, gradients and blur filters". Accepted by the user: the wallpapers ship as PNGs rendered with `rsvg-convert`, which supports blend modes, so the OS never draws the SVG live.

## Settled at intake
1. PNG renders are not committed. They are built from the SVG masters at packaging time with `rsvg-convert`, keeping about 57 MB of binaries out of git.
2. `wallpaper-1` to `wallpaper-3` in the Foundations change to Silk's key colours; the Foundations artifact and spec are updated to match.
