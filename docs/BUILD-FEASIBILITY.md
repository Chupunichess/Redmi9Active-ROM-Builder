# Build feasibility: LineageOS 20 for Redmi 9 Active

## Result

The device-specific source set passed validation. The full Android platform build is **not feasible on the currently observed free GitHub-hosted runner**.

## Measurements from GitHub Actions

The runner capacity workflow measured:

| Resource | Observed |
|---|---:|
| CPU | 4 threads |
| RAM | approximately 15 GiB |
| Free root filesystem | 87 GB |
| Root filesystem size | 146 GB |

Run: https://github.com/barath-207/Redmi9Active-ROM-Builder/actions/runs/44678535449

## Official build guidance

Google's current AOSP requirements guide calls for at least 400 GB of free disk space to check out and build source (about 250 GB checkout plus 150 GB build) and at least 64 GB RAM.

Source: https://source.android.com/docs/setup/start/requirements

The selected LineageOS branch is older than the current AOSP baseline, so the exact requirement for this specific branch may be lower. However, the runner still has less than 100 GB free disk and 15 GiB RAM, which is not a sensible environment for a full Android build.

## GitHub-only constraints

- Standard free GitHub-hosted runners are free for public repositories but have limited fixed resources.
- Larger GitHub-hosted runners require GitHub Team or GitHub Enterprise Cloud and are billed.
- Splitting source clones into multiple jobs does not create one larger filesystem for the compiler.
- GitHub Actions artifacts and cache are not substitutes for a persistent multi-hundred-gigabyte source volume.

Larger runners documentation: https://docs.github.com/en/actions/concepts/runners/larger-runners

## What is already validated

The LineageOS 20 source audit successfully cloned and checked:

1. `dandelion64-Archives/android_device_xiaomi_blossom:lineage-20`
2. `dandelion64-Archives/device_xiaomi_blossom-kernel:lineage-20`
3. `dandelion64-Archives/proprietary_vendor_xiaomi_blossom:lineage-20`
4. `dandelion64-Archives/android_hardware_mediatek:lineage-20`
5. `LineageOS/android_device_mediatek_sepolicy_vndr:lineage-20`

It confirmed `cattail` is included in the device tree, MT6765 is declared, the product is `lineage_blossom`, and kernel, DTB, DTBO, vendor blobs and 11 kernel modules are present.

Audit run: https://github.com/barath-207/Redmi9Active-ROM-Builder/actions/runs/44677351453

## Conclusion

A complete flashable ROM cannot honestly be promised while restricted to the current free GitHub runner. The project can still validate device sources and maintain build configuration on GitHub, but producing the ROM requires a larger build environment or using a ROM image compiled elsewhere. No unverified artifact should be published as a flashable ROM.
