# Redmi 9 Active ROM Builder

GitHub-based source validation and build feasibility tooling for the Xiaomi Redmi 9 Active (`cattail`), on the unified Xiaomi blossom / MT6765 device family.

## Selected ROM candidate

**LineageOS 20 (Android 13)** with the unified `lineage_blossom` product.

The selected device tree, kernel prebuilts, vendor blobs, MediaTek hardware repository and MediaTek vendor SELinux policy repository all have matching `lineage-20` branches. The device tree includes `cattail` in its OTA device assertions; the kernel repository supplies a prebuilt kernel, DTB, DTBO and modules.

**Upstream warning:** the device tree is archived/discontinued. Its README says the tree may be incomplete and bugs are expected. The source audit proves that declared files and dependencies exist, not that the ROM compiles or boots.

## Current result

- Device-specific source audit: **passed**.
- GitHub Actions workflow registration: **passed**.
- Free-runner capacity check: **blocked for full Android build**.
- Flashable ROM: **not built**.

The successful device audit is [here](https://github.com/barath-207/Redmi9Active-ROM-Builder/actions/runs/44678535498). The free-runner capacity check is [here](https://github.com/barath-207/Redmi9Active-ROM-Builder/actions/runs/44678535449).

The capacity workflow measured 4 CPU threads, about 15 GiB RAM and 87 GB free disk. Google's current AOSP guidance recommends at least 400 GB of free disk and 64 GB RAM for a source checkout and build. This makes a complete Android build impractical on this standard free GitHub runner. See the [AOSP build requirements](https://source.android.com/docs/setup/start/requirements).

GitHub's larger hosted runners are not a free workaround: they require GitHub Team or Enterprise Cloud and are billed. See [GitHub's larger runner documentation](https://docs.github.com/en/actions/concepts/runners/larger-runners).

## Repository layout

- `.github/workflows/device-audit.yml`: verifies the selected device tree and its required files.
- `.github/workflows/rom-build.yml`: measures runner capacity and reports whether a full build is feasible. It deliberately does not start a source sync or compile when resources are insufficient.
- `config/target.env`: selected ROM, Android version and product configuration.
- `manifests/lineage-20-blossom.xml`: local manifest for device-specific repositories.
- `scripts/audit-lineage20.sh`: shallow-clones and validates the five device-specific source repositories.

## Run the checks

Open **Actions** in this repository. Run **LineageOS 20 source audit** to validate device sources, or **LineageOS 20 build capacity check** to measure the available runner. Both workflows can also run automatically on relevant changes.

## Device-specific sources

| Component | Repository | Branch |
|---|---|---|
| Device tree | [android_device_xiaomi_blossom](https://github.com/dandelion64-Archives/android_device_xiaomi_blossom) | `lineage-20` |
| Kernel prebuilts | [device_xiaomi_blossom-kernel](https://github.com/dandelion64-Archives/device_xiaomi_blossom-kernel) | `lineage-20` |
| Vendor blobs | [proprietary_vendor_xiaomi_blossom](https://github.com/dandelion64-Archives/proprietary_vendor_xiaomi_blossom) | `lineage-20` |
| MediaTek hardware | [android_hardware_mediatek](https://github.com/dandelion64-Archives/android_hardware_mediatek) | `lineage-20` |
| MediaTek vendor sepolicy | [android_device_mediatek_sepolicy_vndr](https://github.com/LineageOS/android_device_mediatek_sepolicy_vndr) | `lineage-20` |
| ROM manifest | [LineageOS/android](https://github.com/LineageOS/android) | `lineage-20` |

## Build status and safety

This repository currently does not produce a flashable ZIP. A source checkout or a successful dependency audit must not be mistaken for a completed ROM build. Before any future release is flashed, it needs verification of the target variant, image integrity, recovery/rollback path and actual boot testing.
