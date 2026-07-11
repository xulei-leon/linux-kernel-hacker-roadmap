#!/usr/bin/env bash
set -euo pipefail

test_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
lab_dir="$(cd "$test_dir/.." && pwd)"
repo_root="$(cd "$lab_dir/../../.." && pwd)"
collect="$lab_dir/scripts/collect-software-baseline.sh"
validate="$lab_dir/scripts/validate-software-baseline.sh"
required="$lab_dir/expected/required-files.txt"
a01_lab="$repo_root/labs/orin-kernel/a01-identify-exact-orin-platform"

fail() { echo "FAIL: $*" >&2; exit 1; }
assert_contains() { local c; c="$(cat "$1")"; [[ "$c" == *"$2"* ]] || fail "$1 lacks: $2"; }
assert_not_contains() { local c; c="$(cat "$1")"; [[ "$c" != *"$2"* ]] || fail "$1 unexpectedly contains: $2"; }
refresh_manifest() {
  local dir="$1"
  (cd "$dir"; : > SHA256SUMS; while IFS= read -r f; do sha256sum "$f" >> SHA256SUMS; done \
    < <(find . -maxdepth 1 -type f ! -name SHA256SUMS -printf '%f\n' | sort))
}

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

[[ -x "$collect" ]] || fail "missing executable: $collect"
[[ -x "$validate" ]] || fail "missing executable: $validate"

mkdir -p "$tmp/a01-root/proc/device-tree" "$tmp/a01-root/proc" \
  "$tmp/a01-root/sys/devices/soc0" "$tmp/a01-root/etc"
printf 'NVIDIA Jetson Orin Nano Super Developer Kit\0' > "$tmp/a01-root/proc/device-tree/model"
printf 'nvidia,p3767-0005\0nvidia,tegra234\0' > "$tmp/a01-root/proc/device-tree/compatible"
printf 'p3768-0000\0p3767-0005\0' > "$tmp/a01-root/proc/device-tree/nvidia,boardids"
printf 'serial-1\0' > "$tmp/a01-root/proc/device-tree/serial-number"
printf 'A01\n' > "$tmp/a01-root/sys/devices/soc0/revision"
printf 'MemTotal: 7945728 kB\n' > "$tmp/a01-root/proc/meminfo"
printf 'console=ttyTCU0 root=/dev/mmcblk0p1 rw\n' > "$tmp/a01-root/proc/cmdline"
printf '# R39 (release), REVISION: 2.0\n' > "$tmp/a01-root/etc/nv_tegra_release"
printf 'NAME="Ubuntu"\nVERSION="24.04 LTS"\n' > "$tmp/a01-root/etc/os-release"
printf 'nvidia-l4t-core\t39.2.0\n' > "$tmp/a01-packages.txt"
PROC_ROOT="$tmp/a01-root/proc" SYS_ROOT="$tmp/a01-root/sys" ETC_ROOT="$tmp/a01-root/etc" \
NVIDIA_PACKAGES_FILE="$tmp/a01-packages.txt" UNAME_MACHINE=aarch64 \
UNAME_RELEASE=6.8.12-tegra COLLECTED_AT=2026-07-12T00:00:00Z \
  "$a01_lab/scripts/collect-platform.sh" "$tmp/a01"
"$a01_lab/scripts/validate-evidence.sh" "$tmp/a01" "$a01_lab/expected/required-files.txt" >/dev/null

mkdir -p "$tmp/root/proc" "$tmp/root/sys/firmware" "$tmp/root/etc" \
  "$tmp/boot/extlinux" "$tmp/boot/dtb" "$tmp/modules/6.8.12-tegra/kernel/drivers/demo"
