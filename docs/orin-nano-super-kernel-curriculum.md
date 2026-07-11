# Jetson Orin Nano Super Linux Kernel Development Curriculum

## 1. Project Purpose

This document is the normative content specification for an advanced Linux
kernel development curriculum built around the NVIDIA Jetson Orin Nano Super
8GB Developer Kit. It defines what each lesson must teach, how experiments are
made reproducible, which evidence learners must collect, and when QEMU is a
valid substitute for the board.

The curriculum develops practical ability in four areas:

- producing maintainable kernel and driver changes;
- diagnosing failures from evidence instead of guesswork;
- measuring and improving kernel performance;
- understanding subsystem behavior through source paths and experiments.

Tracks are navigation groups, not lessons. Every numbered lesson addresses one
bounded problem and should fit an approximately one-hour learning or practice
unit. Broad survey articles do not satisfy this specification.

The initial platform baseline is JetPack 7.2, Jetson Linux 39.2, Linux 6.8,
and L4T Ubuntu 24.04. Content authors must verify these names and versions
against current NVIDIA documentation before publishing version-sensitive
commands.

## 2. Target Audience and Prerequisites

The intended reader can already:

- read and modify C kernel code;
- build and load a simple out-of-tree module;
- use Git, a shell, a compiler, and basic debugging tools;
- explain processes, virtual memory, interrupts, locking, and device drivers at
  an introductory level;
- recover a normal Linux development host after a failed experiment.

The curriculum is not a C course, an operating-systems survey, a Linux user
guide, or a fixed-duration training schedule. Short prerequisites may be linked
when needed, but a lesson must spend its time on a concrete kernel-development
problem.

## 3. Learning Outcomes

After completing the relevant tracks, a learner should be able to:

1. reproduce an Orin BSP build and deploy one artifact without unnecessarily
   reflashing the whole system;
2. trace a device from the active device tree through driver matching, probe,
   resource acquisition, operation, and teardown;
3. create a minimal reproducer and collect logs, traces, symbols, configuration,
   and workload data before proposing a fix;
4. distinguish an observed symptom, the fault exposure point, the triggering
   action, and the root cause;
5. diagnose common crash, memory, concurrency, interrupt, I/O, networking,
   power-management, and performance failures;
6. validate a fix with a negative check and a focused regression test;
7. state exactly which conclusions were demonstrated in QEMU and which still
   require Orin hardware;
8. prepare a small, reviewable kernel patch with an evidence-based commit
   message and test record.

## 4. Orin-First Platform Strategy

The Orin Nano Super is the authoritative platform for NVIDIA BSP behavior,
Tegra device trees, pin control, real GPIO/I2C/SPI devices, DMA and SMMU
behavior, clocks, regulators, system power states, thermal throttling, and
hardware performance. Results from another machine may guide a hypothesis but
cannot prove an Orin-specific conclusion.

Every lesson begins with exactly these fields:

```markdown
**Primary platform:** Jetson Orin Nano Super / QEMU / Either
**QEMU alternative:** Full / Partial / Not applicable
**Safety level:** S0 / S1 / S2 / S3
```

Expanded lesson files use the three-field block above. The compact catalog in
Section 8 combines the same data as `Platform; QEMU alternative; Safety` to keep
156 entries scannable. The permitted primary-platform values are `Orin only`,
`QEMU only`, `Either`, `Orin primary`, and `QEMU preferred`. `QEMU preferred`
means both platforms teach the generic mechanism but the safer default is QEMU.
The permitted QEMU-alternative values are `full`, `partial`, and `not
applicable`; a QEMU-only lesson always uses `not applicable` because QEMU is
already primary.

Use the following platform classifications in lesson prose:

- **Orin + QEMU:** both platforms teach the core skill; document both paths and
  their observable differences.
- **Orin primary, QEMU alternative:** QEMU teaches the generic mechanism, while
  final hardware validation remains on Orin.
- **QEMU only:** the experiment deliberately risks panic, lockup, or persistent
  corruption and has no requirement for real Tegra hardware.
- **Orin only:** the lesson depends on actual Jetson BSP or board behavior.
- **QEMU not applicable:** state why virtualization would not produce meaningful
  evidence. Do not add a ceremonial QEMU section.

The catalog phrases `Orin primary, QEMU alternative partial` and `Either, QEMU
alternative full` are compact forms of this taxonomy, not additional metadata
fields.

## 5. QEMU Alternative Strategy

QEMU gives learners without an Orin board an executable route through generic
ARM64 kernel skills. It is an auxiliary environment, not a model of the Tegra
SoC. The legacy numbered QEMU environment is to be retained, moved to
`labs/orin-kernel/qemu-auxiliary/`, and renamed without a Day number.

QEMU lessons should prefer real kernel facilities:

- the QEMU ARM64 `virt` machine and virtio console, block, and network devices;
- `dummy`, `loop`, `null_blk`, `scsi_debug`, and other in-tree test facilities;
- kernel fault injection, KUnit, and kselftest;
- KASAN, lockdep, KMEMLEAK, and KCSAN where supported by the selected kernel;
- the QEMU GDB stub, an initramfs or disposable root filesystem, and an
  automatically classified reproducer.

Never invent a Tegra device in QEMU, describe virtio behavior as Tegra driver
behavior, or use QEMU benchmark numbers as Orin performance evidence.

For a lesson with QEMU coverage, use these sections:

```markdown
## Orin Nano Super Path

## QEMU Alternative Path

## Result Comparison
```

For partial coverage, `Result Comparison` must identify the transferable
generic mechanism, the unproven Orin behavior, and the exact validation still
required on the board.

### QEMU coverage by track

