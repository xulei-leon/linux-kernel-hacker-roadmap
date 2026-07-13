#!/usr/bin/env bash
set -euo pipefail

proc_root="${PROC_ROOT:-/proc}"
sys_root="${SYS_ROOT:-/sys}"
etc_root="${ETC_ROOT:-/etc}"
output_dir="${1:-}"

if [[ -z "$output_dir" ]]; then
  echo "usage: $0 OUTPUT_DIR" >&2
  exit 2
fi

if [[ -e "$output_dir" ]] && [[ -n "$(find "$output_dir" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null)" ]]; then
  echo "output directory is not empty: $output_dir" >&2
  exit 2
fi

mkdir -p "$output_dir"

write_unavailable() {
  printf 'unavailable\n' > "$1"
}

copy_text_or_unavailable() {
  local source="$1"
  local destination="$2"
  if [[ -r "$source" ]]; then
    cat "$source" > "$destination"
  else
    write_unavailable "$destination"
  fi
}

copy_dt_or_unavailable() {
  local source="$1"
  local destination="$2"
  if [[ -r "$source" ]]; then
    tr '\000' '\n' < "$source" | sed '/^$/d' > "$destination"
  else
    write_unavailable "$destination"
  fi
}

copy_dt_or_unavailable "$proc_root/device-tree/model" "$output_dir/model.txt"
copy_dt_or_unavailable "$proc_root/device-tree/compatible" "$output_dir/compatible.txt"
copy_dt_or_unavailable "$proc_root/device-tree/serial-number" "$output_dir/device-tree-serial.txt"

carrier_source=""
for candidate in \
  "$proc_root/device-tree/carrier-board" \
  "$proc_root/device-tree/nvidia,boardids" \
  "$proc_root/device-tree/nvidia,boardid"; do
  if [[ -r "$candidate" ]]; then
    carrier_source="$candidate"
    break
  fi
done
if [[ -n "$carrier_source" ]]; then
  copy_dt_or_unavailable "$carrier_source" "$output_dir/carrier-board.txt"
else
  write_unavailable "$output_dir/carrier-board.txt"
fi

soc_revision="$sys_root/devices/soc0/revision"
if [[ -r "$soc_revision" ]]; then
  copy_text_or_unavailable "$soc_revision" "$output_dir/soc-revision.txt"
else
  write_unavailable "$output_dir/soc-revision.txt"
fi

if [[ -r "$proc_root/meminfo" ]]; then
  awk '/^MemTotal:/ { print; found=1 } END { if (!found) exit 1 }' \
    "$proc_root/meminfo" > "$output_dir/memory.txt" \
    || write_unavailable "$output_dir/memory.txt"
else
  write_unavailable "$output_dir/memory.txt"
fi

printf '%s\n' "${UNAME_MACHINE:-$(uname -m)}" > "$output_dir/architecture.txt"
printf '%s\n' "${UNAME_RELEASE:-$(uname -r)}" > "$output_dir/kernel-release.txt"
copy_text_or_unavailable "$proc_root/cmdline" "$output_dir/kernel-command-line.txt"
copy_text_or_unavailable "$etc_root/nv_tegra_release" "$output_dir/nv-tegra-release.txt"
copy_text_or_unavailable "$etc_root/os-release" "$output_dir/os-release.txt"

if [[ -n "${NVIDIA_PACKAGES_FILE:-}" ]]; then
  copy_text_or_unavailable "$NVIDIA_PACKAGES_FILE" "$output_dir/nvidia-packages.txt"
elif command -v dpkg-query >/dev/null 2>&1; then
  dpkg-query -W -f='${binary:Package}\t${Version}\n' 'nvidia-l4t-*' \
    > "$output_dir/nvidia-packages.txt" 2>/dev/null \
    || write_unavailable "$output_dir/nvidia-packages.txt"
else
  write_unavailable "$output_dir/nvidia-packages.txt"
fi

printf '%s\n' "${COLLECTED_AT:-$(date -u +%Y-%m-%dT%H:%M:%SZ)}" \
  > "$output_dir/collected-at.txt"

(
  cd "$output_dir"
  : > SHA256SUMS
  while IFS= read -r file; do
    sha256sum "$file" >> SHA256SUMS
  done < <(find . -maxdepth 1 -type f ! -name SHA256SUMS -printf '%f\n' | sort)
)

echo "evidence collected: $output_dir"
