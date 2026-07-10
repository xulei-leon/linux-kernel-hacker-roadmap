# Day 17: Why do deadlocks need lock ordering evidence?

## Platform

**Mode: Orin analysis, QEMU trigger. Risk: may hang.** Inspect Orin's lockdep
configuration and analyze a saved report, but run `trigger_inversion=1` only
in Day 00 QEMU.

Do not run the destructive trigger on the primary Orin installation.

## Problem

Two lock names in a stack trace do not prove a deadlock. The symptom is a lockdep splat or hang where the real issue is lock order inversion.

## Kernel Mechanism

Lockdep tracks lock classes and dependency chains. A possible circular locking dependency report shows two chains that create a cycle. The problem is the ordering relationship, not the lock names alone.

Useful configs include:

- `CONFIG_LOCKDEP`
- `CONFIG_PROVE_LOCKING`
- `CONFIG_DEBUG_LOCK_ALLOC`

## Problem Analysis

Extract from the report:

- First chain: lock A acquired before lock B.
- Second chain: lock B acquired before lock A.
- The inversion point.
- Whether the locks are the same class or nested classes.
- The valid subsystem ordering rule.

Contention is not deadlock. A cycle in lock ordering is the evidence.

## Debug Path

Collect:

```sh
dmesg -T | grep -A80 -B10 'possible circular locking dependency'
zgrep -E 'LOCKDEP|PROVE_LOCKING|DEBUG_LOCK_ALLOC' /proc/config.gz
```

Annotation:

```text
Report header:
Lock class A:
Lock class B:
Existing chain:
New chain:
Inversion point:
Context of each acquisition:
Valid order:
Fix direction:
```

## Resolution

Common fixes:

- Enforce one lock order in all paths.
- Drop one lock before entering the second subsystem.
- Use existing nested locking annotations only when the nesting is real and documented.
- Split state so the two locks are not both needed.

Do not silence lockdep until the ordering proof is clear.

## 1-Hour Output

Annotate one lockdep report and extract the two chains, inversion point, and valid ordering.

## Evidence Check

The annotation must explain the cycle and avoid confusing it with ordinary contention.
