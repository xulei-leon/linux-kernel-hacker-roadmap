import { defineConfig } from 'vitepress'

const repoName = 'tegra-linux-kernel-roadmap'

const debuggingGuides = [
  ['Identify the Exact Orin Platform', '/docs/orin-kernel-debugging/identify-orin-platform.html'],
  ['Capture a Reproducible Software Baseline', '/docs/orin-kernel-debugging/capture-software-baseline.html'],
  ['Orin Platform Recovery', '/docs/orin-kernel-debugging/platform-recovery.html'],
  ['BSP Build and Deployment', '/docs/orin-kernel-debugging/bsp-build-and-deployment.html'],
  ['QEMU Debug Environment', '/docs/orin-kernel-debugging/qemu-debug-environment.html'],
  ['Device Tree and Driver Probe', '/docs/orin-kernel-debugging/device-tree-and-driver-probe.html'],
  ['Driver Lifecycle and Hardware I/O', '/docs/orin-kernel-debugging/driver-lifecycle-and-hardware-io.html'],
  ['Kernel Observability', '/docs/orin-kernel-debugging/kernel-observability.html'],
  ['Oops and Panic', '/docs/orin-kernel-debugging/oops-and-panic.html'],
  ['Memory Failures', '/docs/orin-kernel-debugging/memory-failures.html'],
  ['Concurrency and CPU Stalls', '/docs/orin-kernel-debugging/concurrency-and-cpu-stalls.html'],
  ['Testing, Reporting, and Upstream Work', '/docs/orin-kernel-debugging/testing-reporting-and-upstream.html'],
].map(([text, link]) => ({ text, link }))

const performanceGuides = [
  ['Performance Engineering', '/docs/orin-kernel-performance/performance-engineering.html'],
  ['IRQ and Scheduler Latency', '/docs/orin-kernel-performance/irq-and-scheduler-latency.html'],
  ['Storage and Filesystem Performance', '/docs/orin-kernel-performance/storage-and-filesystem-performance.html'],
  ['Network Performance', '/docs/orin-kernel-performance/network-performance.html'],
  ['Power, Thermal, and Frequency', '/docs/orin-kernel-performance/power-thermal-and-frequency.html'],
].map(([text, link]) => ({ text, link }))

export default defineConfig({
  base: `/${repoName}/`,
  title: 'Tegra Linux Kernel Roadmap',
  description: 'Project-driven Linux, Tegra, kernel debugging, and performance engineering on Jetson Orin.',
  lastUpdated: true,
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
      {
        text: 'Roadmaps',
        items: [
          { text: 'System Foundations', link: '/docs/orin-system-foundations/README.html' },
          { text: 'Kernel Debugging', link: '/docs/orin-kernel-debugging/README.html' },
          { text: 'Kernel Performance', link: '/docs/orin-kernel-performance/README.html' },
        ],
      },
      {
        text: 'Practice',
        items: [
          { text: 'Runnable Labs', link: '/labs/orin-kernel-debugging/README.html' },
          { text: 'QEMU Environment', link: '/labs/orin-kernel-debugging/qemu-auxiliary/README.html' },
        ],
      },
      { text: 'GitHub', link: 'https://github.com/xulei-leon/tegra-linux-kernel-roadmap' },
    ],
    sidebar: {
      '/docs/orin-system-foundations/': [
        {
          text: 'System Foundations',
          items: [
            { text: 'Foundation Map', link: '/docs/orin-system-foundations/README.html' },
            { text: 'Capability Map', link: '/docs/orin-system-foundations/capability-map.html' },
            { text: 'CPU/SoC Diagnostics', link: '/docs/orin-system-foundations/cpu-soc-diagnostics.html' },
            { text: 'MMIO Diagnostic Driver', link: '/docs/orin-system-foundations/mmio-diagnostic-driver.html' },
            { text: 'DVFS/Thermal Validation', link: '/docs/orin-system-foundations/dvfs-thermal-validation.html' },
            { text: 'Integrated Project Roadmap', link: '/docs/orin-system-foundations/integrated-project-roadmap.html' },
            { text: 'Future Project Directions', link: '/docs/orin-system-foundations/future-project-directions.html' },
          ],
        },
      ],
      '/docs/orin-kernel-debugging/': [
        {
          text: 'Kernel Debugging',
          items: [
            { text: 'Guide Map', link: '/docs/orin-kernel-debugging/README.html' },
            ...debuggingGuides,
          ],
        },
      ],
      '/docs/orin-kernel-performance/': [
        {
          text: 'Kernel Performance',
          items: [
            { text: 'Guide Map', link: '/docs/orin-kernel-performance/README.html' },
            ...performanceGuides,
          ],
        },
      ],
      '/labs/orin-kernel-debugging/': [
        {
          text: 'Runnable Labs',
          items: [
            { text: 'Labs Index', link: '/labs/orin-kernel-debugging/README.html' },
            { text: 'Platform Evidence', link: '/labs/orin-kernel-debugging/identify-orin-platform/README.html' },
            { text: 'Software Baseline', link: '/labs/orin-kernel-debugging/capture-software-baseline/README.html' },
            { text: 'QEMU Environment', link: '/labs/orin-kernel-debugging/qemu-auxiliary/README.html' },
          ],
        },
      ],
    },
    search: {
      provider: 'local',
    },
    outline: {
      level: [2, 3],
      label: 'On this page',
    },
    editLink: {
      pattern: 'https://github.com/xulei-leon/tegra-linux-kernel-roadmap/edit/main/:path',
      text: 'Edit this page on GitHub',
    },
    docFooter: {
      prev: 'Previous topic',
      next: 'Next topic',
    },
    footer: {
      message: 'Evidence-driven Linux, ARM64, and Tegra system engineering.',
      copyright: 'Released under the MIT License.',
    },
    returnToTopLabel: 'Back to top',
    sidebarMenuLabel: 'Documentation menu',
    darkModeSwitchLabel: 'Appearance',
    externalLinkIcon: true,
    socialLinks: [
      { icon: 'github', link: 'https://github.com/xulei-leon/tegra-linux-kernel-roadmap' },
    ],
  },
})
