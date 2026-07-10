# Day 6: How do sampling and dynamic probes complement ftrace?

## Platform

**Mode: Orin. Risk: low.** Use the real ARM64 BSP workload and drivers. Verify
that `perf`, `bpftrace`, BTF, and the required tracepoints are available
before selecting a tool; record missing capabilities instead of switching the
primary experiment to QEMU.

## Problem

Tracing every function can be too much, but sampling alone may miss the exact branch. The symptom is high CPU or latency with no clear choice of tool.

## Kernel Mechanism

The tools answer different questions:

- `perf record` samples where CPU time is spent.
- `perf stat` counts events over a workload.
- Ftrace records specific kernel function paths and durations.
- Tracepoints expose subsystem events with structured fields.
- Kprobes and `bpftrace` attach dynamic probes to functions when built-in tracepoints are not enough.

## Problem Analysis

Match the tool to the signal:

- Unknown high CPU source: start with `perf top` or `perf record`.
- Known function is slow: use function graph ftrace.
- Known event type: use tracepoints through `trace-cmd` or `perf trace`.
- Need an argument or return value from one function: use `bpftrace` or kprobes.

Avoid dynamic probes first when a stable tracepoint already exposes the field.

## Debug Path

Sampling example:

```sh
perf record -a -g -- sleep 10
perf report
```

Function duration example:

```sh
trace-cmd record -p function_graph -g schedule -- sleep 1
trace-cmd report
```

Dynamic probe example:

```sh
bpftrace -e 'kprobe:vfs_read { @[kstack] = count(); }'
```

Tracepoint discovery:

```sh
trace-cmd list -e | less
perf list 'sched:*'
```

## Resolution

Use this selection note:

```text
Symptom:
First tool:
Reason:
Command:
Expected signal:
Fallback if signal is absent:
```

Example: for high CPU in kernel mode, start with `perf record -a -g` because the unknown is "where CPU time goes." Fall back to ftrace after the hot function is known.

## 1-Hour Output

Pick one high-CPU or latency symptom and fill the selection note with one command and expected signal.

## Evidence Check

The note must explain why the chosen tool is better as the first measurement than the other two common choices.
