import { defineConfig } from 'vitepress'

const repoName = 'linux-kernel-hacker-roadmap'

const tracks = [
  ['Track A — Orin Baseline and Recovery', '/docs/orin-kernel/track-a-baseline-recovery.html'],
  ['Track B — BSP Source and Build', '/docs/orin-kernel/track-b-bsp-build.html'],
  ['Track C — QEMU Auxiliary Environment', '/docs/orin-kernel/track-c-qemu.html'],
  ['Track D — Device Tree and Probe', '/docs/orin-kernel/track-d-device-tree.html'],
  ['Track E — Driver Lifecycle and Hardware I/O', '/docs/orin-kernel/track-e-driver-lifecycle.html'],
  ['Track F — Observability', '/docs/orin-kernel/track-f-observability.html'],
  ['Track G — Oops and Panic', '/docs/orin-kernel/track-g-oops-panic.html'],
  ['Track H — Memory Failures', '/docs/orin-kernel/track-h-memory.html'],
  ['Track I — Concurrency and CPU Stalls', '/docs/orin-kernel/track-i-concurrency.html'],
  ['Track J — IRQ, Deferred Work, and Latency', '/docs/orin-kernel/track-j-irq-latency.html'],
  ['Track K — Storage and Filesystems', '/docs/orin-kernel/track-k-storage.html'],
  ['Track L — Networking', '/docs/orin-kernel/track-l-networking.html'],
  ['Track M — Power, Thermal, and Frequency', '/docs/orin-kernel/track-m-power.html'],
  ['Track N — Performance Engineering', '/docs/orin-kernel/track-n-performance.html'],
  ['Track O — Tests, Reports, and Upstream Work', '/docs/orin-kernel/track-o-upstream.html'],
].map(([text, link]) => ({ text, link }))

export default defineConfig({
  base: `/${repoName}/`,
  title: 'NVIDIA CPU System Software Roadmap',
  description: 'A project-driven Linux and Tegra system software roadmap aligned with NVIDIA JR2019268.',
  srcExclude: [
    'AGENTS.md',
    'docs/1-Requirement/**',
    'docs/3-Plan/**',
    'docs/4-Reviews/**',
    'docs/superpowers/**',
    'project/**',
  ],
  themeConfig: {
    nav: [
      { text: 'Roadmap', link: '/docs/orin-system-software/README.html' },
      { text: 'Competencies', link: '/docs/orin-system-software/role-competency-map.html' },
      { text: 'Kernel Library', link: '/docs/orin-kernel/README.html' },
      { text: 'Labs', link: '/labs/orin-kernel/README.html' },
      { text: 'QEMU', link: '/labs/orin-kernel/qemu-auxiliary/README.html' },
      { text: 'GitHub', link: 'https://github.com/xulei-leon/linux-kernel-hacker-roadmap' },
    ],
    sidebar: [
      {
        text: 'Role Roadmap',
        items: [
          { text: 'Overview', link: '/' },
          { text: 'Roadmap', link: '/docs/orin-system-software/README.html' },
          { text: 'Competency Map', link: '/docs/orin-system-software/role-competency-map.html' },
          { text: 'Project 1 — CPU/SoC Diagnostics', link: '/docs/orin-system-software/project-1-cpu-soc-diagnostics.html' },
          { text: 'Project 2 — MMIO Diagnostic Driver', link: '/docs/orin-system-software/project-2-mmio-diagnostic-driver.html' },
          { text: 'Project 3 — DVFS/Thermal Validation', link: '/docs/orin-system-software/project-3-dvfs-thermal-validation.html' },
          { text: 'Delivery Roadmap', link: '/docs/orin-system-software/delivery-roadmap.html' },
        ],
      },
      {
        text: 'Kernel Skill Library',
        items: [
          { text: 'Library Map', link: '/docs/orin-kernel/README.html' },
          ...tracks,
        ],
      },
      {
        text: 'Labs',
        items: [
          { text: 'Labs Index', link: '/labs/orin-kernel/README.html' },
          { text: 'QEMU Auxiliary Environment', link: '/labs/orin-kernel/qemu-auxiliary/README.html' },
        ],
      },
    ],
    socialLinks: [
      { icon: 'github', link: 'https://github.com/xulei-leon/linux-kernel-hacker-roadmap' },
    ],
  },
})