printf 'console=ttyTCU0 root=/dev/mmcblk0p1 rw\n' > "$tmp/root/proc/cmdline"
printf 'demo 16384 0 - Live 0x0\n' > "$tmp/root/proc/modules"
printf 'runtime-fdt-v1\0' > "$tmp/root/sys/firmware/fdt"
printf 'CONFIG_BASE=y\n' > "$tmp/boot/config-6.8.12-tegra"
printf 'kernel-image-v1\n' > "$tmp/boot/Image"
printf 'compressed-kernel-v1\n' > "$tmp/boot/Image.gz"
printf 'initramfs-v1\n' > "$tmp/boot/initrd.img-6.8.12-tegra"
printf 'dtb-v1\n' > "$tmp/boot/dtb/board.dtb"
printf 'DEFAULT primary\nLABEL primary\n  LINUX /boot/Image\n  INITRD /boot/initrd.img-6.8.12-tegra\n  FDT /boot/dtb/board.dtb\n' > "$tmp/boot/extlinux/extlinux.conf"
printf 'module-a\n' > "$tmp/modules/6.8.12-tegra/kernel/drivers/demo/a.ko"
printf 'zlib1g\t1.3\nbash\t5.2\n' > "$tmp/debian-packages.txt"
printf 'nvidia-l4t-kernel\t39.2.0\nnvidia-l4t-core\t39.2.0\n' > "$tmp/nvidia-packages.txt"
printf 'BootCurrent: 0001\nBoot0001* primary\n' > "$tmp/uefi.txt"
printf 'CONFIG_OVERRIDE=y\n' > "$tmp/override.config"
printf 'CONFIG_PROC=y\n' | gzip -c > "$tmp/proc-config.gz"

run_collect() {
  local output="$1"
  shift
  env PROC_ROOT="$tmp/root/proc" SYS_ROOT="$tmp/root/sys" ETC_ROOT="$tmp/root/etc" \
    BOOT_ROOT="$tmp/boot" MODULE_ROOT="$tmp/modules" \
    DEBIAN_PACKAGES_FILE="$tmp/debian-packages.txt" \
    NVIDIA_PACKAGES_FILE="$tmp/nvidia-packages.txt" UEFI_BOOT_STATE_FILE="$tmp/uefi.txt" \
    UNAME_RELEASE=6.8.12-tegra COLLECTED_AT=2026-07-12T01:00:00Z \
    "$@" "$collect" "$tmp/a01" "$output"
}

run_collect "$tmp/out-override" CONFIG_OVERRIDE="$tmp/override.config"
"$validate" "$tmp/out-override" "$required"
assert_contains "$tmp/out-override/kernel-config.txt" 'CONFIG_OVERRIDE=y'
assert_contains "$tmp/out-override/kernel-config-source.txt" 'operator-override'
assert_contains "$tmp/out-override/a01-validation.txt" 'evidence validated'
assert_contains "$tmp/out-override/module-tree.txt" 'kernel/drivers/demo/a.ko'
assert_contains "$tmp/out-override/boot-selection.txt" 'DEFAULT primary'
assert_contains "$tmp/out-override/boot-selection.txt" 'LINUX /boot/Image'
assert_contains "$tmp/out-override/boot-selection.txt" 'FDT /boot/dtb/board.dtb'
assert_contains "$tmp/out-override/boot-artifacts.sha256" 'Image.gz'

run_collect "$tmp/out-proc" PROC_CONFIG_GZ="$tmp/proc-config.gz"
assert_contains "$tmp/out-proc/kernel-config.txt" 'CONFIG_PROC=y'
assert_contains "$tmp/out-proc/kernel-config-source.txt" 'proc-config-gz'

run_collect "$tmp/out-boot"
assert_contains "$tmp/out-boot/kernel-config.txt" 'CONFIG_BASE=y'
assert_contains "$tmp/out-boot/kernel-config-source.txt" 'boot-config'

run_collect "$tmp/out-repeat" CONFIG_OVERRIDE="$tmp/override.config"
for file in $(cat "$required"); do
  cmp "$tmp/out-override/$file" "$tmp/out-repeat/$file" || fail "nondeterministic: $file"
done
cmp "$tmp/out-override/SHA256SUMS" "$tmp/out-repeat/SHA256SUMS" || fail 'nondeterministic SHA256SUMS'

printf 'runtime-fdt-v2\0' > "$tmp/root/sys/firmware/fdt"
printf 'bash\t5.3\nzlib1g\t1.3\n' > "$tmp/debian-packages.txt"
printf 'kernel-image-v2\n' > "$tmp/boot/Image"
run_collect "$tmp/out-changed" CONFIG_OVERRIDE="$tmp/override.config"
cmp -s "$tmp/out-override/runtime-fdt.sha256" "$tmp/out-changed/runtime-fdt.sha256" \
  && fail 'FDT mutation did not change runtime fingerprint'
cmp -s "$tmp/out-override/debian-packages.txt" "$tmp/out-changed/debian-packages.txt" \
  && fail 'package mutation did not change package snapshot'
cmp -s "$tmp/out-override/boot-artifacts.sha256" "$tmp/out-changed/boot-artifacts.sha256" \
  && fail 'boot mutation did not change boot fingerprint'
