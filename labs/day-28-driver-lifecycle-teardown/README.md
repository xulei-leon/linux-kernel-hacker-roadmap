# Day 28: How do module, driver, and hotplug races fail at teardown?

## Platform

**Mode: Orin. Risk: low for the synthetic platform device.** Continue only
after `test -d "/lib/modules/$(uname -r)/build"` succeeds, load the supplied
self-contained module, unload it with
`rmmod platform_lifecycle_demo`, and confirm work and timer cleanup in the
final `dmesg` excerpt. Do not bind it to a real Tegra device.

## Problem

A module unload, device unbind, or hotplug operation crashes after the device appears removed. The symptom is often a UAF, warning, or hang during teardown.

## Kernel Mechanism

Drivers participate in the device model through probe and remove paths. Modules have reference counts. Devices may hold active users, sysfs references, work items, timers, IRQs, runtime PM state, and hotplug callbacks. Teardown must stop new users, drain asynchronous work, and release resources in a safe order.

## Problem Analysis

Identify ownership:

- Who owns the device object?
- Are file descriptors or subsystem users still active?
- Are work items, timers, IRQs, or NAPI instances still running?
- Did remove run while callbacks could still dereference state?
- Does the module refcount prevent unload?

Teardown bugs are lifetime bugs with more moving parts.

## Debug Path

Module and device state:

```sh
lsmod | grep <module>
readlink /sys/bus/<bus>/drivers/<driver>/<device>/driver
```

Bind/unbind lab operation:

```sh
echo <device> > /sys/bus/<bus>/drivers/<driver>/unbind
echo <device> > /sys/bus/<bus>/drivers/<driver>/bind
```

Driver core tracing discovery:

```sh
trace-cmd list -e '*driver*' '*module*' '*workqueue*' 'timer:*'
```

Lifecycle checklist:

```text
Module:
Device:
Active users:
Reference count signal:
Probe resources:
Remove order:
Work cleanup:
Timer cleanup:
IRQ/NAPI cleanup:
Device state after remove:
```

## Resolution

Fix direction often means cancelling delayed work, deleting timers with synchronization where required, disabling IRQ/NAPI before freeing state, and using existing subsystem reference helpers. Do not add a NULL check in a callback while the callback can still race with free.

## 1-Hour Output

Analyze one load/unload or hotplug failure and fill the lifecycle checklist.

## Evidence Check

The checklist must name refcount, active users, work or timer cleanup, and device state.
