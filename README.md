# Redmi 9 Active ROM Builder

Automated source validation and build orchestration for the Xiaomi Redmi 9 Active (`cattail`, MT6765).

## Selected build candidate

**LineageOS 20 (Android 13)** using the unified Xiaomi blossom device tree.

The unified product is named `lineage_blossom`; the device tree's OTA assertions include the Redmi 9 Active variant `cattail`.

We selected this older source set because its device, kernel, vendor, MediaTek hardware and MediaTek SELinux policy repositories all have matching `lineage-20` branches. The kernel repository contains the prebuilt kernel, DTB, DTBO and loadable modules expected by the device tree. The device makefiles do not require the unresolved MiuiCamera package found in the newer crDroid 17.0 candidate.

### Important upstream caveat

The device tree README labels the project discontinued and explicitly warns that the tree may be incomplete and contain bugs. Matching source branches are a good starting point, not proof of a successful build or a bootable ROM. No flashable ZIP has been produced or tested.

## Repository layout

- `config/target.env`: selected ROM, product and device configuration.
- `manifests/lineage-20-blossom.xml`: local manifest for the device-specific source repositories.
- `scripts/audit-lineage20.sh`: reproducible shallow-clone and dependency validation.
- `.github/workflows/device-audit.yml`: runs the source audit on GitHub Actions.

## Run the source audit

Open **Actions → LineageOS 20 source audit → Run workflow**, or push a change to `main`.

The audit clones only the device-specific repositories. It does **not** download the full Android/LineageOS source tree and does **not** compile a ROM.

## GitHub-hosted runner limitation

A complete Android ROM build needs far more disk space and sustained compute than a standard free GitHub-hosted runner reliably provides. This repository therefore validates sources first and does not pretend that a successful dependency audit is a successful ROM build.

The next stage is to measure the actual source/build footprint and determine whether a free GitHub-only build is technically possible. No paid compute or external self-hosted hardware is assumed.

## Device-specific sources

| Component | Repository | Branch |
|---|---|---|
| Device tree | [android_device_xiaomi_blossom](https://github.com/dandelion64-Archives/android_device_xiaomi_blossom) | `lineage-20` |
| Kernel prebuilts | [device_xiaomi_blossom-kernel](https://github.com/dandelion64-Archives/device_xiaomi_blossom-kernel) | `lineage-20` |
| Vendor blobs | [proprietary_vendor_xiaomi_blossom](https://github.com/dandelion64-Archives/proprietary_vendor_xiaomi_blossom) | `lineage-20` |
| MediaTek hardware | [android_hardware_mediatek](https://github.com/dandelion64-Archives/android_hardware_mediatek) | `lineage-20` |
| MediaTek vendor sepolicy | [android_device_mediatek_sepolicy_vndr](https://github.com/LineageOS/android_device_mediatek_sepolicy_vndr) | `lineage-20` |
| ROM manifest | [LineageOS/android](https://github.com/LineageOS/android) | `lineage-20` |

## Safety

A build artifact must not be treated as safe to flash merely because compilation completed. Before installation, it needs device-specific verification, checksums, recovery/boot validation and a tested rollback path.