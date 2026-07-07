# Kernel Debug Skill Training Plan

**Goal:** Build practical Linux kernel debugging capability in 30 days, with an estimated 1 hour of focused work per day.

**Reference kernel:** use a recent mainline or stable v6.x kernel unless a day explicitly requires another version.

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

Store each day as a learning package under `labs/day-*/README.md`, with runnable material in sibling subdirectories such as `modules/`, `tracing/`, `qemu-kernel/`, or `memory-debugging/`. Keep `docs/04-debugging/README.md` as the navigation index for the track.

## 30-Day Plan

| Day | Problem Entry | Kernel Mechanism | Tools / Knobs | 1-Hour Practice | Output | Evidence Check |
|---:|---|---|---|---|---|---|
| 1 | How do you create a debug-ready kernel lab? | Kernel config, boot path, rootfs, serial console | `make defconfig`, `CONFIG_DEBUG_INFO`, QEMU `-append "console=ttyS0"` | Write one reproducible lab command set: kernel commit, config source, build command, QEMU command, rootfs, trigger command. | Lab baseline template | Template can be rerun without guessing commit, config, boot args, or trigger. |
| 2 | Why is a panic or oops log often not enough? | Failure modes, taint flags, panic path, oops path | `dmesg`, serial log, `panic_on_oops=1`, `oops=panic` | Annotate one public or local panic/oops sample with CPU, task, taint, RIP/PC, fault address, and call trace. | Annotated panic/oops log | Log excerpt identifies the faulting function and the first missing evidence. |
| 3 | Why do symbols decide whether a trace is useful? | `vmlinux`, `System.map`, kallsyms, debug info | `addr2line`, `gdb vmlinux`, `scripts/decode_stacktrace.sh` | Map at least one address from an oops to source and explain why inlining or modules may change the result. | Address-to-source note | Note contains command, input address, resolved file/function, and uncertainty if any. |
| 4 | When should you use `printk`, dynamic debug, or `trace_printk`? | Kernel logging, rate limits, timestamps, debug sites | `pr_debug`, `dev_dbg`, `dynamic_debug`, `trace_printk`, `printk.time=1` | Turn one hypothetical noisy log into a controlled debug plan using dynamic debug or trace output. | Logging discipline checklist | Checklist chooses the least invasive logging method and names rate-limit risks. |
| 5 | How do you find where a kernel path spends time without adding logs? | Tracefs, function tracing, function graph tracing, tracepoints | `ftrace`, `trace-cmd`, `set_ftrace_filter`, `function_graph` | Trace one kernel function path or tracepoint and summarize entry, exit, duration, and caller context. | ftrace trace excerpt | Output includes trace command, filter/event, and a short interpretation. |
| 6 | How do sampling and dynamic probes complement ftrace? | PMU sampling, kprobes, tracepoints, aggregation | `perf record/report/stat`, `perf trace`, `bpftrace`, kprobes | Pick a high-CPU or latency symptom and choose `perf`, `bpftrace`, or ftrace with a reason. | Tool-selection note | Note includes one command and the exact signal expected from it. |
| 7 | How do you inspect a crash after the machine is gone? | vmcore, task state, kernel memory snapshot | `kdump`, `crash`, `/proc/vmcore`, `bt`, `ps`, `kmem -i` | Draft a post-mortem checklist for a panic that includes vmcore capture and three `crash` commands. | vmcore analysis checklist | Checklist can recover task, stack, memory pressure, and loaded-module evidence. |
| 8 | How do you stop a kernel at the failure site? | Live debugging, breakpoints, QEMU gdb stub, kgdb | QEMU `-s -S`, `gdb`, `target remote`, `kgdboc` | Define a live-debug session for stopping before a suspected function and inspecting arguments. | kgdb/QEMU gdb session note | Note includes breakpoint target, connection command, and limitation of live debugging. |
| 9 | How do you prove which commit introduced a regression? | Reproducer stability, config minimization, source bisection | `git bisect`, `git bisect run`, QEMU boot script | Turn one symptom into a bisectable test: good commit, bad commit, config, trigger, pass/fail rule. | Regression bisect plan | Plan has deterministic pass/fail output and avoids manual judgment. |
| 10 | Given a NULL-pointer oops, how do you prove the bad access? | Address spaces, page tables, page fault path, user/kernel boundary | fault address, `CR2`, `copy_to_user`, `copy_from_user`, `access_ok` | Analyze one invalid-address trace and identify access type, context, and whether the pointer is user or kernel memory. | Page-fault triage note | Note connects fault address, instruction, access type, and context. |
| 11 | Why must allocator anatomy come before UAF debugging? | Page allocator, slab/slub caches, object lifetime, poisoning | `/proc/slabinfo`, `slabinfo`, `CONFIG_SLUB_DEBUG`, `slub_debug=FZPU` | Map one object from allocation cache to object size, lifetime owner, and free path. | Slab object lifecycle map | Map names cache, object owner, allocation site, and free site candidate. |
| 12 | How do you classify memory corruption beyond UAF? | Slab OOB, UAF, double free, stack overflow, undefined behavior | `KASAN`, `KFENCE`, `UBSAN`, `CONFIG_VMAP_STACK`, `CONFIG_DEBUG_STACKOVERFLOW` | Compare three report types and decide which detector catches each symptom. | Memory-corruption detector matrix | Matrix maps symptom to detector, config, report field, and likely next step. |
| 13 | How do you debug memory leaks and system memory exhaustion? | Reclaim, OOM killer, slab growth, kernel leaks | `/proc/meminfo`, `/proc/slabinfo`, `kmemleak`, `vmstat`, OOM log | Build a flow from symptom to first evidence source: host OOM, slab growth, page-cache growth, or leak. | Memory exhaustion decision tree | Tree separates workload growth, reclaim pressure, slab growth, and leak suspicion. |
| 14 | Why is process memory growth not always a kernel leak? | VMA, RSS, page cache, mmap, memcg accounting | `/proc/<pid>/smaps`, cgroup v2 `memory.stat`, `memory.events`, PSI | Analyze process growth versus memcg OOM versus global OOM using counters and logs. | Process/memcg triage note | Note includes RSS, mapped file, anon memory, memcg event, and OOM source. |
| 15 | Why does a task get stuck in D state? | Task states, scheduler, wait queues, blocking I/O | hung task log, `sysrq-t`, `wchan`, `sched:` tracepoints | Inspect one hung task trace and identify wait site, task state, lock/resource, and wake condition. | Hung-task analysis note | Note distinguishes runnable, interruptible sleep, and uninterruptible wait. |
| 16 | How do missed wakeups, signals, and IPC waits look different? | Wait queues, signal delivery, futexes, pipes, sockets | `wait_event*`, `signal_pending`, futex tracepoints, `strace -f` | Map one user-visible hang to a wait condition and the event that should wake it. | Wait/wake/IPC map | Map shows wait site, wake site, condition, lock, and signal behavior. |
| 17 | Why do deadlocks need lock ordering evidence? | Mutex, spinlock, rwsem, lock classes, lockdep graph | `CONFIG_LOCKDEP`, `CONFIG_PROVE_LOCKING`, lockdep splat | Annotate one lockdep report and extract the two chains, inversion point, and valid ordering. | Lockdep annotation | Annotation explains the cycle and does not confuse it with contention. |
| 18 | How do races and illegal sleeps differ from deadlocks? | Atomic context, preemption, data races, lock hold time | `CONFIG_DEBUG_ATOMIC_SLEEP`, `KCSAN`, `perf lock`, `lockstat` | Classify one concurrency symptom as deadlock, race, illegal sleep, or contention. | Concurrency classification note | Note names detector, expected report, and verification stress loop. |
| 19 | How do you tell hung task, soft lockup, hard lockup, and RCU stall apart? | Watchdogs, scheduling progress, IRQ/NMI context, RCU grace periods | `softlockup_panic=`, `nmi_watchdog`, `watchdog_thresh`, RCU stall log | Build a comparison table of detector, log signature, likely cause, and first evidence. | Lockup classification table | Table separates the four symptoms using observable log signatures. |
| 20 | Why can RCU stalls be hard to localize? | RCU read-side sections, grace periods, quiescent states, callback pressure | `rcu_cpu_stall_timeout`, `rcutorture`, RCU tracepoints | Analyze one RCU stall report and identify blocked CPU/task, grace period state, and possible long reader. | RCU stall triage note | Note explains why the stall is not merely a generic hang. |
| 21 | Why can interrupt storms look like system hangs? | Hard IRQ, threaded IRQ, affinity, MSI-X, interrupt counters | `/proc/interrupts`, IRQ affinity, `threadirqs`, `irqsoff` tracer | Inspect interrupt-rate evidence and identify IRQ line, CPU skew, device, and handler context. | IRQ storm triage note | Note includes before/after interrupt counters and likely device source. |
| 22 | How do softirq and NAPI problems become latency? | Softirq, NAPI polling, `ksoftirqd`, budget, busy poll | `/proc/softirqs`, `napi` tracepoints, `perf top`, `softirq` events | Decide whether work is running in interrupt context, softirq, or `ksoftirqd` under CPU pressure. | Softirq context note | Note contains per-CPU softirq counters and one trace or perf signal. |
| 23 | Why do workqueues stall or amplify memory pressure? | Worker pools, delayed work, reclaim context, blocking work | workqueue tracepoints, `ps`, `sysrq-w`, `WQ_MEM_RECLAIM` | Map one delayed work item from queue site to worker execution and blocking point. | Workqueue stall map | Map identifies whether the queue is starved, blocked, or overloaded. |
| 24 | How do timer bugs create delayed or repeated failures? | Timer wheel, hrtimer, jiffies, delayed work, callback context | timer tracepoints, `jiffies`, `mod_timer`, `del_timer_sync` | Analyze a timeout symptom and identify start, expiry, cancel, callback, and context constraints. | Timer lifecycle note | Note states whether the failure is missed cancel, wrong delay, or bad callback context. |
| 25 | How do filesystem stalls surface as process hangs? | VFS, inode locks, page cache, writeback, block handoff | `sysrq-w`, VFS tracepoints, writeback tracepoints, `iostat` | Trace a stuck process to VFS, writeback, page cache, or block layer evidence. | Filesystem stall triage note | Note names the layer needing deeper inspection and the signal that proves it. |
| 26 | Why does block I/O latency require queue-level evidence? | bio, request queue, blk-mq, scheduler, device timeout | block tracepoints, `blktrace`, `/sys/block/*/stat`, `iostat -x` | Separate filesystem delay, queue delay, and device delay for one I/O latency symptom. | Block latency checklist | Checklist has at least one observable signal per layer. |
| 27 | How do packet drops become kernel debugging tasks? | Driver RX/TX, NAPI, qdisc, socket buffers, protocol drops | `ethtool -S`, `dropwatch`, skb tracepoints, `ss -tin`, qdisc stats | Map a packet-loss symptom to driver, NAPI, qdisc, socket buffer, or protocol evidence. | Packet-drop layer map | Map includes counter source, kernel layer, and next probe. |
| 28 | How do module, driver, and hotplug races fail at teardown? | Module refcount, device model, probe/remove, CPU/memory hotplug | `lsmod`, sysfs bind/unbind, driver core traces, module refcount | Analyze a load/unload or hotplug failure and identify lifetime owner and teardown ordering. | Driver lifecycle checklist | Checklist names refcount, active users, work/timer cleanup, and device state. |
| 29 | Why do suspend/resume bugs look like deadlocks? | PM core, device suspend ordering, freezer, IRQ wakeups | `pm_test`, `dpm_debug`, `initcall_debug`, suspend logs | Classify a suspend/resume hang as freezer, device PM callback, IRQ wake, or ordering failure. | PM hang triage note | Note identifies suspend or resume phase and the blocking device/task. |
| 30 | How do you write a senior-level root-cause debug report? | Evidence chain, mechanism explanation, fix validation, before/after proof | report template, reproducer, trace excerpt, config, counter evidence | Convert one earlier day into a report: symptom, mechanism, evidence, root cause, fix direction, verification. | Root-cause report draft | Report includes raw evidence, mechanism reasoning, and a reproducible verification step. |

