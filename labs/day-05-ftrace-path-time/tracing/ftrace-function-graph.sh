#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
orin_check="${ORIN_CHECK:-$script_dir/../../common/check-orin-env.sh}"

function_name="${1:-}"
shift || true

if [[ -z "$function_name" ]]; then
  echo "usage: $0 <function> [command ...]" >&2
  echo "example: $0 vfs_read cat /proc/version" >&2
  exit 2
fi

tracefs="${TRACEFS:-/sys/kernel/tracing}"
if [[ ! -d "$tracefs" && -d /sys/kernel/debug/tracing ]]; then
  tracefs="/sys/kernel/debug/tracing"
fi

ORIN_TRACEFS="${ORIN_TRACEFS:-$tracefs}" bash "$orin_check" --require-tracefs

if [[ ! -w "$tracefs/tracing_on" ]]; then
  echo "tracefs is not writable; run as root or mount tracefs at /sys/kernel/tracing" >&2
  exit 1
fi

if ! grep -Fqx "$function_name" "$tracefs/available_filter_functions"; then
  echo "function is not traceable on this kernel: $function_name" >&2
  exit 1
fi

out="${OUT:-ftrace-${function_name}.txt}"
cmd=("$@")
if [[ ${#cmd[@]} -eq 0 ]]; then
  cmd=(cat /proc/version)
fi

previous_tracer="$(cat "$tracefs/current_tracer")"

cleanup() {
  echo 0 > "$tracefs/tracing_on" || true
  echo > "$tracefs/set_graph_function" || true
  echo "$previous_tracer" > "$tracefs/current_tracer" || true
}
trap cleanup EXIT

echo 0 > "$tracefs/tracing_on"
echo nop > "$tracefs/current_tracer"
echo > "$tracefs/trace"
echo > "$tracefs/set_graph_function"
echo "$function_name" > "$tracefs/set_graph_function"
echo function_graph > "$tracefs/current_tracer"

echo 1 > "$tracefs/tracing_on"
"${cmd[@]}"
echo 0 > "$tracefs/tracing_on"

cat "$tracefs/trace" > "$out"
echo "wrote $out"
