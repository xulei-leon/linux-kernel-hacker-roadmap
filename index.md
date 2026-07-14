---
layout: home
title: Jetson Orin System Engineering Roadmap
titleTemplate: false

hero:
  name: Jetson Orin
  text: System Engineering Roadmap
  tagline: Build demonstrable Linux, ARM64, Tegra, kernel debugging, and performance skills through reproducible evidence.
  actions:
    - theme: brand
      text: Start with foundations
      link: /docs/orin-system-foundations/README.html
    - theme: alt
      text: Run the first lab
      link: /labs/orin-kernel-debugging/identify-orin-platform/README.html

features:
  - icon: '01'
    title: System foundations
    details: Establish platform identity, recovery, build provenance, and bounded hardware access before making changes.
    link: /docs/orin-system-foundations/README.html
    linkText: Open the foundation map
  - icon: '02'
    title: Kernel debugging
    details: Move from symptom to root cause with source-level evidence, controlled triggers, and repeatable verification.
    link: /docs/orin-kernel-debugging/README.html
    linkText: Choose a debugging guide
  - icon: '03'
    title: Performance engineering
    details: Measure latency, throughput, power, and thermal behavior without hiding noise or platform limits.
    link: /docs/orin-kernel-performance/README.html
    linkText: Choose a performance guide
---

<section class="roadmap-section evidence-section" aria-labelledby="evidence-status">
  <div class="roadmap-section-heading">
    <h2 id="evidence-status">Know what is runnable today</h2>
    <p>The roadmap separates verified practice from project blueprints so every claim has a clear evidence boundary.</p>
  </div>
  <div class="evidence-grid">
    <article>
      <span class="status status-ready">Runnable</span>
      <h3>Platform evidence</h3>
      <p>Identify the exact Orin platform and capture a reproducible software baseline with bounded checks.</p>
      <a href="./labs/orin-kernel-debugging/README.html">Browse runnable labs →</a>
    </article>
    <article>
      <span class="status status-planned">Blueprints</span>
      <h3>Integrated projects</h3>
      <p>CPU/SoC diagnostics, safe MMIO access, and DVFS validation remain planning assets until implementation evidence exists.</p>
      <a href="./docs/orin-system-foundations/integrated-project-roadmap.html">Review the project roadmap →</a>
    </article>
    <article>
      <span class="status status-boundary">Evidence boundary</span>
      <h3>Orin and QEMU</h3>
      <p>Orin is authoritative for Tegra hardware claims. QEMU supports generic kernel work and destructive experiments.</p>
      <a href="./labs/orin-kernel-debugging/qemu-auxiliary/README.html">Open the QEMU environment →</a>
    </article>
  </div>
</section>

<section class="roadmap-section projects-section" aria-labelledby="integrated-projects">
  <div class="roadmap-section-heading">
    <h2 id="integrated-projects">Build toward three integrated projects</h2>
    <p>Each project turns guides and labs into source, failure evidence, repeatable tests, and a defensible technical result.</p>
  </div>
  <ol class="project-list">
    <li>
      <span>01</span>
      <div><strong>CPU/SoC diagnostic suite</strong><p>Compose bounded platform checks into structured, reproducible system evidence.</p></div>
      <a href="./docs/orin-system-foundations/cpu-soc-diagnostics.html">Project blueprint →</a>
    </li>
    <li>
      <span>02</span>
      <div><strong>Safe MMIO diagnostic driver</strong><p>Read declared resources through a platform driver without exposing arbitrary physical memory.</p></div>
      <a href="./docs/orin-system-foundations/mmio-diagnostic-driver.html">Project blueprint →</a>
    </li>
    <li>
      <span>03</span>
      <div><strong>DVFS and thermal validation</strong><p>Use controlled workloads and repeated trials to make explicit regression decisions.</p></div>
      <a href="./docs/orin-system-foundations/dvfs-thermal-validation.html">Project blueprint →</a>
    </li>
  </ol>
</section>

<section class="roadmap-section policy-section" aria-labelledby="platform-policy">
  <div>
    <h2 id="platform-policy">Evidence stays platform-specific</h2>
    <p>Never present x86_64, virtio, host, replay, or emulated results as ARM64 or Tegra hardware evidence. Recovery precedes boot-critical modification, and hardware access stays bounded to declared resources.</p>
  </div>
  <a class="policy-link" href="./docs/orin-system-foundations/capability-map.html">See the capability and evidence map →</a>
</section>
