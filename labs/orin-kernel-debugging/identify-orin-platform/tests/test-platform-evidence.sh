#!/usr/bin/env bash
set -euo pipefail

test_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
lab_dir="$(cd "$test_dir/.." && pwd)"
collect="$lab_dir/scripts/collect-platform.sh"
validate="$lab_dir/scripts/validate-evidence.sh"
required="$lab_dir/expected/required-files.txt"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local file="$1"
  local pattern="$2"
  local content
  content="$(cat "$file")"
  [[ "$content" == *"$pattern"* ]] || fail "$file does not contain: $pattern"
}

refresh_manifest() {
  local output="$1"
  (
    cd "$output"
    : > SHA256SUMS
    while IFS= read -r file; do
      sha256sum "$file" >> SHA256SUMS
    done < <(find . -maxdepth 1 -type f ! -name SHA256SUMS -printf '%f\n' | sort)
  )
}

make_fixture() {
  local root="$1"
  local model="$2"

  mkdir -p "$root/proc/device-tree" "$root/proc" \
    "$root/sys/devices/soc0" "$root/etc"
  printf '%s\0' "$model" > "$root/proc/device-tree/model"
  printf 'nvidia,p3767-0005\0nvidia,tegra234\0' \
    > "$root/proc/device-tree/compatible"
  printf '1422524000012\0' > "$root/proc/device-tree/serial-number"
  printf 'p3768-0000\0p3767-0005\0' \
    > "$root/proc/device-tree/nvidia,boardids"
  printf 'Revision: A01\n' > "$root/sys/devices/soc0/revision"
  printf 'MemTotal:        7945728 kB\n' > "$root/proc/meminfo"
  printf 'console=ttyTCU0 root=/dev/mmcblk0p1 rw\n' > "$root/proc/cmdline"
  printf '# R39 (release), REVISION: 2.0\n' > "$root/etc/nv_tegra_release"
  printf 'NAME="Ubuntu"\nVERSION="24.04 LTS"\n' > "$root/etc/os-release"
  printf 'nvidia-l4t-core\t39.2.0\n' > "$root/nvidia-packages.txt"
}

run_collect() {
  local fixture="$1"
  local output="$2"
  PROC_ROOT="$fixture/proc" \
  SYS_ROOT="$fixture/sys" \
  ETC_ROOT="$fixture/etc" \
  NVIDIA_PACKAGES_FILE="$fixture/nvidia-packages.txt" \
  UNAME_MACHINE="aarch64" \
  UNAME_RELEASE="6.8.12-tegra" \
  COLLECTED_AT="2026-07-11T12:00:00Z" \
    "$collect" "$output"
}

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

[[ -x "$collect" ]] || fail "missing executable: $collect"
[[ -x "$validate" ]] || fail "missing executable: $validate"

complete_fixture="$tmp_dir/complete-fixture"
complete_output="$tmp_dir/complete-output"
make_fixture "$complete_fixture" "NVIDIA Jetson Orin Nano Engineering Reference Developer Kit Super"
run_collect "$complete_fixture" "$complete_output"
"$validate" "$complete_output" "$required"
assert_contains "$complete_output/model.txt" "Jetson Orin Nano"
assert_contains "$complete_output/memory.txt" "7945728 kB"
assert_contains "$complete_output/soc-revision.txt" "Revision: A01"
assert_contains "$complete_output/carrier-board.txt" "p3767-0005"
(cd "$complete_output" && sha256sum -c SHA256SUMS >/dev/null) \
  || fail "SHA256SUMS validation failed"

missing_fixture="$tmp_dir/missing-optional-fixture"
missing_output="$tmp_dir/missing-optional-output"
make_fixture "$missing_fixture" "NVIDIA Jetson Orin Nano Super Developer Kit"
rm "$missing_fixture/proc/device-tree/nvidia,boardids" \
  "$missing_fixture/sys/devices/soc0/revision" \
  "$missing_fixture/proc/device-tree/serial-number"
printf 'tegra234\n' > "$missing_fixture/sys/devices/soc0/machine"
run_collect "$missing_fixture" "$missing_output"
"$validate" "$missing_output" "$required"
assert_contains "$missing_output/carrier-board.txt" "unavailable"
assert_contains "$missing_output/soc-revision.txt" "unavailable"
assert_contains "$missing_output/device-tree-serial.txt" "unavailable"

nonempty_output="$tmp_dir/nonempty-output"
mkdir -p "$nonempty_output"
printf 'keep\n' > "$nonempty_output/existing.txt"
if run_collect "$complete_fixture" "$nonempty_output" >"$tmp_dir/nonempty.stdout" 2>"$tmp_dir/nonempty.stderr"; then
  fail "non-empty output directory unexpectedly accepted"
fi
assert_contains "$tmp_dir/nonempty.stderr" "output directory is not empty"

tampered_output="$tmp_dir/tampered-output"
cp -R "$complete_output" "$tampered_output"
printf 'tampered\n' >> "$tampered_output/memory.txt"
if "$validate" "$tampered_output" "$required" >"$tmp_dir/tamper.stdout" 2>"$tmp_dir/tamper.stderr"; then
  fail "tampered evidence unexpectedly passed validation"
fi
assert_contains "$tmp_dir/tamper.stderr" "evidence checksum validation failed"

unavailable_output="$tmp_dir/unavailable-required-output"
cp -R "$complete_output" "$unavailable_output"
printf 'unavailable\n' > "$unavailable_output/kernel-command-line.txt"
refresh_manifest "$unavailable_output"
if "$validate" "$unavailable_output" "$required" >"$tmp_dir/unavailable.stdout" 2>"$tmp_dir/unavailable.stderr"; then
  fail "unavailable required evidence unexpectedly passed validation"
fi
assert_contains "$tmp_dir/unavailable.stderr" "required evidence unavailable: kernel-command-line.txt"

non_orin_fixture="$tmp_dir/non-orin-fixture"
non_orin_output="$tmp_dir/non-orin-output"
make_fixture "$non_orin_fixture" "QEMU Virtual Machine"
run_collect "$non_orin_fixture" "$non_orin_output"
if "$validate" "$non_orin_output" "$required" >"$tmp_dir/non-orin.stdout" 2>"$tmp_dir/non-orin.stderr"; then
  fail "non-Orin evidence unexpectedly passed validation"
fi
assert_contains "$tmp_dir/non-orin.stderr" "model is not Jetson Orin Nano"

rm "$complete_output/kernel-release.txt"
if "$validate" "$complete_output" "$required" >"$tmp_dir/missing.stdout" 2>"$tmp_dir/missing.stderr"; then
  fail "missing required file unexpectedly passed validation"
fi
assert_contains "$tmp_dir/missing.stderr" "missing required evidence: kernel-release.txt"

no_newline_contract="$tmp_dir/no-newline-required.txt"
printf 'soc-revision.txt' > "$no_newline_contract"
rm "$missing_output/soc-revision.txt"
if "$validate" "$missing_output" "$no_newline_contract" >"$tmp_dir/no-newline.stdout" 2>"$tmp_dir/no-newline.stderr"; then
  fail "last contract entry without newline was skipped"
fi
assert_contains "$tmp_dir/no-newline.stderr" "missing required evidence: soc-revision.txt"

echo "Platform evidence tests passed"
