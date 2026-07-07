# Day 1: How do you create a debug-ready kernel lab?

## Problem

A kernel bug report is useless if the lab cannot be recreated. The common symptom is: "it crashed once in QEMU, but nobody knows the exact kernel commit, config, rootfs, boot arguments, or trigger."

## Kernel Mechanism

A debug-ready lab controls four things:

- Kernel image: built from a named commit, not "whatever was in the tree."
- Config: starts from a reproducible base such as `make defconfig`, then records debug options.
- Boot path: QEMU command, root device, console, CPU count, memory size, and boot arguments.
- Evidence channel: serial console and persistent logs, because graphical output often loses early boot messages.

Use a recent mainline or stable v6.x kernel unless the bug is version-specific.

## Problem Analysis

Before debugging the kernel, answer these questions:

- Can another developer build the same `vmlinux` and `bzImage`?
- Does the console always land on `ttyS0`?
- Is the rootfs named and immutable enough for the test?
- Is the trigger command recorded with expected output?
- Are debug symbols available for stack decoding?

If any answer is missing, stop and fix the lab first. Otherwise later traces cannot be compared.

## Debug Path

Record this command set in the lab note:

```sh
git rev-parse HEAD
make mrproper
make defconfig
scripts/config --enable DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT
scripts/config --enable KALLSYMS
scripts/config --enable KALLSYMS_ALL
make olddefconfig
make -j"$(nproc)" bzImage vmlinux
```

Boot with a serial console:

```sh
qemu-system-x86_64 \
  -kernel arch/x86/boot/bzImage \
  -append "console=ttyS0 root=/dev/vda rw panic=-1" \
  -drive file=rootfs.ext4,format=raw,if=virtio \
  -m 2G -smp 2 -nographic
```

Capture the run:

```sh
script -fec 'qemu-system-x86_64 ... -nographic' qemu-serial.log
```

## Resolution

The minimum reusable lab baseline is a filled-in template:

```text
Kernel tree:
Kernel commit:
Config source:
Config changes:
Build command:
Kernel image:
Rootfs image:
QEMU command:
Boot arguments:
Trigger command:
Expected symptom:
Expected evidence file:
```

Do not add automation until the manual baseline has been rerun once.

## 1-Hour Output

Fill the template with one real kernel tree and rootfs. The output is complete only when a second run can boot without guessing commit, config, boot arguments, or trigger.

## Evidence Check

The lab note must include:

- `git rev-parse HEAD` output.
- The config source and any debug config deltas.
- Full QEMU command.
- Trigger command.
- Serial log path.

