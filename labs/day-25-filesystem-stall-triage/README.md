# Day 25: How do filesystem stalls surface as process hangs?

## Problem

An application hangs in file I/O, but the root cause may be VFS locking, page cache, writeback, or the block layer. The symptom is a task stuck in `D` state during a filesystem operation.

## Kernel Mechanism

Filesystem I/O passes through VFS, filesystem-specific code, page cache, writeback, and block I/O. A stack may show a generic wait function, so the layer must be identified by stack frames, tracepoints, and device counters.

## Problem Analysis

Separate layers:

- VFS or inode lock: task waits before reaching storage.
- Page cache: waiting on page lock, writeback, or read completion.
- Writeback: dirty pages or flusher behavior.
- Block layer: request queue or device latency.

The right next probe depends on which layer owns the wait.

## Debug Path

Capture waiting tasks:

```sh
echo w > /proc/sysrq-trigger
dmesg -T > fs-sysrq-w.log
cat /proc/<pid>/stack
```

Inspect I/O:

```sh
iostat -x 1 10
cat /proc/meminfo | grep -E 'Dirty|Writeback'
```

List relevant tracepoints before recording:

```sh
trace-cmd list -e '*vfs*' 'writeback:*' 'filemap:*' 'block:*'
```

Record available events for the suspected layer:

```sh
trace-cmd record -e writeback:* -e block:block_rq_issue -e block:block_rq_complete -- sleep 10
```

## Resolution

Filesystem stall triage note:

```text
Task:
Syscall or operation:
Wait site:
VFS evidence:
Page-cache evidence:
Writeback evidence:
Block evidence:
Layer needing deeper inspection:
Proof signal:
```

## 1-Hour Output

Trace a stuck process to VFS, writeback, page cache, or block layer evidence.

## Evidence Check

The note must name the layer needing deeper inspection and the signal that proves it.

