# Orin Kernel Resource Policy

Project and skill-library documents should link to primary sources close to the
claim they support.
This file defines resource categories and verification rules; it deliberately
does not provide a large, rapidly stale link dump.

## Preferred sources

1. NVIDIA Jetson Linux release notes, developer guides, BSP source, and Jetson
   hardware documentation for release- and board-specific behavior.
2. Linux kernel source and in-tree documentation for kernel APIs and subsystem
   behavior.
3. Kernel.org stable, mainline, linux-next, subsystem trees, and official test
   projects for version and workflow claims.
4. Official Arm architecture manuals, architecture supplements, and technical
   reference manuals for architectural behavior not fully described by kernel
   documentation. Record the document identifier and revision; do not cite an
   unspecific Arm landing page for a register or ordering claim.

## Special provenance records

- **Job postings:** retain a local snapshot only when redistribution terms and
  repository policy permit it. Otherwise retain a structured metadata and
  extracted-claim record with the live URL and review date. Record employer,
  role ID, posting date when known, and the public claim categories used. A
  snapshot or claim record supports roadmap interpretation, not a claim about
  undocumented systems or hiring outcomes.
- **Arm documentation:** record publisher, exact title, document identifier,
  revision, applicable architecture/core, URL, and review date. Distinguish Arm
  architectural rules from Linux behavior and from Tegra implementation facts.
- **Benchmarks:** retain tool/workload version, source, build options, inputs,
  full command line, warm-up, repetitions, affinity, platform controls, raw
  results, excluded trials with reasons, analysis code/version, and review
  date. A chart without reproducible raw evidence is not acceptance evidence.
- **External links:** each non-primary link needs an owner, nearby claim,
  review date, and a note explaining why a primary source is insufficient.
  Reopen it during affected content review; replace or remove links that no
  longer support the claim.

## Current job-posting provenance

- **Publisher:** NVIDIA
- **Title:** Senior System Software Engineer, CPU
- **Job ID:** JR2019268
- **Official URL:** [NVIDIA careers posting](https://nvidia.wd5.myworkdayjobs.com/en-US/NVIDIAExternalCareerSite/job/China-Shenzhen/Senior-System-Software-Engineer--CPU_JR2019268)
- **Posted:** 2026-06-05
- **Reviewed:** 2026-07-13
- **Claim categories used:** Tegra diagnostic software, device drivers, SoC
  feature development and optimization, full-lifecycle debugging and testing,
  C/C++, Linux kernel internals, ARM platforms, communication, education, and
  experience requirements.

This record is a dated extraction from the public posting. The live URL and
review date are the provenance retained here; no local snapshot is asserted.

## Link acceptance

Before adding a changing resource, record its title, publisher, applicable
release/version, URL, and review date. Open the link and verify that it supports
the nearby claim. Do not cite search-result pages, undated mirrors, or a current
product landing page as evidence for a historical release mapping.

The first executable Orin hardware lesson must add a dated official NVIDIA
source that establishes the selected JetPack, Jetson Linux, and kernel mapping.

Reviewed external links are supporting material, not authority over a
conflicting official specification, kernel source, or measured project
evidence. Keep enough local metadata to identify the intended source if its URL
changes, and do not silently substitute a different revision.
