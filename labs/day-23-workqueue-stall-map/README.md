# Day 23: Why do workqueues stall or amplify memory pressure?

## Problem

A delayed operation never finishes, or memory reclaim appears stuck behind background work. The symptom is a workqueue item queued but not making visible progress.

## Kernel Mechanism

Workqueues run deferred work in worker pools. Work can be delayed because the pool is saturated, the worker blocks, the work item requeues itself, or reclaim waits on work that lacks the right `WQ_MEM_RECLAIM` behavior.

## Problem Analysis

Classify the stall:

- Starved: work queued but no worker runs it.
- Blocked: worker starts but sleeps on I/O, lock, reclaim, or completion.
- Overloaded: work runs but queue depth grows faster than completion.
- Reclaim-sensitive: memory reclaim depends on workqueue progress.

## Debug Path

Trace workqueue lifecycle:

```sh
trace-cmd record \
  -e workqueue:workqueue_queue_work \
  -e workqueue:workqueue_execute_start \
  -e workqueue:workqueue_execute_end \
  -- sleep 10
trace-cmd report > workqueue-report.txt
```

Collect blocked workers:

```sh
ps -eo pid,comm,stat,wchan | grep -E 'kworker|workqueue'
echo w > /proc/sysrq-trigger
dmesg -T > workqueue-sysrq-w.log
```

Map:

```text
Work item:
Queue site:
Workqueue name:
Execution start:
Execution end:
Worker PID:
Blocking point:
Reclaim involvement:
Classification:
```

## Resolution

Fix direction depends on the class. Starvation may need queue selection or concurrency analysis. Blocking needs the waited resource. Overload needs producer rate and batching. Reclaim involvement may require using or preserving a reclaim-safe workqueue.

## 1-Hour Output

Map one delayed work item from queue site to worker execution and blocking point.

## Evidence Check

The map must identify whether the queue is starved, blocked, or overloaded.

