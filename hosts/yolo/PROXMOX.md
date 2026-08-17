# yolo — Proxmox VM settings

Hypervisor-side configuration for VM 132. Nix cannot express any of it, and
three of these are load-bearing in ways that fail silently if changed.

```
qm create 132 --name yolo \
  --cores 8 --sockets 1 --cpu host \
  --memory 16384 \
  --machine q35 \
  --bios ovmf \
  --ostype l26 \
  --scsihw virtio-scsi-single \
  --scsi0 data:400,discard=on,iothread=1,ssd=1 \
  --efidisk0 data:1,efitype=4m,pre-enrolled-keys=0 \
  --net0 virtio,bridge=vmbr0,tag=7,firewall=1 \
  --vga virtio-gl \
  --serial0 socket \
  --agent 1 \
  --onboot 1 \
  --args '-display egl-headless,gl=core,rendernode=/dev/dri/renderD128'
```

After creating the disk, drop its ZFS reservation — the `data` pool has no
`sparse` flag, so a 400G zvol otherwise reserves all 400G up front:

```
zfs set refreservation=none data/vm-132-disk-1
```

## The four that matter

**`--vga virtio-gl`.** Lets mesa allocate GBM buffers. With plain `virtio`
every capture fails with `Failed to create GBM buffer`, and sunshine streams a
black picture while reporting no error at all.

**`--args '-display egl-headless,...,rendernode=/dev/dri/renderD128'`.** Pins
host-side rendering to the UHD 770. Without it the guest renders on llvmpipe —
see below.

**`--serial0 socket`.** `virtio-gl` renders through a GL context with no QEMU
console surface, so the Proxmox noVNC console and `qm screendump` both go dark.
This plus `boot.kernelParams = [ "console=ttyS0,115200" ]` keeps
`qm terminal 132` working as the only out-of-band way in.

**`--bios ovmf`.** `hosts/common/features/user.nix` uses systemd-boot, which
needs UEFI. SeaBIOS gives an unbootable disk.

## Why the render node has to be pinned

pve 8.4.1 hardcodes `-display egl-headless,gl=core` in
`/usr/share/perl5/PVE/QemuServer.pm` with no `rendernode=`. qemu then picks a
node itself by scanning `/dev/dri` in `readdir` order and taking the first
`renderD*` that opens. Here that lands on renderD129 — the nvidia card, which
is reserved for LXCs. mesa cannot drive it, so virglrenderer falls back to
software and the guest reports `virgl (LLVMPIPE)`: Hyprland manages ~2fps at
2560x1440 while sunshine asks for 60, and moonlight disconnects.

The `--args` line overrides this. PVE appends `args` after its own `-display`,
and qemu's last `-display` wins, so rendering is pinned to renderD128 (the UHD
770, `i915`) without touching the packaged perl — which any pve-manager upgrade
would revert. Confirm from the guest:

```
grep "Renderer:" /run/user/1000/hypr/*/hyprland.log
```

`virgl (Mesa Intel(R) Graphics (RPL-S))` is correct; `LLVMPIPE` means the
override is not taking. On the host, `ls -l /proc/$(cat
/var/run/qemu-server/132.pid)/fd | grep dri` shows which node qemu actually
holds.

Forcing the EGL vendor instead (`__EGL_VENDOR_LIBRARY_FILENAMES=.../50_mesa.json`)
does not help and was tried: the vendor was never the problem, the node was.

Encoding stays on x264. virgl accelerates GL only — the guest sees a
virtio-gpu, not the Intel device, so there is no VAAPI/QuickSync encode path.
Not a bottleneck: x264 manages 1440p at 3x realtime here.

## Network

`tag=7` puts the guest on the VLAN behind `10.7.10.1`. That VLAN is the
UNTRUSTED zone: internet and DNS are allowed, private networks are denied by
default. Reaching `10.6.10.0/24` or the wireguard clients on `10.10.0.0/24`
needs an OPNsense pass rule on the UNTRUSTED interface, above
"Allow access to the Internet but block access to private networks".
