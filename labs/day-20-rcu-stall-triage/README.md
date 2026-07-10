# Day 20: Why can RCU stalls be hard to localize?

## Platform

**Mode: Orin analysis, QEMU trigger. Risk: destructive.** Inspect the Jetson
kernel's RCU configuration and analyze saved evidence. Generate an RCU stall
only in Day 00 QEMU.

Do not run the destructive trigger on the primary Orin installation.

## Problem

An RCU stall report names a CPU, but the bad code may be a long reader, disabled preemption, IRQ pressure, or a blocked grace-period path. The symptom looks like a generic hang unless the RCU fields are read.

## Kernel Mechanism

RCU allows readers to run without heavy locks. Updates wait for a grace period, which completes after CPUs pass through quiescent states. A stall means RCU cannot observe required progress. The cause may be a long read-side critical section, a CPU that does not schedule, callback pressure, or a stalled task depending on RCU flavor.

## Problem Analysis

Extract:

- RCU flavor from the log.
- Stalled CPU or task.
- Grace-period sequence state.
- Whether the CPU is in kernel, IRQ, softirq, or idle context.
- Whether callbacks are backing up.
- Nearby lockup or IRQ storm evidence.

An RCU stall is not just "the system hung." It is a failure to complete RCU progress.

## Debug Path

Collect log:

```sh
dmesg -T | grep -A80 -B20 -i 'rcu.*stall' > rcu-stall.log
```

List available RCU tracepoints:

```sh
trace-cmd list -e 'rcu:*'
```

Trace selected RCU events when available:

```sh
trace-cmd record -e 'rcu:*' -- sleep 10
trace-cmd report > rcu-trace.txt
```

Lab knob:

```sh
qemu-system-x86_64 ... -append "console=ttyS0 rcu_cpu_stall_timeout=21"
```

## Resolution

RCU stall triage note:

```text
RCU flavor:
Stalled CPU/task:
Grace-period state:
CPU context:
Callback pressure:
Nearby watchdog evidence:
Possible long reader:
Next proof:
```

Fix direction usually requires shortening the read-side section, adding scheduling points in long loops when legal, fixing IRQ/preemption-off regions, or resolving the blocking subsystem that prevents quiescent states.

## 1-Hour Output

Analyze one RCU stall report and fill the triage note.

## Evidence Check

The note must explain why the stall is RCU-specific rather than merely a generic hang.
