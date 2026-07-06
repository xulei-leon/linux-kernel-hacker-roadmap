# AGENTS.md

## Project Scope

This repository is a documentation-first roadmap for Linux kernel developers who want to grow from basic kernel contribution toward advanced kernel hacking capability.

Keep the project aligned with the README goal:

- high-quality kernel code
- kernel debugging
- kernel performance analysis and optimization
- subsystem understanding

Do not turn this into a generic operating systems course, a Linux user guide, or a fixed training-plan repository.

## Content Rules

- Write project content in English.
- Keep explanations practical and specific to Linux kernel development.
- Prefer concise roadmap/checklist/lab material over long essays.
- Split documents into roughly one-hour learning or practice units.
- Each document should analyze one concrete problem, difficulty, or focused topic.
- Prefer How, Q/A, and Why formats over purely What-style explanations.
- Avoid generic tutorial articles that only explain concepts, because that material is already easy to find elsewhere.
- Focus on practical skill growth: diagnosis steps, trade-offs, commands, experiments, observations, and verification.
- Use real Linux kernel terminology where possible: mainline, stable, linux-next, kselftest, KUnit, perf, ftrace, lockdep, KASAN.
- Do not invent commands, tools, or kernel workflows that are not real.
- When adding resources that may change over time, verify current names and links before committing them.

## Repository Structure

The README is the current entry point. Only create directories when adding real content.

Suggested future structure:

```text
docs/
labs/
resources/
```

Do not add empty scaffolding directories or placeholder files.

## Editing Guidelines

- Keep changes small and focused.
- Preserve existing user edits.
- Prefer one useful document over multiple thin documents.
- Use Markdown tables only when they improve scanning.
- Use code formatting for commands, file names, kernel symbols, and tool names.
- Avoid unverified claims about kernel internals or tool behavior.

## Verification

For documentation-only changes:

- Run `git diff --check`.
- Review the rendered Markdown mentally for heading order, broken tables, and stray non-English text when the target file is English-only.

For future lab or script changes:

- Add the smallest runnable check that proves the lab or script still works.
- Document the kernel version, config, QEMU command, and expected result when relevant.
