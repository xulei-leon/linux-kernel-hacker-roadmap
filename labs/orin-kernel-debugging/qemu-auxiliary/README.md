# QEMU Auxiliary Environment

**Primary platform:** QEMU

**QEMU alternative:** Not applicable

**Safety level:** S0

The roadmap's primary target is the Jetson Orin Nano Super. Complete this lab
before any destructive,
> virtualization-dependent, GDB-stub, or automated-bisection exercise.

## Goal

Build one reproducible x86_64 Linux kernel under WSL2 Ubuntu, boot it once in
QEMU, and record the paths that later QEMU labs need.

This retained bootstrap uses x86_64 because that is the verified environment
available in the repository. It teaches generic build, boot, symbol, initramfs,
and automation skills. The QEMU debugging guide may add a separately verified
ARM64 `virt` variant; this x86_64 result must not be presented as ARM64 or
Tegra evidence.

The output of this lab is:

```text
KERNEL_TREE=/home/xl/src/linux-6.12.95
kernel_version=6.12.95
kernel_commit=296aabce459470a4c1b68ffd0c0c0920e563aaad
kernel_image=/home/xl/src/linux-6.12.95/arch/x86/boot/bzImage
vmlinux=/home/xl/src/linux-6.12.95/vmlinux
initramfs=/home/xl/kernel-lab/initramfs.cpio.xz
qemu_command=qemu-system-x86_64 -kernel /home/xl/src/linux-6.12.95/arch/x86/boot/bzImage -initrd /home/xl/kernel-lab/initramfs.cpio.xz -append "console=ttyS0 rdinit=/init panic=-1" -m 2G -smp 2 -nographic
```

## Host Environment

This lab assumes Windows with WSL2 Ubuntu. It creates a disposable VM for
experiments that should not run on the primary Orin installation; it is not the
Jetson BSP build environment.

Keep the kernel tree under the WSL2 Linux filesystem, such as `~/src/linux-6.12.95`. Do not build under `/mnt/c/...`; kernel builds create many small files and are much slower on the Windows-mounted filesystem.

KVM acceleration may not be available in WSL2. The QEMU command below intentionally does not use `-enable-kvm`; it may boot slowly, but it should work in a plain terminal.

Serial logging through `SERIAL_LOG` requires the util-linux implementation of
`script`; verify it with `script --version` before relying on the captured log.

## Step 1: Install WSL2 Ubuntu dependencies

```sh
sudo apt update
sudo apt install git build-essential flex bison libssl-dev libelf-dev bc dwarves qemu-system-x86 cpio rsync xz-utils busybox-static wget ca-certificates
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

The fixed version for this lab is `v6.12.95`.

Method A uses Git and is recommended:

```sh
mkdir -p ~/src ~/kernel-lab
cd ~/src
KERNEL_VERSION=v6.12.95
git clone --depth=1 --single-branch --branch "$KERNEL_VERSION" \
  https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git \
  linux-6.12.95
cd linux-6.12.95
```

If Git HTTPS/TLS fails or the network is unstable, remove the partial checkout and retry with HTTP/1.1:

```sh
cd ~/src
rm -rf linux-6.12.95
KERNEL_VERSION=v6.12.95
git -c http.version=HTTP/1.1 clone --depth=1 --single-branch \
  --branch "$KERNEL_VERSION" \
  https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git \
  linux-6.12.95
cd linux-6.12.95
```

If you are in mainland China, the BFSU mirror is usually faster. Use it as a backup source with the same fixed tag:

```sh
cd ~/src
rm -rf linux-6.12.95
git clone \
  --depth=1 \
  --single-branch \
  --branch v6.12.95 \
  https://mirrors.bfsu.edu.cn/git/linux-stable.git \
  linux-6.12.95
