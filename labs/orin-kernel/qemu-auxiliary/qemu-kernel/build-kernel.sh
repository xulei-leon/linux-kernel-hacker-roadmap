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
: "${CONFIG_TARGET:=defconfig}"
: "${MAKE_JOBS:=$(nproc)}"
: "${MAKE_TARGETS:=bzImage vmlinux}"
: "${CLEAN_TREE:=0}"

if [[ ! -d "$KERNEL_TREE" ]]; then
  echo "KERNEL_TREE not a directory: $KERNEL_TREE" >&2
  exit 2
fi

cd "$KERNEL_TREE"

echo "kernel_commit=$(git rev-parse HEAD 2>/dev/null || echo tarball-source)"

if [[ "$CLEAN_TREE" == "1" ]]; then
  make mrproper
fi

make "$CONFIG_TARGET"

scripts/config --enable DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT
scripts/config --enable KALLSYMS
scripts/config --enable KALLSYMS_ALL

make olddefconfig
make -j"$MAKE_JOBS" $MAKE_TARGETS

test -r arch/x86/boot/bzImage && echo "kernel image is readable: $KERNEL_TREE/arch/x86/boot/bzImage"
test -r vmlinux && echo "vmlinux is readable: $KERNEL_TREE/vmlinux"
