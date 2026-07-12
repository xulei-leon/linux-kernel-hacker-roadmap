# JR2019268 Role Competency Map

This map translates the public NVIDIA posting into repository evidence. It was
reviewed against [NVIDIA JR2019268](https://nvidia.wd5.myworkdayjobs.com/en-US/NVIDIAExternalCareerSite/job/China-Shenzhen/Senior-System-Software-Engineer--CPU_JR2019268)
on 2026-07-13; the posting date is 2026-06-05.

**Current** means a repository asset exists now. **Planned** means the named
portfolio artifact is not yet delivered. A current guide is useful preparation,
but only a runnable lab is execution evidence.

Direct evidence entry points: [A01 platform evidence lab](../../labs/orin-kernel/a01-identify-exact-orin-platform/README.md),
[A02 software baseline lab](../../labs/orin-kernel/a02-capture-software-baseline/README.md),
[QEMU auxiliary environment](../../labs/orin-kernel/qemu-auxiliary/README.md),
and [kernel skill library](../orin-kernel/README.md).

| Public job signal | Current repository evidence | Planned portfolio evidence |
|---|---|---|
| Design, develop, and debug a diagnostic software stack for Tegra chips and products | A01 and A02 provide runnable Orin identity and baseline evidence; the kernel library provides diagnostic guidance. No integrated diagnostic stack exists yet. | Project 1: modular CPU/SoC diagnostic suite with bounded execution and structured reports. |
| Write device drivers | Driver lifecycle, device-tree, IRQ, DMA/SMMU, and PM guides exist in the kernel skill library. No role-focused diagnostic driver exists yet. | Project 2: safe MMIO diagnostic platform driver using only declared, allow-listed resources. |
| Develop drivers and tests through the full software development lifecycle | The lab contract requires triggers, expected evidence, fixes, negative verification, and cleanup; A01/A02 include runnable validation. | Project 2 design, implementation, KUnit-testable decoding, failure tests, review notes, and acceptance evidence. |
| Implement and optimize diagnostic features for SoC use cases | A01/A02 capture platform and software facts needed before feature work. There is no current optimization deliverable. | Project 1 adds diagnostic features; Project 3 measures DVFS, thermal, and performance behavior with regression thresholds. |
| Triage, debug, and fix the software stack | A01/A02 support reproducible triage; the QEMU bootstrap and A–O guides support generic debugging practice. They do not yet prove an end-to-end role project fix. | All three projects retain symptoms, hypotheses, raw evidence, root cause, change, and retest results. |
| Communicate and plan across teams and with customers | Not evidenced by repository content alone. Authored documentation does not prove cross-team or customer collaboration. | Require a reviewed design discussion or user-feedback record that identifies participants, feedback, decisions, and resulting changes; otherwise keep this signal not evidenced. |
| Strong C and C++ | Existing runnable labs exercise shell and kernel-facing workflows, not a completed C/C++ portfolio artifact. | Project 1 uses modular C++17; Project 2 implements a focused C driver and testable decoding. |
| BS or MS in Electrical Engineering or Computer Science, plus 5+ years of relevant experience | Not evidenced by this repository. It cannot create or verify academic credentials or years of professional experience. | No repository deliverable can satisfy this requirement; candidates must represent their own credentials and experience accurately. |
| SoC architecture and close-to-hardware development | A01/A02 run on Orin and capture board, kernel, FDT, boot, and NVIDIA package facts; the kernel library covers relevant subsystems. | Projects 1–3 connect declared hardware interfaces, ARM/Tegra observations, and platform-specific evidence. |
| Large, modular system software experience is preferred | No current asset claims a large modular diagnostic system. | Project 1 defines separable diagnostic plugins, orchestration, result aggregation, and report outputs. |
| Strong problem solving and debugging | Current labs require evidence validation and explicit failure behavior; QEMU provides an isolated kernel environment. | Each project supplies at least one reproducible failure path, source-level diagnosis, minimal fix or decision, and retest. |
| Communication and planning | Current public pages demonstrate written planning only. They do not prove collaboration or communication with another person. | Project plans and reports demonstrate planning; a collaboration claim additionally requires an actual reviewed design discussion or user-feedback record and documented response. |
| Linux kernel internals are a standout qualification | The A–O kernel skill library and QEMU kernel build are current learning assets; they are not a completed driver portfolio. | Project 2 demonstrates driver lifecycle, resource management, test seams, error paths, and cleanup. |
| ARM platforms are a standout qualification | A01/A02 collect evidence on the ARM64 Orin target; the existing QEMU bootstrap is x86_64 and is labeled accordingly. | All Tegra claims in Projects 1–3 require Orin/ARM64 evidence. |
| Diagnostic software experience is a standout qualification | A01/A02 provide diagnostic inputs, not a general diagnostic product. | Project 1 is the flagship diagnostic stack; Projects 2 and 3 add kernel and system-validation evidence. |

## How to use the map

Start with A01 and A02 on Orin, or the QEMU bootstrap for generic kernel work.
Build projects in the published order and update a signal to current only when
its linked artifact, tests, raw evidence, and failure behavior are present.
Use the [kernel skill library](../orin-kernel/README.md) on demand when a project
exposes a driver, debugging, performance, or testing gap.
