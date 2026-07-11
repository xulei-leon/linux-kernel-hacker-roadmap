# Track F — Observability

## Outcome

Select the least intrusive instrumentation that can confirm or reject a kernel
hypothesis, and preserve evidence that another developer can reproduce.

## Prerequisites

A debug-capable kernel, resolved `vmlinux`/module symbols, debugfs/tracefs
access, and a repeatable trigger or workload.

## Platform boundary

Logging, ftrace, trace-cmd, tracepoints, kprobes, perf, and bpftrace are broadly
available on Orin and QEMU. Instrumentation overhead must be measured on the
platform whose behavior is being characterized.

## Ordered lessons

| ID | Focus |
|---|---|
| F01 | Write useful `printk` diagnostics |
| F02 | Control dynamic debug |
| F03 | Prevent log flooding |
| F04 | Capture a tracepoint |
| F05 | Trace a function with ftrace |
| F06 | Save reproducible `trace-cmd` evidence |
| F07 | Add a custom tracepoint |
| F08 | Use a kprobe for a bounded question |
| F09 | Profile kernel CPU samples with `perf` |
| F10 | Choose ftrace, perf, or bpftrace |
| F11 | Measure instrumentation overhead |

## Concrete diagnostic decision

Use a tracepoint when a stable semantic event exists, function-graph tracing
when call order and duration matter, sampling when the question is “where is
CPU time spent?”, and a kprobe only for a temporary question that lacks a
stable event. More data is not automatically better evidence.

## Lab and evidence policy

Every capture records kernel release, config, enabled probes, filters, workload,
start/stop commands, output path, and overhead comparison. A custom tracepoint
must expose structured state and must not make `trace_printk()` a permanent API.

## Completion criteria

You can justify the selected tool, capture only relevant events, resolve kernel
symbols, quantify overhead, and give another developer a repeatable trace.