| Track | QEMU role |
|---|---|
| A. Baseline and Recovery | Partial only for experiment classification; Jetson release, serial, flashing, and recovery evidence require Orin |
| B. BSP Source and Build | Partial: generic ARM64 builds are useful, but NVIDIA BSP deployment requires Orin |
| C. QEMU Environment | Full: the track creates the board-independent auxiliary environment |
| D. Device Tree and Probe | Partial: generic matching and resource errors are reproducible; Tegra resources are not |
| E. Driver Lifecycle | Broad generic coverage; real buses, DMA, and SMMU conclusions remain Orin-specific |
| F. Observability | Broad coverage for ftrace, perf, tracepoints, kprobes, and logging |
| G. Oops and Panic | Full and preferred for destructive exercises |
| H. Memory Failures | Broad coverage for UAF, overflow, leaks, allocation failure, and sanitizers |
| I. Concurrency and Stalls | Full for generic races, deadlocks, and stalls; destructive cases prefer QEMU |
| J. IRQ and Latency | Partial: mechanisms are teachable; real IRQ topology and latency require Orin |
| K. Storage and Filesystems | Generic paths and fault injection are teachable; Orin NVMe performance is not |
| L. Networking | Generic stack and virtual-driver work is teachable; Tegra MAC/PHY results require Orin |
| M. Power and Thermal | Partial: generic runtime-PM framework behavior transfers; sleep/wake state, frequency, and thermal evidence require Orin |
| N. Performance | Methods and tools transfer; measurements do not characterize Orin |
| O. Tests and Upstream | Broad coverage for tests, static analysis, bisect, reports, and patch preparation |

## 6. Safety and Recovery Policy

Every lab receives one safety level:

- **S0 — observation only:** read-only observation or an ordinary workload;
  safe for Orin.
- **S1 — recoverable module fault:** may emit a warning or fail an operation;
  Orin requires a working serial console and tested cleanup path.
- **S2 — kernel crash or loss of control:** may oops, panic, stall, or disconnect
  the board; run in QEMU by default.
- **S3 — persistent-state risk:** may corrupt a filesystem or durable state; run
  only with a disposable QEMU image.

Loading a demo module must never trigger the defect. A separate, explicit
action triggers it. S2 and S3 scripts must inspect both
`/proc/device-tree/model` and `/proc/device-tree/compatible`, fail closed when
the identity cannot be read, record the observed identity, and refuse known
Jetson hardware. An override is permitted only when the individual lesson
defines a narrowly justified board experiment, requires an explicit override
token, and records that token and justification in the evidence bundle.

S3 QEMU labs must use `-snapshot` or a fresh qcow2 overlay whose backing image
is read-only. Cleanup must discard the overlay and verify that a checksum or
read-only smoke test of the base image is unchanged.

Before any module-based lesson, check the running configuration for
`CONFIG_MODULE_SIG`, `CONFIG_MODULE_SIG_FORCE`, and the effective signature
enforcement state. Provide a lab signing workflow when enforcement is active;
do not instruct readers to disable Secure Boot globally as a convenience.

An Orin lesson that changes `Image`, a DTB, initramfs, modules, or boot arguments
must document the current artifact, the replacement, the selection mechanism,
the expected serial evidence, and the tested recovery command before making the
change.

## 7. Atomic Lesson Design

This section summarizes the design contract. Section 10 is the single
canonical, ordered lesson procedure; authors must not maintain a second local
variant. Each lesson must provide:

1. one problem statement and one measurable success criterion;
2. platform applicability, safety level, and recovery requirement;
3. required kernel configuration and tools;
4. a buggy demo, device-tree variant, fault injection, or real workload;
5. complete build, deployment, and load commands when those actions apply, or
   exact evidence-gathering commands for observation-only lessons;
6. a pre-trigger baseline;
7. one explicit and repeatable trigger;
8. stable expected log, trace, counter, or performance evidence;
9. a step-by-step path from evidence to source;
10. separation of symptom, exposure point, trigger, and root cause;
11. the smallest defensible fix and its reasoning;
12. a fixed demo or patch;
13. retest, negative verification, and regression checks;
14. cleanup or recovery steps;
15. one variation for independent practice;
16. a QEMU path, or a concise reason why QEMU is not applicable.

Expected-output checks must match stable features rather than addresses, PIDs,
timestamps, CPU numbers, or other run-specific values.

## 8. Track A–O Curriculum

The platform notation below is normative. `Partial` means the lesson must state
what QEMU teaches and what still requires Orin.

### Track A — Orin Baseline and Recovery

- **A01 Identify the exact Orin platform.** Record module, carrier board, RAM,
  SoC revision, JetPack, L4T, and kernel. **Platform:** Orin only; QEMU not
  applicable; **Safety:** S0.
- **A02 Capture a reproducible software baseline.** Save release metadata,
  config, modules, command line, DTB identity, and packages. **Platform:** Orin
  only; QEMU not applicable; **Safety:** S0.
- **A03 Establish serial evidence collection.** Capture UEFI through user-space
  boot logs and prove they belong to the experiment. **Platform:** Orin only;
  QEMU not applicable; **Safety:** S0.
- **A04 Enter Force Recovery Mode safely.** Verify USB enumeration and host-side
  recovery tooling. **Platform:** Orin only; QEMU not applicable; **Safety:** S0.
- **A05 Back up boot-critical artifacts.** Preserve kernel, DTB, initramfs,
  modules, and boot selection state. **Platform:** Orin only; QEMU not
  applicable; **Safety:** S0.
- **A06 Recover from an unbootable kernel.** Use a controlled failure and the
  previously tested fallback. **Platform:** Orin only; QEMU not applicable;
  **Safety:** S1.
- **A07 Build an experiment safety matrix.** Classify planned experiments and
  assign Orin or QEMU execution. **Platform:** Orin primary, QEMU alternative
  partial; **Safety:** S0.

### Track B — BSP Source and Build

- **B01 Map Jetson Linux BSP components.** Separate kernel, NVIDIA modules,
  device trees, bootloader, rootfs, and tools. **Platform:** Orin primary, QEMU
  alternative partial; **Safety:** S0.
- **B02 Match source to the running release.** Verify tag, L4T release, kernel
  release, and module vermagic. **Platform:** Orin only; QEMU not applicable;
  **Safety:** S0.
