# Orin Documentation Taxonomy Migration Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reorganize the public documentation into neutral system-foundation, kernel-debugging, and kernel-performance areas without global letter numbering or career-oriented wording.

**Architecture:** Keep integrated system project blueprints under one foundations directory. Split the existing kernel library by primary outcome, assign every guide to exactly one directory, and use descriptive filenames plus cross-links instead of global track IDs. Keep runnable labs in their existing location.

**Tech Stack:** Markdown, VitePress, Git.

## Global Constraints

- Public content must not describe job seeking, hiring requirements, role matching, candidates, or interview preparation.
- Preserve NVIDIA, Jetson, Tegra, Linux, and tool names when they identify real technical platforms or interfaces.
- Use `docs/orin-system-foundations/`, `docs/orin-kernel-debugging/`, and `docs/orin-kernel-performance/` as the only public documentation directories.
- Do not use A–O, A01, F01, or similar global identifiers in public article filenames, titles, lesson lists, or cross-references.
- Keep `labs/orin-kernel/` unchanged except for documentation links and reader-facing labels.
- Do not duplicate shared guides; use descriptive cross-links.

---

### Task 1: Establish the directory and filename taxonomy

**Files:**
- Move: `docs/orin-system-software/` to `docs/orin-system-foundations/`
- Split: `docs/orin-kernel/` into the debugging and performance directories
- Move: `docs/orin-nano-super-kernel-curriculum.md` to `project/orin-kernel-authoring-contract.md`

- [x] Rename system files to descriptive names: `capability-map.md`, `future-project-directions.md`, `cpu-soc-diagnostics.md`, `mmio-diagnostic-driver.md`, and `dvfs-thermal-validation.md`.
- [x] Move platform, build, driver, debugging, and verification guides into `orin-kernel-debugging` with descriptive filenames.
- [x] Move latency, storage, networking, power, and performance guides into `orin-kernel-performance` with descriptive filenames.
- [x] Confirm `docs/` contains only the three approved directories.

### Task 2: Rewrite public indexes and guide headings

**Files:**
- Modify: all Markdown files under the three new documentation directories

- [x] Rewrite the system foundations README as a neutral technical entry point with integrated projects and capability evidence.
- [x] Create focused README files for debugging and performance, including platform boundaries and descriptive guide maps.
- [x] Remove global track identifiers from titles, lesson lists, prerequisites, completion text, and cross-links.
- [x] Replace career-oriented wording with engineering evidence, technical capability, reproducible demonstration, and review terminology.

### Task 3: Update navigation and repository links

**Files:**
- Modify: `README.md`, `index.md`, `.vitepress/config.mts`
- Modify: Markdown under `labs/`, `resources/`, and `project/` that links to moved documents

- [x] Update VitePress title, description, navigation, and sidebar for the three public documentation areas.
- [x] Update every active documentation path and descriptive link label.
- [x] Keep historical project records unchanged so their completed decisions remain accurate.

### Task 4: Verify the migration

**Files:**
- Test: complete repository documentation graph

- [x] Run `rg` checks proving old directory names, global track identifiers, and career-oriented wording are absent from public documentation.
- [x] Run the two existing lab fixture tests.
- [x] Run `npm run docs:build` and require exit code 0.
- [x] Run `git diff --check` and inspect `git status --short` for only intended changes.
