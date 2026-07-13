# Document Review: Kernel Debug Skill Training Plan

**Reviewed file:** `docs/kernel-debug-skill-training-plan.md`

**Review type:** Document review

**Reviewer:** opencode-go/kimi-k2.7-code

**Date:** 2026-07-06

---

## Executive Summary

This is a well-structured 30-day plan for building practical Linux kernel debugging skills. It succeeds at breaking a broad topic into one-hour, mechanism-based units and demands concrete artifacts (checklists, notes, triage maps) rather than passive reading. It covers the major symptom domains a kernel engineer will encounter: memory exhaustion, hung tasks, deadlocks, RCU stalls, interrupt/softirq issues, I/O stalls, and network drops.

However, for a plan that targets *senior* kernel debugging capability and is intended as the backbone of a public article series, it under-represents several pillars of professional kernel work: dynamic tracing (`ftrace`, `perf`, BPF), failure capture (`kdump`/`crash`), deterministic reproduction and regression location (`git bisect`), modern bug-detection instrumentation (`KCSAN`, `KFENCE`, `UBSAN`), and the fuzzing/reproducer culture represented by `syzkaller`/`syzbot`. The sequencing also has a few places where prerequisite mechanisms appear after the symptoms that depend on them.

The writing style is mostly clear and consistent with the project's preference for How/Q&A/Why framing. The biggest style risk is that many days describe the *goal* of an hour rather than the *path* through it, which could leave readers without enough signal to actually execute.

---

## Findings

