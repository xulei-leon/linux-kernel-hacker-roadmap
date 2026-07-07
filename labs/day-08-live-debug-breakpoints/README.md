# Day 8: How do you stop a kernel at the failure site?

## Problem

The failure happens after a specific function is entered, but logs are too late or too noisy. The symptom is a reproducible bug where inspecting arguments before the crash would decide the next step.

## Kernel Mechanism

QEMU can start a guest paused and expose a GDB stub with `-s -S`. GDB then connects to the guest and uses the matching `vmlinux` for symbols. Kgdb provides live kernel debugging on real or virtual targets, often through `kgdboc`.

Live debugging changes timing. It is good for deterministic setup bugs and poor for races unless the breakpoint is carefully chosen.

## Problem Analysis

Define the breakpoint before starting:

- Which function is the first suspicious boundary?
- Which arguments or fields decide whether the state is bad?
- Can the system stop there without breaking watchdog expectations?
- Is the bug timing-sensitive?

If the bug is a race, prefer tracing first and use live debugging only after the state boundary is known.

## Debug Path

Start QEMU stopped:

```sh
qemu-system-x86_64 \
  -kernel arch/x86/boot/bzImage \
  -append "console=ttyS0 root=/dev/vda rw" \
  -drive file=rootfs.ext4,format=raw,if=virtio \
  -m 2G -smp 2 -nographic -s -S
```

Connect GDB:

```sh
gdb vmlinux
(gdb) target remote :1234
(gdb) hbreak suspect_function
(gdb) continue
```

Inspect arguments and state:

```text
(gdb) info registers
(gdb) bt
(gdb) p/x $rdi
(gdb) p *some_struct_pointer
```

## Resolution

Session note:

```text
Breakpoint target:
Why this boundary:
QEMU command:
GDB connection command:
State to inspect:
Expected good state:
Expected bad state:
Live-debug limitation:
```

## 1-Hour Output

Define one live-debug session for stopping before a suspected function and inspecting arguments.

## Evidence Check

The note must include the breakpoint target, connection command, and one limitation of live debugging for the symptom.

