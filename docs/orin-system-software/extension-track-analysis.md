# Extension-Track Decision Analysis

**Status:** Decision support. These tracks are conditional options, not active
projects or current capability claims.

## Primary direction and boundary

The portfolio targets two roles:

- Senior System Software Engineer, CPU;
- Senior Software Engineer - Networking and Virtualization.

The [CPU project sequence](README.md) remains the current delivery core. A
networking-specific project must be designed and approved separately before it
becomes part of that core. Do not start an extension track in parallel with an
unfinished core project merely to broaden the portfolio.

This document answers one question for each extension: what evidence and
equipment must exist before the direction is worth a dedicated project?

## Direction comparison

| Direction | Portfolio value | Entry constraint | Decision priority |
|---|---|---|---|
| HPC/AI Networking | Deepens the networking target with RDMA data-path and performance evidence | Supported RDMA hardware, a peer, and a reproducible test topology | First extension when the hardware gate is met |
| Enterprise Solution | Adds container operations, reliability, and customer-issue diagnosis evidence | A supported Jetson container runtime and one reproducible inference workload | Alternative when enterprise platform roles become a target |
| Robotics DevTech | Adds ROS 2 integration, sensor reliability, and edge inference evidence | A real supported sensor and a working ROS 2 environment | Defer unless robotics becomes an active application target |

## HPC/AI Networking

### Why consider it?

This direction is useful only when it adds evidence beyond ordinary Linux
network benchmarking: RDMA device setup, transport behavior, CPU cost, latency,
throughput, and a defensible bottleneck investigation on ARM64.

### Entry gate

Start a project only after all of the following are available and recorded:

- an RDMA-capable NIC supported by the selected Jetson kernel and BSP;
- a compatible PCIe connection and a second RDMA endpoint;
- a direct or switched topology whose link mode and configuration can be
  captured;
- repeatable baseline commands and permission to retain raw measurements.

### Minimum project

Build an **ARM64 RDMA data-path performance investigation**. Compare one named
baseline and candidate configuration while holding hardware, topology,
workload, CPU affinity, power mode, and cooling constant. Preserve link,
driver, interrupt, throughput, latency, and CPU-profile evidence, then explain
one observed bottleneck or inconclusive result.

### Required evidence

- exact board, BSP, kernel, firmware, driver, NIC, peer, link, and topology;
- repeatable RDMA benchmark commands plus supported `perf`, `ftrace`,
  interrupt, and interface statistics;
- raw results from repeated runs and the rule used to compare them;
- one failure or regression investigation followed by a retest or documented
  disposition;
- a five-minute offline demonstration using live or clearly labeled retained
  evidence.

### Defer when

Do not start without supported RDMA hardware and a real peer. `iperf3`, network
namespaces, or a software-only setup can support the primary networking path,
but cannot be presented as RDMA, RoCE, NCCL, or multi-node AI networking
experience. Add NCCL claims only after running a supported multi-GPU workload
and retaining its actual communication evidence.

## Enterprise Solution

### Why consider it?

This direction converts Linux troubleshooting experience into a customer-style
incident narrative: reproduce a service failure, separate platform from
application causes, restore service, and document a bounded operational path.

### Entry gate

Start only after a Jetson-compatible container runtime and one fixed inference
workload run reproducibly outside and inside the selected container. Record the
BSP, runtime, image digest, model, inputs, and expected output before injecting
failures.

### Minimum project

Build a **containerized edge-inference incident lab**. Operate one inference
service, capture its healthy latency and throughput, reproduce one resource,
configuration, or service-lifecycle failure, diagnose it from retained system
and application evidence, apply the smallest fix, and retest the same input.

### Required evidence

- immutable container-image and workload identifiers plus exact run commands;
- health, service lifecycle, CPU/GPU, memory, thermal, and application logs;
- a concise incident record containing symptom, hypotheses, root cause, fix,
  rollback, and retest;
- a bounded recovery procedure and five-minute offline demonstration.

### Defer when

Do not add Kubernetes to the first project. A single Jetson cannot demonstrate
DGX or distributed-cluster operations, so limit claims to the container,
Linux, NVIDIA runtime, and failure paths actually exercised. Consider an
orchestrator only when a real multi-node deployment or target role requires
it.

## Robotics DevTech

### Why consider it?

This direction is valuable when it demonstrates reliable integration of a
real sensor, ROS 2 communication, inference, diagnostics, and recovery. It does
not require presenting the candidate as a robotics algorithm researcher.

### Entry gate

Start only after a supported camera or sensor produces repeatable data on the
Jetson and the chosen ROS 2 distribution runs on the recorded BSP. Fix the
message type, input rate, inference workload, and expected output before
measuring the pipeline.

### Minimum project

Build a **ROS 2 sensor-to-inference reliability pipeline**. Carry real sensor
data through ROS 2 to one inference result, measure end-to-end latency and loss,
then reproduce a sensor disconnect, stalled topic, or overloaded processing
path and demonstrate bounded detection and recovery.

### Required evidence

- board, BSP, ROS 2 distribution, sensor, message type, model, and launch
  configuration;
- retained sensor input or a clearly labeled replay, topic statistics,
  end-to-end timing, resource use, and thermal observations;
- one integration failure with diagnosis, recovery, and retest;
- a five-minute demonstration that distinguishes live input from replayed
  evidence.

### Defer when

Do not use synthetic-only input as proof of real sensor integration. Do not
claim Isaac, reinforcement learning, imitation learning, controls, or physics
simulation expertise unless a later project exercises those capabilities
directly and records reproducible evidence.

## Shared evidence gate

Any extension that becomes active must satisfy the portfolio-wide gate in the
[delivery roadmap](delivery-roadmap.md): source, exact build and run steps,
dependency versions, platform identity, automated checks, raw success and
failure evidence, bounded cleanup or recovery, one diagnosis and retest, and a
five-minute interview demonstration.

Label every result as Orin/ARM64, generic host, or simulation/replay evidence.
If an entry gate or required signal is missing, record the direction as
deferred or the result as inconclusive instead of upgrading it to a project or
capability claim.
