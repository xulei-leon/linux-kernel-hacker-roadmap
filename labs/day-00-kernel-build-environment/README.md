# Day 0: How do you set up a WSL2 Ubuntu kernel build lab?

## Goal

Build one reproducible Linux kernel under WSL2 Ubuntu, boot it once in QEMU, and record the paths that later labs need.

The output of this lab is:

```text
KERNEL_TREE=$HOME/src/linux
Kernel tag: v6.6.144
Kernel commit:
Kernel image: $HOME/src/linux/arch/x86/boot/bzImage
vmlinux: $HOME/src/linux/vmlinux
ROOTFS_IMAGE:
QEMU command:
```

## Host Environment

This lab assumes Windows with WSL2 Ubuntu.

Keep the kernel tree under the WSL2 Linux filesystem, such as `~/src/linux`. Do not build under `/mnt/c/...`; kernel builds create many small files and are much slower on the Windows-mounted filesystem.

KVM acceleration may not be available in WSL2. The QEMU command below intentionally does not use `-enable-kvm`; it may boot slowly, but it should work in a plain terminal.

## Step 1: Install WSL2 Ubuntu dependencies

```sh
sudo apt update
sudo apt install git build-essential flex bison libssl-dev libelf-dev bc dwarves qemu-system-x86 cpio rsync xz-utils busybox-static
```

Check the tools:

```sh
$ git --version
git version 2.43.0

$ make --version
GNU Make 4.3
Built for x86_64-pc-linux-gnu
Copyright (C) 1988-2020 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

$ qemu-system-x86_64 --version
QEMU emulator version 8.2.2 (Debian 1:8.2.2+ds-0ubuntu1.17)
Copyright (c) 2003-2023 Fabrice Bellard and the QEMU Project developers
```

## Step 2: Download the Linux kernel source

```sh
mkdir -p ~/src ~/kernel-lab
KERNEL_VERSION=v6.6.144
git clone --branch "$KERNEL_VERSION" --single-branch \
  https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git ~/src/linux
cd ~/src/linux
```

If you already cloned the tree, fetch and check out the same fixed tag:

```sh
cd ~/src/linux
KERNEL_VERSION=v6.6.144
git fetch origin "refs/tags/$KERNEL_VERSION:refs/tags/$KERNEL_VERSION"
git checkout "$KERNEL_VERSION"
```

## Step 3: Verify the fixed kernel version

Confirm that the tree is on the exact tag used by this lab:

```sh
git describe --tags --exact-match
git rev-parse HEAD
```

Expected tag: `v6.6.144`.

Record both the tag and commit hash. Later debugging notes should never say only "latest kernel."

## Step 4: Configure a debug-capable kernel

Start from the default x86_64 config and enable the minimum symbol information used by the debugging labs:

```sh
make defconfig
scripts/config --enable DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT
scripts/config --enable KALLSYMS
scripts/config --enable KALLSYMS_ALL
make olddefconfig
```

Check that the expected options are present:

```sh
grep -E 'CONFIG_DEBUG_INFO|CONFIG_KALLSYMS' .config
```

## Step 5: Build bzImage and vmlinux

```sh
make -j"$(nproc)" bzImage vmlinux
```

Check the build artifacts:

```sh
test -r arch/x86/boot/bzImage
test -r vmlinux
ls -lh arch/x86/boot/bzImage vmlinux
```

## Step 6: Prepare or select a rootfs image

If you already have a bootable ext4 rootfs, copy or record its path:

```sh
ROOTFS_IMAGE="$HOME/kernel-lab/rootfs.ext4"
test -r "$ROOTFS_IMAGE"
```

If you do not have one yet, create a minimal BusyBox initramfs so this lab can still prove the kernel boots:

```sh
mkdir -p ~/kernel-lab/initramfs/{bin,dev,proc,sys}
cp /bin/busybox ~/kernel-lab/initramfs/bin/
ln -sf busybox ~/kernel-lab/initramfs/bin/sh
cat > ~/kernel-lab/initramfs/init <<'EOF'
#!/bin/sh
mount -t devtmpfs none /dev 2>/dev/null || true
mount -t proc none /proc
mount -t sysfs none /sys
echo "booted debug-ready kernel"
exec /bin/busybox sh
EOF
chmod +x ~/kernel-lab/initramfs/init
cd ~/kernel-lab/initramfs
find . -print0 | cpio --null -ov --format=newc | xz -9 --check=crc32 > ~/kernel-lab/initramfs.cpio.xz
```

Use the ext4 rootfs for day-01 if you have one. Use the initramfs only as the smallest WSL2-friendly boot check.

## Step 7: Boot the kernel once with QEMU

For an ext4 rootfs:

```sh
cd ~/src/linux
qemu-system-x86_64 \
  -kernel arch/x86/boot/bzImage \
  -append "console=ttyS0 root=/dev/vda rw panic=-1" \
  -drive file="$ROOTFS_IMAGE",format=raw,if=virtio \
  -m 2G -smp 2 -nographic
```

For the minimal initramfs:

```sh
cd ~/src/linux
qemu-system-x86_64 \
  -kernel arch/x86/boot/bzImage \
  -initrd ~/kernel-lab/initramfs.cpio.xz \
  -append "console=ttyS0 rdinit=/init panic=-1" \
  -m 2G -smp 2 -nographic
```

Expected result: the serial console prints kernel boot logs and eventually reaches either the rootfs login prompt or a BusyBox shell.

Exit QEMU from `-nographic` mode with:

```text
Ctrl-a x
```

## Step 8: Record the baseline for day-01

Save these values in your lab note:

```sh
cd ~/src/linux
printf 'KERNEL_TREE=%s\n' "$HOME/src/linux"
printf 'kernel_commit=%s\n' "$(git rev-parse HEAD)"
printf 'kernel_image=%s\n' "$HOME/src/linux/arch/x86/boot/bzImage"
printf 'vmlinux=%s\n' "$HOME/src/linux/vmlinux"
printf 'rootfs_image=%s\n' "${ROOTFS_IMAGE:-not set; initramfs was used for boot check}"
```

If you have an ext4 rootfs, run this from the roadmap repository root and copy the values into `labs/day-01-debug-ready-kernel-lab/qemu-kernel/lab.env`:

```sh
cp labs/day-01-debug-ready-kernel-lab/qemu-kernel/lab.env.example \
  labs/day-01-debug-ready-kernel-lab/qemu-kernel/lab.env
```

Then edit:

```text
KERNEL_TREE="$HOME/src/linux"
ROOTFS_IMAGE="$HOME/kernel-lab/rootfs.ext4"
```

## Completion Check

This lab is complete when you can answer all of these without guessing:

- Which WSL2 Ubuntu environment built the kernel?
- Which kernel tag or commit was checked out?
- Where is `arch/x86/boot/bzImage`?
- Where is `vmlinux`?
- Which rootfs or initramfs booted?
- What exact QEMU command reached a serial console?
