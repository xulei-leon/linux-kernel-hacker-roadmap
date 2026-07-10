# Day 11: Why must allocator anatomy come before UAF debugging?

## Platform

**Mode: Orin. Risk: low with default parameters.** The supplied module only
allocates and frees its own cache object. Verify
`/lib/modules/$(uname -r)/build`, load it with defaults, unload it with
`rmmod slab_lifecycle_demo`, and capture the final log. Use Day 00 QEMU for
boot-time `slub_debug` changes or any added UAF trigger.

## Problem

A report says "use-after-free," but the object owner and free path are unknown. The symptom is a KASAN or poisoning report that names an address but not the lifetime rule that was violated.

## Kernel Mechanism

Kernel objects usually come from the page allocator or slab allocators such as SLUB. SLUB groups objects by cache. A cache name, object size, allocation stack, and free stack tell you which subsystem owns the object and where lifetime ended.

Debug options change evidence:

- `CONFIG_SLUB_DEBUG` enables SLUB debugging support.
- `slub_debug=FZPU` can enable sanity checks, red zones, poisoning, and user tracking.
- `/proc/slabinfo` shows cache counts and object sizes.

## Problem Analysis

Before chasing callers, map the object:

- Which cache allocated it?
- What is the object type or likely type?
- Which code owns references?
- Which path frees it?
- Can the address be stale because a different object reused the slot?

UAF debugging without ownership mapping often fixes the caller that crashed, not the path that violated lifetime.

## Debug Path

Inspect slab cache growth:

```sh
cat /proc/slabinfo | head
grep -E 'kmalloc-|dentry|inode' /proc/slabinfo
```

Enable SLUB debugging only in the Day 00 QEMU fallback. Add the parameter to
the local `KERNEL_APPEND` value in Day 00 `lab.env`, then boot through its
wrapper:

```sh
grep '^KERNEL_APPEND=.*slub_debug=FZPU' \
  labs/day-00-kernel-build-environment/qemu-kernel/lab.env
bash labs/day-00-kernel-build-environment/qemu-kernel/boot-qemu.sh
```

When a report names a cache, write:

```text
Address:
Cache:
Object size:
Allocation stack:
Free stack:
Use stack:
Likely owner:
Expected free rule:
Suspicious reference:
```

## Resolution

Fix the lifetime rule, not just the crash site. Common fix directions are:

- Take a reference before handing the object to another context.
- Cancel work or timers before freeing the owner.
- Move free after the last callback can run.
- Use the subsystem's existing get/put helper instead of open-coded lifetime logic.

## 1-Hour Output

Build a slab object lifecycle map for one object type. Name the cache, object owner, allocation site, and free site candidate.

## Evidence Check

The map is complete only if it can explain who is allowed to hold the object and which event releases the final reference.