- **B03 Prepare ARM64 cross-compilation.** Make toolchain, output directory, and
  environment reproducible. **Platform:** Either; QEMU alternative full;
  **Safety:** S0.
- **B04 Reproduce the vendor kernel configuration.** Obtain the correct config
  and reconcile it with `olddefconfig`. **Platform:** Orin primary, QEMU
  alternative partial; **Safety:** S0.
- **B05 Build only the kernel image.** Verify architecture, release string,
  symbols, and output. **Platform:** Either; QEMU alternative full; **Safety:** S0.
- **B06 Build only kernel modules.** Stage modules and verify dependency and
  vermagic data. **Platform:** Either; QEMU alternative full; **Safety:** S0.
- **B07 Build device trees separately.** Locate the actual board outputs.
  **Platform:** Orin primary, QEMU alternative partial; **Safety:** S0.
- **B08 Use incremental builds correctly.** Observe which targets rebuild after
  source, config, module, and DTS changes. **Platform:** Either; QEMU alternative
  full; **Safety:** S0.
- **B09 Deploy a kernel without a full reflash.** Retain a bootable fallback.
  **Platform:** Orin only; QEMU not applicable; **Safety:** S1.
- **B10 Deploy modules without version mismatch.** Install, run `depmod`, and
  diagnose symbol or vermagic failures. **Platform:** Orin + QEMU; QEMU
  alternative full; **Safety:** S1.
- **B11 Deploy a DTB with rollback.** Prove which DTB the boot entry loads.
  **Platform:** Orin only; QEMU not applicable; **Safety:** S1.
- **B12 Diagnose a build failure.** Find the first actionable compiler error
  instead of a later cascade. **Platform:** Either; QEMU alternative full;
  **Safety:** S0.

### Track C — QEMU Auxiliary Environment

- **C01 Build an ARM64 kernel for QEMU.** Preserve and rename the legacy QEMU
  build workflow. **Platform:** QEMU only; QEMU alternative not applicable; **Safety:** S0.
- **C02 Boot a minimal ARM64 root filesystem.** Verify console, rootfs, modules,
  and exit state. **Platform:** QEMU only; QEMU alternative not applicable; **Safety:** S0.
- **C03 Debug early boot with the GDB stub.** Load `vmlinux`, break, inspect, and
  continue. **Platform:** QEMU only; QEMU alternative not applicable; **Safety:** S0.
- **C04 Preserve evidence after panic.** Save console, QEMU arguments, config,
  and trigger. **Platform:** QEMU only; QEMU alternative not applicable; **Safety:** S2.
- **C05 Restore a disposable image.** Return an S3 experiment to a known state.
  **Platform:** QEMU only; QEMU alternative not applicable; **Safety:** S3.
- **C06 Run an automated reproducer.** Use timeouts, exit codes, and stable log
  classification. **Platform:** QEMU only; QEMU alternative not applicable; **Safety:** S2.
- **C07 Drive `git bisect run` with QEMU.** Build, boot, test, and classify
  good/bad/skip. **Platform:** QEMU only; QEMU alternative not applicable; **Safety:** S2.

### Track D — Device Tree and Probe

- **D01 Identify the active device tree.** Confirm model, compatible, and key
  runtime nodes. **Platform:** Orin only; QEMU not applicable; **Safety:** S0.
- **D02 Decompile and compare the running DTB.** Explain source versus runtime
  differences. **Platform:** Orin primary, QEMU alternative partial; **Safety:** S0.
- **D03 Trace DTS include and override order.** Find original and final property
  values. **Platform:** Orin primary, QEMU alternative partial; **Safety:** S0.
- **D04 Match `compatible` to a driver.** Fix a deliberately mismatched minimal
  platform driver. **Platform:** Orin + QEMU; QEMU alternative full; **Safety:** S1.
- **D05 Diagnose a disabled node.** Show how `status` prevents instantiation.
  **Platform:** Orin primary, QEMU alternative full; **Safety:** S1.
- **D06 Diagnose a missing MMIO resource.** Trace a bad `reg` to probe failure.
  **Platform:** Orin primary, QEMU alternative full; **Safety:** S1.
- **D07 Diagnose an IRQ description error.** Isolate parent, specifier, and
  trigger-type errors. **Platform:** Orin primary, QEMU alternative partial;
  **Safety:** S1.
- **D08 Diagnose a clock dependency.** Separate wrong names, missing clocks, and
  an unready provider. **Platform:** Orin only; QEMU not applicable; **Safety:** S1.
- **D09 Diagnose a reset dependency.** Verify acquisition, deassertion, and
  rollback. **Platform:** Orin only; QEMU not applicable; **Safety:** S1.
- **D10 Diagnose a regulator dependency.** Fix supply naming and enable-order
  failures. **Platform:** Orin only; QEMU not applicable; **Safety:** S1.
- **D11 Diagnose a pinctrl state error.** Analyze mux, function, pull, and
  default state. **Platform:** Orin only; QEMU not applicable; **Safety:** S1.
- **D12 Diagnose `-EPROBE_DEFER`.** Distinguish normal deferral, absent provider,
  and dependency cycles. **Platform:** Orin + QEMU; QEMU alternative full;
  **Safety:** S1.
- **D13 Validate a DTB change on Orin.** Complete source-to-runtime proof.
  **Platform:** Orin only; QEMU not applicable; **Safety:** S1.

### Track E — Driver Lifecycle and Hardware I/O

- **E01 Build a minimal platform driver.** Implement match, probe, logging, and
  remove. **Platform:** Orin + QEMU; QEMU alternative full; **Safety:** S1.
- **E02 Handle probe error unwinding.** Inject failure at each acquisition step
  and verify reverse cleanup. **Platform:** Orin + QEMU; QEMU alternative full;
  **Safety:** S1.
- **E03 Compare manual and `devm_*` management.** Demonstrate lifetime and
  ordering differences. **Platform:** Orin + QEMU; QEMU alternative full;
  **Safety:** S1.
