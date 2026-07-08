# Day 1: How do you create a debug-ready kernel lab?

## Problem

A kernel bug report is useless if the lab cannot be recreated. The common symptom is: "it crashed once in QEMU, but nobody knows the exact kernel commit, config, initramfs, boot arguments, or trigger."

## Kernel Mechanism

A debug-ready lab controls four things:

- Kernel image: built from a named commit, not "whatever was in the tree."
- Config: starts from a reproducible base such as `make defconfig`, then records debug options.
- Boot path: QEMU command, initramfs, console, CPU count, memory size, and boot arguments.
- Evidence channel: serial console and persistent logs, because graphical output often loses early boot messages.

Use the day-00 baseline kernel first: Linux `v6.12.95` under `~/src/linux-6.12.95`.

## Problem Analysis

Before debugging the kernel, answer these questions:

- Can another developer build the same `vmlinux` and `bzImage`?
- Does the console always land on `ttyS0`?
- Is the initramfs path named and immutable enough for the test?
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
  -initrd ~/kernel-lab/initramfs.cpio.xz \
  -append "console=ttyS0 rdinit=/init panic=-1" \
  -m 2G -smp 2 -nographic
```

Capture the run:

```sh
script -fec 'qemu-system-x86_64 -kernel arch/x86/boot/bzImage -initrd ~/kernel-lab/initramfs.cpio.xz -append "console=ttyS0 rdinit=/init panic=-1" -m 2G -smp 2 -nographic' qemu-serial.log
```

Exit QEMU from `-nographic` mode by pressing `Ctrl-a` first, releasing `Ctrl`, then pressing `x` by itself.

## Reusable Scripts

Run the manual path once before relying on scripts. After that, the wrappers in `qemu-kernel/` keep the same baseline repeatable:

```sh
cd labs/day-01-debug-ready-kernel-lab/qemu-kernel
cp lab.env.example lab.env
bash build-kernel.sh
bash boot-qemu.sh
```

- `lab.env.example`: records the day-00 kernel tree, initramfs, QEMU command parts, and log path. Copy it to `lab.env`; the local `lab.env` file is ignored by git.
- `build-kernel.sh`: rebuilds `bzImage` and `vmlinux`. Set `CLEAN_TREE=1` in `lab.env` when you want it to run `make mrproper` before `make defconfig`.
- `boot-qemu.sh`: boots the kernel with `-initrd`. Set `SERIAL_LOG` in `lab.env` to capture the serial console with `script`.
- `smoke-test.sh`: syntax-checks the scripts and verifies the missing-kernel error path.

## Resolution

The minimum reusable lab baseline is a filled-in template:

```text
Kernel tree:
Kernel commit:
Config source:
Config changes:
Build command:
Kernel image:
Initramfs image:
QEMU command:
Boot arguments:
Trigger command:
Expected symptom:
Expected evidence file:
```

Do not rely on automation until the manual baseline has been rerun once.

## 1-Hour Output

Fill the template with one real kernel tree and initramfs. The output is complete only when a second run can boot without guessing commit, config, boot arguments, or trigger.

## Evidence Check

The lab note must include:

- `git rev-parse HEAD` output.
- The config source and any debug config deltas.
- Full QEMU command.
- Trigger command.
- Serial log path.