cd linux-6.12.95
```

Method B downloads the release tarball. Use it when Git access is slow or blocked and you only need this fixed version:

```sh
mkdir -p ~/src ~/kernel-lab
cd ~/src
wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.12.95.tar.xz
tar -xf linux-6.12.95.tar.xz
cd linux-6.12.95
```

The tarball method is simpler, but it does not provide Git history, tag switching, or `git rev-parse HEAD`.

## Step 3: Verify the fixed kernel version

Confirm that the tree is on the exact tag used by this lab:

```sh
$ make kernelversion
6.12.95

$ git describe --tags --exact-match 2>/dev/null || true
v6.12.95

$ git rev-parse HEAD 2>/dev/null || true
296aabce459470a4c1b68ffd0c0c0920e563aaad
```

Expected kernel version: `6.12.95`.

If you used Git, record both the tag and commit hash. If you used the tarball, record `linux-6.12.95.tar.xz` as the source. Later debugging notes should never say only "latest kernel."

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
$ grep -E 'CONFIG_DEBUG_INFO|CONFIG_KALLSYMS' .config
CONFIG_KALLSYMS=y
# CONFIG_KALLSYMS_SELFTEST is not set
CONFIG_KALLSYMS_ALL=y
CONFIG_KALLSYMS_ABSOLUTE_PERCPU=y
CONFIG_DEBUG_INFO=y
# CONFIG_DEBUG_INFO_NONE is not set
CONFIG_DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT=y
# CONFIG_DEBUG_INFO_DWARF4 is not set
# CONFIG_DEBUG_INFO_DWARF5 is not set
# CONFIG_DEBUG_INFO_REDUCED is not set
CONFIG_DEBUG_INFO_COMPRESSED_NONE=y
# CONFIG_DEBUG_INFO_COMPRESSED_ZLIB is not set
# CONFIG_DEBUG_INFO_COMPRESSED_ZSTD is not set
# CONFIG_DEBUG_INFO_SPLIT is not set
```

## Step 5: Build bzImage and vmlinux

```sh
make -j"$(nproc)" bzImage vmlinux
```

Check the build artifacts:

```sh
$ ls -lh arch/x86/boot/bzImage vmlinux
-rw-r--r-- 1 xl xl  13M Jul  8 10:28 arch/x86/boot/bzImage
-rwxr-xr-x 1 xl xl 371M Jul  8 10:28 vmlinux
```

## Step 6: Prepare a BusyBox initramfs

Create a minimal BusyBox initramfs. This is enough to prove that QEMU can load your kernel and reach a shell:

```sh
mkdir -p ~/kernel-lab/initramfs/{bin,dev,proc,sys}
cp /bin/busybox ~/kernel-lab/initramfs/bin/
for applet in sh mount cat uname ls dmesg grep; do
  ln -sf busybox ~/kernel-lab/initramfs/bin/"$applet"
done
cat > ~/kernel-lab/initramfs/init <<'EOF'
#!/bin/sh
mount -t devtmpfs devtmpfs /dev 2>/dev/null || true
mount -t proc proc /proc
mount -t sysfs sysfs /sys
echo "booted debug-ready kernel"
exec /bin/sh
EOF
chmod +x ~/kernel-lab/initramfs/init
cd ~/kernel-lab/initramfs
find . -print0 | cpio --null -ov --format=newc | xz -9 --check=crc32 > ~/kernel-lab/initramfs.cpio.xz
test -r ~/kernel-lab/initramfs.cpio.xz && echo "initramfs is readable: ~/kernel-lab/initramfs.cpio.xz"
```

The symlinks matter. BusyBox provides many commands through one binary, but a
minimal initramfs still needs command names such as `mount`, `cat`, and `uname`
to resolve to `/bin/busybox`. Without those links, `/init` can reach a shell but
print errors such as `mount: not found`, and checks like `cat /proc/cmdline`
will fail.

## Step 7: Boot the kernel once with QEMU

