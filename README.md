<h1 align="left">
  <br>
  <b>Unofficial Eden Nightly Release</b>
  <br>
</h1>

[![GitHub Release](https://img.shields.io/github/v/release/pflyly/eden-nightly?label=Current%20Release)](https://github.com/pflyly/eden-nightly/releases/latest)
[![GitHub Downloads](https://img.shields.io/github/downloads/pflyly/eden-nightly/total?logo=github&label=GitHub%20Downloads)](https://github.com/pflyly/eden-nightly/releases/latest)
[![CI Build Status](https://github.com//pflyly/eden-nightly/actions/workflows/build-nightly.yml/badge.svg)](https://github.com/pflyly/eden-nightly/releases/latest)

## Release Overview

This repository provides **unofficial nightly releases** of **Eden** for the following platforms:

- **Linux** (`x86_64`, `aarch64`)
- **FreeBSD** (Highly Experimental)
- **Android** — *Cancelled from release for now*
- **Windows** (`x86_64`, `arm64`)
- **MacOS** (`x86_64`, `arm64`)

>[!WARNING]
>**This repository is not affiliated with the official Eden development team. It exists solely to provide an easy way for users to try out the latest features from recent commits.**
>
>**These builds are experimental and may be unstable. Use them at your own risk, and please do not report issues from these builds to the official channels unless confirmed on official releases.**

---------------------------------------------------------------

### 🐧 Linux Builds

The builds for Linux are built with several CPU-specific compliler optimization flags targeting:

- **Steam Deck** — optimized for `znver2` (Zen 2)
- **Modern x86_64 CPUs** — optimized for `x86-64-v3` (via the Common Build)
- **Legacy x86_64 CPUs** — compatible with baseline `x86-64` (via the Legacy Build)
- **AArch64 devices** — compatible with `aarch64` architecture

AppImages built using [**Sharun**](https://github.com/VHSgunzo/sharun) are bundled with **Mesa drivers** to ensure maximum compatibility — similar to Eden’s official releases and may include the latest fixes for certain games (though untested).
>[!WARNING]
Some users have reported issues with this version. Use with caution and report any problems if possible.

A newly added **AppBundle** version, built with [**pelf**](https://github.com/xplshn/pelf), serves as an alternative to AppImage. It's a lightweight format written in Go and intended for broader Linux compatibility.

A **Light version** Appimage is also available, built with **linuxdeploy**. It does **not** include Mesa drivers, resulting in a more lightweight build that relies on the system’s native graphics drivers — similar to many other emulators.

> ⚠️ The `aarch64` build is based on a workaround change and is intended for testing purposes only.
>
> If you encounter any problems, you're welcome to open an issue.

These builds should work on any linux distro.

---------------------------------------------------------------

### FreeBSD Builds
> ⚠️ FreeBSD builds are **not officially supported** at the moment and are provided for **testing purposes only**.
>   
> Functionality may be limited and issues are expected. If you encounter any problems, you're welcome to open an issue.
> 
---------------------------------------------------------------

### 🤖 Android Builds

Eden nightly for Android is available in two versions:

- **Replace** Build
  
Shares the same application ID as the official Eden release. Installing this version will replace the official app on your device. It appears as "**eden**" on the home screen.

- **Coexist** Build
  
Uses a nightly application ID, allowing it to coexist with the official Eden release. It appears as "**eden unofficial**" on the home screen, and "**Eden Unofficial**" on the main screen of eden.

- **Optimised** Build
  
Using com.miHoYo.Yuanshen for application ID to enable device dependent features such as AI frame generation. It appears as "**eden Optimised**" on the home screen.

---------------------------------------------------------------

### 🪟 Windows Builds

> ⚠️ The Windows **ARM64** build is based on **work-in-progress (WIP)** changes and is intended for testing purposes only.
>
> If you encounter any problems, you're welcome to open an issue.

---------------------------------------------------------------

### 🍎 MacOS Builds

> ⚠️ MacOS builds are **not officially supported** at the moment and are provided for **testing purposes only**.
>   
> Functionality may be limited and issues are expected. If you encounter any problems, you're welcome to open an issue.


---------------------------------------------------------------


* [**Latest Nightly Release Here**](https://github.com/pflyly/eden-nightly/releases/latest)


---------------------------------------------------------------
This repo is ported from my [citron-nightly repo](https://github.com/pflyly/Citron-Nightly), which is a fork based on the work of **@Samueru-sama**.

It is possible that this appimage may fail to work with appimagelauncher, I recommend these alternatives instead: 

* [AM](https://github.com/ivan-hc/AM) `am -i eden-nightly` or `appman -i eden-nightly`

* [dbin](https://github.com/xplshn/dbin) `dbin install eden-nightly.appimage`

* [soar](https://github.com/pkgforge/soar) `soar install eden-nightly`

This appimage works without fuse2 as it can use fuse3 instead, it can also work without fuse at all thanks to the [uruntime](https://github.com/VHSgunzo/uruntime)
