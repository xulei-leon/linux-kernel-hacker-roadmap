# Track E — Driver Lifecycle and Hardware I/O

## Outcome

Build drivers whose acquisition, asynchronous work, teardown, bus errors, DMA,
and runtime-PM behavior remain correct under failure and repeated reload.

## Prerequisites

Complete the relevant build/deployment lessons in Track B and the matching/probe
lessons in Track D; be able to build and load an out-of-tree module.

## Platform boundary

Platform-driver lifecycle, failure unwinding, work, timers, and generic PM
references work in QEMU. Physical I2C/SPI/GPIO, coherency, and SMMU conclusions
must be verified on Orin.

## Ordered lessons

| ID | Focus |
|---|---|
| E01 | Build a minimal platform driver |
| E02 | Handle probe error unwinding |
| E03 | Compare manual and `devm_*` management |
| E04 | Diagnose module reload failure |
| E05 | Prevent work after remove |
| E06 | Prevent timer use after remove |
| E07 | Implement a threaded IRQ |
| E08 | Diagnose an IRQ storm |
| E09 | Handle I2C transfer errors |
| E10 | Handle SPI transfer errors |
| E11 | Control GPIO ownership correctly |
| E12 | Handle DMA mapping failure |
| E13 | Diagnose DMA coherency errors |
| E14 | Analyze an SMMU fault |
| E15 | Balance runtime-PM references |

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