| Severity | Type | Location | Issue | Evidence | Recommendation |
|---|---|---|---|---|---|
| High | Coverage | Entire plan | `ftrace` is not taught as a first-class tool. | `ftrace` is only mentioned implicitly in Day 15 (`"trace"`). Function graph tracing, tracepoints, `function_graph`, `set_ftrace_filter`, and `trace_events` are absent despite being the most common kernel-side localization tool. | Add a dedicated day (around Day 4-6) for `ftrace` fundamentals: enable `CONFIG_FUNCTION_TRACER`, use `/sys/kernel/debug/tracing/`, read function-graph output, and attach a tracepoint to a symptom. Reference existing days back to this foundation. |
| High | Coverage | Entire plan | `perf` and BPF/`bpftrace`/`bcc` are largely absent. | `perf` appears once in Day 15. BPF-based dynamic tracing, `kprobe`/`kretprobe`, `bpftrace` one-liners, and `perf` flame graphs are not covered. | Insert a day on CPU/latency profiling with `perf` and a day on dynamic instrumentation with `bpftrace`/BPF. Show when to use each: `ftrace` for kernel mechanism tracing, `perf` for sampling, BPF for custom aggregate probes. |
| High | Coverage | Entire plan | No coverage of `kdump`/`crash` or vmcore analysis. | The plan never mentions capturing a crash dump, `kdump` service configuration, `/proc/vmcore`, or the `crash` utility. For senior debugging and production post-mortems this is a critical gap. | Add a day on failure capture: configure `kdump`, trigger a panic, inspect `vmcore` with `crash` (`bt`, `ps`, `task`, `vm`, `files`), and correlate it with Day 1 panic/oops reading. |
| High | Coverage | Entire plan | `git bisect` and regression location are missing. | A senior kernel debug workflow must locate *which* commit introduced a bug. No day covers `git bisect`, `git bisect start/bad/good`, or bisection with QEMU reboot loops. | Add a day on deterministic bisection: define a fast reproducer, automate boot/test with QEMU, and bisect between a known-good and known-bad kernel. Cross-reference with Day 28 reproducer reduction. |
| High | Sequencing | Day 7 vs. Day 10 | Use-after-free is taught before slab allocator internals. | Day 7 covers UAF, KASAN, allocation/free/use stacks. Day 10 covers slab caches, object size, allocation sites. Understanding slab caches and object lifetime is a prerequisite for UAF triage. | Swap Day 7 and Day 10, or move slab allocator basics to Day 6-7 and make Day 7 build UAF/KASAN on top of that knowledge. |
| Medium | Coverage | Entire plan | Modern dynamic sanitizers beyond KASAN are absent. | KASAN appears on Day 7. `KCSAN` (data races), `KFENCE` (low-overhead memory errors), and `UBSAN` (undefined behavior) are not mentioned. | Add a day or a section comparing `KASAN`/`KCSAN`/`KFENCE`/`UBSAN`: what each catches, config flags, output format, and when to use which in CI vs. targeted debugging. |
| Medium | Coverage | Days 1-3 | No boot-time / early failure capture setup. | Days 1-3 discuss panic/oops and QEMU but omit `earlyprintk`, serial console capture, `netconsole`, `kdb`, and `kgdb` setup. These are prerequisites for capturing many real failures. | Add an early day for boot/debug environment: serial console, `earlyprintk=serial`, `console=ttyS0`, `netconsole`, `kgdboc`, and when each is appropriate. |
| Medium | Coverage | Entire plan | No `syzkaller` / fuzzing / `syzbot` workflow. | Senior kernel hackers routinely reproduce and reduce `syzbot` reports. The plan has no fuzzing, corpus reduction, or `syzkaller` reproduction workflow. | Add a day or backlog item on reproducing a `syzbot` report: fetch reproducer, build matching config, run under QEMU, reduce C reproducer, and write a Fixes: tag. |
| Medium | Coverage | Days 25-27 | Block and filesystem tracing tools are under-specified. | Day 25 mentions VFS/writeback/block layer but does not reference `blktrace`, `btrfs`/ext4 tracepoints, or `iostat`. Day 26 mentions bio/request queue/blk-mq but omits `blktrace -d`. | In Day 25/26, include concrete commands: `blktrace`, `tracefs` block events, `/sys/block/*/stat`, and how to separate filesystem vs. block-device latency with real evidence. |
| Medium | Coverage | Days 21-24 | No day on kernel logging discipline (`dynamic debug`, rate limiting, timestamps). | `dmesg` is implied but `pr_debug`/`dev_dbg`, dynamic debug (`/sys/kernel/debug/dynamic_debug/control`), `printk` time stamps, and `dmesg --ctime` are not covered. | Add a short day on controlled logging: enable dynamic debug, annotate a trace with `dmesg` timestamps, and explain rate limiting (`printk_ratelimit`). |
| Medium | Requirement | Day 2 | QEMU/rootfs setup is described too briefly for execution. | Day 2 says "Define a minimal lab note: kernel version, config source, boot command, rootfs, and trigger command" but does not give the actual commands or a sample. | Provide a concrete template including `make defconfig`, `make -j`, `qemu-system-x86_64 -kernel ... -append ...`, and a sample rootfs choice (Buildroot / Debian initramfs / virtiofs). |
| Medium | Clarity | Days 5-6 | User/kernel address split and page fault path could be misordered. | Day 5 jumps into page fault path; Day 6 covers user access. A reader may need the user/kernel boundary (Day 6) before reasoning about faulting context (Day 5). | Consider swapping Day 5 and Day 6, or explicitly connect them so Day 5 references the boundary and Day 6 deepens it. |
| Medium | Coverage | Days 11-14 | Scheduler deep-debug tools are missing. | Hung task and wait/wake analysis is covered, but `sched_debug`, `/proc/schedstat`, `trace_sched_*` tracepoints, and `sched_domain` debugging are absent. | Add scheduler-specific instrumentation to Day 11 or 15: `/proc/sys/kernel/sched_*`, `ftrace` `sched:` events, and interpreting `schedstat`. |
| Medium | Coverage | Day 27 | Network debugging conflates kernel drops with user-space tooling. | Day 27 maps drops to driver/qdisc/socket/protocol but does not mention `dropwatch`, `perf trace` skb tracepoints, `ss -tin`, or `ethtool -S`. | Expand Day 27 with a concrete counter-to-layer table and commands like `ethtool -S eth0`, `dropwatch`, and skb tracepoint one-liners. |
| Low | Coverage | Backlog | `cgroups` only appears in backlog despite being common in memory/latency bugs. | Item "How do cgroups change memory debugging?" is in the backlog. cgroup memory accounting and CPU throttling are frequent root causes in container workloads. | Promote cgroups memory debugging from backlog to a day, or integrate it into Day 8/9 with `memory.stat`, `memory.pressure`, and cgroup OOM logs. |
| Low | Consistency | Header and table | Column named "1-Hour Work" while pattern section calls it "1-Hour Output". | Section header says "1-Hour Output" but the table uses "1-Hour Work". The table also has a separate "Output" column, causing confusion. | Rename the table column to "Practice" or "Exercise" and keep "Output" for the artifact. Align with the pattern section terminology. |
| Low | Clarity | Days 8-10 | Memory days lack a unifying diagnostic flow. | Days 8-10 cover OOM, process memory growth, and slab growth, but no single flow shows how to pick `meminfo`, `slabinfo`, `smaps`, or cgroup stats first. | Add a small decision diagram at the top of the memory block (Days 8-10) showing the first evidence source per symptom class. |
| Low | Coverage | Day 16 | Lockdep coverage omits `lockdep` limitations and false positives. | Day 16 extracts lock chains but does not warn that `lockdep` can report false cycles with `mutex_lock_nested` or that `prove_locking` has overhead. | Add a note on `lockdep` caveats: false positives, enabling/disabling, `LOCKDEP_BITS`, and validating a reported cycle before changing code. |
| Low | Coverage | Day 18 | RCU stall day omits `rcutorture` and stall timeout knobs. | Day 18 reads a stall report but does not mention `rcutorture`, `/proc/sys/kernel/rcu_cpu_stall_timeout`, or `rcu_nocbs`. | Expand Day 18 with stall knobs and an optional `rcutorture` run to exercise read-side critical sections. |
| Info | Style | Many days | Days often state the objective without a concrete starting artifact. | E.g., Day 4: "Compare the top frame, faulting instruction, and surrounding frames in one trace" — which trace? | Provide a link or inline sample trace/panic/OOM log for each day so the reader has raw material to practice on. If samples are too long, link to `samples/` or kernel documentation examples. |
| Info | Requirement | Completion Criteria | Criteria are output-oriented but not skill-verifiable. | "A repeatable way to capture kernel failure evidence" is vague. | Convert each criterion into a measurable check, e.g., "Given an oops, produce an annotated trace with RIP, call stack, and taint in under 10 minutes." |
| Info | Style | Backlog | Backlog items are useful but unprioritized. | Items include page table corruption, direct reclaim, cgroups, priority inversion, RCU stalls, DMA bugs, and driver timeouts. | Group backlog items by prerequisite (e.g., memory, locking, driver) and mark which are natural extensions after Day 30. |
| Info | Consistency | Day 30 | Personal workflow asks for end-to-end discipline but the plan itself does not model a review gate. | Day 30 says "Create a reusable workflow" but no earlier day models peer review or checklist refinement. | Add a lightweight review step on Day 29: exchange a root-cause report draft with a checklist (clarity, evidence, mechanism link, verification). |

