# Driver Lifecycle and Hardware I/O

## Outcome

Build drivers whose acquisition, asynchronous work, teardown, bus errors, DMA,
and runtime-PM behavior remain correct under failure and repeated reload.

## Prerequisites

Complete the relevant [BSP Build and Deployment](bsp-build-and-deployment.md)
and [Device Tree and Driver Probe](device-tree-and-driver-probe.md) topics; be
able to build and load an out-of-tree module.

## Platform boundary

Platform-driver lifecycle, failure unwinding, work, timers, and generic PM
references work in QEMU. Physical I2C/SPI/GPIO, coherency, and SMMU conclusions
must be verified on Orin.

## Focus areas

- Build a minimal platform driver
- Handle probe error unwinding
- Compare manual and `devm_*` management
- Diagnose module reload failure
- Prevent work after remove
- Prevent timer use after remove
- Implement a threaded IRQ
- Diagnose an IRQ storm
- Handle I2C transfer errors
- Handle SPI transfer errors
- Control GPIO ownership correctly
- Handle DMA mapping failure
- Diagnose DMA coherency errors
- Analyze an SMMU fault
- Balance runtime-PM references

## Concrete diagnostic decision

For a failure after the third acquired resource, list ownership in acquisition
order and verify cleanup in reverse order. Then repeat probe/remove and forced
failure at every boundary. A successful first load does not prove correct
lifetime management.

## Demo and evidence policy

Generic lessons use small drivers with explicit fault-injection stages and safe
default behavior. Lifecycle lessons run at least 20 load/unload cycles. Hardware
lessons record the exact peripheral and never replace an unavailable bus with a
fabricated Tegra device.

## Completion criteria

You can demonstrate correct behavior for successful probe, each failed probe
stage, active operation, remove, asynchronous cancellation, and repeated reload.
