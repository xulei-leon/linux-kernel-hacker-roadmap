#!/usr/bin/env bash
set -euo pipefail

expected_model='Jetson Orin Nano'
expected_arch='aarch64'
expected_l4t='39.2'
expected_kernel='6.8'

require_tracefs=0
require_headers=0
required_tools=()

usage() {
  echo "usage: $0 [--require-tracefs] [--require-headers] [--require-tool NAME]" >&2
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --require-tracefs)
      require_tracefs=1
      shift
      ;;
    --require-headers)
      require_headers=1
      shift
      ;;
    --require-tool)
      [[ $# -ge 2 ]] || { usage; exit 2; }
      required_tools+=("$2")
      shift 2
      ;;
    *)
      usage
      echo "unknown option: $1" >&2
      exit 2
      ;;
  esac
done

model_file="${ORIN_MODEL_FILE:-/proc/device-tree/model}"
release_file="${ORIN_RELEASE_FILE:-/etc/nv_tegra_release}"
arch="${ORIN_ARCH:-$(uname -m)}"
kernel_release="${ORIN_KERNEL_RELEASE:-$(uname -r)}"
tracefs="${ORIN_TRACEFS:-/sys/kernel/tracing}"
headers="${ORIN_HEADERS:-/lib/modules/$kernel_release/build}"
config_file="${ORIN_CONFIG_FILE:-/boot/config-$kernel_release}"

errors=0

fail() {
  echo "ERROR: $*" >&2
  errors=$((errors + 1))
}

warn() {
  echo "WARN: $*" >&2
}

if [[ -r "$model_file" ]]; then
  model="$(tr -d '\0' < "$model_file")"
else
  model=''
  fail "cannot read Jetson model from $model_file"
fi

release_text=''
if [[ -r "$release_file" ]]; then
  release_text="$(cat "$release_file")"
fi

if [[ -n "${ORIN_L4T_VERSION+x}" ]]; then
  l4t_version="$ORIN_L4T_VERSION"
elif command -v dpkg-query >/dev/null 2>&1; then
  l4t_version="$(dpkg-query -W -f='${Version}' nvidia-l4t-core 2>/dev/null || true)"
else
  l4t_version=''
fi

printf 'model=%s\narch=%s\nkernel=%s\nl4t=%s\n' \
  "${model:-unknown}" "$arch" "$kernel_release" "${l4t_version:-unknown}"

[[ "$model" == *"$expected_model"* ]] ||
  fail "expected a Jetson Orin Nano model"
[[ "$arch" == "$expected_arch" ]] ||
  fail "expected aarch64, observed $arch"
[[ "$kernel_release" == "$expected_kernel"* ]] ||
  fail "expected kernel 6.8, observed $kernel_release"

if [[ -n "$l4t_version" ]]; then
  [[ "$l4t_version" == *"$expected_l4t"* ]] ||
    fail "expected Jetson Linux 39.2"
elif ! { [[ "$release_text" == *'R39'* ]] &&
         [[ "$release_text" =~ REVISION:[[:space:]]*2([.]0)? ]]; }; then
  fail "expected Jetson Linux 39.2"
fi

if (( require_tracefs )); then
  [[ -d "$tracefs" ]] || fail "required tracefs is missing: $tracefs"
elif [[ ! -d "$tracefs" ]]; then
  warn "tracefs is not mounted at $tracefs"
fi

if (( require_headers )); then
  [[ -d "$headers" ]] || fail "matching kernel build directory is missing: $headers"
elif [[ ! -d "$headers" ]]; then
  warn "matching kernel build directory is missing: $headers"
fi

for tool in "${required_tools[@]}"; do
  command -v "$tool" >/dev/null 2>&1 || fail "required tool is missing: $tool"
done

if [[ ! -r /proc/config.gz && ! -r "$config_file" ]]; then
  warn "running kernel configuration is not exposed through procfs or /boot"
fi

(( errors == 0 )) || exit 1
echo 'JetPack 7.2 / Jetson Linux 39.2 environment verified'
