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
  --onboot 1
```

After creating the disk, drop its ZFS reservation — the `data` pool has no
`sparse` flag, so a 400G zvol otherwise reserves all 400G up front:

```
zfs set refreservation=none data/vm-132-disk-1
```

## The three that matter

**`--vga virtio-gl`.** Not for speed — the host's virglrenderer falls back to
llvmpipe either way. It is what lets mesa allocate GBM buffers. With plain
`virtio` every capture fails with `Failed to create GBM buffer`, and sunshine
streams a black picture while reporting no error at all.

**`--serial0 socket`.** `virtio-gl` renders through a GL context with no QEMU
console surface, so the Proxmox noVNC console and `qm screendump` both go dark.
This plus `boot.kernelParams = [ "console=ttyS0,115200" ]` keeps
`qm terminal 132` working as the only out-of-band way in.

**`--bios ovmf`.** `hosts/common/features/user.nix` uses systemd-boot, which
needs UEFI. SeaBIOS gives an unbootable disk.

## Known limit: no GPU acceleration

The guest reports `virgl (LLVMPIPE)`, so compositing and capture readback are
both on CPU. Hyprland delivers ~2fps at 2560x1440, sunshine asks for 60, and
moonlight disconnects. Capture and encoding are otherwise fine — x264 manages
1440p at 3x realtime here.

The host can do better: `iris_dri.so` is present and `i915` is loaded on
renderD128 (the UHD 770; renderD129 is the nvidia card, reserved for LXCs and
not available to VMs). Two things stop it being used:

- pve 8.4.1 hardcodes `-display egl-headless,gl=core` in
  `/usr/share/perl5/PVE/QemuServer.pm` with no `rendernode=`, so qemu picks the
  EGL device itself.
- `/usr/share/glvnd/egl_vendor.d/` lists `10_nvidia.json` ahead of
  `50_mesa.json`, and lower wins — so EGL initialises against nvidia and falls
  back to llvmpipe.

Adding `,rendernode=/dev/dri/renderD128` to that line targets the iGPU. It is
reverted by any pve-manager upgrade.

## Network

`tag=7` puts the guest on the VLAN behind `10.7.10.1`. That VLAN is the
UNTRUSTED zone: internet and DNS are allowed, private networks are denied by
default. Reaching `10.6.10.0/24` or the wireguard clients on `10.10.0.0/24`
needs an OPNsense pass rule on the UNTRUSTED interface, above
"Allow access to the Internet but block access to private networks".
