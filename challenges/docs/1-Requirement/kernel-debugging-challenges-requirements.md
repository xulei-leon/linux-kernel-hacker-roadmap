# Kernel Debugging Challenges Requirements

## Summary

Kernel Debugging Challenges is a standalone static website inside this repository. It presents the existing Linux kernel debugging roadmap as a challenge-based learning path. The existing `labs/day-*/README.md` documents remain the background explanations for each challenge, and the sibling lab files remain the runnable local materials.

The first version should be a local-first challenge catalog, not an online judge. It should help a learner choose a challenge, understand the symptom, run the related local lab, collect evidence, and know what counts as completion.

## Goals

- Turn the 30 debugging days into a browsable challenge list.
- Make each challenge outcome concrete: reproduce, observe, analyze, explain, or verify.
- Link every challenge to its background document under `labs/day-*/README.md`.
- Link every challenge to related lab material under `labs/` when available.
- Keep the website independent from kernel build execution; all kernel commands run locally outside the browser.

## Non-Goals

- No backend service.
- No login, account system, leaderboard, or online submission.
- No browser-based QEMU, kernel build, or root-only command execution.
- No replacement for the existing Markdown documents.
- No automatic grading for analysis-only challenges.

## Target Users

- Developers with basic Linux kernel development experience.
- Learners who can build or boot a local kernel lab and want structured debugging practice.
- Maintainers or mentors who want to assign focused kernel debugging exercises.

## Information Architecture

The site must have these views:

- Home: project title, short positioning, progress summary, and challenge grid.
- Challenge detail: one challenge with symptom, goal, background link, lab link, run commands, evidence checklist, and completion criteria.
- About or Method: short explanation of the local-first workflow.

The Home challenge grid should support simple filtering by category:

- Lab setup
- Crash and oops
- Tracing
- Memory
- Hangs and concurrency
- IRQ, softirq, timers, and workqueues
- I/O and networking
- Driver lifecycle
- Reporting

## Challenge Model

Each challenge should be represented by structured data with these fields:

```json
{
  "id": "day-10-page-fault-triage",
  "day": 10,
  "title": "Given a NULL-pointer oops, how do you prove the bad access?",
  "category": "Crash and oops",
  "difficulty": "intermediate",
  "summary": "Analyze a controlled page-fault oops and connect fault address, instruction, access type, and context.",
  "backgroundDoc": "../labs/day-10-page-fault-triage/README.md",
  "labPath": "../labs/day-10-page-fault-triage/",
  "commands": [
    "make -C labs/day-10-page-fault-triage/modules",
    "sudo insmod fault_demo.ko trigger_null=1"
  ],
  "evidenceChecklist": [
    "RIP or PC",
    "fault address",
    "access type",
    "execution context",
    "source line"
  ],
  "completionCriteria": "A note connects fault address, instruction, access type, and context before proposing a fix direction."
}
```

The implementation may store this data as JSON or TypeScript data. The data source must be easy to edit without touching page layout code.

## Challenge Types

The first version should support three challenge types:

- Reading challenge: requires an annotation, checklist, or short report.
- Local lab challenge: requires running a shell script or kernel module locally.
- Evidence challenge: requires collecting logs, traces, counters, or decoded stack output.

The UI should label each challenge type clearly. It should not imply that the browser can verify kernel-side work.

## Content Mapping

All 30 Markdown documents under `labs/day-*/README.md` should appear as challenges.

Challenges with existing labs should include lab links and commands. Challenges without labs should still appear, but their lab section should say "No runnable lab yet" and focus on the evidence checklist.

The first version should not create new challenge content beyond metadata needed to present existing docs and labs.

## User Workflow

1. Learner opens Kernel Debugging Challenges.
2. Learner picks a challenge from the grid.
3. Learner reads the symptom, goal, and completion criteria.
4. Learner opens the background Markdown document.
5. Learner runs the linked local lab when available.
6. Learner records the requested evidence.
7. Learner marks the challenge complete locally in the browser.

Progress tracking may use browser local storage only. If local storage is unavailable, the site should still be usable without saved progress.

## UX Requirements

- The first screen should be the challenge catalog, not a marketing landing page.
- Challenge cards should be compact and scannable.
- Each card should show day number, category, challenge title, type, and lab availability.
- Challenge detail pages should keep commands copyable.
- The UI should make local execution risks explicit for crash, corruption, lockdep, and atomic sleep demos.
- The site should work without network access after dependencies are installed or built.

## Technical Requirements

- The website lives under the root-level `kernel-debugging-challenges/` directory.
- The site must link to existing repository paths rather than duplicating document content.
- The first implementation should be static and client-side only.
- Use the smallest existing frontend stack available in the repository, or plain static HTML/CSS/JS if no stack exists.
- Do not introduce a backend or database.
- Do not execute shell commands from the browser.

## Acceptance Criteria

- The site lists all 30 debugging challenges.
- Each challenge links to the matching `labs/day-*/README.md` document.
- Each challenge with a matching `labs/day-*` directory links to that lab.
- A learner can filter challenges by category.
- A learner can mark challenges complete locally.
- Dangerous local labs are visibly marked before showing trigger commands.
- The site can be built or opened using documented commands.

## Open Decisions

- Whether to implement with plain static files or a lightweight frontend framework.
- Whether to keep challenge metadata in JSON, TypeScript, or Markdown front matter.
- Whether the first version should include one-page routing only or separate challenge URLs.
