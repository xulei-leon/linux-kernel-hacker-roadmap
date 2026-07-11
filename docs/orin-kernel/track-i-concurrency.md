# Track I — Concurrency and CPU Stalls

## Outcome

Reconstruct lock dependencies, event ordering, object lifetimes, and watchdog
evidence to diagnose races, deadlocks, missed wakeups, and CPU stalls.

## Prerequisites

Complete Track C for destructive triggers and Track F for tracing; understand
mutex, spinlock, wait queue, completion, and RCU fundamentals.

## Platform boundary

Generic concurrency failures are fully teachable in QEMU and destructive
triggers are QEMU-only. Orin is used later when a real device or workload is
required to reproduce timing.

## Ordered lessons

| ID | Failure class |
|---|---|
| I01 | Lock-order inversion |
| I02 | Self-deadlock |
| I03 | Sleeping in atomic context |
| I04 | Lost update |
| I05 | Teardown use-after-free |
| I06 | Lost wakeup |
| I07 | Completion misuse |
| I08 | RCU lifetime error |
| I09 | Hung task |
| I10 | Soft lockup |
| I11 | Hard-lockup detection feasibility |
| I12 | RCU stall |

## Concrete diagnostic decision

Do not treat every “stuck” system as a deadlock. A blocked task has a wait
point; a lock dependency report has an ownership cycle; a soft lockup has a CPU
that fails to schedule; a hard-lockup detector depends on watchdog support; an
RCU stall has grace-period evidence. Classify before selecting tools.

## Demo and evidence policy

Micro-modules expose one explicit race or ordering defect. Lockdep, KASAN,
KCSAN, scheduling traces, and watchdog output are enabled only as required.
I11 must preflight the ARM64 virtual watchdog and may teach a detector gap
instead of falsely claiming a reproduced hard lockup.

## Completion criteria

You can draw the failing happens-before or ownership relationship, name the
missing synchronization/lifetime rule, and prove the fix under stress.