- **E04 Diagnose module reload failure.** Leave and then fix a registered
  resource. **Platform:** Orin + QEMU; QEMU alternative full; **Safety:** S1.
- **E05 Prevent work after remove.** Reproduce asynchronous access after state
  teardown. **Platform:** Orin + QEMU; QEMU alternative full; **Safety:** S1.
- **E06 Prevent timer use after remove.** Fix a timer teardown race. **Platform:**
  Orin + QEMU; QEMU alternative full; **Safety:** S1.
- **E07 Implement a threaded IRQ.** Separate hard-handler and thread duties.
  **Platform:** Orin primary, QEMU alternative partial; **Safety:** S1.
- **E08 Diagnose an IRQ storm.** Correlate event rate, handler return, and
  masking. **Platform:** Orin primary, QEMU alternative partial; **Safety:** S1.
- **E09 Handle I2C transfer errors.** Test NACK, short transfer, and retry policy.
  **Platform:** Orin primary, QEMU alternative partial; **Safety:** S1.
- **E10 Handle SPI transfer errors.** Verify completion, errors, and buffer
  lifetime. **Platform:** Orin primary, QEMU alternative partial; **Safety:** S1.
- **E11 Control GPIO ownership correctly.** Verify descriptor ownership,
  direction, polarity, and release. **Platform:** Orin only; QEMU not applicable;
  **Safety:** S1.
- **E12 Handle DMA mapping failure.** Check mapping, direction, and unmap
  symmetry. **Platform:** Orin primary, QEMU alternative partial; **Safety:** S1.
- **E13 Diagnose DMA coherency errors.** Explain CPU/device ownership and sync
  operations. **Platform:** Orin only; QEMU not applicable; **Safety:** S1.
- **E14 Analyze an SMMU fault.** Map fault evidence to device and DMA path.
  **Platform:** Orin only; QEMU not applicable; **Safety:** S1.
- **E15 Balance runtime-PM references.** Reproduce and fix a leaked reference.
  **Platform:** Orin primary, QEMU alternative partial; **Safety:** S1.

### Track F — Observability

- **F01 Write useful `printk` diagnostics.** Include level, device, state, and
  actionable context. **Platform:** Either; QEMU alternative full; **Safety:** S0.
- **F02 Control dynamic debug.** Target a file, function, and module, then turn
  output off. **Platform:** Orin + QEMU; QEMU alternative full; **Safety:** S0.
- **F03 Prevent log flooding.** Apply rate limiting or state-transition logging.
  **Platform:** Orin + QEMU; QEMU alternative full; **Safety:** S1.
- **F04 Capture a tracepoint.** Enable, trigger, save, and interpret one event.
  **Platform:** Orin + QEMU; QEMU alternative full; **Safety:** S0.
- **F05 Trace a function with ftrace.** Use function and function-graph tracing.
  **Platform:** Orin + QEMU; QEMU alternative full; **Safety:** S0.
- **F06 Save reproducible `trace-cmd` evidence.** Preserve trace data and
  environment. **Platform:** Orin + QEMU; QEMU alternative full; **Safety:** S0.
- **F07 Add a custom tracepoint.** Expose stable structured state. **Platform:**
  Orin + QEMU; QEMU alternative full; **Safety:** S1.
- **F08 Use a kprobe for a bounded question.** Handle symbols and ARM64 argument
  details. **Platform:** Orin + QEMU; QEMU alternative full; **Safety:** S1.
- **F09 Profile kernel CPU samples with `perf`.** Resolve symbols and call
  stacks. **Platform:** Orin + QEMU; QEMU alternative full; **Safety:** S0.
- **F10 Choose ftrace, perf, or bpftrace.** Compare evidence and overhead on one
  problem. **Platform:** Orin + QEMU; QEMU alternative full; **Safety:** S0.
- **F11 Measure instrumentation overhead.** Compare a controlled baseline with
  probes enabled. **Platform:** Orin primary, QEMU alternative partial;
  **Safety:** S0.

### Track G — Oops and Panic

- **G01 Decode a NULL dereference.** Locate fault address, PC, LR, stack, and
  source line. **Platform:** QEMU preferred; QEMU alternative full; **Safety:** S2.
- **G02 Decode an invalid function pointer.** Distinguish data and instruction
  faults. **Platform:** QEMU only; QEMU alternative not applicable; **Safety:** S2.
- **G03 Decode an out-of-bounds exposure.** Explain why corruption may surface
  later. **Platform:** QEMU only; QEMU alternative not applicable; **Safety:** S2.
- **G04 Compare WARN, BUG, oops, and panic.** Observe taint and continuation
  behavior. **Platform:** QEMU only; QEMU alternative not applicable; **Safety:** S2.
- **G05 Analyze an explicit panic.** Preserve evidence and recovery behavior.
  **Platform:** QEMU only; QEMU alternative not applicable; **Safety:** S2.
- **G06 Analyze kernel stack overflow.** Recognize recursion and damaged
  backtraces. **Platform:** QEMU only; QEMU alternative not applicable; **Safety:** S2.
- **G07 Decode a module address.** Use section addresses, symbols, `addr2line`,
  and disassembly. **Platform:** QEMU preferred; QEMU alternative full;
  **Safety:** S2.
- **G08 Separate trigger from root cause.** Use delayed list corruption to find
  the earlier defect. **Platform:** QEMU only; QEMU alternative not applicable; **Safety:** S2.

### Track H — Memory Failures

- **H01 Diagnose slab use-after-free.** Interpret allocation, free, and access
  stacks from KASAN. **Platform:** QEMU preferred; QEMU alternative full;
  **Safety:** S2.
- **H02 Diagnose slab/kmalloc out-of-bounds access.** Interpret object bounds, access size, and
  shadow data. **Platform:** QEMU preferred; QEMU alternative full; **Safety:** S2.
- **H03 Diagnose double free.** Compare allocator diagnostics and KASAN.
  **Platform:** QEMU only; QEMU alternative not applicable; **Safety:** S2.
