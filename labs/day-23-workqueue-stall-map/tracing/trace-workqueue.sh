#!/usr/bin/env bash
set -euo pipefail

duration="${1:-10}"
out_dir="${OUT_DIR:-workqueue-trace-$(date +%Y%m%d-%H%M%S)}"
mkdir -p "$out_dir"

if ! command -v trace-cmd >/dev/null 2>&1; then
  echo "trace-cmd not found" >&2
  exit 1
fi

trace-cmd record -o "$out_dir/workqueue.dat" \
  -e workqueue:workqueue_queue_work \
  -e workqueue:workqueue_execute_start \
  -e workqueue:workqueue_execute_end \
  -- sleep "$duration"

ps -eo pid,comm,stat,wchan | grep -E 'kworker|workqueue' > "$out_dir/workers.txt" || true
dmesg -T > "$out_dir/dmesg.txt"

echo "wrote $out_dir"

