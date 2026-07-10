#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
checker="$script_dir/check-orin-env.sh"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

printf 'NVIDIA Jetson Orin Nano Engineering Reference Developer Kit Super\0' > "$tmp_dir/model"
printf '# R39 (release), REVISION: 2.0\n' > "$tmp_dir/nv_tegra_release"
mkdir -p "$tmp_dir/tracefs" "$tmp_dir/headers"
printf 'CONFIG_KALLSYMS=y\n' > "$tmp_dir/config"

run_checker() {
  ORIN_MODEL_FILE="$tmp_dir/model" \
  ORIN_RELEASE_FILE="$tmp_dir/nv_tegra_release" \
  ORIN_ARCH="${ORIN_ARCH_OVERRIDE:-aarch64}" \
  ORIN_KERNEL_RELEASE="${ORIN_KERNEL_OVERRIDE:-6.8.12-tegra}" \
  ORIN_L4T_VERSION="${ORIN_L4T_OVERRIDE:-39.2.0-20260602123456}" \
  ORIN_TRACEFS="$tmp_dir/tracefs" \
  ORIN_HEADERS="$tmp_dir/headers" \
  ORIN_CONFIG_FILE="$tmp_dir/config" \
  bash "$checker" "$@"
}

run_checker --require-tracefs --require-headers > "$tmp_dir/pass.log" 2> "$tmp_dir/pass.err"
grep -q 'JetPack 7.2 / Jetson Linux 39.2 environment verified' "$tmp_dir/pass.log"
test ! -s "$tmp_dir/pass.err"

if ORIN_ARCH_OVERRIDE=x86_64 run_checker > "$tmp_dir/arch.log" 2>&1; then
  echo 'x86_64 mismatch unexpectedly passed' >&2
  exit 1
fi
grep -q 'expected aarch64' "$tmp_dir/arch.log"

if ORIN_L4T_OVERRIDE=36.4.4 run_checker > "$tmp_dir/release.log" 2>&1; then
  echo 'Jetson Linux 36.4 mismatch unexpectedly passed' >&2
  exit 1
fi
grep -q 'expected Jetson Linux 39.2' "$tmp_dir/release.log"

if ORIN_KERNEL_OVERRIDE=5.15.148-tegra run_checker > "$tmp_dir/kernel.log" 2>&1; then
  echo 'kernel 5.15 mismatch unexpectedly passed' >&2
  exit 1
fi
grep -q 'expected kernel 6.8' "$tmp_dir/kernel.log"

echo 'Orin environment checker tests passed'
