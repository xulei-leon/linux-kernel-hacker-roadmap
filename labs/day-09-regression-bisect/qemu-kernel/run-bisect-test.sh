#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
env_file="${1:-$script_dir/../../day-01-debug-ready-kernel-lab/qemu-kernel/lab.env}"
log="${BISECT_LOG:-run.log}"

if [[ ! -r "$env_file" ]]; then
  echo "usage: $0 [lab.env]" >&2
  exit 125
fi

# shellcheck source=/dev/null
source "$env_file"

: "${KERNEL_TREE:?set KERNEL_TREE in lab.env}"
: "${MAKE_JOBS:=$(nproc)}"
: "${MAKE_TARGETS:=bzImage}"
: "${BAD_PATTERN:=BUG: unable to handle page fault}"

env_abs="$(cd "$(dirname "$env_file")" && pwd)/$(basename "$env_file")"

cd "$KERNEL_TREE"

make olddefconfig || exit 125
make -j"$MAKE_JOBS" $MAKE_TARGETS || exit 125

if ! "$script_dir/boot-qemu-and-trigger.sh" "$env_abs" > "$log" 2>&1; then
  exit 125
fi

if grep -qE "$BAD_PATTERN" "$log"; then
  exit 1
fi

exit 0
