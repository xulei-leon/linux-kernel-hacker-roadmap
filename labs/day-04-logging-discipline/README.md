# Day 4: When should you use printk, dynamic debug, or trace_printk?

## Problem

Adding raw `printk()` calls can hide timing bugs, flood logs, or make a reproducer slower than the bug. The symptom is a noisy debug patch that produces many lines but no decision.

## Kernel Mechanism

Kernel logging has different costs:

- `pr_info()` and `printk()` are always visible at their log level.
- `pr_debug()` and `dev_dbg()` can be compiled out or controlled by dynamic debug.
- Dynamic debug enables specific call sites at runtime.
- `trace_printk()` writes into the tracing buffer and is for temporary debugging only.
- Rate-limited variants such as `pr_warn_ratelimited()` prevent log storms.

## Problem Analysis

Choose the least invasive signal:

- Need one persistent boot message: use `pr_info()` or `dev_info()`.
- Need temporary logs at existing debug sites: use dynamic debug.
- Need high-frequency timing-sensitive breadcrumbs: use trace events or `trace_printk()` in a throwaway patch.
- Need repeated warning protection: use a rate-limited logging helper.

Never turn a high-frequency path into a serial-console benchmark by accident.

## Debug Path

Enable timestamps:

```sh
qemu-system-x86_64 ... -append "console=ttyS0 printk.time=1"
```

Enable one dynamic debug site:

```sh
mount -t debugfs none /sys/kernel/debug
echo 'file drivers/example/foo.c +p' > /sys/kernel/debug/dynamic_debug/control
```

Enable a function pattern:

```sh
echo 'func foo_* +p' > /sys/kernel/debug/dynamic_debug/control
```

Inspect the tracing buffer when using trace output:

```sh
cat /sys/kernel/tracing/trace
```

## Resolution

Use this checklist before adding logs:

```text
Question:
Path frequency:
Existing debug site:
Chosen method:
Enable command:
Expected line:
Rate-limit risk:
Removal plan:
```

## 1-Hour Output

Turn one hypothetical noisy debug patch into the checklist above. Name the exact method and enable command.

## Evidence Check

The checklist is acceptable only if it chooses a less invasive method than unconditional `printk()` for high-frequency paths and names the rate-limit risk.