```sh
cd ~/src/linux-6.12.95
qemu-system-x86_64 \
  -kernel arch/x86/boot/bzImage \
  -initrd ~/kernel-lab/initramfs.cpio.xz \
  -append "console=ttyS0 rdinit=/init panic=-1" \
  -m 2G -smp 2 -nographic
```

Expected result: the serial console prints kernel boot logs and reaches a BusyBox shell.

```sh
BusyBox v1.36.1 (Ubuntu 1:1.36.1-6ubuntu3.1) built-in shell (ash)
Enter 'help' for a list of built-in commands.

sh: can't access tty; job control turned off

~ # uname -a
Linux (none) 6.12.95 #1 SMP PREEMPT_DYNAMIC Wed Jul  8 10:27:07 CST 2026 x86_64 GNU/Linux

~ # cat /proc/cmdline
console=ttyS0 rdinit=/init panic=-1
```

Exit QEMU from `-nographic` mode with:

```text
Ctrl-a x

~ # QEMU: Terminated
```

Press `Ctrl-a` first, release `Ctrl`, then press `x` by itself. Do not press `Ctrl-a-x` all at once.

## Step 8: Record the baseline for later QEMU labs

Save these values in your lab note:

```sh
cd ~/src/linux-6.12.95
printf 'KERNEL_TREE=%s\n' "$HOME/src/linux-6.12.95"
printf 'kernel_version=%s\n' "$(make -s kernelversion)"
printf 'kernel_commit=%s\n' "$(git rev-parse HEAD 2>/dev/null || echo tarball-source)"
printf 'kernel_image=%s\n' "$HOME/src/linux-6.12.95/arch/x86/boot/bzImage"
printf 'vmlinux=%s\n' "$HOME/src/linux-6.12.95/vmlinux"
printf 'initramfs=%s\n' "$HOME/kernel-lab/initramfs.cpio.xz"
printf 'qemu_command=%s\n' "qemu-system-x86_64 -kernel $HOME/src/linux-6.12.95/arch/x86/boot/bzImage -initrd $HOME/kernel-lab/initramfs.cpio.xz -append \"console=ttyS0 rdinit=/init panic=-1\" -m 2G -smp 2 -nographic"
```

Example output from one verification run follows. Replace its user path, commit,
and build timestamp with values captured from your own environment:

```text
KERNEL_TREE=/home/xl/src/linux-6.12.95
kernel_version=6.12.95
kernel_commit=296aabce459470a4c1b68ffd0c0c0920e563aaad
kernel_image=/home/xl/src/linux-6.12.95/arch/x86/boot/bzImage
vmlinux=/home/xl/src/linux-6.12.95/vmlinux
initramfs=/home/xl/kernel-lab/initramfs.cpio.xz
qemu_command=qemu-system-x86_64 -kernel /home/xl/src/linux-6.12.95/arch/x86/boot/bzImage -initrd /home/xl/kernel-lab/initramfs.cpio.xz -append "console=ttyS0 rdinit=/init panic=-1" -m 2G -smp 2 -nographic
```

## Step 9: Use the reusable QEMU wrappers

After the manual build and boot work once, configure the wrappers owned by this
lab:

```sh
cd labs/orin-kernel-debugging/qemu-auxiliary/qemu-kernel
cp lab.env.example lab.env
```

Edit `lab.env` so `KERNEL_TREE`, `INITRAMFS_IMAGE`, and the optional
`ROOTFS_IMAGE` point to local artifacts. Then run:

```sh
bash build-kernel.sh
bash boot-qemu.sh
bash smoke-test.sh
```

The smoke test checks script syntax and a missing-input failure path. It does
not prove that QEMU booted the kernel.

## Completion Check

This lab is complete when you can answer all of these without guessing:

- Which WSL2 Ubuntu environment built the kernel?
- Which kernel version and source method were used?
- Where is `arch/x86/boot/bzImage`?
- Where is `vmlinux`?
- Which initramfs booted?
- What exact QEMU command reached a serial console?
- Where is the reusable QEMU `lab.env` used by later QEMU labs?
