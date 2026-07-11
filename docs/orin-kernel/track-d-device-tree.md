# Track D — Device Tree and Probe

## Outcome

Trace an active device-tree property through matching and resource acquisition,
then prove a minimal source-to-runtime correction.

## Prerequisites

Complete Tracks A and B for Orin work, or Track C for generic QEMU variants;
understand platform-driver matching and basic DTS syntax.

## Platform boundary

QEMU can reproduce generic matching, disabled-node, MMIO, IRQ, and deferred
probe errors. Tegra clock, reset, regulator, pinctrl, and active-board DTB
conclusions require Orin.

## Ordered lessons

| ID | Focus |
|---|---|
| D01 | Identify the active device tree |
| D02 | Decompile and compare the running DTB |
| D03 | Trace DTS include and override order |
| D04 | Match `compatible` to a driver |
| D05 | Diagnose a disabled node |
| D06 | Diagnose a missing MMIO resource |
| D07 | Diagnose an IRQ description error |
| D08 | Diagnose a clock dependency |
| D09 | Diagnose a reset dependency |
| D10 | Diagnose a regulator dependency |
| D11 | Diagnose a pinctrl state error |
| D12 | Diagnose `-EPROBE_DEFER` |
| D13 | Validate a DTB change on Orin |

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
