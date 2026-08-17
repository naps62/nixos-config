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

## Network

`tag=7` puts the guest on the VLAN behind `10.7.10.1`. That VLAN is the
UNTRUSTED zone: internet and DNS are allowed, private networks are denied by
default. Reaching `10.6.10.0/24` or the wireguard clients on `10.10.0.0/24`
needs an OPNsense pass rule on the UNTRUSTED interface, above
"Allow access to the Internet but block access to private networks".
