#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
env_file="${1:-$script_dir/../../day-01-debug-ready-kernel-lab/qemu-kernel/lab.env}"

if [[ ! -r "$env_file" ]]; then
  echo "usage: $0 [lab.env]" >&2
  exit 2
fi

# shellcheck source=/dev/null
source "$env_file"

: "${KERNEL_TREE:?set KERNEL_TREE in lab.env}"
: "${ROOTFS_IMAGE:?set ROOTFS_IMAGE in lab.env}"
: "${TRIGGER_COMMAND:?set TRIGGER_COMMAND in lab.env for bisect runs}"
: "${QEMU:=qemu-system-x86_64}"
: "${KERNEL_IMAGE:=arch/x86/boot/bzImage}"
: "${MEMORY:=2G}"
: "${SMP:=2}"
: "${DRIVE_OPTS:=format=raw,if=virtio}"
: "${KERNEL_APPEND:=console=ttyS0 root=/dev/vda rw panic=-1}"
: "${QEMU_TIMEOUT:=60}"
: "${LOGIN_PROMPT:=login:}"
: "${LOGIN_USER:=root}"
: "${LOGIN_PASSWORD:=}"
: "${SHELL_PROMPT:=# }"

if ! command -v expect >/dev/null 2>&1; then
  echo "expect not found; install expect or replace this script with your lab trigger" >&2
  exit 125
fi

export QEMU KERNEL_TREE KERNEL_IMAGE KERNEL_APPEND ROOTFS_IMAGE DRIVE_OPTS MEMORY SMP
export QEMU_TIMEOUT LOGIN_PROMPT LOGIN_USER LOGIN_PASSWORD SHELL_PROMPT TRIGGER_COMMAND

expect <<'EOF'
set timeout $env(QEMU_TIMEOUT)
spawn $env(QEMU) \
  -kernel "$env(KERNEL_TREE)/$env(KERNEL_IMAGE)" \
  -append "$env(KERNEL_APPEND)" \
  -drive "file=$env(ROOTFS_IMAGE),$env(DRIVE_OPTS)" \
  -m "$env(MEMORY)" \
  -smp "$env(SMP)" \
  -nographic

expect $env(LOGIN_PROMPT)
send "$env(LOGIN_USER)\r"

if {$env(LOGIN_PASSWORD) ne ""} {
  expect "Password:"
  send "$env(LOGIN_PASSWORD)\r"
}

expect $env(SHELL_PROMPT)
send "$env(TRIGGER_COMMAND)\r"
expect $env(SHELL_PROMPT)
send "poweroff -f\r"
expect eof
EOF
