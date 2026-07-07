# Day 2: Why is a panic or oops log often not enough?

## Problem

A panic or oops log shows where the kernel noticed failure, not always where the bug started. The common symptom is a report that pastes only the call trace and says "kernel crashed."

## Kernel Mechanism

An oops reports an exception in kernel context. A panic stops the system. A panic can be caused directly, or it can be forced after an oops with `panic_on_oops=1` or `oops=panic`.

The log also carries taint flags. A tainted kernel may include proprietary modules, forced modules, prior warnings, machine check events, or other state that changes trust in the evidence.

## Problem Analysis

Annotate the first failure, not the last visible crash. Look for:

- CPU and PID.
- Current task name.
- Kernel version and config hints.
- Taint flags.
- Faulting instruction pointer such as `RIP` on x86.
- Fault address such as `CR2` on x86 page faults.
- Loaded modules.
- The first missing evidence.

The first missing evidence is often the reproducer, symbolized source line, module version, or previous warning.

## Debug Path

Capture complete logs:

```sh
dmesg -T > dmesg-after-oops.log
journalctl -k -b > journal-kernel.log
```

For a lab where stopping after the first oops is useful:

```sh
qemu-system-x86_64 ... -append "console=ttyS0 panic_on_oops=1 oops=panic"
```

Use this annotation format:

```text
Kernel:
CPU:
PID/task:
Tainted:
Faulting instruction:
Fault address:
Access type:
First suspicious function:
Call trace root:
Loaded modules:
Missing evidence:
```

## Resolution

Treat the log as an index into the investigation. If the faulting function is visible but the source line is not, Day 3 comes next. If the log starts after earlier warnings, reproduce with serial logging enabled from boot.

## 1-Hour Output

Annotate one panic or oops sample using the format above. Keep the raw excerpt next to the annotation so the reasoning is auditable.

## Evidence Check

The annotation is acceptable only if it identifies the faulting function and names one missing piece of evidence needed before proposing a fix.