- **H04 Diagnose a memory leak.** Use KMEMLEAK plus a module object count.
  **Platform:** Orin + QEMU; QEMU alternative full; **Safety:** S1.
- **H05 Handle allocation failure.** Inject failure at each allocation site.
  **Platform:** Orin + QEMU; QEMU alternative full; **Safety:** S1.
- **H06 Diagnose uninitialized state.** Make the result deterministic and apply
  compiler/static evidence. **Platform:** Orin + QEMU; QEMU alternative full;
  **Safety:** S1.
- **H07 Diagnose memory pressure.** Observe reclaim, compaction, and allocation
  latency. **Platform:** Orin primary, QEMU alternative partial; **Safety:** S1.
- **H08 Diagnose an OOM kill.** Read allocation context, memory state, victim,
  and memcg boundary. **Platform:** QEMU preferred; QEMU alternative full;
  **Safety:** S2.
- **H09 Diagnose a memcg limit failure.** Separate local cgroup exhaustion from
  system exhaustion. **Platform:** Orin + QEMU; QEMU alternative full;
  **Safety:** S1.
- **H10 Diagnose a page-reference leak.** Omit and restore a page put, then
  verify counts. **Platform:** Orin + QEMU; QEMU alternative full; **Safety:** S1.

### Track I — Concurrency and CPU Stalls

- **I01 Diagnose lock-order inversion.** Use lockdep on a two-lock cycle.
  **Platform:** QEMU preferred; QEMU alternative full; **Safety:** S2.
- **I02 Diagnose self-deadlock.** Reacquire a non-recursive mutex. **Platform:**
  QEMU only; QEMU alternative not applicable; **Safety:** S2.
- **I03 Diagnose sleeping in atomic context.** Decode the warning and held-lock
  path. **Platform:** QEMU preferred; QEMU alternative full; **Safety:** S2.
- **I04 Diagnose a lost update.** Compare unprotected, atomic, locked, and
  per-CPU counters. **Platform:** Orin + QEMU; QEMU alternative full; **Safety:** S1.
- **I05 Diagnose teardown use-after-free.** Race asynchronous work with object
  release. **Platform:** QEMU preferred; QEMU alternative full; **Safety:** S2.
- **I06 Diagnose a lost wakeup.** Reconstruct state and wake order from traces.
  **Platform:** Orin + QEMU; QEMU alternative full; **Safety:** S1.
- **I07 Diagnose completion misuse.** Compare one-shot use, reuse, and incorrect
  reinitialization. **Platform:** Orin + QEMU; QEMU alternative full;
  **Safety:** S1.
- **I08 Diagnose an RCU lifetime error.** Restore the required grace period.
  **Platform:** QEMU preferred; QEMU alternative full; **Safety:** S2.
- **I09 Diagnose a hung task.** Find the blocked stack and resource owner.
  **Platform:** QEMU preferred; QEMU alternative full; **Safety:** S2.
- **I10 Diagnose a soft lockup.** Run a busy loop longer than the configured
  `watchdog_thresh` and match the stable `soft lockup` warning signature.
  **Platform:** QEMU only; QEMU alternative not applicable; **Safety:** S2.
- **I11 Diagnose hard-lockup detection feasibility.** Preflight the selected
  ARM64 kernel and virtual watchdog to prove that a hard-lockup report can be
  generated before running the trigger; otherwise analyze the detector gap
  without claiming reproduction. **Platform:** QEMU only; QEMU alternative not
  applicable; **Safety:** S2.
- **I12 Diagnose an RCU stall.** Separate a long read-side section from a CPU
  lockup. **Platform:** QEMU only; QEMU alternative not applicable; **Safety:** S2.

### Track J — IRQ, Deferred Work, and Latency

- **J01 Measure IRQ distribution.** Associate devices, CPUs, counts, and
  affinity. **Platform:** Orin primary, QEMU alternative partial; **Safety:** S0.
- **J02 Diagnose a long hard-IRQ handler.** Demonstrate propagation of handler
  delay. **Platform:** Orin primary, QEMU alternative full; **Safety:** S1.
- **J03 Move work to a threaded IRQ.** Repair J02 and compare latency.
  **Platform:** Orin primary, QEMU alternative full; **Safety:** S1.
- **J04 Diagnose softirq saturation.** Combine counters, traces, and CPU
  profiles. **Platform:** Orin primary, QEMU alternative partial; **Safety:** S1.
- **J05 Diagnose a workqueue stall.** Trace queue, start, finish, and waiter.
  **Platform:** Orin + QEMU; QEMU alternative full; **Safety:** S1.
- **J06 Diagnose workqueue starvation.** Show shared-pool concurrency limits.
  **Platform:** Orin + QEMU; QEMU alternative full; **Safety:** S1.
- **J07 Diagnose timer teardown races.** Race callback with remove and fix it.
  **Platform:** QEMU preferred; QEMU alternative full; **Safety:** S2.
- **J08 Measure scheduler wakeup latency.** Build a wake-to-run timeline.
  **Platform:** Orin primary, QEMU alternative partial; **Safety:** S0.
- **J09 Separate IRQ and scheduler latency.** Combine timerlat, osnoise, and
  ftrace. **Platform:** Orin primary, QEMU alternative partial; **Safety:** S0.
- **J10 Diagnose affinity-induced latency.** Compare poor and balanced task/IRQ
  placement. **Platform:** Orin primary, QEMU alternative partial; **Safety:** S0.

### Track K — Storage and Filesystems

- **K01 Trace a read to the block layer.** Connect syscall, VFS, cache,
  filesystem, and request. **Platform:** Orin + QEMU; QEMU alternative full;
  **Safety:** S0.
- **K02 Trace write and writeback.** Separate write return, dirtying, and device
  completion. **Platform:** Orin + QEMU; QEMU alternative full; **Safety:** S0.
- **K03 Diagnose page-cache miss latency.** Compare controlled hot and cold
  cache cases. **Platform:** Orin + QEMU; QEMU alternative full; **Safety:** S0.
