#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
env_file="${1:-$script_dir/lab.env}"

if [[ ! -r "$env_file" ]]; then
  echo "usage: $0 [lab.env]" >&2
  echo "copy lab.env.example to lab.env and edit paths first" >&2
  exit 2
fi

# shellcheck source=/dev/null
source "$env_file"

: "${KERNEL_TREE:?set KERNEL_TREE in lab.env}"
: "${INITRAMFS_IMAGE:?set INITRAMFS_IMAGE in lab.env}"
: "${QEMU:=qemu-system-x86_64}"
: "${KERNEL_IMAGE:=arch/x86/boot/bzImage}"
: "${MEMORY:=2G}"
: "${SMP:=2}"
: "${KERNEL_APPEND:=console=ttyS0 rdinit=/init panic=-1}"

kernel_path="$KERNEL_TREE/$KERNEL_IMAGE"

if [[ ! -r "$kernel_path" ]]; then
  echo "kernel image not found: $kernel_path" >&2
  exit 1
fi

if [[ ! -r "$INITRAMFS_IMAGE" ]]; then
  echo "initramfs image not found: $INITRAMFS_IMAGE" >&2
  exit 1
fi

cmd=(
  "$QEMU"
  -kernel "$kernel_path" \
  -initrd "$INITRAMFS_IMAGE" \
  -append "$KERNEL_APPEND" \
  -m "$MEMORY" \
  -smp "$SMP" \
  -nographic
)

if [[ -n "${SERIAL_LOG:-}" ]]; then
  printf -v qemu_cmd '%q ' "${cmd[@]}"
  exec script -q -f -e -c "$qemu_cmd" "$SERIAL_LOG"
fi

exec "${cmd[@]}"
