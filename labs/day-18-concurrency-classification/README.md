# Day 18: How do races and illegal sleeps differ from deadlocks?

## Problem

Concurrency symptoms are often grouped as "locking bugs." The symptom may actually be a deadlock, data race, illegal sleep, or lock contention.

## Kernel Mechanism

Different mechanisms fail differently:

- Deadlock: progress is impossible because dependencies form a cycle.
- Data race: shared state is accessed without proper synchronization.
- Illegal sleep: code sleeps in atomic context, IRQ-disabled context, or while holding a spinlock.
- Contention: progress continues, but lock hold time or wait time is high.

Detectors include `CONFIG_DEBUG_ATOMIC_SLEEP`, KCSAN, `perf lock`, and `lockstat`.

## Problem Analysis

Classify from evidence:

- Lockdep cycle: deadlock risk.
- `BUG: sleeping function called from invalid context`: illegal sleep.
- KCSAN report: data race.
- High lock wait time without cycle: contention.
- Hung tasks with no owner progress: possible deadlock, but needs owner evidence.

## Debug Path

Config checks:

```sh
zgrep -E 'DEBUG_ATOMIC_SLEEP|KCSAN|LOCK_STAT|LOCKDEP' /proc/config.gz
```

Contention measurement:

```sh
perf lock record -- sleep 10
perf lock report
```

KCSAN lab direction:

```sh
dmesg -T | grep -i kcsan
```

Classification note:

```text
Symptom:
Observed report:
Class:
Detector:
Why not the other classes:
Stress loop:
Verification signal:
```

## Resolution

Fix by class:

- Deadlock: change ordering or break dependency.
- Race: add the right synchronization or use existing atomic/refcount helpers.
- Illegal sleep: move sleep outside atomic context or use non-sleeping primitive.
- Contention: reduce hold time or move work outside the lock after measuring.

## 1-Hour Output

Classify one concurrency symptom as deadlock, race, illegal sleep, or contention.

## Evidence Check

The note must name the detector, expected report, and verification stress loop.

