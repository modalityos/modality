# Development installs mirror the production prefix

A development build installs into a dev root (`/opt/modalityos-dev` in the test VM) laid out exactly like the production prefix `/usr`, and code finds its files through one variable, `MODALITYOS_PREFIX`, defaulting to `/usr`. One install step serves both the PKGBUILD and the dev sync, so dev and production run the same code against the same relative layout, and removing the dev root undoes a dev install completely.

## Considered Options

- A dev-only layout (e.g. `shell/` at the dev root's top level): rejected, because every path would need two mappings.
- Symlinks into `/usr`: rejected, because they modify the installed system and go stale.
- systemd-sysext overlays: kept as a later option for testing real install paths.
