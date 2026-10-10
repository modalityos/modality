# Foundations first, with Tokens and Controls kept in this repo

The Foundations are designed as their own piece before the first screen (the Greeter), so every screen and Control takes its look from Tokens rather than hard-coded values. In code, Tokens live in `Modality.Theme` and Controls in `Modality.Controls`, both under `qml/Modality/` in this repo rather than a separate design-system repo: every consumer (Shell, Greeter, Apps) is here, and a Token or Control change usually lands with the screen that needs it. The set grows screen by screen; nothing is built until a screen needs it.

## Consequences

- `qml/Modality/*` never imports from `shell/`, `greeter/` or `apps/`, so it can be split into its own repo later if outside projects start using it.
- New or changed Tokens and Controls get their own ticket, which blocks the screen tickets that use them. This is a deliberate horizontal ticket against `/to-tickets`' vertical-slice default, and needs a `CLAUDE.md` rule to say so.