---

## Overall Assessment

**Completeness for senior kernel debugging:** Good breadth, but missing production post-mortem (`kdump`/`crash`), dynamic tracing depth (`ftrace`/`perf`/BPF), and regression tooling (`git bisect`, `syzkaller`).

**Common problem coverage:** Strong on memory, locks, hung tasks, interrupts, timers, and I/O. Weaker on logging discipline, scheduler internals, and container/cgroup symptoms.

**Learning order:** Mostly reasonable progression from panic reading → reproducibility → memory/process → locks → interrupts/timers → I/O/network → reproducer/reporting. Needs fixes around slab/UAF ordering and user/kernel boundary/page fault ordering.

**Kernel expertise for public series:** The plan demonstrates real kernel literacy through terminology (KASAN, lockdep, RCU, blk-mq, NAPI). Adding concrete command examples, sample traces, and references to mainline tools (`ftrace`, `perf`, BPF, `crash`) would make it credible to experienced kernel engineers.

**Writing style:** Consistent Q/A/How framing. The main weakness is abstraction: many days describe *what* to do in an hour without giving the reader the actual trace, command, or starting state. Concrete samples and templates will significantly improve usability.

---

## Recommended Next Steps

1. Insert `ftrace` and `perf`/BPF days near the front (Days 4-6 and 13-14).
2. Add a `kdump`/`crash` day after Day 3 and a `git bisect` day after Day 28.
3. Swap or merge slab allocator content so it precedes UAF/KASAN.
4. Provide a concrete QEMU lab template on Day 2.
5. Add sample traces/logs for each symptom day so readers have material to annotate.
6. Expand completion criteria into measurable skill checks.
