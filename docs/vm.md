# The test VM

Some things only show in a real boot: the Greeter under greetd and Cage, the KWin Session, power actions. You check those in a test VM. `just vm-create` builds one, `just deploy` puts a development build in it, and `just vm-destroy` throws it away. This page covers all of it. These commands are yours to run, usually in a second terminal while you work.

## Quick reference

| Command | What it does |
|---|---|
| `just vm-create` | Build the VM `modality-dev` at `192.168.122.50`; prints the `export MODALITYOS_VM=…` line |
| `export MODALITYOS_VM=dev@192.168.122.50` | Tell the other commands which VM to use (once per terminal) |
| `just deploy --reboot` | Install the build, make greetd the display manager, reboot into the Greeter |
| `just deploy-watch` | Leave running: sends each saved change to the VM |
| `just sync` | Send changed files once |
| `just vm-user-add <name>` | Add a login user (to try Other users) |
| `just vm-user-remove <name>` | Remove one |
| `just rollback` | Back to the VM's previous login |
| `just vm-snapshot <name> "<description>"` | Save the VM as it is now (it shuts down and starts again) |
| `just vm-snapshots` | List the snapshots, with date and description |
| `just vm-revert <name>` | Put the VM back to a snapshot and boot it; `initial` is the fresh VM |
| `just vm-snapshot-delete <name>` | Delete a snapshot |
| `just vm-destroy` | Throw the VM away |

**Logging in at the Greeter:** user `dev`, password `modality`. Users added with `just vm-user-add` get the same password unless you pass `--password`.

## Install the tools once

On an Arch host:

```sh
sudo pacman -S --needed libvirt virt-manager qemu-full edk2-ovmf dnsmasq
sudo systemctl enable --now libvirtd
sudo usermod -aG libvirt "$USER"
```

Log out and back in, so the `libvirt` group applies. `virsh -c qemu:///system list --all` should then work without `sudo`. Nothing else needs root: the scripts talk to libvirt's system instance (`qemu:///system`) as a member of that group.

