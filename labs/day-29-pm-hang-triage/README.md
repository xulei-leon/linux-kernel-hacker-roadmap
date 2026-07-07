# Day 29: Why do suspend/resume bugs look like deadlocks?

## Problem

The system hangs during suspend or resume, and the stack looks blocked. The symptom may be a freezer issue, device PM callback stall, IRQ wake problem, or ordering failure.

## Kernel Mechanism

Power management coordinates the freezer, device suspend and resume ordering, wakeup IRQs, and platform states. Device PM callbacks run in ordered phases. A hang can be caused by one device callback, a task that will not freeze, an IRQ wake event, or dependency ordering.

## Problem Analysis

Classify the phase:

- Freezer: tasks fail to freeze before device suspend.
- Suspend callback: device hangs while entering low-power state.
- Resume callback: device fails to come back.
- Wake IRQ: unexpected wake or missing wake source.
- Ordering: dependency between devices is wrong or incomplete.

The first useful evidence is the last successful PM log line before the stall.

## Debug Path

PM test modes:

```sh
cat /sys/power/pm_test
echo freezer > /sys/power/pm_test
echo mem > /sys/power/state
```

Enable PM timing and debug messages when available:

```sh
cat /sys/power/pm_print_times
echo 1 > /sys/power/pm_print_times
cat /sys/power/pm_debug_messages
echo 1 > /sys/power/pm_debug_messages
```

Boot with initcall timing if early PM setup is suspect:

```sh
qemu-system-x86_64 ... -append "console=ttyS0 initcall_debug"
```

Collect:

```sh
dmesg -T > suspend-resume.log
```

## Resolution

PM hang triage note:

```text
Operation:
pm_test mode:
Last successful phase:
Blocking device or task:
Freezer evidence:
Device callback evidence:
Wake IRQ evidence:
Ordering suspicion:
Next narrowed test:
```

Use `pm_test` to stop before deeper power transitions. If `freezer` fails, do not debug device callbacks yet. If `devices` fails, identify the last device callback in the log.

## 1-Hour Output

Classify a suspend/resume hang as freezer, device PM callback, IRQ wake, or ordering failure.

## Evidence Check

The note must identify suspend or resume phase and the blocking device or task.