cmp -s "$tmp/out-override/SHA256SUMS" "$tmp/out-changed/SHA256SUMS" \
  && fail 'mutations did not change top-level manifest'
printf 'runtime-fdt-v1\0' > "$tmp/root/sys/firmware/fdt"
printf 'zlib1g\t1.3\nbash\t5.2\n' > "$tmp/debian-packages.txt"
printf 'kernel-image-v1\n' > "$tmp/boot/Image"

empty_modules="$tmp/empty-modules"
mkdir -p "$empty_modules/6.8.12-tegra"
: > "$tmp/root/proc/modules"
run_collect "$tmp/out-none" MODULE_ROOT="$empty_modules" CONFIG_OVERRIDE="$tmp/override.config"
assert_contains "$tmp/out-none/loaded-modules.txt" 'none'
assert_contains "$tmp/out-none/module-tree.txt" 'none'

empty_boot="$tmp/empty-boot"
mkdir -p "$empty_boot"
run_collect "$tmp/out-no-boot" BOOT_ROOT="$empty_boot" CONFIG_OVERRIDE="$tmp/override.config"
assert_contains "$tmp/out-no-boot/boot-artifacts.sha256" 'unavailable'
if "$validate" "$tmp/out-no-boot" "$required" >"$tmp/no-boot.out" 2>"$tmp/no-boot.err"; then
  fail 'baseline without boot artifacts unexpectedly validated'
fi
assert_contains "$tmp/no-boot.err" 'required evidence unavailable: boot-artifacts.sha256'

empty_uefi="$tmp/empty-uefi.txt"; : > "$empty_uefi"
run_collect "$tmp/out-empty-uefi" UEFI_BOOT_STATE_FILE="$empty_uefi" CONFIG_OVERRIDE="$tmp/override.config"
assert_not_contains "$tmp/out-empty-uefi/boot-selection.txt" '--- UEFI boot state ---'

mkdir -p "$tmp/nonempty"; printf 'keep\n' > "$tmp/nonempty/file"
if run_collect "$tmp/nonempty" CONFIG_OVERRIDE="$tmp/override.config" 2>"$tmp/nonempty.err"; then
  fail 'non-empty output accepted'
fi
assert_contains "$tmp/nonempty.err" 'output directory is not empty'

if run_collect "$tmp/out-bad-override" CONFIG_OVERRIDE="$tmp/does-not-exist" 2>"$tmp/bad-override.err"; then
  fail 'explicit unreadable config override unexpectedly fell back'
fi
assert_contains "$tmp/bad-override.err" 'config override is not readable'

cp -R "$tmp/out-override" "$tmp/out-tamper"
printf 'tampered\n' >> "$tmp/out-tamper/kernel-config.txt"
if "$validate" "$tmp/out-tamper" "$required" >"$tmp/tamper.out" 2>"$tmp/tamper.err"; then
  fail 'tampered output accepted'
fi
assert_contains "$tmp/tamper.err" 'checksum validation failed'

mv "$tmp/override.config" "$tmp/override.config.off"
mv "$tmp/boot/config-6.8.12-tegra" "$tmp/boot/config.off"
if run_collect "$tmp/out-no-config" 2>"$tmp/no-config.err"; then fail 'missing config accepted'; fi
assert_contains "$tmp/no-config.err" 'kernel config unavailable'

cp -R "$tmp/a01" "$tmp/a01-non-orin"
printf 'QEMU Virtual Machine\n' > "$tmp/a01-non-orin/model.txt"
refresh_manifest "$tmp/a01-non-orin"
original_a01="$tmp/a01"
tmp_a01_saved="$tmp/a01-saved"
mv "$original_a01" "$tmp_a01_saved"
mv "$tmp/a01-non-orin" "$original_a01"
if run_collect "$tmp/out-non-orin-a01" CONFIG_OVERRIDE="$tmp/override.config.off" 2>"$tmp/non-orin-a01.err"; then
  fail 'non-Orin A01 unexpectedly accepted'
fi
assert_contains "$tmp/non-orin-a01.err" 'A01 validation failed'
rm -rf "$original_a01"; mv "$tmp_a01_saved" "$original_a01"

printf 'corrupt\n' >> "$tmp/a01/model.txt"
if run_collect "$tmp/out-bad-a01" CONFIG_OVERRIDE="$tmp/override.config.off" 2>"$tmp/bad-a01.err"; then
  fail 'corrupt A01 accepted'
fi
assert_contains "$tmp/bad-a01.err" 'A01 validation failed'

echo 'A02 software baseline tests passed'
