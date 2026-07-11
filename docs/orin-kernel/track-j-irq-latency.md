# Track J — IRQ, Deferred Work, and Latency

## Outcome

Attribute latency to hard IRQ, softirq, threaded IRQ, workqueue, timer, CPU
affinity, or scheduler wakeup rather than treating all delay as “scheduler
latency.”

## Prerequisites

Complete Tracks E and F, and record a stable workload plus the relevant IRQ and
CPU topology before changing affinity or handler design.

## Platform boundary

QEMU teaches generic handler and deferred-work mechanisms. Real interrupt
topology, CPU placement, and latency claims require measurement on Orin.

## Ordered lessons

| ID | Focus |
|---|---|
| J01 | Measure IRQ distribution |
| J02 | Diagnose a long hard-IRQ handler |
| J03 | Move work to a threaded IRQ |
| J04 | Diagnose softirq saturation |
| J05 | Diagnose a workqueue stall |
| J06 | Diagnose workqueue starvation |
| J07 | Diagnose timer teardown races |
| J08 | Measure scheduler wakeup latency |
| J09 | Separate IRQ and scheduler latency |
| J10 | Diagnose affinity-induced latency |

## Concrete diagnostic decision

For a delayed task, build a timeline from device interrupt through handler,
softirq/thread/work, wakeup, and actual scheduling. A long wakeup-to-run interval
is scheduler evidence; a late wakeup caused by an IRQ handler is not.

## Demo and evidence policy

Generic demos provide controlled delay and safe reset. Orin lessons record
`/proc/interrupts`, affinity, workload placement, timerlat/osnoise/ftrace
settings, and before/after latency distributions.

## Completion criteria

You can identify the stage that introduced delay, move inappropriate work to
the correct context, and verify both functional behavior and tail latency.
