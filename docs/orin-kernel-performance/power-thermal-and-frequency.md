# Power, Thermal, and Frequency

## Outcome

Diagnose runtime/system PM failures and distinguish thermal, frequency, and
power-mode limits from kernel-code regressions.

## Prerequisites

Complete [Orin Platform Recovery](../orin-kernel-debugging/platform-recovery.md),
[Driver Lifecycle and Hardware I/O](../orin-kernel-debugging/driver-lifecycle-and-hardware-io.md),
and [Kernel Observability](../orin-kernel-debugging/kernel-observability.md).
Establish serial recovery before suspend/resume work and record the active Orin
power mode and cooling conditions.

## Platform boundary

Frequency, thermal, suspend/resume, and wake evidence is Orin-only. QEMU is a
partial teaching environment for generic runtime-PM reference and callback
logic, not physical power behavior.

## Focus areas

- Identify the active power mode
- Trace CPU frequency changes
- Diagnose thermal throttling
- Diagnose a runtime-PM reference leak
- Diagnose runtime suspend failure
- Diagnose runtime resume failure
- Diagnose system suspend entry failure
- Diagnose system resume hang
- Diagnose unexpected wakeups
- Separate power limits from regressions

## Concrete diagnostic decision

A benchmark slowdown that follows temperature and falling frequency is not yet
a scheduler or driver regression. Hold power mode, cooling, clocks, workload,
and background activity constant before comparing code versions.

## Lab and evidence policy

Orin evidence records power mode, temperature, CPU/GPU/memory frequencies,
governors, throttling indicators, wake sources, callback timing, and serial
logs. Resume-hang experiments require a tested recovery path.

## Completion criteria

You can identify the failing PM callback or platform limit, restore balanced PM
state, and reproduce performance comparisons under controlled conditions.