You also need an SSH key. By default the VM trusts the first key `ssh-add -L` lists (your SSH agent's first key); pass `--ssh-key FILE.pub` to pick another.

## Create the VM

```sh
just vm-create                        # trusts the first key in ssh-add -L
just vm-create --ssh-key ~/.ssh/id_ed25519.pub
just vm-create --timezone Europe/London   # instead of the host's timezone
just vm-create --password secret          # instead of the Greeter password "modality"
```

It builds a libvirt domain called `modality-dev` and, when it is ready, prints the line to paste:

```sh
export MODALITYOS_VM=dev@192.168.122.50
```

What it builds:

- **The disk:** Arch Linux's official cloud image (from the arch-boxes project), copied and grown to 40 GB, stored as `modality-dev.qcow2` in libvirt's `default` storage pool (usually `/var/lib/libvirt/images`). The first download is cached in `~/.cache/modalityos/vm/` (or `$XDG_CACHE_HOME/modalityos/vm/`), so later builds skip it.
- **The machine:** 16 GB of memory, 8 vCPUs, UEFI firmware without Secure Boot (the cloud image is not signed), a virtio disk, a virtio network card on libvirt's `default` network, and 3D-accelerated virtio graphics (`virtio-vga-gl`) shown through SPICE with `egl-headless`. The Greeter and KWin need that GPU.
- **First boot**, set up by cloud-init (the cloud image's first-boot setup tool): hostname `modality-dev`; the host's timezone, so the Greeter's clock matches yours (from `timedatectl`, else where `/etc/localtime` points, else UTC; `--timezone Area/City` picks another); user `dev` with password `modality` for the Greeter (`--password` picks another; SSH stays key-only), your SSH key and passwordless `sudo`; a full system upgrade (`pacman -Syu`); and `rsync`, which `just deploy` needs. The script waits until all of that is done, which takes a few minutes.

The script refuses to run if `modality-dev` already exists; run `just vm-destroy` first.

### Why it is repeatable

The cloud image is pinned to one dated release, and the script checks it against its SHA256 checksum before using it; a mismatch stops the build. So every build starts from the same bytes. The packages installed on top come from the Arch mirrors on the day you build, since Arch is a rolling release: two builds a month apart start the same but end with that month's packages. That matches what `just deploy` does anyway (it runs `pacman -Syu` too).

To move to a newer image, update `image_release` and `image_sha256` at the top of `tools/vm/create.sh` from a newer `v<date>.<build>` folder on `https://geo.mirror.pkgbuild.com/images/`, after checking that folder's `.SHA256.sig` signature.

### The fixed address

The VM always gets `192.168.122.50`. The script gives the domain a fixed MAC address (`52:54:00:4d:44:50`) and adds a DHCP reservation for it on the `default` network (a line in the network's config telling libvirt's DHCP server to hand that address to that MAC). The address sits inside the network's DHCP range, but a reserved address is never handed to another machine; the script stops if another machine already holds it. Running it again keeps the reservation that is there.

Each new VM has new SSH host keys at the same address, so the scripts drop that address's old line from `~/.ssh/known_hosts`, and the first connection accepts the new key.

## See the screen

Open **virt-manager**, connect to **QEMU/KVM** (the system connection), and double-click `modality-dev`. Before a deploy you see a text login; after one, the Greeter. Or from a terminal:

```sh
virt-manager --connect qemu:///system --show-domain-console modality-dev
```

## Deploy and roll back

With `MODALITYOS_VM` set:

```sh
just deploy             # install the build, make greetd the display manager
just deploy --reboot    # the same, then reboot into the Greeter
just rollback           # back to the previous login
```

[Testing](testing.md#manual-testing-in-the-vm) explains both, and how to roll back from a text console in the VM; a deploy keeps SSH and a console on tty2 enabled for that.

## Users

The VM starts with one user, `dev`, so the Greeter shows no **Other users** pill. Add users to see it and the **Choose a user** panel, and remove them to go back:

```sh
just vm-user-add ada --real-name "Ada Lovelace" --avatar data/avatars/avatar-flower.png
just vm-user-add grace --real-name "Grace Hopper"     # no --avatar: the built-in avatar
just vm-user-add alan --password other                # a different password
just vm-user-remove grace
```

Each user gets a home folder and the password `modality` unless `--password` says otherwise. `--avatar` takes a PNG or JPEG and sets it as the user's AccountsService picture; the four samples in `data/avatars/` work. Adding or removing a user restarts greetd, so the Greeter reads the new list. `dev` can't be removed: the scripts and `just deploy` sign in as it.

## Edit and see it live

Deploy once, then leave a watcher running while you edit:

```sh
just deploy --reboot    # once: packages, greetd, the Greeter
just deploy-watch       # then: sync on every save
```

`just deploy-watch` watches `greeter/`, `qml/Modality/`, `data/` and `session/`, ignoring editor temp files. Half a second after a save it runs `just sync`, which rebuilds the development root, sends only the files that changed (it prints each one) and takes about a second. It needs `watchexec` (`sudo pacman -S watchexec`). Stop it with Ctrl+C.

- **Reloads by itself:** the Greeter's own files (`greeter/`). Quickshell watches them and reloads the Greeter in place, with no restart.
- **Restarts greetd:** everything else Quickshell does not watch: the shared modules (`qml/Modality/`), data (settings, avatars, wallpapers) and the files from `session/` (launchers, Session entries, the tmpfiles rule). The Greeter relaunches in a couple of seconds; a Session started from it can end too.
- **Needs `just deploy`:** the greetd config and the polkit rule, which live outside the development root, and the package list. `just sync` says so when the greetd config or polkit rule differ.

For a one-off, run `just sync`. It refuses until the VM has had a full `just deploy`.

## Snapshots

A snapshot saves the VM's disk under a name, so you can come back to that exact state in under a minute instead of rebuilding. Use them to jump between set-ups: a fresh VM, a deployed one, one with several users.

`just vm-create` takes the first one, `initial`: the fresh VM from the Arch cloud image, with only user `dev` and nothing deployed.

A suggested flow:

```sh
just deploy --reboot
just vm-snapshot deployed "Deployed, one user"
just vm-user-add ada --real-name "Ada Lovelace" --avatar data/avatars/avatar-flower.png
just vm-user-add grace --real-name "Grace Hopper"
just vm-snapshot users-added "Deployed, three users"

just vm-revert deployed       # back to one user
just vm-revert users-added    # and to three again
just vm-revert initial        # the fresh VM, to test a first deploy
just vm-snapshots             # what there is
just vm-snapshot-delete deployed
```

- **Taking one shuts the VM down.** The VM's 3D graphics can't be saved while it runs, so `just vm-snapshot` shuts the VM down cleanly, takes the snapshot and starts it again (about a minute). Anything only in memory, such as an open Session, is not kept; the VM comes back booted fresh at the Greeter, or at a text login before a deploy.
- **Reverting throws away everything since.** `just vm-revert` switches the VM off without asking, puts the disk back and boots it, then waits for SSH. Take a snapshot first if you want to keep where you are.
- **After reverting, deploy again** if your working tree has moved on: the VM holds the build it had when the snapshot was taken. `just sync` works after reverting to any snapshot taken after a full `just deploy`.
- **Names** are letters, digits, `.`, `_` and `-`. Taking a name that exists fails; delete the old one first. `just vm-snapshots` marks the one last taken or reverted to.
- **Where they live:** inside the VM's disk file (libvirt internal snapshots), so they cost disk space for what changed since and go away with `just vm-destroy`.

## Rebuild

To start again from a clean VM:

```sh
just vm-destroy
just vm-create
```

`just vm-destroy` stops and removes the `modality-dev` domain with its snapshots and UEFI variables, deletes its disk and removes its address reservation. It matches only `modality-dev`; other VMs, their disks and their reservations are not touched. The cached image stays, so the rebuild skips the download.

## Troubleshooting

- **`virsh` cannot reach `qemu:///system`:** libvirtd is not running (`sudo systemctl enable --now libvirtd`), or your login does not have the `libvirt` group yet (log out and in; `id` should list it).
- **"network default is not active":** start it with `sudo virsh net-start default`, and `sudo virsh net-autostart default` so it starts at boot. If it does not exist, `sudo virsh net-define /usr/share/libvirt/networks/default.xml` first. libvirt needs `dnsmasq` installed to run it.
- **virt-install fails with `No module named 'gi'`:** a Python from a version manager (pyenv, mise) is first on your `PATH`. The script already runs virt-install against `/usr/bin/python3`; if you call virt-install yourself, do the same.
- **No SSH after 10 minutes:** open the console in virt-manager to see where boot stopped. If it reached a login prompt, check the address: `virsh -c qemu:///system domifaddr modality-dev --source arp`.
- **SSH asks for a password, or says "Permission denied (publickey)":** the VM trusts only the key it was built with. Check which one that was (`--ssh-key`, or the first in `ssh-add -L`), and that your agent offers it. To change keys, rebuild.
- **cloud-init failed:** SSH in and run `sudo cloud-init status --long` and `sudo journalctl -u cloud-final`. A failed `pacman -Syu` (a mirror down) is the usual cause; rebuild.
- **The VM already exists:** `just vm-destroy`, then `just vm-create`.
- **The VM powers off instead of rebooting:** virt-install runs a VM's first boot as an install, where a reboot means power off. `just vm-create` power-cycles the VM once at the end to leave that mode, and checks it worked. A VM built before that step will power off on its first reboot only: start it again in virt-manager (or `virsh -c qemu:///system start modality-dev`) and it reboots normally from then on.
- **No `initial` snapshot:** the VM was built before `just vm-create` took one. The other snapshot commands work on it as it is; to get `initial`, rebuild with `just vm-destroy && just vm-create`.
- **`just vm-snapshot` says the VM did not shut down:** something in it is holding up shutdown. Open the console in virt-manager to see what, or shut it down there, then take the snapshot again; it is taken from a shut-off VM without starting it.
