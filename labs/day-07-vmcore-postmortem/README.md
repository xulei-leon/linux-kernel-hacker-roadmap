# Day 7: How do you inspect a crash after the machine is gone?

## Problem

The system panicked and rebooted before anyone could inspect it. The symptom is a saved console log with no live machine left to query.

## Kernel Mechanism

Kdump boots a crash kernel after panic and writes a vmcore. The vmcore is a snapshot of kernel memory, including task state, stacks, modules, slab state, and system memory information. The `crash` utility inspects the vmcore with the matching `vmlinux`.

## Problem Analysis

Post-mortem debugging needs:

- Matching `vmlinux` with debug symbols.
- The vmcore file.
- The panic log that explains why the dump was taken.
- Module list and taint state.
- A checklist that extracts task, stack, memory, and module evidence before guessing.

## Debug Path

Confirm that a vmcore was captured:

```sh
ls -lh /var/crash
file /var/crash/*/vmcore
```

Open it:

```sh
crash /path/to/vmlinux /var/crash/<date>/vmcore
```

Run the first commands:

```text
bt
ps
kmem -i
mod
log
```

Use `bt -a` when the panic may involve another CPU.

## Resolution

Post-mortem checklist:

```text
Vmcore path:
vmlinux path:
Panic string:
Current task:
Current CPU:
Backtrace:
All blocked or suspicious tasks:
Memory pressure from kmem -i:
Loaded modules:
First missing evidence:
```

Do not rely on `bt` alone. A memory-pressure panic and a bad pointer panic can both show a short current stack.

## 1-Hour Output

Draft the checklist and fill it with one real or sample vmcore scenario. Include at least three `crash` commands: `bt`, `ps`, and `kmem -i`.

## Evidence Check

The checklist must recover task evidence, stack evidence, memory pressure, and loaded-module evidence.

