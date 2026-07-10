# Day 26: Why does block I/O latency require queue-level evidence?

## Platform

**Mode: Orin. Risk: low observation.** Use the actual Jetson NVMe or selected
storage device. Record the device name, model, scheduler, queue settings, and
filesystem before collecting block tracepoints.

## Problem

File operations are slow, but the filesystem may only be waiting on block I/O. The symptom is high read or write latency without queue-level proof.

## Kernel Mechanism

Block I/O travels through bios, request queues, blk-mq hardware queues, schedulers, and the device. Latency can come from filesystem submission delay, queueing delay, scheduler behavior, device service time, or timeouts.

## Problem Analysis

Separate:

- Filesystem delay: request not submitted yet.
- Queue delay: request queued but not issued.
- Device delay: request issued but not completed.
- Timeout or reset: device or driver reports recovery.

One `iostat` number is not enough. Use block tracepoints or `blktrace` for timing.

## Debug Path

Device counters:

```sh
iostat -x 1 10
cat /sys/block/<dev>/stat
```

Block tracepoints:

```sh
trace-cmd record \
  -e block:block_bio_queue \
  -e block:block_rq_insert \
  -e block:block_rq_issue \
  -e block:block_rq_complete \
  -- sleep 10
trace-cmd report > block-report.txt
```

`blktrace` path:

```sh
blktrace -d /dev/<dev> -o - | blkparse -i -
```

## Resolution

Block latency checklist:

```text
Workload:
Device:
Filesystem wait signal:
Bio queued:
Request inserted:
Request issued:
Request completed:
Queue delay evidence:
Device delay evidence:
Timeout/reset evidence:
```

Fix direction may be filesystem batching, queue scheduler choice, driver/device investigation, or workload throttling. Pick only after timing shows where delay accumulates.

## 1-Hour Output

Separate filesystem delay, queue delay, and device delay for one I/O latency symptom.

## Evidence Check

The checklist must have at least one observable signal per layer.
