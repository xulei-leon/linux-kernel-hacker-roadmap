# Day 22: How do softirq and NAPI problems become latency?

## Platform

**Mode: Orin. Risk: low observation.** Use a bounded network workload on the
real Jetson interface and record IRQ affinity, NAPI and softirq availability,
CPU frequency state, and thermal state with the latency evidence.

## Problem

Network or storage latency spikes while CPUs appear busy, but application stacks only show waiting. The symptom may come from softirq or NAPI backlog.

## Kernel Mechanism

Softirqs run deferred kernel work. NAPI polls network devices in softirq context up to a budget. Under pressure, work can move to `ksoftirqd`, which runs as a schedulable kernel thread and can add latency when CPU time is scarce.

## Problem Analysis

Decide where work runs:

- Hard IRQ: device interrupt handler.
- Softirq: immediate deferred work on return from interrupt or kernel exit.
- `ksoftirqd`: backlog processed by kernel thread under pressure.
- NAPI: network polling budget and completion behavior.

If `ksoftirqd/<cpu>` consumes CPU, latency may be scheduler pressure plus deferred work, not just a driver issue.

## Debug Path

Counter snapshot:

```sh
cat /proc/softirqs > softirqs.before
sleep 5
cat /proc/softirqs > softirqs.after
```

CPU view:

```sh
ps -eo pid,comm,psr,stat,pcpu | grep ksoftirqd
perf top
```

Trace available softirq and NAPI events:

```sh
trace-cmd list -e 'irq:*' 'napi:*'
trace-cmd record -e irq:softirq_entry -e irq:softirq_exit -e 'napi:*' -- sleep 5
trace-cmd report > softirq-report.txt
```

## Resolution

Softirq context note:

```text
Symptom:
Dominant softirq:
Per-CPU counter skew:
ksoftirqd CPU use:
NAPI event signal:
Driver or subsystem:
Next probe:
```

Fix direction may involve driver budget behavior, interrupt moderation, CPU affinity, backlog tuning, or removing the upstream source of packet or request bursts.

## 1-Hour Output

Decide whether work is running in interrupt context, softirq, or `ksoftirqd` under CPU pressure.

## Evidence Check

The note must contain per-CPU softirq counters and one trace or perf signal.
