#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
lab_dir="$(cd "$script_dir/.." && pwd)"
repo_root="$(cd "$lab_dir/../../.." && pwd)"
a01_lab="$repo_root/labs/orin-kernel/a01-identify-exact-orin-platform"

a01_dir="${1:-}"
output_dir="${2:-}"
proc_root="${PROC_ROOT:-/proc}"
sys_root="${SYS_ROOT:-/sys}"
boot_root="${BOOT_ROOT:-/boot}"
module_root="${MODULE_ROOT:-/lib/modules}"
release="${UNAME_RELEASE:-$(uname -r)}"

if [[ -z "$a01_dir" || -z "$output_dir" ]]; then
  echo "usage: $0 A01_EVIDENCE_DIR OUTPUT_DIR" >&2
  exit 2
fi
if [[ -e "$output_dir" ]] && [[ -n "$(find "$output_dir" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null)" ]]; then
  echo "output directory is not empty: $output_dir" >&2
  exit 2
fi

a01_result=""
if ! a01_result="$($a01_lab/scripts/validate-evidence.sh \
  "$a01_dir" "$a01_lab/expected/required-files.txt" 2>&1)"; then
  echo "A01 validation failed: $a01_result" >&2
  exit 1
fi

mkdir -p "$output_dir"
printf '%s\n' "$a01_result" > "$output_dir/a01-validation.txt"
printf 'resolved_path=%s\nmanifest_sha256=%s\n' \
  "$(cd "$a01_dir" && pwd)" \
  "$(sha256sum "$a01_dir/SHA256SUMS" | awk '{print $1}')" \
  > "$output_dir/a01-reference.txt"

printf '%s\n' "$release" > "$output_dir/kernel-release.txt"
if [[ -r "$proc_root/cmdline" ]]; then
  cat "$proc_root/cmdline" > "$output_dir/kernel-command-line.txt"
else
  printf 'unavailable\n' > "$output_dir/kernel-command-line.txt"
fi

proc_config="${PROC_CONFIG_GZ:-$proc_root/config.gz}"
boot_config="$boot_root/config-$release"
if [[ -n "${CONFIG_OVERRIDE:-}" ]] && [[ ! -r "$CONFIG_OVERRIDE" ]]; then
  echo "config override is not readable: $CONFIG_OVERRIDE" >&2
  exit 1
elif [[ -n "${CONFIG_OVERRIDE:-}" ]]; then
  cat "$CONFIG_OVERRIDE" > "$output_dir/kernel-config.txt"
  printf 'source=operator-override\npath=%s\nfallback=none\n' "$CONFIG_OVERRIDE" \
    > "$output_dir/kernel-config-source.txt"
elif [[ -r "$proc_config" ]]; then
  gzip -dc "$proc_config" > "$output_dir/kernel-config.txt"
  printf 'source=proc-config-gz\npath=%s\nfallback=override-unavailable\n' "$proc_config" \
    > "$output_dir/kernel-config-source.txt"
elif [[ -r "$boot_config" ]]; then
  cat "$boot_config" > "$output_dir/kernel-config.txt"
  printf 'source=boot-config\npath=%s\nfallback=override-and-proc-unavailable\n' "$boot_config" \
    > "$output_dir/kernel-config-source.txt"
else
  echo "kernel config unavailable for release: $release" >&2
  exit 1
fi

if [[ -r "$proc_root/modules" ]]; then
  if [[ -s "$proc_root/modules" ]]; then
    LC_ALL=C sort "$proc_root/modules" > "$output_dir/loaded-modules.txt"
  else
    printf 'none\n' > "$output_dir/loaded-modules.txt"
  fi
else
  printf 'unavailable\n' > "$output_dir/loaded-modules.txt"
fi

module_dir="$module_root/$release"
if [[ -d "$module_dir" ]]; then
  find "$module_dir" -type f -printf '%P\n' | LC_ALL=C sort \
    > "$output_dir/module-tree.txt"
  [[ -s "$output_dir/module-tree.txt" ]] || printf 'none\n' > "$output_dir/module-tree.txt"
else
  printf 'unavailable\n' > "$output_dir/module-tree.txt"
fi

runtime_fdt="$sys_root/firmware/fdt"
if [[ -r "$runtime_fdt" ]]; then
  printf '%s  firmware/fdt\n' "$(sha256sum "$runtime_fdt" | awk '{print $1}')" \
    > "$output_dir/runtime-fdt.sha256"
else
  printf 'unavailable\n' > "$output_dir/runtime-fdt.sha256"
fi

: > "$output_dir/boot-artifacts.sha256"
if [[ -d "$boot_root" ]]; then
  while IFS= read -r file; do
    rel="${file#"$boot_root"/}"
    case "$rel" in
      Image|Image-*|Image.*|vmlinuz*|initrd*|initramfs*|*.dtb|*.dtbo|extlinux/extlinux.conf)
        printf '%s  %s\n' "$(sha256sum "$file" | awk '{print $1}')" "$rel" \
          >> "$output_dir/boot-artifacts.sha256"
        ;;
    esac
  done < <(find "$boot_root" -type f | LC_ALL=C sort)
fi
[[ -s "$output_dir/boot-artifacts.sha256" ]] \
  || printf 'unavailable\n' > "$output_dir/boot-artifacts.sha256"

: > "$output_dir/boot-selection.txt"
extlinux="$boot_root/extlinux/extlinux.conf"
if [[ -r "$extlinux" ]]; then
  awk '/^[[:space:]]*(DEFAULT|LABEL|LINUX|INITRD|FDT)[[:space:]]+/ { print }' "$extlinux" \
    >> "$output_dir/boot-selection.txt"
fi
if [[ -n "${UEFI_BOOT_STATE_FILE:-}" ]] && [[ -s "$UEFI_BOOT_STATE_FILE" ]]; then
  printf '%s\n' '--- UEFI boot state ---' >> "$output_dir/boot-selection.txt"
  cat "$UEFI_BOOT_STATE_FILE" >> "$output_dir/boot-selection.txt"
fi
[[ -s "$output_dir/boot-selection.txt" ]] || printf 'unavailable\n' > "$output_dir/boot-selection.txt"

collect_packages() {
  local override="$1"
  local pattern="$2"
  local destination="$3"
  if [[ -n "$override" ]] && [[ -r "$override" ]]; then
    LC_ALL=C sort -u "$override" > "$destination"
  elif command -v dpkg-query >/dev/null 2>&1; then
    dpkg-query -W -f='${binary:Package}\t${Version}\n' "$pattern" 2>/dev/null \
      | LC_ALL=C sort -u > "$destination" || true
    [[ -s "$destination" ]] || printf 'unavailable\n' > "$destination"
  else
    printf 'unavailable\n' > "$destination"
  fi
}

collect_packages "${DEBIAN_PACKAGES_FILE:-}" '*' "$output_dir/debian-packages.txt"
collect_packages "${NVIDIA_PACKAGES_FILE:-}" 'nvidia-l4t-*' "$output_dir/nvidia-packages.txt"
printf '%s\n' "${COLLECTED_AT:-$(date -u +%Y-%m-%dT%H:%M:%SZ)}" \
  > "$output_dir/collected-at.txt"

(
  cd "$output_dir"
  : > SHA256SUMS
  while IFS= read -r file; do sha256sum "$file" >> SHA256SUMS; done \
    < <(find . -maxdepth 1 -type f ! -name SHA256SUMS -printf '%f\n' | LC_ALL=C sort)
)

echo "software baseline collected: $output_dir"
