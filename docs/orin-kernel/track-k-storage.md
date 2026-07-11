# Track K — Storage and Filesystems

## Outcome

Follow an I/O request across syscall, VFS, page cache, filesystem, writeback,
block layer, and device completion, then localize errors or tail latency.

## Prerequisites

Complete Track F and prepare disposable storage for injected-error work; know
the basic VFS, page-cache, and block-request path.

## Platform boundary

QEMU supports generic paths, virtual block devices, and destructive error
injection. NVMe throughput and Orin power/thermal interactions require Orin.

## Ordered lessons

| ID | Focus |
|---|---|
| K01 | Trace a read to the block layer |
| K02 | Trace write and writeback |
| K03 | Diagnose page-cache miss latency |
| K04 | Diagnose writeback throttling |
| K05 | Diagnose filesystem lock contention |
| K06 | Diagnose block tail latency |
| K07 | Diagnose I/O error propagation |
| K08 | Diagnose Orin NVMe throughput regression |
| K09 | Separate storage and reclaim stalls |

## Concrete diagnostic decision

High `iowait` does not identify the slow layer. Correlate request issue and
completion with reclaim, writeback, filesystem locks, and task stacks. If no
block request exists during the stall, tuning the device queue is not a
root-cause fix.

## Lab and evidence policy

Use `loop`, `null_blk`, `scsi_debug`, or disposable QEMU storage for injected
errors. K07 is S3 and must use a snapshot/overlay. Orin NVMe measurements record
filesystem, mount options, capacity, temperature, clocks, power mode, workload,
and latency distribution.

## Completion criteria

You can identify the layer responsible for delay or error propagation and
repeat the same workload to verify a narrowly scoped correction.
