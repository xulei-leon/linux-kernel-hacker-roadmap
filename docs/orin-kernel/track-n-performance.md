# Track N — Performance Engineering

## Outcome

Design a repeatable benchmark, quantify noise, localize a bottleneck, and show
that a minimal optimization improves the intended metric without regression.

## Prerequisites

Complete Track F and the subsystem Track being measured; prepare a repeatable
workload and controls for frequency, temperature, background load, and input.

## Platform boundary

Methods and tools work on Orin and QEMU. QEMU is suitable for teaching and
automation, but its numbers never characterize Orin hardware.

## Ordered lessons

| ID | Focus |
|---|---|
| N01 | Define a reproducible benchmark |
| N02 | Quantify measurement noise |
| N03 | Profile CPU hotspots |
| N04 | Analyze kernel call graphs |
| N05 | Diagnose cache-miss bottlenecks |
| N06 | Diagnose lock contention |
| N07 | Diagnose memory-bandwidth saturation |
| N08 | Diagnose IRQ-driven performance loss |
| N09 | Compare a candidate optimization |
| N10 | Automate performance bisect |

## Concrete diagnostic decision

Do not call a change faster because one run improved. Establish warmup,
repetition, variance, thermal/frequency controls, and an effect larger than the
noise. Then use profiles or counters to connect the metric change to the code
path the patch actually modifies.

## Lab and evidence policy

Store raw results, environment, commands, revisions, summary statistics, and
profiles. Optimization lessons include functional regression tests and report
negative or neutral results honestly.

## Completion criteria

Another developer can rerun the benchmark, reproduce the effect within stated
variance, and explain why the evidence supports the proposed bottleneck and
fix.
