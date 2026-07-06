# Kernel Debug Skill Training Plan

**Goal:** Build practical Linux kernel debugging capability in 30 days, with an estimated 1 hour of focused work per day.

This plan treats debugging as a combination of kernel mechanism knowledge, symptom analysis, tool usage, and verification discipline. Each day starts from a practical problem symptom, connects it to the relevant kernel mechanism, then produces a small artifact that proves learning.

## Daily Article Pattern

Use this structure for future documents created from this plan:

1. **Problem:** Start with a real symptom seen in practice.
2. **Kernel Mechanism:** Explain the kernel mechanism needed to understand the symptom.
3. **Problem Analysis:** Break down what the symptom means and what evidence matters.
4. **Debug Path:** Give concrete localization steps, commands, traces, or checks.
5. **Resolution:** Describe likely fix patterns, mitigation, or validation targets.
6. **1-Hour Output:** Produce one note, log, trace, checklist, reproducer sketch, or verification result.

Avoid pure "what is X" explanations. Prefer How, Q/A, and Why topics that improve debugging skill.

## 30-Day Plan

| Day | Problem Entry | Kernel Mechanism | 1-Hour Work | Output | Verification |
|---:|---|---|---|---|---|
| 1 | Why is a panic log often not enough? | Kernel failure modes, panic, oops, taint, call trace | Read one panic/oops sample and mark the timestamp, CPU, task, RIP/PC, call trace, and taint flags. | Annotated panic/oops checklist | Can explain panic vs oops and identify the first useful evidence. |
| 2 | How do you make a kernel bug reproducible? | Kernel config, boot parameters, debug symbols, QEMU/rootfs boundary | Define a minimal lab note: kernel version, config source, boot command, rootfs, and trigger command. | Reproducibility template | Template has all fields needed to rerun the same experiment. |
| 3 | Why do debug symbols matter when reading an oops? | `vmlinux`, `System.map`, kallsyms, address-to-line mapping | Practice mapping one function/address to source with `addr2line`, `gdb`, or `scripts/decode_stacktrace.sh`. | Address mapping note | Can map at least one address or symbol to a source location. |
| 4 | How do you avoid being misled by a stack trace? | Stack unwinding, inlining, interrupt context, compiler optimization | Compare the top frame, faulting instruction, and surrounding frames in one trace. | Stack trace reading checklist | Can state which frame likely caused the failure and why. |
| 5 | How does an invalid pointer become an oops? | Virtual address space, page tables, page fault path | Analyze one NULL pointer or invalid-address oops and identify access type and faulting context. | Page fault analysis note | Can connect fault address, instruction, and process/context. |
| 6 | Why can user memory access crash kernel code? | User/kernel address split, `copy_to_user`, `copy_from_user`, access checks | Trace one user-copy failure path and list the required checks before dereference/copy. | User-copy debug checklist | Checklist distinguishes user pointer validation from kernel pointer use. |
| 7 | How do you debug use-after-free symptoms? | Slab/slub allocator, object lifetime, poisoning, KASAN | Study a KASAN-style report and extract allocation stack, free stack, and use stack. | UAF evidence table | Can identify the lifetime gap that caused the invalid access. |
| 8 | How do you debug system memory exhaustion? | Page allocator, reclaim, OOM killer, memory pressure | Inspect sample OOM logs or `/proc/meminfo` fields and map them to memory pressure causes. | OOM analysis checklist | Can separate leak suspicion from reclaim pressure or workload growth. |
| 9 | Why is process memory growth not always a kernel leak? | VMA, RSS, page cache, anonymous memory, mmap | Build a decision tree for RSS growth, mapped file growth, page cache growth, and kernel memory growth. | Process memory growth decision tree | Can choose first evidence source: `smaps`, `meminfo`, slab info, or cgroup stats. |
| 10 | How do you inspect slab memory growth? | Slab caches, object size, allocation sites, shrinkers | Identify which slab caches matter in a memory-growth symptom and what extra data is needed. | Slab growth triage note | Can name the cache, growth pattern, and next instrumentation point. |
| 11 | Why does a task get stuck in D state? | Task states, scheduler, blocking I/O, wait queues | Analyze a hung task log and identify the wait site and resource being waited on. | Hung task analysis note | Can distinguish CPU running, sleeping, and uninterruptible wait symptoms. |
| 12 | How do wake-up bugs happen? | Wait queues, condition checks, wake-ups, missed events | Trace a wait/wake pattern and mark the condition, lock, wait site, and wake site. | Wait/wake checklist | Checklist shows where missed wake-ups or wrong conditions could occur. |
| 13 | Why do signal problems look like process bugs? | Signal delivery, task state, fatal signals, blocked signals | Analyze a process that does not exit on signal and list state, blocked mask, and kernel wait reason. | Signal triage note | Can explain when a signal cannot interrupt the current wait. |
| 14 | How do IPC waits become kernel debugging problems? | Pipes, futexes, sockets, wait queues, scheduler interaction | Pick one IPC path and identify where blocking occurs and which event wakes it. | IPC blocking map | Can connect user-visible hang to one kernel wait point. |
| 15 | How do you debug high CPU from scheduler evidence? | Run queues, preemption, scheduling classes, softirq load | Use a sample `perf top`, trace, or scheduler stat to separate busy loop, softirq, and wake-up storm. | High-CPU classification note | Can name the dominant execution context and next measurement. |
| 16 | Why do deadlocks need lock ordering, not just lock names? | Mutex, spinlock, rwsem, lockdep graph, lock ordering | Read one lockdep report and extract the two lock chains and inversion point. | Lockdep report annotation | Can explain the cycle and the order that must be preserved. |
| 17 | How do sleeping-in-atomic bugs happen? | Atomic context, preemption, IRQ disabled regions, spinlocks | Analyze a "scheduling while atomic" style report and identify the forbidden sleep path. | Atomic-context checklist | Can list context, held locks, and the sleeping function. |
| 18 | Why can RCU stalls be hard to localize? | RCU read-side critical sections, grace periods, CPU quiescent states | Read one RCU stall report and identify blocked CPU/task and likely long critical section. | RCU stall triage note | Can separate RCU stall evidence from generic CPU hang evidence. |
| 19 | How do you debug lock contention instead of deadlock? | Contention, lock hold time, scheduling latency, perf lock | Define a measurement plan for one contended lock symptom. | Lock contention measurement plan | Plan names metric, command/tool, and expected evidence. |
| 20 | How do you verify a synchronization fix? | Race windows, reproducer loops, stress runs, before/after evidence | Write a minimal verification checklist for a race or lock fix. | Race verification checklist | Checklist includes reproduction frequency and negative test evidence. |
| 21 | Why can interrupt storms look like system hangs? | Hard IRQ, softirq, interrupt affinity, interrupt counters | Inspect interrupt counters and define how to detect abnormal interrupt rate. | Interrupt storm triage note | Can point to the IRQ line, device, CPU, and rate evidence. |
| 22 | How do softirq problems affect network or storage latency? | Softirq, NAPI, ksoftirqd, bottom halves | Analyze a latency symptom and decide whether work runs in softirq or ksoftirqd context. | Softirq context note | Can identify whether CPU pressure pushed work to ksoftirqd. |
| 23 | Why do workqueues stall? | Workqueue concurrency, worker pools, blocking work, reclaim interactions | Map one delayed work item from queue site to worker execution and blocking point. | Workqueue stall map | Can identify whether the queue is starved, blocked, or overloaded. |
| 24 | How do timer bugs create delayed or repeated failures? | Timer wheel, hrtimer, jiffies, delayed work | Analyze one timeout symptom and identify timer start, expiry, cancel, and callback context. | Timer lifecycle note | Can explain whether the bug is missed cancel, wrong delay, or callback context. |
| 25 | How do filesystem stalls surface as process hangs? | VFS, inode locks, page cache, writeback, block layer handoff | Trace a process stuck in filesystem I/O to VFS, writeback, or block layer evidence. | Filesystem stall triage note | Can name which layer needs deeper inspection. |
| 26 | Why does block I/O latency require queue-level evidence? | bio, request queue, blk-mq, device timeout | Build a checklist for separating filesystem delay, block queue delay, and device delay. | Block latency checklist | Checklist has at least one signal per layer. |
| 27 | How do network packet drops become kernel debug tasks? | Driver RX/TX path, NAPI, socket buffers, qdisc, drops | Map one packet-loss symptom to drop counters and likely kernel layer. | Packet drop triage note | Can distinguish driver, qdisc, socket buffer, and protocol drops. |
| 28 | How do you reduce a kernel bug into a small reproducer? | Trigger minimization, config minimization, workload isolation | Take one symptom and write a smallest-known reproducer plan with inputs and stop conditions. | Reproducer reduction plan | Plan identifies what to remove, what to preserve, and what proves the bug remains. |
| 29 | How do you write a root-cause debug report? | Evidence chain, hypothesis, mechanism, fix validation | Convert one daily note into a report with symptom, mechanism, evidence, root cause, and verification. | Root-cause report draft | Report avoids tool dumps and explains why the cause fits the evidence. |
| 30 | How do you build a personal kernel debug workflow? | End-to-end debug discipline, notes, checklists, tool selection | Create a reusable workflow from symptom intake to verification. | Personal debug workflow | Workflow covers evidence capture, mechanism analysis, localization, fix, and verification. |

## Completion Criteria

By the end of 30 days, you should have:

- A repeatable way to capture kernel failure evidence.
- A mechanism-based approach to memory, process, lock, interrupt, timer, I/O, and networking symptoms.
- A small set of checklists for common practical failures: panic/oops, deadlock, memory exhaustion, process memory growth, hung task, interrupt storm, and latency.
- A root-cause report format that connects symptoms to kernel mechanisms and verified evidence.

## Topic Expansion Backlog

Use these as future one-hour documents:

- How do you debug page table corruption symptoms?
- Why does direct reclaim show up in unrelated call traces?
- How do cgroups change memory debugging?
- How do priority inversion symptoms differ from deadlocks?
- Why do RCU stalls appear only under CPU isolation or real-time load?
- How do DMA bugs show up as memory corruption?
- How do device driver timeout paths interact with workqueues and timers?
