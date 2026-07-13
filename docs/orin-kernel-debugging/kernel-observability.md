# Kernel Observability

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

## Focus areas

- Write useful `printk` diagnostics
- Control dynamic debug
- Prevent log flooding
- Capture a tracepoint
- Trace a function with ftrace
- Save reproducible `trace-cmd` evidence
- Add a custom tracepoint
- Use a kprobe for a bounded question
- Profile kernel CPU samples with `perf`
- Choose ftrace, perf, or bpftrace
- Measure instrumentation overhead

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
