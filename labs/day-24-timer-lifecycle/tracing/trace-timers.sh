#!/usr/bin/env bash
set -euo pipefail

duration="${1:-10}"
out_dir="${OUT_DIR:-timer-trace-$(date +%Y%m%d-%H%M%S)}"
mkdir -p "$out_dir"

if ! command -v trace-cmd >/dev/null 2>&1; then
  echo "trace-cmd not found" >&2
  exit 1
fi

trace-cmd record -o "$out_dir/timers.dat" \
  -e timer:timer_start \
  -e timer:timer_cancel \
  -e timer:timer_expire_entry \
  -e timer:hrtimer_start \
  -e timer:hrtimer_cancel \
  -e timer:hrtimer_expire_entry \
  -- sleep "$duration"

echo "wrote $out_dir"

