# Day 14: Why is process memory growth not always a kernel leak?

## Problem

A process grows in memory and the first guess is "kernel leak." The symptom is rising RSS, a memcg OOM, or global OOM while a workload is active.

## Kernel Mechanism

Process memory includes anonymous RSS, file-backed mappings, shared mappings, page cache effects, and cgroup accounting. Memcg OOM can happen while the host still has free memory. Global OOM means the whole system failed to reclaim enough memory.

## Problem Analysis

Classify the source:

- Anonymous growth: likely heap, stack, or private mappings.
- File-backed growth: may be mapped files or page cache.
- Memcg pressure: cgroup limit or events, not necessarily host exhaustion.
- Kernel memory growth: slab or other kernel allocations.
- PSI: shows stall pressure even before OOM.

The same workload can show RSS growth and page-cache growth at the same time. Use counters, not labels.

## Debug Path

Process view:

```sh
cat /proc/<pid>/status
cat /proc/<pid>/smaps_rollup
grep -E '^(Rss|Pss|Private|Shared|Anonymous|File)' /proc/<pid>/smaps_rollup
```

Cgroup v2 view:

```sh
cat /sys/fs/cgroup/<group>/memory.current
cat /sys/fs/cgroup/<group>/memory.stat
cat /sys/fs/cgroup/<group>/memory.events
```

Pressure view:

```sh
cat /proc/pressure/memory
```

OOM source:

```sh
dmesg -T | grep -i 'memory cgroup out of memory\|out of memory'
```

## Resolution

Triage note:

```text
PID/workload:
RSS/PSS:
Anonymous memory:
File-backed memory:
Mapped file evidence:
Memcg current:
Memcg events:
PSI memory pressure:
OOM source:
Kernel memory signal:
```

If memory is charged to a memcg, debug the cgroup limit and workload first. If slab or unreclaimable kernel memory grows independently, move to allocator evidence.

## 1-Hour Output

Analyze one process growth scenario versus memcg OOM versus global OOM.

## Evidence Check

The note must include RSS, mapped file or anonymous split, memcg event evidence, and OOM source.

