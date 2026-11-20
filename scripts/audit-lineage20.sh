#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "${ROOT_DIR}/config/target.env"

WORK_DIR="${1:-${RUNNER_TEMP:-/tmp}/blossom-lineage20-audit}"
rm -rf "${WORK_DIR}"
mkdir -p "${WORK_DIR}"

log() { printf '[audit] %s\n' "$*"; }
die() { printf '[error] %s\n' "$*" >&2; exit 1; }

clone_source() {
    local repo="$1"
    local branch="$2"
    local destination="$3"
    local url="https://github.com/${repo}.git"

    log "Cloning ${repo} @ ${branch}"
    git clone --quiet --depth=1 --single-branch --branch "${branch}" "${url}" "${destination}"         || die "Could not clone ${repo} branch ${branch}"
    git -C "${destination}" rev-parse HEAD
}

log "Selected target: ${ROM_NAME} ${ROM_BRANCH} (Android ${ANDROID_VERSION})"
log "Product: ${PRODUCT_NAME}; hardware alias: ${DEVICE_VARIANT}"
log "Runner disk before source checkout:"
df -h /

clone_source "dandelion64-Archives/android_device_xiaomi_blossom" "${DEVICE_SOURCE_BRANCH}" "${WORK_DIR}/device"
clone_source "dandelion64-Archives/device_xiaomi_blossom-kernel" "${DEVICE_SOURCE_BRANCH}" "${WORK_DIR}/kernel"
clone_source "dandelion64-Archives/proprietary_vendor_xiaomi_blossom" "${DEVICE_SOURCE_BRANCH}" "${WORK_DIR}/vendor"
clone_source "dandelion64-Archives/android_hardware_mediatek" "${DEVICE_SOURCE_BRANCH}" "${WORK_DIR}/mediatek-hardware"
clone_source "LineageOS/android_device_mediatek_sepolicy_vndr" "${DEVICE_SOURCE_BRANCH}" "${WORK_DIR}/mediatek-sepolicy"

DEVICE="${WORK_DIR}/device"
KERNEL="${WORK_DIR}/kernel"
VENDOR="${WORK_DIR}/vendor"
HARDWARE="${WORK_DIR}/mediatek-hardware"
SEPOLICY="${WORK_DIR}/mediatek-sepolicy"

log "Validating device tree and product configuration"
for file in README.md BoardConfig.mk device.mk AndroidProducts.mk lineage_blossom.mk lineage.dependencies manifest.xml; do
    [[ -s "${DEVICE}/${file}" ]] || die "Missing device source file: ${file}"
done

grep -qi "Redmi 9 Active" "${DEVICE}/README.md" || die "README does not identify Redmi 9 Active"
grep -qi "cattail" "${DEVICE}/README.md" || die "README does not list cattail"
grep -Eq 'TARGET_OTA_ASSERT_DEVICE[[:space:]]*:=.*cattail' "${DEVICE}/BoardConfig.mk" || die "cattail is absent from OTA device assertions"
grep -q 'TARGET_BOARD_PLATFORM := mt6765' "${DEVICE}/BoardConfig.mk" || die "Expected MT6765 platform declaration is missing"
grep -q 'TARGET_FORCE_PREBUILT_KERNEL := true' "${DEVICE}/BoardConfig.mk" || die "Expected prebuilt kernel configuration is missing"
grep -q 'PRODUCT_NAME := lineage_blossom' "${DEVICE}/lineage_blossom.mk" || die "Unexpected product name"
grep -q 'lineage_blossom-userdebug' "${DEVICE}/AndroidProducts.mk" || die "Expected lunch target is missing"

log "Validating declared lineage.dependencies"
python3 - "${DEVICE}/lineage.dependencies" <<'PY'
import json
import sys

path = sys.argv[1]
with open(path, encoding="utf-8") as stream:
    dependencies = json.load(stream)

expected = {
    ("android_device_mediatek_sepolicy_vndr", "device/mediatek/sepolicy_vndr"),
    ("android_hardware_mediatek", "hardware/mediatek"),
    ("device_xiaomi_blossom-kernel", "device/xiaomi/blossom-kernel"),
}
actual = {
    (entry["repository"].split("/")[-1], entry["target_path"])
    for entry in dependencies
}
missing = expected - actual
if missing:
    raise SystemExit(f"Missing expected dependency declarations: {sorted(missing)}")
print("lineage.dependencies matches all three device-specific dependency paths.")
PY

log "Validating prebuilt kernel, DTB, DTBO and loadable modules"
for file in kernel dtb.img dtbo.img; do
    [[ -s "${KERNEL}/${file}" ]] || die "Missing kernel prebuilt: ${file}"
done
[[ -d "${KERNEL}/modules" ]] || die "Kernel modules directory is missing"
MODULE_COUNT="$(find "${KERNEL}/modules" -type f -name '*.ko' | wc -l)"
(( MODULE_COUNT > 0 )) || die "No kernel modules were found"
log "Found ${MODULE_COUNT} kernel modules"

log "Validating vendor blobs"
for file in BoardConfigVendor.mk blossom-vendor.mk Android.bp; do
    [[ -s "${VENDOR}/${file}" ]] || die "Missing vendor file: ${file}"
done
[[ -s "${VENDOR}/proprietary/vendor/firmware/chipone-tddi-tianma.bin" ]]     || die "Expected vendor firmware blob is missing"

log "Validating MediaTek build dependencies"
[[ -s "${HARDWARE}/Android.bp" ]] || die "MediaTek hardware Android.bp is missing"
[[ -s "${SEPOLICY}/SEPolicy.mk" ]] || die "MediaTek vendor sepolicy makefile is missing"

log "Checking source maintenance status"
if grep -qi 'discontinued' "${DEVICE}/README.md"; then
    log "WARNING: upstream device tree is marked discontinued."
fi
if grep -qi 'bugs are expected' "${DEVICE}/README.md"; then
    log "WARNING: upstream README explicitly warns that the device tree may be incomplete."
fi

log "Runner disk after source checkout:"
df -h /

log "PASS: all selected LineageOS 20 device-specific source repositories are present."
log "This audit does not compile Android or prove that a flashable ROM can be produced."