- **K04 Diagnose writeback throttling.** Observe dirty limits and task blocking.
  **Platform:** Orin + QEMU; QEMU alternative full; **Safety:** S1.
- **K05 Diagnose filesystem lock contention.** Require lock evidence rather than
  infer from I/O wait. **Platform:** Orin + QEMU; QEMU alternative partial;
  **Safety:** S1.
- **K06 Diagnose block tail latency.** Measure issue, dispatch, and completion.
  **Platform:** Orin primary, QEMU alternative partial; **Safety:** S0.
- **K07 Diagnose I/O error propagation.** Inject an error and follow it to user
  space. **Platform:** QEMU only; QEMU alternative not applicable; **Safety:** S3.
- **K08 Diagnose Orin NVMe throughput regression.** Control filesystem, queue,
  power, and temperature. **Platform:** Orin only; QEMU not applicable;
  **Safety:** S0.
- **K09 Separate storage and reclaim stalls.** Correlate block traces, reclaim
  events, and task stacks. **Platform:** Orin primary, QEMU alternative partial;
  **Safety:** S1.

### Track L — Networking

- **L01 Trace packet receive.** Connect IRQ/NAPI to socket receive. **Platform:**
  Orin primary, QEMU alternative partial; **Safety:** S0.
- **L02 Trace packet transmit.** Connect socket send, qdisc, driver queue, and
  completion. **Platform:** Orin primary, QEMU alternative partial; **Safety:** S0.
- **L03 Locate a packet-drop layer.** Eliminate interface, driver, stack, qdisc,
  and socket causes. **Platform:** Orin primary, QEMU alternative partial;
  **Safety:** S0.
- **L04 Diagnose NAPI budget exhaustion.** Correlate poll budget and softirq
  load; use virtio-net only for the generic mechanism. **Platform:** Orin
  primary, QEMU alternative partial; **Safety:** S0.
- **L05 Diagnose network IRQ imbalance.** Compare queue and CPU distribution.
  Virtio-net can train queue inspection but cannot prove Tegra NIC behavior.
  **Platform:** Orin primary, QEMU alternative partial; **Safety:** S0.
- **L06 Diagnose RX queue imbalance.** Test RSS/RPS changes. **Platform:** Orin
  primary, QEMU alternative partial; **Safety:** S0.
- **L07 Diagnose TX queue congestion.** Separate qdisc, driver queue, and device
  completion. **Platform:** Orin primary, QEMU alternative partial; **Safety:** S0.
- **L08 Diagnose network teardown races.** Use a minimal virtual network driver.
  **Platform:** Orin + QEMU; QEMU alternative full; **Safety:** S1.
- **L09 Diagnose TCP retransmissions.** Relate retransmission to loss,
  congestion, MTU, and peer behavior. **Platform:** Orin + QEMU; QEMU
  alternative partial; **Safety:** S0.
- **L10 Diagnose TCP throughput regression.** Control offload, window, CPU,
  peer, and duration. **Platform:** Orin primary, QEMU alternative partial;
  **Safety:** S0.

### Track M — Power, Thermal, and Frequency

- **M01 Identify the active power mode.** Record power limits and CPU/GPU/memory
  frequencies. **Platform:** Orin only; QEMU not applicable; **Safety:** S0.
- **M02 Trace CPU frequency changes.** Relate governor, load, frequency, and
  benchmark. **Platform:** Orin only; QEMU not applicable; **Safety:** S0.
- **M03 Diagnose thermal throttling.** Build a temperature-frequency-performance
  timeline. **Platform:** Orin only; QEMU not applicable; **Safety:** S0.
- **M04 Diagnose a runtime-PM reference leak.** Observe and repair an unbalanced
  usage count. **Platform:** Orin primary, QEMU alternative partial; **Safety:** S1.
- **M05 Diagnose runtime suspend failure.** Trace callback error and retained
  resources. **Platform:** Orin primary, QEMU alternative partial; **Safety:** S1.
- **M06 Diagnose runtime resume failure.** Trace caller response and device
  state. **Platform:** Orin primary, QEMU alternative partial; **Safety:** S1.
- **M07 Diagnose system suspend entry failure.** Find the failing device
  callback. **Platform:** Orin only; QEMU not applicable; **Safety:** S1.
- **M08 Diagnose system resume hang.** Require serial recovery on Orin or use
  QEMU for generic callback practice. **Platform:** Orin primary, QEMU
  alternative partial; **Safety:** S2.
- **M09 Diagnose unexpected wakeups.** Connect wake source, IRQ, and device
  state. **Platform:** Orin only; QEMU not applicable; **Safety:** S0.
- **M10 Separate power limits from regressions.** Repeat under fixed mode,
  cooling, and frequency conditions. **Platform:** Orin only; QEMU not
  applicable; **Safety:** S0.

### Track N — Performance Engineering

- **N01 Define a reproducible benchmark.** Fix input, warmup, repetitions,
  environment, and storage. **Platform:** Orin primary, QEMU alternative full;
  **Safety:** S0.
- **N02 Quantify measurement noise.** Decide whether an observed change exceeds
  normal variance. **Platform:** Orin primary, QEMU alternative full;
  **Safety:** S0.
- **N03 Profile CPU hotspots.** Progress from `perf stat` to samples and source.
  **Platform:** Orin + QEMU; QEMU alternative full; **Safety:** S0.
- **N04 Analyze kernel call graphs.** Capture reliable stacks and repair symbol
  gaps. **Platform:** Orin + QEMU; QEMU alternative full; **Safety:** S0.
- **N05 Diagnose cache-miss bottlenecks.** Use a switchable access-pattern demo
  and PMU events. **Platform:** Orin primary, QEMU alternative partial;
  **Safety:** S0.
- **N06 Diagnose lock contention.** Use a high-contention module and lock
  evidence. **Platform:** Orin + QEMU; QEMU alternative full; **Safety:** S1.
- **N07 Diagnose memory-bandwidth saturation.** Separate compute and bandwidth
  limits. **Platform:** Orin only; QEMU not applicable; **Safety:** S0.
