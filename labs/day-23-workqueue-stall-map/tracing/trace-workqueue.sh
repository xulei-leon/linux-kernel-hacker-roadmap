#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
orin_check="${ORIN_CHECK:-$script_dir/../../common/check-orin-env.sh}"
tracefs="${TRACEFS:-/sys/kernel/tracing}"
ORIN_TRACEFS="${ORIN_TRACEFS:-$tracefs}" \
  "$orin_check" --require-tracefs --require-tool trace-cmd

duration="${1:-10}"
out_dir="${OUT_DIR:-workqueue-trace-$(date +%Y%m%d-%H%M%S)}"
mkdir -p "$out_dir"

for event in workqueue_queue_work workqueue_execute_start workqueue_execute_end; do
  if [[ ! -e "$tracefs/events/workqueue/$event/enable" ]]; then
    echo "required tracepoint unavailable: workqueue:$event" >&2
    exit 1
  fi
done

trace-cmd record -o "$out_dir/workqueue.dat" \
  -e workqueue:workqueue_queue_work \
  -e workqueue:workqueue_execute_start \
  -e workqueue:workqueue_execute_end \
  -- sleep "$duration"

ps -eo pid,comm,stat,wchan | grep -E 'kworker|workqueue' > "$out_dir/workers.txt" || true
dmesg -T > "$out_dir/dmesg.txt"

echo "wrote $out_dir"
