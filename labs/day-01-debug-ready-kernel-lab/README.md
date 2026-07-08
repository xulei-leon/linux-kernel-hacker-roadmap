# Day 1: How do you prepare a debug-ready kernel lab?

## Goal

Turn the day-00 kernel build into a repeatable debugging lab. The purpose is to make sure later crash, trace, and
performance labs can be rebuilt and rerun without guessing the kernel commit,
config, initramfs, boot arguments, or evidence file.

At the end of this lab, you should have:

```text
Kernel tree:
Kernel commit or source archive:
Config source:
Debug config changes:
Kernel image:
vmlinux:
Initramfs image:
QEMU command:
Serial log path:
How to rerun:
```

## Prerequisites

Complete `labs/day-00-kernel-build-environment/README.md` first.

This lab assumes:

- Linux `v6.12.95` is available under `~/src/linux-6.12.95`.
- A minimal initramfs exists at `~/kernel-lab/initramfs.cpio.xz`.
- `qemu-system-x86_64` can boot the day-00 kernel with `-nographic`.
- You are working in WSL2 Ubuntu or another Linux shell with the same tools.

Keep the kernel tree on the Linux filesystem, not under `/mnt/c/...`, because
kernel builds create many small files.

## Step 1: Check the baseline inputs

Start by confirming the exact tree and boot image that later labs will use:

```sh
cd ~/src/linux-6.12.95
make -s kernelversion
git rev-parse HEAD 2>/dev/null || echo tarball-source
test -r arch/x86/boot/bzImage && echo "bzImage is readable"
test -r vmlinux && echo "vmlinux is readable"
test -r ~/kernel-lab/initramfs.cpio.xz && echo "initramfs is readable"
```

Expected kernel version:

```text
6.12.95
```

If `git rev-parse HEAD` fails because you used the release tarball, record the
tarball name instead, such as `linux-6.12.95.tar.xz`. Do not write only
"latest kernel" in lab notes.

## Step 2: Configure the kernel for debugging

Rebuild from a known config source. For this lab, use x86_64 `defconfig` plus
debug symbols and full kallsyms:

```sh
cd ~/src/linux-6.12.95
make defconfig
scripts/config --enable DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT
scripts/config --enable KALLSYMS
scripts/config --enable KALLSYMS_ALL
make olddefconfig
```

Check the options that matter for early debugging:

```sh
~/src/linux-6.12.95$ grep -E 'CONFIG_DEBUG_INFO|CONFIG_KALLSYMS' .config
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

Why these options matter:

- `CONFIG_DEBUG_INFO` keeps source-level information in `vmlinux`.
- `CONFIG_KALLSYMS` makes kernel symbols visible in stack traces.
- `CONFIG_KALLSYMS_ALL` keeps more symbols available for decoding addresses.

## Step 3: Build the kernel artifacts

Build both the bootable image and the uncompressed symbol file:

```sh
make -j"$(nproc)" bzImage vmlinux
```

Verify the files before booting:

```sh
ls -lh arch/x86/boot/bzImage vmlinux
file arch/x86/boot/bzImage vmlinux
```

Later debugging commands usually need `vmlinux`, even when QEMU boots
`arch/x86/boot/bzImage`.

## Step 4: Boot once by hand

Run QEMU manually before relying on wrappers:

```sh
qemu-system-x86_64 \
  -kernel arch/x86/boot/bzImage \
  -initrd ~/kernel-lab/initramfs.cpio.xz \
  -append "console=ttyS0 rdinit=/init panic=-1" \
  -m 2G -smp 2 -nographic
```

Expected result: the serial console prints kernel boot messages and reaches the
BusyBox shell from the initramfs.

Useful checks inside the guest:

```sh
~ # uname -a
Linux (none) 6.12.95 #2 SMP PREEMPT_DYNAMIC Wed Jul  8 23:49:27 CST 2026 x86_64 GNU/Linux

~ # cat /proc/cmdline
console=ttyS0 rdinit=/init panic=-1
```
Exit QEMU from `-nographic` mode by pressing `Ctrl-a`, releasing `Ctrl`, then
pressing `x` by itself.

## Step 5: Capture a serial log

Rerun the same QEMU command through `script` so the boot evidence survives after
the terminal closes:

```sh
script -fec 'qemu-system-x86_64 -kernel arch/x86/boot/bzImage -initrd ~/kernel-lab/initramfs.cpio.xz -append "console=ttyS0 rdinit=/init panic=-1" -m 2G -smp 2 -nographic' qemu-serial.log
```

After exiting QEMU, check that the log exists and contains boot output:

```sh
test -s qemu-serial.log && echo "serial log captured"
grep -m1 'Linux version' qemu-serial.log
```

```text
[    0.000000] Linux version 6.12.95 (xxx) (gcc (Ubuntu 13.3.0-6ubuntu2~24.04.1) 13.3.0, GNU ld (GNU Binutils for Ubuntu) 2.46
```

This log is the minimum evidence channel for later labs. Graphical QEMU output
is not enough because early boot messages can disappear.

## Step 6: Write the lab note

Record one concrete run:

```text
Kernel tree:
Kernel version:
Kernel commit or source archive:
Config source:
Debug config changes:
Build command:
Kernel image:
vmlinux:
Initramfs image:
QEMU command:
Boot arguments:
Serial log path:
Expected boot result:
How to exit QEMU:
```

Fill it with real paths and command output. The note is incomplete if another
developer cannot rebuild the same kernel and rerun the same QEMU command.

## Step 7: Use the reusable wrappers

After the manual path works once, use the scripts in `qemu-kernel/` to avoid
typing long commands by hand:

```sh
cd labs/day-01-debug-ready-kernel-lab/qemu-kernel
cp lab.env.example lab.env
```

Edit `lab.env` and check these values:

```sh
KERNEL_TREE="$HOME/src/linux-6.12.95"
INITRAMFS_IMAGE="$HOME/kernel-lab/initramfs.cpio.xz"
KERNEL_APPEND="console=ttyS0 rdinit=/init panic=-1"
SERIAL_LOG="$PWD/qemu-serial.log"
```

Build and boot through the wrappers:

```sh
bash build-kernel.sh
bash boot-qemu.sh
```

Script roles:

- `lab.env.example` documents the expected local paths and QEMU settings.
- `build-kernel.sh` runs the same debug config and builds `bzImage vmlinux`.
- `boot-qemu.sh` boots the kernel with `-initrd` and captures `SERIAL_LOG` when
  that variable is set.
- `smoke-test.sh` checks script syntax and the missing-kernel error path.

Run the smoke test after editing scripts, not as proof that the kernel boots:

```sh
bash smoke-test.sh
```

## Completion Check

This lab is complete when all of these are true:

- You can name the exact kernel version and commit or source archive.
- `arch/x86/boot/bzImage` and `vmlinux` both exist and are readable.
- QEMU reaches the initramfs shell with `console=ttyS0 rdinit=/init panic=-1`.
- A serial log file captures the boot.
- The manual QEMU command and the `qemu-kernel/` wrapper path both work.
- The lab note contains enough detail for a second run without guessing.

Stop here before starting real bug analysis. If the lab is not reproducible,
later stack traces, ftrace output, sanitizer reports, or performance numbers
will be hard to compare.
