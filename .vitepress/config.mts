import { existsSync, readdirSync } from 'node:fs'
import { join, parse } from 'node:path'
import { defineConfig } from 'vitepress'

const repoName = 'linux-kernel-hacker-roadmap'

function titleFromSlug(slug: string) {
  const words = slug.split('-').filter(Boolean)
  const title: string[] = []

  if (words[0] === 'day' && /^\d+$/.test(words[1] ?? '')) {
    title.push(`Day ${words[1]}`)
    words.splice(0, 2)
  } else if (/^\d+$/.test(words[0] ?? '')) {
    words.shift()
  }

  return [
    ...title,
    ...words.map((word) => {
      const known = new Map([
        ['abi', 'ABI'],
        ['bpftrace', 'bpftrace'],
        ['debug', 'Debug'],
        ['ftrace', 'ftrace'],
        ['gdb', 'gdb'],
        ['ipc', 'IPC'],
        ['irq', 'IRQ'],
        ['kernel', 'Kernel'],
        ['kunit', 'KUnit'],
        ['linux', 'Linux'],
        ['memcg', 'memcg'],
        ['napi', 'NAPI'],
        ['perf', 'perf'],
        ['pm', 'PM'],
        ['qemu', 'QEMU'],
        ['rcu', 'RCU'],
        ['slab', 'slab'],
        ['softirq', 'softirq'],
        ['vmcore', 'vmcore'],
        ['wsl2', 'WSL2'],
      ])

      return known.get(word) ?? word[0].toUpperCase() + word.slice(1)
    }),
  ]
    .join(' ')
}

function readmeLinks(root: string) {
  return readdirSync(root, { withFileTypes: true })
    .filter((entry) => entry.isDirectory())
    .map((entry) => entry.name)
    .filter((name) => name !== '4-Reviews')
    .filter((name) => existsSync(join(root, name, 'README.md')))
    .sort((a, b) => a.localeCompare(b, undefined, { numeric: true }))
    .map((name) => ({
      text: titleFromSlug(name),
      link: `/${root}/${name}/README.html`,
    }))
}

function markdownLinks(root: string) {
  return readdirSync(root, { withFileTypes: true })
    .filter((entry) => entry.isFile() && entry.name.endsWith('.md'))
    .map((entry) => parse(entry.name).name)
    .sort((a, b) => a.localeCompare(b, undefined, { numeric: true }))
    .map((name) => ({
      text: titleFromSlug(name),
      link: `/${root}/${name}.html`,
    }))
}

export default defineConfig({
  base: `/${repoName}/`,
  title: 'Linux Kernel Hacker Roadmap',
  description: 'A practical roadmap for advanced Linux kernel development skills.',
  srcExclude: ['AGENTS.md', 'docs/4-Reviews/**'],
  ignoreDeadLinks: true,
  themeConfig: {
    nav: [
      { text: 'Roadmap', link: '/' },
      { text: 'Docs', link: '/docs/04-debugging/README.html' },
      { text: 'Labs', link: '/labs/day-01-debug-ready-kernel-lab/README.html' },
      { text: 'GitHub', link: 'https://github.com/xulei-leon/linux-kernel-hacker-roadmap' },
    ],
    sidebar: [
      {
        text: 'Roadmap',
        items: [{ text: 'Overview', link: '/' }],
      },
      {
        text: 'Docs',
        items: [...markdownLinks('docs'), ...readmeLinks('docs')],
      },
      {
        text: 'Labs',
        items: readmeLinks('labs'),
      },
    ],
    socialLinks: [
      { icon: 'github', link: 'https://github.com/xulei-leon/linux-kernel-hacker-roadmap' },
    ],
  },
})
