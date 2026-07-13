# Orin Kernel Performance Guides

These guides cover reproducible Linux kernel performance analysis on Jetson
Orin. They start from a fixed workload and platform baseline, measure before
changing anything, and preserve raw data plus the limits of each conclusion.

## Measurement policy

- Record the board, BSP, kernel, configuration, power mode, cooling, workload,
  affinity, tool versions, and exact commands.
- Change one declared independent variable at a time.
- Retain repeated-run data and invalid trials instead of hiding outliers.
- Measure instrumentation overhead on the platform being characterized.
- Keep QEMU, host, replay, and Orin/ARM64 results explicitly separated.

## Guide map

| Guide | Outcome |
|---|---|
| [Performance Engineering](performance-engineering.md) | Design benchmarks, quantify noise, profile bottlenecks, and compare changes |
| [IRQ and Scheduler Latency](irq-and-scheduler-latency.md) | Attribute delay to IRQ, deferred work, wakeup, affinity, or scheduling |
| [Storage and Filesystem Performance](storage-and-filesystem-performance.md) | Localize I/O errors and tail latency across VFS, cache, filesystem, block, and device layers |
| [Network Performance](network-performance.md) | Localize packet drops, queue imbalance, retransmissions, and throughput regressions |
| [Power, Thermal, and Frequency](power-thermal-and-frequency.md) | Separate PM defects, thermal behavior, and platform limits from regressions |

## Prerequisite guides

Use the [platform identification](../orin-kernel-debugging/identify-orin-platform.md),
[software baseline](../orin-kernel-debugging/capture-software-baseline.md), and
[kernel observability](../orin-kernel-debugging/kernel-observability.md) guides
before making target-platform performance claims. Use the
[QEMU debug environment](../orin-kernel-debugging/qemu-debug-environment.md) for
generic failure injection, but do not present emulated measurements as Tegra
hardware results.
