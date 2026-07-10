#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

bash -n "$script_dir/build-kernel.sh"
bash -n "$script_dir/boot-qemu.sh"

cat > "$tmp_dir/lab.env" <<EOF
KERNEL_TREE="$tmp_dir/missing-kernel"
INITRAMFS_IMAGE="$tmp_dir/missing-initramfs.cpio.xz"
EOF

if bash "$script_dir/boot-qemu.sh" "$tmp_dir/lab.env" 2>"$tmp_dir/stderr"; then
  echo "boot-qemu.sh unexpectedly succeeded" >&2
  exit 1
fi

grep -q "kernel image not found" "$tmp_dir/stderr"
echo "Day 00 QEMU smoke test passed"
