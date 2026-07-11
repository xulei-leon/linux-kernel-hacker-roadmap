# Track M — Power, Thermal, and Frequency

## Outcome

Diagnose runtime/system PM failures and distinguish thermal, frequency, and
power-mode limits from kernel-code regressions.

## Prerequisites

Complete Tracks A, E, and F; establish serial recovery before suspend/resume
work and record the active Orin power mode and cooling conditions.

## Platform boundary

Frequency, thermal, suspend/resume, and wake evidence is Orin-only. QEMU is a
partial teaching environment for generic runtime-PM reference and callback
logic, not physical power behavior.

## Ordered lessons

| ID | Focus |
|---|---|
| M01 | Identify the active power mode |
| M02 | Trace CPU frequency changes |
| M03 | Diagnose thermal throttling |
| M04 | Diagnose a runtime-PM reference leak |
| M05 | Diagnose runtime suspend failure |
| M06 | Diagnose runtime resume failure |
| M07 | Diagnose system suspend entry failure |
| M08 | Diagnose system resume hang |
| M09 | Diagnose unexpected wakeups |
| M10 | Separate power limits from regressions |

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
