# Device Tree and Driver Probe

## Outcome

Trace an active device-tree property through matching and resource acquisition,
then prove a minimal source-to-runtime correction.

## Prerequisites

Complete [Orin Platform Recovery](platform-recovery.md) and
[BSP Build and Deployment](bsp-build-and-deployment.md) for Orin work, or use
the [QEMU Debug Environment](qemu-debug-environment.md) for generic variants;
understand platform-driver matching and basic DTS syntax.

## Platform boundary

QEMU can reproduce generic matching, disabled-node, MMIO, IRQ, and deferred
probe errors. Tegra clock, reset, regulator, pinctrl, and active-board DTB
conclusions require Orin.

## Focus areas

- Identify the active device tree
- Decompile and compare the running DTB
- Trace DTS include and override order
- Match `compatible` to a driver
- Diagnose a disabled node
- Diagnose a missing MMIO resource
- Diagnose an IRQ description error
- Diagnose a clock dependency
- Diagnose a reset dependency
- Diagnose a regulator dependency
- Diagnose a pinctrl state error
- Diagnose `-EPROBE_DEFER`
- Validate a DTB change on Orin

## Concrete diagnostic decision

When `probe()` never appears, first decide whether the device object exists. A
missing device points to DT selection, node status, bus enumeration, or match
failure; a present device with a failed probe points to resource acquisition or
driver logic. Adding logs inside a probe that never runs cannot resolve the
first class.

## Lab and evidence policy

Generic lessons use a minimal platform driver and controlled DT variants. Orin
lessons preserve the active DTB, decompile the running tree, capture probe logs,
and verify the final runtime property. QEMU variants must state which Tegra
resource behavior remains unproven.

## Completion criteria

You can identify why a device did not bind, name the exact final DT property
responsible, and validate the correction without confusing source DTS with the
tree the board actually booted.
