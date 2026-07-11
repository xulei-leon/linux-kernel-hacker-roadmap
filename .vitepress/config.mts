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
  title: 'Orin Nano Super Kernel Course',
  description: 'An advanced, problem-driven Linux kernel development course.',
  srcExclude: [
    'AGENTS.md',
    'docs/1-Requirement/**',
    'docs/3-Plan/**',
    'docs/4-Reviews/**',
  ],
  themeConfig: {
    nav: [
      { text: 'Course', link: '/docs/orin-kernel/README.html' },
      { text: 'Tracks', link: '/docs/orin-kernel/track-a-baseline-recovery.html' },
      { text: 'Labs', link: '/labs/orin-kernel/README.html' },
      { text: 'QEMU', link: '/labs/orin-kernel/qemu-auxiliary/README.html' },
      { text: 'GitHub', link: 'https://github.com/xulei-leon/linux-kernel-hacker-roadmap' },
    ],
    sidebar: [
      {
        text: 'Course',
        items: [
          { text: 'Overview', link: '/' },
          { text: 'Course Map', link: '/docs/orin-kernel/README.html' },
        ],
      },
      { text: 'Tracks', items: tracks },
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
