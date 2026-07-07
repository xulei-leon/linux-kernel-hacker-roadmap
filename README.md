# linux-kernel-hacker-roadmap

A structured roadmap for Linux kernel developers who want to grow beyond basic contribution and advance toward master-level capability. It organizes core knowledge, debugging skills, performance analysis, subsystem understanding, and development practices for becoming a more skilled Linux kernel hacker.

## Project Positioning

This project is a long-term capability map for Linux kernel developers. It helps developers with basic Linux kernel development experience build the knowledge, tools, and practical methods required to become stronger Linux kernel hackers.

It focuses on three core capabilities expected from advanced kernel developers:

- High quality: write readable, maintainable, and testable kernel code
- Debugging: locate and analyze kernel problems
- Performance: analyze and optimize kernel performance

## Target Audience

- Developers who already understand basic Linux user-space and kernel development
- Developers who want to improve kernel debugging and performance analysis skills

This project is not suitable for learners with no Linux, C, or operating system background. If those foundations are missing, start with C, computer architecture, operating system fundamentals, and basic Linux usage.

## Capability Map

### 1. Foundation

- C language: pointers, bit operations, memory layout, macros, inline functions, compiler warnings
- Assembly and ABI: calling conventions, stack frames, interrupt/exception entry, system call boundaries
- Architecture: CPU cache, TLB, MMU, memory barriers, NUMA, I/O buses
- Operating system concepts: processes, threads, virtual memory, file systems, devices, interrupts, scheduling
- Linux user-space tools: shell, strace, perf, gdb, objdump, readelf, systemd/journalctl

### 2. Kernel Build and Lab Environment

- Source trees: mainline, stable, linux-next, subsystem trees
- Configuration and build: `defconfig`, `menuconfig`, `olddefconfig`, cross-compilation
- Boot environment: QEMU, KVM, initramfs, rootfs, kernel parameters
- Fast iteration: ccache, partial builds, module builds, symbol tables, debug information
- Test entry points: kselftest, KUnit, LTP, xfstests, blktests, syzbot reproducers

### 3. Core Kernel Mechanisms

- Processes and scheduling: task, scheduler classes, CFS/RT, wake-up, load balancing
- Memory management: page allocator, slab/slub, vmalloc, page faults, reclaim, memory cgroups
- Concurrency and synchronization: spinlock, mutex, rwsem, RCU, seqlock, atomic operations, memory barriers
- Interrupts and time: IRQ, softirq, tasklet/workqueue, timer, hrtimer, timekeeping
- System calls and VFS: syscall path, file descriptors, inode, dentry, mount namespace
- Modules and driver model: module lifecycle, device/driver/bus, sysfs, udev

### 4. Subsystem Tracks

Choose one primary track and study it deeply. This is more effective than trying to read every subsystem at once.

- Scheduling and real-time: scheduler, RT, deadline, latency tracing
- Memory management: MM, OOM, reclaim, hugetlb, NUMA, memcg
- File systems: VFS, ext4, xfs, btrfs, overlayfs, page cache
- Block layer and storage: bio, blk-mq, I/O scheduler, NVMe, dm, loop
- Networking stack: socket, TCP/IP, netfilter, XDP/eBPF, driver datapath
- Device drivers: platform, PCI, USB, I2C, SPI, DMA, interrupt handling
- Virtualization: KVM, virtio, vhost, guest/host boundary
- Security: LSM, capability, seccomp, namespaces, cgroups, hardening
- eBPF and tracing: BPF verifier, kprobes, tracepoints, ftrace, BTF

### 5. Debugging and Analysis

- Logging and dynamic debug: `printk`, dynamic debug, trace_printk
- Crash analysis: oops, panic, kdump, crash, addr2line, decode_stacktrace
- Interactive debugging: kgdb, gdb with vmlinux, QEMU gdb stub
- Tracing: ftrace, trace-cmd, perf trace, bpftrace, kprobes, uprobes
- Performance analysis: perf record/report/stat, flame graphs, lock contention, cache misses
- Concurrency bugs: lockdep, KCSAN, KASAN, KFENCE, UBSAN, KMEMLEAK
- Regression isolation: git bisect, reproducer minimization, config differences, hardware differences

### 6. Development Practice

- Code reading: start from the problem, call chain, data structures, and lock ordering
- Code quality: small changes, clear ownership of behavior, readable control flow, no unrelated refactoring
- Validation: reproduction steps, test environment, kernel config, commands, expected results
- Static checks: compiler warnings, sparse, smatch, clang-tidy where applicable
- Local testing: KUnit, kselftest, targeted subsystem tests, regression reproducers
- Iteration discipline: keep notes on hypothesis, observation, root cause, fix, and verification

## Suggested Directory Structure

Debugging learning packages use `labs/day-*/README.md` as the canonical day document, with runnable code beside it.

```text
linux-kernel-hacker-roadmap/
├── README.md
├── docs/
│   ├── 00-foundation/
│   ├── 01-build-and-boot/
│   ├── 02-core-kernel/
│   ├── 03-subsystems/
│   ├── 04-debugging/        # Index for debugging learning packages
│   ├── 05-performance/
│   └── 06-code-quality/
├── labs/
│   ├── day-00-kernel-build-environment/
│   │   └── README.md
│   ├── day-01-debug-ready-kernel-lab/
│   │   ├── README.md
│   │   └── qemu-kernel/
│   └── day-05-ftrace-path-time/
│       ├── README.md
│       ├── modules/
│       └── tracing/
└── resources/
    ├── books.md
    ├── talks.md
    ├── docs.md
    └── tools.md
```

## Recommended Learning Method

1. On Windows, complete `labs/day-00-kernel-build-environment/README.md` in WSL2 Ubuntu first.
2. Build a repeatable QEMU-based kernel lab with `labs/day-01-debug-ready-kernel-lab/README.md`.
3. Choose one subsystem as the main track instead of chasing too many directions.
4. Pair every mechanism you study with a minimal experiment: configure, boot, trigger, observe, record.
5. For every bug, save the reproducer, kernel config, logs, stack traces, and analysis notes.
6. Practice turning observations into a root-cause explanation and a verified fix.
7. Repeat the loop: read code, form a hypothesis, instrument, measure, fix, verify.

## Document Writing Principles

- Split documents into roughly one-hour learning or practice units.
- Each document should analyze one concrete problem, difficulty, or focused topic.
- Prefer How, Q/A, and Why formats over purely What-style explanations.
- Avoid generic tutorial articles that only explain concepts, because that material is already easy to find elsewhere.
- Focus on practical skill growth: diagnosis steps, trade-offs, commands, experiments, observations, and verification.

## Stage Reference

| Stage | Focus | Outcome |
|------|------|------|
| Foundation | C, architecture, OS, Linux tools | Explain basic control flow and data structures in kernel code |
| Build & Boot | Source, config, build, QEMU/rootfs | Boot a custom kernel repeatably |
| Core Kernel | Scheduling, memory, VFS, synchronization, interrupts | Analyze core mechanisms through call chains |
| Subsystem Deep Dive | Long-term focus on one subsystem | Locate real problems inside that subsystem |
| Debugging | Crash, trace, perf, sanitizers | Produce evidence-based problem analysis |
| Code Quality | Local fixes, tests, static checks | Produce maintainable and verified kernel changes |
| Performance | perf, tracing, contention, cache behavior | Explain and improve measurable bottlenecks |

## License

MIT
