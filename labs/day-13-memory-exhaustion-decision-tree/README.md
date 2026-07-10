# Day 13: How do you debug memory leaks and system memory exhaustion?

## Platform

**Mode: Orin. Risk: read-only observation.** Capture real 8GB target memory,
reclaim, slab, and cgroup evidence. Do not force global OOM on the primary
board; use natural pressure evidence or a bounded cgroup workload with an SSH
and recovery path.

## Problem

The machine runs out of memory, but "kernel leak" is only one possibility. The symptom is rising memory pressure, OOM kills, or allocation failures.

## Kernel Mechanism

Memory pressure can come from workload growth, unreclaimable kernel memory, page cache, memcg limits, or a real leak. Reclaim and the OOM killer decide what happens when free memory cannot satisfy demand.

Evidence sources answer different questions:

- `/proc/meminfo` shows global memory shape.
- `/proc/slabinfo` shows slab cache growth.
- `vmstat` shows reclaim and swap activity.
- Kmemleak reports unreachable kernel allocations when configured.
- OOM logs show allocation context and victim choice.

## Problem Analysis

Separate these cases:

- Workload growth: process RSS or cache grows with load.
- Reclaim pressure: scans, stalls, and OOM happen under demand.
- Slab growth: one or more caches grow without shrinking.
- Kernel leak suspicion: unreclaimable memory grows without owner growth.

Do not call it a leak until reclaim and workload accounting have been checked.

## Debug Path

First snapshot:

```sh
cat /proc/meminfo > meminfo.before
cat /proc/slabinfo > slabinfo.before
vmstat 1 10 > vmstat.txt
dmesg -T | grep -i 'out of memory\|oom' > oom.log
```

Later snapshot:

```sh
cat /proc/meminfo > meminfo.after
cat /proc/slabinfo > slabinfo.after
```

Kmemleak lab flow:

```sh
mount -t debugfs none /sys/kernel/debug
echo scan > /sys/kernel/debug/kmemleak
cat /sys/kernel/debug/kmemleak
```

## Resolution

Decision tree:

```text
OOM or allocation failure?
  yes -> collect OOM log and allocation context
Global memory low?
  yes -> compare anon, file, slab, unreclaimable
One process or memcg growing?
  yes -> use smaps or memory.stat before kernel leak theory
Slab growing?
  yes -> identify cache, owner, shrinker, allocation path
Unreachable kernel allocations?
  yes -> use kmemleak as suspicion, then verify lifetime
```

## 1-Hour Output

Build a memory exhaustion decision tree for one symptom.

## Evidence Check

The tree must separate workload growth, reclaim pressure, slab growth, and leak suspicion.
