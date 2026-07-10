# Day 16: How do missed wakeups, signals, and IPC waits look different?

## Platform

**Mode: Orin. Risk: low.** Trace a bounded user-space wait/wake or IPC example
on the real ARM64 scheduler. Verify the chosen scheduler and signal tracepoints
exist before recording.

## Problem

A user-visible hang may be a missed wakeup, a signal handling issue, or an IPC wait. The symptom is "process stuck" with no clear kernel layer.

## Kernel Mechanism

Wait queues block until a condition becomes true. Correct code checks the condition under the right lock and wakes waiters after changing state. Signals may interrupt interruptible waits, but not uninterruptible waits. Futexes, pipes, and sockets use wait/wake paths to connect user-visible blocking to kernel events.

## Problem Analysis

Map the wait:

- Where does the task sleep?
- What condition is it waiting for?
- Which lock protects the condition?
- Who changes the condition?
- Which wake function should run?
- Are signals allowed to interrupt this wait?

Missed wakeups are condition bugs. IPC stalls often have a real peer or buffer condition.

## Debug Path

User boundary:

```sh
strace -ff -p <pid>
cat /proc/<pid>/wchan
```

Futex direction:

```sh
perf trace -e futex -p <pid>
```

Scheduling direction:

```sh
trace-cmd record -e sched:sched_switch -e sched:sched_wakeup -- sleep 10
```

Source review checklist:

```text
wait_event condition:
Lock protecting condition:
State update site:
Wake site:
Signal behavior:
Timeout behavior:
Peer or resource expected:
```

## Resolution

Fix direction depends on classification:

- Missed wakeup: fix condition update, lock ordering, or wake placement.
- Signal issue: verify wait type and signal mask before changing kernel code.
- Futex or IPC wait: identify peer state, buffer state, or owner death handling.

## 1-Hour Output

Map one user-visible hang to a wait condition and the event that should wake it.

## Evidence Check

The map must show wait site, wake site, condition, lock, and signal behavior.
