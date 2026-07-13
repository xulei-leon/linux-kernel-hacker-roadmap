# IRQ and Scheduler Latency

## Outcome

Attribute latency to hard IRQ, softirq, threaded IRQ, workqueue, timer, CPU
affinity, or scheduler wakeup rather than treating all delay as “scheduler
latency.”

## Prerequisites

Complete [Driver Lifecycle and Hardware I/O](../orin-kernel-debugging/driver-lifecycle-and-hardware-io.md)
and [Kernel Observability](../orin-kernel-debugging/kernel-observability.md),
then record a stable workload plus the relevant IRQ and CPU topology before
changing affinity or handler design.

## Platform boundary

QEMU teaches generic handler and deferred-work mechanisms. Real interrupt
topology, CPU placement, and latency claims require measurement on Orin.

## Focus areas

- Measure IRQ distribution
- Diagnose a long hard-IRQ handler
- Move work to a threaded IRQ
- Diagnose softirq saturation
- Diagnose a workqueue stall
- Diagnose workqueue starvation
- Diagnose timer teardown races
- Measure scheduler wakeup latency
- Separate IRQ and scheduler latency
- Diagnose affinity-induced latency

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
