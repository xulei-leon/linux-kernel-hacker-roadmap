# Day 21: Why can interrupt storms look like system hangs?

## Problem

The machine is responsive only in short bursts, but no single process explains the load. The symptom is high interrupt activity that looks like a hang from user space.

## Kernel Mechanism

Hard IRQ handlers run in interrupt context. Devices may use MSI-X, threaded IRQs, affinity masks, and per-CPU interrupt delivery. An interrupt storm can starve normal work, overload one CPU, or push follow-up work into softirq and ksoftirqd.

## Problem Analysis

Look for:

- One IRQ line increasing much faster than others.
- CPU skew where one CPU handles nearly all interrupts.
- Device name tied to the IRQ.
- Whether the handler is hard IRQ or threaded IRQ.
- Whether softirq counters rise after the hard IRQ.

An interrupt storm is proven by counter rate and device attribution, not by high load average alone.

## Debug Path

Capture before and after counters:

```sh
cat /proc/interrupts > interrupts.before
sleep 5
cat /proc/interrupts > interrupts.after
```

Trace IRQ handlers:

```sh
trace-cmd record -e irq:irq_handler_entry -e irq:irq_handler_exit -- sleep 5
trace-cmd report > irq-report.txt
```

Inspect affinity:

```sh
cat /proc/irq/<irq>/smp_affinity
cat /proc/irq/<irq>/effective_affinity
```

Use `irqsoff` only for IRQ-disabled latency, not for every interrupt storm:

```sh
echo irqsoff > /sys/kernel/tracing/current_tracer
```

## Resolution

IRQ storm triage note:

```text
IRQ number:
Device:
Before count:
After count:
Rate:
CPU skew:
Handler context:
Related softirq growth:
Next device-specific probe:
```

Fix direction may be device interrupt masking, driver acknowledgement, affinity tuning, or investigating hardware/firmware noise.

## 1-Hour Output

Inspect interrupt-rate evidence and identify IRQ line, CPU skew, device, and handler context.

## Evidence Check

The note must include before/after interrupt counters and likely device source.

