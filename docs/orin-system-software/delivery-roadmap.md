# Portfolio Delivery Roadmap

**Status:** Planning guide. The order and gates are current; project
implementations and evidence remain planned.

## Delivery order

Use this sequence because each project supplies evidence and interfaces needed
by the next:

1. [CPU/SoC health diagnostic suite](project-1-cpu-soc-diagnostics.md) is the
   flagship. It establishes bounded execution, structured diagnostic results,
   platform identity, and evidence discipline.
2. [Safe MMIO diagnostic platform driver](project-2-mmio-diagnostic-driver.md)
   adds a narrow kernel boundary, lifecycle testing, and KUnit-tested decoding.
3. [DVFS, thermal, and performance validation](project-3-dvfs-thermal-validation.md)
   applies the evidence model to controlled whole-system experiments.

A focused 3–4 month effort is a suggested planning envelope, not a guaranteed
completion time. Board access, kernel/BSP setup, review feedback, and failure
investigation may change the schedule. Advance on evidence gates, not dates.

## Suggested planning envelope

- Opening phase: complete A01/A02, freeze portfolio conventions, and deliver
  Project 1 contracts, core, plugins, Orin run, and demo.
- Middle phase: deliver Project 2 decoder tests, lifecycle implementation,
  negative safety evidence, target run, and demo.
- Closing phase: deliver Project 3 harness, pilot controls, repeated trials,
  comparison report, and the integrated portfolio walkthrough.

Do not parallelize target claims before platform identity and evidence naming
are stable. While hardware is unavailable, progress only host fixtures, KUnit,
generic platform mechanics, and analysis tests, labeling them accordingly.

## Portfolio-wide evidence gate

A project moves from **planned** to **current evidence** only when all items
below are linked from its page or completion report:

- source, exact build/run instructions, dependency versions, and platform
  identity;
- automated results at the smallest practical boundary and one end-to-end run;
- raw evidence for success, unsupported or invalid input, and a failure path;
- bounded execution, cleanup/recovery behavior, and retained logs;
- symptom, hypotheses, diagnosis, change or disposition, and retest for one
  reproducible failure;
- a concise design review recording trade-offs and any feedback-driven change;
- truthful labels separating Orin/ARM64, generic kernel, fixture, and QEMU
  evidence.

If any item is missing, describe the gap and retain the planned label. A design
page is evidence of planning only, not evidence that its system exists.

## Interview-demo gate

Each project needs a rehearsed five-minute path that can run without network
access and does all of the following:

1. Names the problem, platform, safety boundary, and one rejected alternative.
2. Runs or replays a bounded happy path from versioned inputs.
3. Shows a real or injected failure and the evidence used to classify it.
4. Points from an observable result to the relevant component and test.
5. Explains one trade-off, one limitation, and the cleanup/recovery path.

The integrated walkthrough should fit within 15–20 minutes and use retained
evidence if board access is unavailable. A replay must be labeled as a replay.

## Completion decision

The portfolio is delivery-ready when all three project acceptance lists and
both portfolio-wide gates pass, all links resolve, and a fresh environment can
reproduce the documented build or analysis. Hiring requirements such as degree
or years of experience remain personal credentials and are not portfolio
outcomes.

