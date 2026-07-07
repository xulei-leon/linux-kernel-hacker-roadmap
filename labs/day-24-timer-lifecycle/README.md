# Day 24: How do timer bugs create delayed or repeated failures?

## Problem

A failure happens later than the triggering action, repeats unexpectedly, or fires after teardown. The symptom points to timers, hrtimers, or delayed work.

## Kernel Mechanism

Kernel timers and hrtimers schedule callbacks in specific contexts. Delayed work combines a timer with workqueue execution. Jiffies-based timers and high-resolution timers differ in precision and callback context. Teardown must cancel timers safely before freeing state used by callbacks.

## Problem Analysis

Identify:

- Start site.
- Expiry time or delay calculation.
- Cancel or rearm site.
- Callback context.
- Object lifetime tied to the callback.
- Whether teardown races with callback execution.

Timer bugs often look like UAF, repeated timeout, or missing timeout.

## Debug Path

Trace timer events:

```sh
trace-cmd record \
  -e timer:timer_start \
  -e timer:timer_cancel \
  -e timer:timer_expire_entry \
  -e timer:hrtimer_start \
  -e timer:hrtimer_cancel \
  -e timer:hrtimer_expire_entry \
  -- sleep 10
trace-cmd report > timer-report.txt
```

Source review checklist:

```text
Timer object:
Start site:
Delay expression:
Expiry target:
Cancel site:
Uses del_timer_sync or equivalent:
Callback context constraints:
Object lifetime owner:
```

## Resolution

Classify:

- Missed cancel: callback runs after teardown.
- Wrong delay: timeout fires too early, too late, or wraps incorrectly.
- Bad callback context: callback sleeps or takes an unsafe lock.
- Repeated failure: callback re-arms unexpectedly or delayed work loops.

Fix the lifecycle edge. Do not only add a guard in the callback if teardown can still race.

## 1-Hour Output

Analyze one timeout symptom and fill the timer lifecycle note.

## Evidence Check

The note must state whether the failure is missed cancel, wrong delay, or bad callback context.