- **N08 Diagnose IRQ-driven performance loss.** Relate rate and CPU time to
  throughput. **Platform:** Orin primary, QEMU alternative partial; **Safety:** S0.
- **N09 Compare a candidate optimization.** Report effect size, variance, and
  side effects. **Platform:** Orin primary, QEMU alternative partial;
  **Safety:** S0.
- **N10 Automate performance bisect.** Define thresholds, retries, and skip
  conditions. **Platform:** Orin primary, QEMU alternative partial; **Safety:** S0.

### Track O — Tests, Reports, and Upstream Work

- **O01 Turn a demo into KUnit.** Isolate hardware-independent defect logic.
  **Platform:** Orin + QEMU; QEMU alternative full; **Safety:** S0.
- **O02 Turn a reproducer into kselftest.** Automate setup, trigger, assertion,
  and cleanup. **Platform:** Orin + QEMU; QEMU alternative full; **Safety:** S1.
- **O03 Test probe failure paths.** Inject failure at each resource stage.
  **Platform:** Orin + QEMU; QEMU alternative full; **Safety:** S1.
- **O04 Repeat load and unload.** Run at least 20 cycles and check resources and
  logs. **Platform:** Orin + QEMU; QEMU alternative full; **Safety:** S1.
- **O05 Use sparse on a driver.** Investigate address-space, type, and locking
  reports. **Platform:** Either; QEMU alternative full; **Safety:** S0.
- **O06 Use Smatch on error paths.** Review returns, releases, and state
  propagation. **Platform:** Either; QEMU alternative full; **Safety:** S0.
- **O07 Write a root-cause report.** Record environment, reproduction, evidence,
  path, cause, fix, and verification. **Platform:** Either; QEMU alternative
  full; **Safety:** S0.
- **O08 Produce a minimal fix.** Remove changes unrelated to the demonstrated
  cause. **Platform:** Either; QEMU alternative full; **Safety:** S0.
- **O09 Write a regression test.** Prove failure before and success after the
  fix. **Platform:** Orin + QEMU; QEMU alternative full; **Safety:** S1.
- **O10 Determine BSP versus upstream ownership.** Decide where the defect and
  fix belong. **Platform:** Orin primary, QEMU alternative partial; **Safety:** S0.
- **O11 Prepare an upstream commit message.** Explain problem, cause, fix,
  impact, provenance, and tests. **Platform:** Either; QEMU alternative full;
  **Safety:** S0.
- **O12 Prepare a reviewable patch series.** Split dependencies and publish a
  verification matrix. **Platform:** Either; QEMU alternative full;
  **Safety:** S0.

## 9. Demo Module Specification

When a module is the smallest truthful reproducer, use this layout:

```text
labs/orin-kernel/<lesson-id>-<topic>/
├── README.md
├── module/
│   ├── Makefile
│   ├── <topic>_demo.c
│   └── <topic>_fixed.c
├── scripts/
│   ├── build.sh
│   ├── load.sh
│   ├── trigger.sh
│   ├── collect.sh
│   ├── verify-fixed.sh
│   └── cleanup.sh
├── qemu/
│   ├── run.sh
│   └── lab.env.example
└── expected/
    ├── failure-patterns.txt
    └── fixed-result.txt
```

Create `qemu/` only when that lesson has a useful QEMU path. Reuse the shared
`labs/orin-kernel/qemu-auxiliary/` build and boot infrastructure; lesson
directories contain only lesson-specific arguments, rootfs additions, or
trigger logic.

Where appropriate, demos expose:

```text
/sys/kernel/debug/orin_kernel_lab/<demo>/trigger
/sys/kernel/debug/orin_kernel_lab/<demo>/status
/sys/kernel/debug/orin_kernel_lab/<demo>/reset
```

`trigger` must be created with mode `0600`, reject callers without
`CAP_SYS_ADMIN` (or a narrower capability justified by the lesson), and require
an explicit lesson-specific token. Group- or world-writable trigger nodes are
forbidden. `status` reports state and trigger count. Recoverable demos
provide `reset`. Module parameters must not silently enable the bug. A single
source file with an explicit bug/fixed mode is an allowed alternative to the
preferred two-file layout when it is clearer, but the safe behavior remains the
default.

Do not force every lesson into a module. Use an in-tree test facility, fault
injection, a controlled workload, a device-tree variant, or a real peripheral
when that produces more truthful evidence.

## 10. Required Lesson Procedure

A completed lesson follows this order:

1. **Problem and outcome:** define the symptom and the evidence the learner
   must produce.
2. **Platform and safety:** provide the three mandatory metadata fields and
   recovery prerequisites.
3. **Mechanism:** explain only the kernel concepts needed to reason about this
   fault.
4. **Source walkthrough:** identify the deliberate defect without yet giving
   away every diagnostic conclusion.
5. **Environment check:** verify kernel release, config symbols, tools, symbols,
   debugfs, free storage, and serial capture as applicable.
6. **Build and deploy:** give exact commands and expected artifacts.
7. **Baseline:** capture the quiet-state logs, counters, trace settings, and
   workload result.
8. **Trigger:** perform one explicit action and record its expected stable
   signature.
9. **Evidence collection:** save relevant logs, traces, stacks, symbol data,
   configuration, and workload output before changing the system.
10. **Localization:** decode evidence and follow the shortest source path to the
    defective statement or state transition.
11. **Root cause:** distinguish the underlying invalid assumption from the line
    where the kernel finally reports damage.
12. **Minimal fix:** show the change and explain lifetime, locking, ordering,
    error-propagation, or performance reasoning.
13. **Retest:** rebuild and repeat the identical trigger.
14. **Negative verification:** prove the original warning, leak, stall, error,
    or regression no longer occurs.
15. **Cleanup:** unload, restore boot artifacts or trace state, and verify a
    reusable environment.
16. **Transfer exercise:** alter one condition so the learner repeats the
    method without copying the answer.

## 11. Repository and Navigation Structure

The first restructuring change creates only real entry points and migrated
content:

