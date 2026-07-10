# Day 12: How do you classify memory corruption beyond UAF?

## Platform

**Mode: Orin analysis, QEMU trigger. Risk: destructive.** Run out-of-bounds,
use-after-free, and intentional corruption parameters only in Day 00 QEMU.
Use Orin to inspect detector availability and verify a safe fix.

Do not run the destructive trigger on the primary Orin installation.

## Problem

"Memory corruption" is too vague to debug. The symptom could be slab out-of-bounds, use-after-free, double free, stack overflow, or undefined behavior.

## Kernel Mechanism

Different detectors catch different bug classes:

- KASAN detects many invalid memory accesses with allocation and free stacks.
- KFENCE samples heap objects with low overhead and catches some out-of-bounds and UAF bugs.
- UBSAN detects selected undefined behavior such as invalid shifts or signed integer overflow when configured.
- `CONFIG_VMAP_STACK` helps catch kernel stack overflows with guard pages.
- `CONFIG_DEBUG_STACKOVERFLOW` adds stack overflow warnings where supported.

## Problem Analysis

Classify by report shape:

- UAF: report includes allocation stack, free stack, and use stack.
- Slab out-of-bounds: report shows access outside object bounds.
- Double free: allocator complains at free time.
- Stack overflow: stack guard or overflow warning, often near deep recursion or large stack object.
- UBSAN: report names undefined behavior and source line.

The next step depends on the class. A UAF wants lifetime evidence; OOB wants bounds and size evidence.

## Debug Path

Detector matrix:

| Symptom | Detector | Config or boot knob | Key report field | Next step |
|---|---|---|---|---|
| Heap use after free | KASAN | `CONFIG_KASAN` | alloc/free/use stacks | Map object lifetime |
| Low-overhead heap UAF/OOB | KFENCE | `CONFIG_KFENCE` | guarded object report | Reproduce longer, inspect owner |
| Slab red-zone overwrite | SLUB debug | `CONFIG_SLUB_DEBUG`, `slub_debug=FZPU` | cache and red-zone info | Find writer and object size |
| Undefined shift or overflow | UBSAN | `CONFIG_UBSAN` | source line and operation | Check input range |
| Stack overflow | VMAP stack | `CONFIG_VMAP_STACK` | guard-page fault or warning | Inspect call depth and stack objects |

Useful first commands:

```sh
zgrep -E 'KASAN|KFENCE|UBSAN|VMAP_STACK|SLUB_DEBUG' /proc/config.gz
dmesg -T | grep -E 'KASAN|KFENCE|UBSAN|BUG:|slab'
```

## Resolution

Pick the detector that matches the symptom and cost. KASAN is strong for lab reproduction. KFENCE is useful for lower-overhead long runs. SLUB debugging is good when allocator metadata points to a cache. UBSAN is for undefined operations, not generic corruption.

## 1-Hour Output

Compare three report types and decide which detector catches each symptom.

## Evidence Check

The matrix must map symptom to detector, config, report field, and likely next step.
