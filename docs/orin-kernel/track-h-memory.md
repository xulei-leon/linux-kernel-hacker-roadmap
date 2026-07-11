# Track H — Memory Failures

## Outcome

Diagnose object lifetime, bounds, leak, allocation, reclaim, OOM, memcg, and
page-reference failures with the detector appropriate to each class.

## Prerequisites

Complete Track C for destructive demos and Track F for evidence capture; know
the basic slab, page-allocation, reclaim, and cgroup vocabulary.

## Platform boundary

KASAN, KMEMLEAK, allocation failure, and generic pressure work in QEMU. Orin is
needed when the result depends on its memory capacity, BSP configuration, or
device interaction.

## Ordered lessons

| ID | Failure class | Primary evidence |
|---|---|---|
| H01 | Slab use-after-free | KASAN allocation/free/access stacks |
| H02 | Slab/kmalloc out-of-bounds access | Object bounds and access size |
| H03 | Double free | Allocator and KASAN report |
| H04 | Memory leak | KMEMLEAK plus object count |
| H05 | Allocation failure | Injected failure and error unwind |
| H06 | Uninitialized state | Deterministic state and static/compiler evidence |
| H07 | Memory pressure | Reclaim, compaction, allocation latency |
| H08 | OOM kill | Allocation context, memory state, victim |
| H09 | memcg limit failure | Cgroup-local versus global state |
| H10 | Page-reference leak | Reference accounting across cleanup |

## Concrete diagnostic decision

Low free memory is not by itself a leak. First separate reclaimable page cache,
slab growth, unreclaimable memory, a memcg limit, fragmentation, and retained
object ownership. Choose KMEMLEAK only for unreachable allocations; use counters
and ownership paths for referenced-but-never-released objects.

## Demo and evidence policy

Memory-safety demos default to QEMU and use detector-specific configs. Pressure
and OOM workloads are bounded and record recovery. Fixed versions must prove
both detector silence and balanced object/page counts.

## Completion criteria

You can classify the memory failure, read the relevant detector or pressure
evidence, locate the invalid ownership transition, and demonstrate balanced
cleanup under repeated execution.
