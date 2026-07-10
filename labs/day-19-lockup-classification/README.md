# Day 19: How do you tell hung task, soft lockup, hard lockup, and RCU stall apart?

## Platform

**Mode: Orin analysis, QEMU trigger. Risk: destructive.** Analyze Orin watchdog
and saved-console evidence, but generate soft or hard lockups only in Day 00
QEMU. Do not run the destructive trigger on the primary Orin installation.

## Problem

The system appears frozen, but the detector matters. The symptom may be a hung task, soft lockup, hard lockup, or RCU stall.

## Kernel Mechanism

The detectors observe different progress:

- Hung task: a task stays blocked too long.
- Soft lockup: a CPU fails to schedule normally for too long.
- Hard lockup: an NMI watchdog detects that a CPU is not taking interrupts normally.
- RCU stall: an RCU grace period cannot complete because quiescent states are missing or callbacks are stuck.

## Problem Analysis

Use the log signature first. Do not treat all stalls as deadlocks.

| Symptom | Detector | Log signature | Likely cause | First evidence |
|---|---|---|---|---|
| Blocked task | Hung task detector | `INFO: task ... blocked for more than` | I/O wait, lock wait, reclaim | Task stack and `wchan` |
| CPU schedules poorly | Soft lockup watchdog | `BUG: soft lockup - CPU#... stuck` | Busy loop, IRQ-off section, preemption disabled | CPU stack and timer context |
| CPU stops taking interrupts | Hard lockup watchdog | `Watchdog detected hard LOCKUP` | IRQs/NMI issue, hardware, long non-maskable stall | NMI backtrace |
| Grace period stuck | RCU stall detector | `rcu: INFO: rcu_preempt detected stalls` | Long RCU reader, CPU no quiescent state | RCU log fields and blocked CPU |

## Debug Path

Useful knobs for labs:

```sh
sysctl kernel.watchdog_thresh
qemu-system-x86_64 ... -append "console=ttyS0 nmi_watchdog=1 softlockup_panic=1"
```

Collect:

```sh
dmesg -T > lockup.log
echo l > /proc/sysrq-trigger
echo t > /proc/sysrq-trigger
```

Classification note:

```text
Observed signature:
Detector:
CPU or task:
Execution context:
First stack to trust:
Most likely class:
Next evidence:
```

## Resolution

Move to the matching workflow. Hung tasks need wait-site evidence. Soft lockups need CPU execution evidence. Hard lockups need NMI and IRQ context. RCU stalls need grace-period and reader evidence.

## 1-Hour Output

Build the classification table and apply it to one log.

## Evidence Check

The table must separate the four symptoms using observable log signatures.
