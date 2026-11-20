# Redmi 9 Active ROM Builder

Automated investigation and build orchestration for the Xiaomi Redmi 9 Active (`cattail`, MT6765).

## Current status

This repository starts with a **source and dependency validation stage**. It does not claim to produce a flashable ROM yet.

The candidate device tree is [crDroid's unified blossom tree](https://github.com/crdroidandroid/android_device_xiaomi_blossom/tree/17.0). Its README lists Redmi 9 Active under `cattail`, but explicitly warns that the tree is incomplete and bugs are expected. Its BoardConfig also uses prebuilt kernel, DTB and DTBO images. We must validate the matching kernel and vendor repositories before attempting any ROM build.

## GitHub Actions plan

1. Inspect the candidate device tree and confirm `cattail`.
2. Audit the device tree's kernel/vendor references and build prerequisites.
3. Test available runner resources and disk limits.
4. Only then decide whether a complete build can fit on a free GitHub-hosted runner.

## Important build limitation

The standard GitHub-hosted runner has finite disk, memory and execution time. Android source checkouts and builds commonly exceed those limits. This project therefore does **not** promise a successful full ROM compile on free runners. It will first gather evidence and fail safely rather than upload an invalid ZIP.

## Device

- Marketing name: Redmi 9 Active
- Device family/codename in candidate tree: `cattail`
- Platform: MediaTek MT6765
- Candidate device tree: `crdroidandroid/android_device_xiaomi_blossom`, branch `17.0`

## Build status

See the latest [Actions run](../../actions).
