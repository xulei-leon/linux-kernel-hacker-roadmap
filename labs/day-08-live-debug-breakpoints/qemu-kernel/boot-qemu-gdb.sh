#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
env_file="${1:-$script_dir/../../day-01-debug-ready-kernel-lab/qemu-kernel/lab.env}"

if [[ ! -r "$env_file" ]]; then
  echo "usage: $0 [lab.env]" >&2
  echo "expected a Day 1 lab.env by default: $env_file" >&2
  exit 2
fi

# shellcheck source=/dev/null
source "$env_file"

: "${KERNEL_TREE:?set KERNEL_TREE in lab.env}"
: "${ROOTFS_IMAGE:?set ROOTFS_IMAGE in lab.env}"
: "${QEMU:=qemu-system-x86_64}"
: "${KERNEL_IMAGE:=arch/x86/boot/bzImage}"
: "${MEMORY:=2G}"
: "${SMP:=2}"
: "${DRIVE_OPTS:=format=raw,if=virtio}"
: "${KERNEL_APPEND:=console=ttyS0 root=/dev/vda rw}"

exec "$QEMU" \
  -kernel "$KERNEL_TREE/$KERNEL_IMAGE" \
  -append "$KERNEL_APPEND" \
  -drive "file=$ROOTFS_IMAGE,$DRIVE_OPTS" \
  -m "$MEMORY" \
  -smp "$SMP" \
  -nographic \
  -s -S
