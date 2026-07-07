# Day 5: How do you find where a kernel path spends time without adding logs?

## Problem

A kernel operation is slow, but adding logs would perturb the path. The symptom is a latency complaint with no evidence about where time is spent.

## Kernel Mechanism

Ftrace records kernel execution through tracefs. Function tracing records function entry. Function graph tracing records entry, exit, duration, and caller nesting. Tracepoints expose stable subsystem events where available.

Tracefs is usually mounted at `/sys/kernel/tracing`; older systems may expose it under `/sys/kernel/debug/tracing`.

## Problem Analysis

Before tracing, reduce scope:

- Which command triggers the slow path?
- Which function or tracepoint is closest to the suspected layer?
- Is the path frequent enough to flood the buffer?
- Do you need function duration or only event ordering?

Start with one filter. Broad tracing creates unreadable output.

## Debug Path

Mount tracefs if needed:

```sh
mount -t tracefs nodev /sys/kernel/tracing
cd /sys/kernel/tracing
```

Trace one function with function graph tracing:

```sh
echo 0 > tracing_on
echo function_graph > current_tracer
echo vfs_read > set_graph_function
echo > trace
echo 1 > tracing_on
cat /proc/version > /dev/null
echo 0 > tracing_on
cat trace > ftrace-vfs-read.txt
```

With `trace-cmd`:

```sh
trace-cmd record -p function_graph -g vfs_read -- cat /proc/version
trace-cmd report > ftrace-vfs-read-report.txt
```

## Resolution

Summarize the trace:

```text
Trigger:
Tracer:
Filter:
Entry function:
Caller context:
Longest child:
Observed duration:
Interpretation:
```

If the longest delay is outside the selected function, move the filter one layer down or switch to subsystem tracepoints.

## 1-Hour Output

Produce one ftrace excerpt and a short interpretation. The excerpt should show entry, exit, duration, and caller context.

## Evidence Check

The output must include the trace command, selected filter or event, and one sentence explaining what the trace proves.