## Completion Criteria

By the end of 30 days, you should be able to:

- Given an oops, produce an annotated trace with taint, task, CPU, faulting instruction, symbolized source, and missing evidence in under 10 minutes.
- Given a memory symptom, choose the first evidence source among `smaps`, `meminfo`, `slabinfo`, memcg stats, OOM logs, KASAN, KFENCE, UBSAN, and KMEMLEAK.
- Given a hang, classify it as hung task, soft lockup, hard lockup, RCU stall, missed wakeup, deadlock, contention, or I/O wait using log signatures and counters.
- Given a latency symptom, choose between ftrace, tracepoints, perf, bpftrace, block traces, or subsystem counters and explain the expected signal.
- Given a suspected regression, define a reproducible pass/fail rule suitable for `git bisect run`.
- Produce a root-cause report that connects symptom, kernel mechanism, evidence, fix direction, and verification.

## Topic Expansion Backlog

Use these as future one-hour documents after the 30-day plan:

- How do you debug page table corruption symptoms?
- Why does direct reclaim show up in unrelated call traces?
- How do io_uring stalls surface as blocked tasks?
- How do priority inversion symptoms differ from deadlocks?
- Why do RCU stalls appear only under CPU isolation or real-time load?
- How do DMA bugs show up as memory corruption?
- How do security hardening toggles change debug behavior?
- How do cgroup CPU throttling and PSI explain latency spikes?
- How do syzkaller and syzbot reproducers fit into a local debug workflow?
