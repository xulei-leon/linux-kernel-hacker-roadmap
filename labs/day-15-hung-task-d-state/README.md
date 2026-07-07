# Day 15: Why does a task get stuck in D state?

## Problem

A process will not exit and appears in `D` state. The symptom is a hung task warning or a process blocked in uninterruptible sleep.

## Kernel Mechanism

Task state describes scheduling behavior. `TASK_UNINTERRUPTIBLE` is commonly shown as `D`. It usually means the task is waiting for a kernel condition that signals cannot interrupt, often I/O, memory reclaim, or a lock-like resource.

Hung task reports show a stack, but the stack must be tied to the wait condition and wakeup source.

## Problem Analysis

Distinguish:

- Runnable but not scheduled: scheduler or CPU pressure issue.
- Interruptible sleep: signal can wake it.
- Uninterruptible wait: signal usually cannot wake it until the condition changes.
- Deadlock: wait condition cannot become true because of ordering.
- Slow I/O: wait condition eventually becomes true.

## Debug Path

Collect blocked tasks:

```sh
cat /proc/<pid>/status | grep '^State'
cat /proc/<pid>/wchan
echo w > /proc/sysrq-trigger
echo t > /proc/sysrq-trigger
dmesg -T > hung-task.log
```

Scheduler tracepoint direction:

```sh
trace-cmd record -e sched:sched_switch -e sched:sched_wakeup -- sleep 10
trace-cmd report > sched-report.txt
```

Annotate:

```text
Task:
State:
Wait function:
Stack wait site:
Resource:
Wake condition:
Possible owner:
Evidence for slow wait vs deadlock:
```

## Resolution

If the task waits on I/O, continue into filesystem or block evidence. If it waits on a lock, gather owner and ordering evidence. If it waits on reclaim, inspect memory pressure. Do not patch signal handling when the task is in a non-interruptible kernel wait by design.

## 1-Hour Output

Inspect one hung task trace and fill the annotation.

## Evidence Check

The note must distinguish runnable, interruptible sleep, and uninterruptible wait.