```text
docs/
└── orin-nano-super-kernel-curriculum.md
labs/
└── orin-kernel/
    └── qemu-auxiliary/
resources/
└── orin-kernel/
    └── README.md
```

Later lessons use:

```text
docs/orin-kernel/<lesson-id>-<topic>.md
labs/orin-kernel/<lesson-id>-<topic>/
```

Do not pre-create empty Track directories, lesson directories, or placeholder
files. The lesson ID supplies ordering; the Track is navigation metadata.

The eventual cleanup removes old course documents, `labs/common`, and old
Day-numbered labs other than the QEMU content being migrated. `README.md`,
`index.md`, and `.vitepress/config.mts` must then link only to real new content
and the renamed QEMU environment. This specification does not itself perform
that cleanup.

| Existing path or reference | Required migration action |
|---|---|
| `labs/day-00-kernel-build-environment/` | Move the reusable QEMU content to `labs/orin-kernel/qemu-auxiliary/` and remove the numbered name |
| `labs/day-01-*` through `labs/day-30-*` | Remove; do not map them into the new curriculum |
| `labs/common/` | Remove after moving any helper still required by the retained QEMU environment into that environment |
| `docs/00-foundation/` through `docs/06-code-quality/` and old course documents | Remove obsolete scaffolding and content; retain this specification |
| existing `resources/` content | Replace with verified Orin curriculum resources under `resources/orin-kernel/` |
| `README.md`, `index.md`, `.vitepress/config.mts`, and internal Markdown links | Update in the same change as the moves/removals; enable a scoped dead-link failure instead of relying on `ignoreDeadLinks: true` |

## 12. Content Development Order

Content should be developed in vertical slices that leave a runnable result:

1. migrate and verify the shared QEMU environment (Track C);
2. write Orin baseline, serial, backup, and recovery lessons (A01–A06);
3. write the reproducible BSP build and deployment path (B01–B12);
4. establish demo conventions through E01, E02, F01, and F04;
5. deliver one complete crash slice (G01), memory slice (H01), and concurrency
   slice (I01), including buggy code, analysis, fix, and automated checks;
6. expand the remaining failure lessons one at a time;
7. add hardware-specific device-tree, bus, SMMU, storage, networking, power,
   and performance lessons only when they can be verified on the fixed Orin
   baseline;
8. finish each group with the relevant test, root-cause report, and patch-quality
   lessons from Track O.

One useful, verified lesson is preferred over several thin or untested lessons.

## 13. Verification and Acceptance Criteria

### Per-lesson acceptance

- The lesson addresses one main failure or skill.
- Its platform metadata matches the actual experiment.
- Loading a demo is safe; triggering is explicit.
- Commands are real and include expected results or stable patterns.
- The buggy path reproduces the stated symptom on the declared platform.
- Evidence is sufficient to locate the defect without relying on hindsight.
- The fix addresses the stated root cause.
- The same trigger demonstrates the fix, and a negative check confirms the old
  signature is absent.
- Cleanup returns S0/S1 environments to a reusable state.
- Loadable modules survive at least 20 load/unload cycles when the lesson
  exercises `module_init`/`module_exit`, probe/remove, or asynchronous teardown.
- S2/S3 trigger scripts refuse known Jetson hardware by default.
- S2/S3 refusal tests cover known Jetson identity, unreadable identity, and the
  lesson-specific documented override when one exists.
- S3 tests prove that a snapshot or fresh overlay was used and that the backing
  image remained unchanged.
- Module labs record signature-enforcement preflight and demonstrate a valid
  signing path when enforcement is active.
- Partial QEMU lessons state what remains unverified on Orin.

### Repository acceptance

- Run `git diff --check`.
- Run `npm run docs:build`.
- Review rendered heading order, tables, code fences, and internal links.
- Search for stale Day-numbered navigation after the migration change.
- In the migration change, disable global dead-link suppression or replace it
  with a documented narrow allow-list so links to removed labs fail the build.
- Confirm published project content is English.
- Confirm every lesson entry has platform and safety classification.
- Confirm no text presents QEMU or virtio evidence as Tegra hardware evidence.
- Confirm no empty course scaffolding was added.

### Glossary

- **BSP:** Board Support Package.
- **DTB/DTS:** Device Tree Blob / Device Tree Source.
- **IOMMU/SMMU:** Input-Output Memory Management Unit / ARM System Memory
  Management Unit.
- **NAPI:** New API, the Linux networking interrupt-mitigation polling model.
- **PMU:** Performance Monitoring Unit.
- **RCU:** Read-Copy Update.
- **RPS/RSS:** Receive Packet Steering / Receive Side Scaling.
- **UEFI:** Unified Extensible Firmware Interface.
- **memcg:** the Linux memory-control-group subsystem.
- **osnoise:** the kernel tracer for operating-system interference and noise.

## 14. Version and Compatibility Policy

The fixed initial teaching baseline is JetPack 7.2, Jetson Linux 39.2, Linux
6.8, and L4T Ubuntu 24.04. Every hardware lesson records the exact board,
carrier, release, config, DTB identity, and relevant firmware or package
versions used for verification.

Before this baseline is used by the first hardware lesson, the baseline record
must cite a dated official NVIDIA release-notes page that explicitly establishes
the JetPack-to-Jetson-Linux-to-kernel mapping. A current product landing page or
an undated search result is not sufficient evidence.

Version-sensitive NVIDIA commands and download names must be checked against
official NVIDIA documentation when a lesson is written or refreshed. Generic
kernel mechanisms should identify the upstream kernel version used by the QEMU
path and note meaningful differences from the fixed BSP kernel.

Do not silently update the baseline. A future baseline change requires:

1. a recorded decision and release mapping;
2. a successful build and recovery rehearsal;
3. revalidation of shared QEMU and Orin environment checks;
4. targeted review of lessons that depend on changed NVIDIA interfaces, device
   trees, configuration symbols, or tool output;
5. an explicit compatibility note for readers remaining on the previous
   baseline.
