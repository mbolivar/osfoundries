+++
title = "Zephyr Newsletter 4 June 2018"
date = "2018-06-04"
tags = ["zephyr"]
categories = ["zephyr-news"]
banner = "img/banners/zephyr.png"
author = "Marti Bolivar"
+++

This is the 4 June 2018 newsletter tracking the latest
[Zephyr](https://www.zephyrproject.org/) development merged into the
[mainline tree on
GitHub](https://github.com/zephyrproject-rtos/zephyr).

<!--more-->

As usual, content is broken down as follows:

- **Highlights**
  - Important changes: ABI/API breaks and some features
  - New features: non-exhaustive descriptions of new features
  - Bug fixes: non-exhaustive list of fixed bugs
- **Individual changes**: a complete list of patches, sorted
  chronologically and categorized into areas, like:
  - Architectures
  - Kernel
  - Drivers
  - etc.

Highlights
==========

This covers what's happened since v1.12 rc1 was tagged, including
v1.12 rc2, which was tagged on 29 May, and changes since then.

Patch flow continues actively since rc1. This newsletter summarizes
the 409 patches in this inclusive range:

- [c182520e](https://github.com/zephyrproject-rtos/zephyr/commit/c182520ee18b8826b8dcdd164de0263914ce12e6) tests: kernel: Add description for test cases
- [b5a3ddf7](https://github.com/zephyrproject-rtos/zephyr/commit/b5a3ddf7d73e42ac9551f66414df82b7779cff2c) tests: ieee802154/crypto: use console harness

Since it's currently the stabilization period prior to the release of
Zephyr v1.12, the emphasis will be on tests, bug fixes, and
documentation, which are officially all that's currently permitted for
merge. (Of course, late-breaking exceptions manage to wiggle through.)

The final release is blocked until there are zero high priority and
less than twenty medium priority bugs.

Zephyr's wiki has links to helpful [filters showing the number of open
bugs](https://github.com/zephyrproject-rtos/zephyr/wiki/Filters) and
other issues of various types. At time of writing, there are two high
priority bugs and 33 medium priority bugs open, so there's still work
to do before v1.12 is fully baked.

Important Changes
-----------------

**Schedule\(r) wrangling:**

The following appeared in the previous newsletter: "In a highly
significant but (hopefully mostly) behind-the-scenes change, the
scheduler was rewritten." Hope springs eternal.

As may have been expected, patches affecting central and notoriously
tricky areas like kernel schedulers inevitably result in bugs which
need shaking out. Most noticeably, boot hangs and increasingly lengthy
context switch times have been observed in a variety of circumstances,
and some significant bug fixes have been flowing in following the
rewrite, notably affecting pre-emption, scheduling of dummy threads,
and SMP scheduling.

**CONFIG_TOOLCHAIN_VARIANT removed:**

This legacy Kconfig option is gone now. Any remaining users must
switch to the ZEPHYR_TOOLCHAIN_VARIANT CMake or environment variable,
as documented in the [Getting
Started](http://docs.zephyrproject.org/getting_started/getting_started.html)
guide.

**Kconfig cleanup:**

In a valiant tree-wide cleanup effort, a number of stale or incorrect
Kconfig symbols were updated and fixed. This affected essentially
every subsystem. Merge conflicts for out-of-tree patches seem likely.

**zephyr_library_ifdef() removed:**

The build system's `zephyr_library_ifdef()` macro was that evil type
which modifies the control flow of the caller. In-tree uses were
replaced with safer alternatives and the macro was removed; any out of
tree users will need updates.

Features
--------

**Architectures:**

Nordic SoCs have their instruction cache enabled. Users who don't want
their code to run faster can disable the new
`CONFIG_NRF_ENABLE_ICACHE`, which is on by default.

Precious, precious MPU regions were freed up on various ARM SoCs by
deleting existing entries for memory-mapped peripheral buses and other
such areas in SoC configuration files. Access privileges for these
areas are now determined by the special "background region", or
default configuration, which allows RWX access for supervisor mode,
and prevents user mode access. This frees up these scarce resources
for use by application developers.

**Boards:**

Support was added for the NUCLEO-L053R8 board, which features an
STM32L053R8 SoC.

**Drivers:**

Some new features were added here, in some cases to enable bug fixes,
and in others as late-breaking exceptions to the freeze.

In order to address issues with entropy gathering, a new
interrupt-safe source of entropy, `entropy_get_entropy_isr()`, was
added to the API in include/entropy.h. An implementation is provided
for nRF devices. This was aided by other initialization order changes
which collectively allow the kernel to safely collect entropy earlier
in its initialization.

Users of the w25qxxdv SPI flash driver have new Kconfig options
allowing them to control chip select pins, which can be enabled and
set using `CONFIG_SPI_FLASH_W25QXXDV_GPIO_SPI_CS`.

A new `status_cb` field was added to `struct netusb_function`, as part
of a change which allows functions to define status callbacks. This
new API was needed to fix some issues causing kernel crashes.

Driver support was added for STM32 low power UARTs (LPUARTs); this can
be enabled with `CONFIG_UART_STM32_LPUART_1`.

**Kernel:**

A new "meta-IRQ" feature was added to control scheduling for a new
type of thread. A meta-IRQ is not a true interrupt, but threads with
meta-IRQ priority will be scheduled before any other threads, even
cooperative ones or those which have the scheduler lock. See the
[Meta-IRQ Priorities](http://docs.zephyrproject.org/kernel/threads/scheduling.html#meta-irq-priorities)
section in the threads documentation for details.

A patch was merged which enables ongoing work producing a requirements
traceability matrix from requirements to test cases in APIs exposed by
the main include/kernel.h. This adds Doxygen comments with requirement
IDs to individual APIs, so it's technically documentation.

A simple deadline scheduling policy was implemented. See
`CONFIG_SCHED_DEADLINE` for details.

**Scripts:**

The Python menuconfig implementation has new features for showing a
symbol's name when 'c' is pressed, along with improvements to
searching, saving, and loading.

Kconfiglib now warns if a string symbol's default value is not quoted.

Bug Fixes
---------

**Arches:**

The majority of the fixes applied to the x86 and ARM architectures.
These cover typos and coding style, scheduling, stack management, IRQ
management, scheduling, and MPU management, as well as SoC
specific fixes mostly targeting STM32 and x86 chips.

Optional mitigation was added for Spectre variant v4 on Intel chips;
see `CONFIG_DISABLE_SSBD` for details.

**Bluetooth:**

It was quiet, but not too quiet.

Beyond the Kconfig cleanup, a small number of fixes were merged,
including a compiler-version specific fix for Mesh and a fix for
non-priority event handling in the core controller code. The Bluetooth
subsystem is one of Zephyr's best tested, and the small size of the
change list in this period reflects this.

**Boards:**

Beyond the tree-wide Kconfig fixes, a general fix was merged for "make
flash" for boards using the "bossac" flashing tool. A variety of
patches were merged fixing board-specific issues and enabling some
missing features. See the Boards list of commits in the Individual
Changes section below to learn if boards you use were affected.

**Continuous Integration:**

An arguable misconfiguration in sanitycheck related to job parallelism
was addressed, resulting in a 24% speed improvement. Other
miscellaneous fixes to sanitycheck were merged as well.

External libraries are no longer tracked in code coverage
measurements, improving the accuracy of the code coverage output for
Zephyr-specific code.

**Device Tree:**

A variety of fixes went in for warnings generated by the new dtc
v1.4.6 compiler which was part of the new Zephyr 0.9.3 SDK, with a
handful of fixes in other areas.

**Documentation:**

The effort preparing the documentation for release is picking up steam.

Missing documentation was added covering system calls and userspace,
kernel and threading APIs, POSIX compatibility, VLANs, network traffic
classification, the sanitycheck script used by CI, and more.

Numerous spelling errors were corrected in a series of commits, each
targeting specific areas.

**Drivers:**

About fifteen percent of the total patches in this period affected
Zephyr's device drivers.

Apart from the Kconfig cleanup, STM32-specific driver fixes featured
prominently, affecting SPI, UART, Ethernet, GPIO, and more. Fixes for
drivers needed by the new intel_s1000_crb board for I2S, DMA, and more
were also merged.

**External:**

The build system integration for OpenAMP and libmetal was fixed to
avoid recursive builds, which the Zephyr build system (maintainer)
abhors. May other developers tempted down that dark way be warned, and
stay along the straight path.

mbedTLS was updated to version 2.9.0 from 2.8.0; this brings
security fixes along with other improvements.

A subtle power-related USB fix was merged, adding a patch to Zephyr's
copy of the STM32L4 HAL.

**Kernel:**

Various fixes were merged apart from the scheduler rodeo. It looks
like the dust is settling on these issues for v1.12, but the opening
of the v1.13 will include additional refactoring of the scheduler to
better consolidate flags associated with non-running threads, so the
list of incoming scheduler changes won't be empty anytime soon.

A race was fixed in the mempool allocator. Some architecture-specific
fixes were made that the meta-IRQ addition exposed. The kernel now
uses the new ISR-safe entropy source during early initialization,
before threads are available, and uses the entropy API directly to
initialize stack canaries.

**Libraries:**

A bug making the `clock_gettime()` implementation non-monotonic when
called with CLOCK_MONOTONIC was fixed.

**Networking:**

Not much was merged; the networking developers are hard at
work with the ongoing rewrite of Zephyr's TLS implementation to use a
new and nonstandard setsockopt()-based API. Since that's feature work,
it will have to wait for v1.13 to be merged.

Fixes went in around the subsystem addressing problems where incorrect
timeouts were set due to use of `MSEC()` or raw numbers instead of
`K_MSEC()`, and other related issues.

A boot hang related to invalid use of a receive queue was fixed.

A security session initialization bug affecting 802.15.4 was fixed.

Most of the other fixes appear to be of the usual variety: a null
pointer dereference, packet management and checksumming issues, edge
cases and error handling, etc.

**Samples:**

Other than the Kconfig cleanup, the samples didn't seem to need too
many changes since rc1, which is good.

The coap_server sample properly handles the case where the client no
longer wishes to receive notifications following an initial observe
operation. The coap_client application also saw general improvements
and fixes.

The OpenAMP sample has improved documentation and comments.

**Scripts:**

Not much happened here.

The elf_helper.py library used by the build system to manipulate
Zephyr binaries got some cleanup and an architecture-specific corner
case fix.

Issues in west preventing "make flash" etc. from working on certain
boards, as well as running as root on Unix, were fixed.

Fixes were made to genrest.py, which generates Zephyr's Kconfig symbol
documentation.

**Storage:**

This subsystem was fairly quiet as well.

As might be expected with new code, a variety of bug fixes went in to
the non-volatile storage (NVS) layer. These are mostly related to
buffer management and padding, and also include a fix related to
device addressing.

A pile of issues in the disk subsystem discovered by Coverity were
fixed with extra NULL pointer checks.

**Testing:**

Test, test, one, two, three, ... eighty commits have gone in to
improving Zephyr's tests. These break down into the following rough
categories:

- tons of test descriptions added as Doxygen comments (see [issue
  #6991](https://github.com/zephyrproject-rtos/zephyr/issues/6991) for
  details on how this is part of a larger strategy)
- other restructuring and refactoring to make #6991 infrastructure work better
- fixes to problems in the sources for the test case themselves
- fixes and improvements related to testing user mode
- Kconfig cleanup
- new tests

As always, details are below.

Individual Changes
==================

Patches by area (409 patches total):

- Arches: 63
- Bluetooth: 6
- Boards: 38
- Build: 9
- Continuous Integration: 8
- Device Tree: 12
- Documentation: 31
- Drivers: 59
- External: 12
- Kernel: 20
- Libraries: 3
- Miscellaneous: 5
- Networking: 15
- Samples: 27
- Scripts: 12
- Storage: 9
- Testing: 80

Arches (63):

- [edf7c4fd](https://github.com/zephyrproject-rtos/zephyr/commit/edf7c4fd08315d72ad71e42fff58911d6cf1946c) arch: arm: kw41z: Set DTS fixup for CONFIG_RTC_0_NAME
- [a21a075c](https://github.com/zephyrproject-rtos/zephyr/commit/a21a075c1d148448208ae66c79bdc90e9b9f08a4) native: ethernet: fix k_sleep() wait time
- [9731a0cc](https://github.com/zephyrproject-rtos/zephyr/commit/9731a0cce982f4d6170428e236b1d4fc19767fe8) arm: syscalls: fix some register issues
- [99f36de0](https://github.com/zephyrproject-rtos/zephyr/commit/99f36de0a1cda61b2d00fedb40a64a1bb443bca1) arm: userspace: fix initial user sp location
- [5b37cd73](https://github.com/zephyrproject-rtos/zephyr/commit/5b37cd7346357346d10a32cc52a86a923288bf1d) arch: arm: swap: Remove old context switch code
- [d4221f9a](https://github.com/zephyrproject-rtos/zephyr/commit/d4221f9a7176d952faf1c638e484ea743598e122) arch: x86: Rename MSR-handling functions to conform to convention
- [7faac6a7](https://github.com/zephyrproject-rtos/zephyr/commit/7faac6a761b416afc4f4d74885d1dd6bc580fb1f) arch: arm: atmel_sam: Add quotes to strings in Kconfig
- [c2742f66](https://github.com/zephyrproject-rtos/zephyr/commit/c2742f66ac884371f0c7583eb8cca0b3fe3e104f) arch: arc: Fix typo in comment
- [6ef2f76b](https://github.com/zephyrproject-rtos/zephyr/commit/6ef2f76b2f400b56142964fb1be941aaedd9dcc9) arch: arm: thread.c: Fix typo in comment
- [e653e478](https://github.com/zephyrproject-rtos/zephyr/commit/e653e47824257c63432ebb54a80a13007d853f35) arch: arm: Fix typo in comment
- [33628f1c](https://github.com/zephyrproject-rtos/zephyr/commit/33628f1c47c35c14fa9f4ea45533d1c80a6743ed) arch: arc: userspace: Fix typo in comment
- [95592770](https://github.com/zephyrproject-rtos/zephyr/commit/955927709428a85f97cfb5ddf106c7ad6d624044) arch: stm32: Remove unsupported MPU options
- [5b20350a](https://github.com/zephyrproject-rtos/zephyr/commit/5b20350a722d289b85cfbaa530bdc7de377141fb) gdb_server: Remove leftover testing and x86 parts
- [8321b6b6](https://github.com/zephyrproject-rtos/zephyr/commit/8321b6b64fca1944b2835c6198d4e4420500427b) arch: arm: nxp: Fixup HAS_MCUX_RTC
- [dc01b990](https://github.com/zephyrproject-rtos/zephyr/commit/dc01b9906864df045fce368c217703b794666f6c) arch: stm32l4: only enable USB OTG on SoCs supporting it
- [509e6964](https://github.com/zephyrproject-rtos/zephyr/commit/509e6964ccd6ace72bc0e62607b5044a89857906) arch: stm32l432: add support for USB controller
- [2bfcb849](https://github.com/zephyrproject-rtos/zephyr/commit/2bfcb8496d1b60a3bb8c8e4c32db5548b90ebfee) arch/arc: UART QMSI's baudrate is not present in Kconfig anymore
- [46a3e8bd](https://github.com/zephyrproject-rtos/zephyr/commit/46a3e8bdf0d2a61fbda634fe8aff48937b281ee0) arch: arm: fix fault status register bitfield masks
- [fb0fba91](https://github.com/zephyrproject-rtos/zephyr/commit/fb0fba91a57be9d9b36885282b136a5f825d8106) arch: x86: Rename CPU_NO_SPECTRE to CPU_NO_SPECTRE_V2
- [ecadd465](https://github.com/zephyrproject-rtos/zephyr/commit/ecadd465a29d86272520389f53f8ab2154c7f363) arch: x86: Allow disabling speculative store bypass
- [d9a227c1](https://github.com/zephyrproject-rtos/zephyr/commit/d9a227c19cb5ecffeeb950033e882fb41cca332b) arm: st_stm32: reduce boot MPU regions
- [6f6acb46](https://github.com/zephyrproject-rtos/zephyr/commit/6f6acb4667753a837e11f0d54d250b1d8821b482) arm_mpu: reduce boot MPU regions for various soc
- [77eb883a](https://github.com/zephyrproject-rtos/zephyr/commit/77eb883ab0fd6ffd33ea6b0cbca383535d0d2f29) arch: arc: fix the bug in exception return for secure mode
- [876a9af9](https://github.com/zephyrproject-rtos/zephyr/commit/876a9af9d5569d3442f8975b489bca1dae68e4b4) arch: arc: fix the bug in register clear for USER_SPACE
- [d2c8a205](https://github.com/zephyrproject-rtos/zephyr/commit/d2c8a205603ca12c45048ea3df19ce2c9e74dd79) arch: arm: document non-returning fatal handlers
- [d54dc42a](https://github.com/zephyrproject-rtos/zephyr/commit/d54dc42af94ecb76a5eb2c97e472db77c3c99bbf) arch: arm: refactor FAULT_DUMP to retrieve the fatal error reason
- [49f0dabf](https://github.com/zephyrproject-rtos/zephyr/commit/49f0dabfcccfa1417ebe704dbaf7d73c938ab69e) arch: arm: refactor default _FaultDump to provide fatal error code
- [24fcba44](https://github.com/zephyrproject-rtos/zephyr/commit/24fcba44d34ff5594306b2c3e318e41dbb4353c2) arch: arm: remove redundant ifdef check
- [8b7c3cff](https://github.com/zephyrproject-rtos/zephyr/commit/8b7c3cffb1c2d3c57ccab2d536bab7219a6ef74e) arch: arm: soc: stm32l0: add LPUART1 pinmux options
- [8cc002e6](https://github.com/zephyrproject-rtos/zephyr/commit/8cc002e657e127ce3853b5b606bafeef7a8fe6d8) soc: stm32f1: add port uart4
- [94a22daf](https://github.com/zephyrproject-rtos/zephyr/commit/94a22daf361a7a0ca2e78000ac4bd3ed86a2fc04) arch: arm: STM32L053X8 support
- [0825d0cd](https://github.com/zephyrproject-rtos/zephyr/commit/0825d0cd19f1774d4a1ab42a3f3dc42dda1913ed) arch: arm: fix undefined variable bug
- [a9fe133d](https://github.com/zephyrproject-rtos/zephyr/commit/a9fe133d07d900ace2f45f65a82176ab4bfca816) arch: arm: fix a typos in Kconfig file
- [edd18c8f](https://github.com/zephyrproject-rtos/zephyr/commit/edd18c8f5aab10f5dd0dc13813911ecb537da33a) arch: x86: Better document that CR0.WP will also be set when CR0.PG is
- [3ac3216d](https://github.com/zephyrproject-rtos/zephyr/commit/3ac3216d8939b363e655e494e0156b6ae2a66cac) soc: defconfig: Consistently quote string defaults
- [d946ed73](https://github.com/zephyrproject-rtos/zephyr/commit/d946ed73280cf716d5c680367c871a1c4067bc4a) soc: defconfig.series: Consistently quote string defaults
- [cc447383](https://github.com/zephyrproject-rtos/zephyr/commit/cc4473831f031c8a0da7731e3236b0e398e876e4) soc: soc_family: Consistently quote string defaults
- [71ce9b52](https://github.com/zephyrproject-rtos/zephyr/commit/71ce9b524ab9baf41096f29c5d261c6aec43354b) arch: arc: snps_emsk: Removed dead code
- [cbac8fca](https://github.com/zephyrproject-rtos/zephyr/commit/cbac8fcadba283608ba5f281be02d12e3c32c885) arch: arm: select CPU_HAS_FPU on STM32L4 family
- [93a46432](https://github.com/zephyrproject-rtos/zephyr/commit/93a464321d7f0679d5d5e52875a248ebef6a25bc) arch: arm: nordic: nrf52: Enable instruction cache
- [699aacad](https://github.com/zephyrproject-rtos/zephyr/commit/699aacad509722f3f979e10e398b350a5ec6dfeb) arch: arm: add_subdirectory shouldn't depend on a hidden kconfig.
- [a9ea1554](https://github.com/zephyrproject-rtos/zephyr/commit/a9ea155425e85d5bbce758624d28f4a0ece71be0) arch: arm: add_subdirectory shouldn't depend on a hidden kconfig.
- [c2d632d6](https://github.com/zephyrproject-rtos/zephyr/commit/c2d632d69def25a13a34fb6d0c5880acf7242ada) arch: arm/arc: Remove usage of zephyr_library_ifdef.
- [f315afd0](https://github.com/zephyrproject-rtos/zephyr/commit/f315afd0a78b286e36945f9bd7d300b7abbd3416) arch: stm32: Fix inclusion of SPI headers
- [3c8ed211](https://github.com/zephyrproject-rtos/zephyr/commit/3c8ed211c2369fdf3e4b2682e0445f5e4ff96d9b) arch: arc: fix the wrong setting of STACK_CHECK for user thread
- [76b1cefd](https://github.com/zephyrproject-rtos/zephyr/commit/76b1cefda9192550ee1963168d101ac0882f5419) arch: arc: fix the bug in STACK_ARRAY defintion.
- [ec7d483b](https://github.com/zephyrproject-rtos/zephyr/commit/ec7d483b5bedc833b6401d9bed31dfd291ae0b64) arch: arm: soc: cc2650: Remove dead code.
- [1fe6c367](https://github.com/zephyrproject-rtos/zephyr/commit/1fe6c3673007336cad2f29d35d0b84529705bd6b) esp32: Add some "logging" voodoo to SMP initialization
- [56c97608](https://github.com/zephyrproject-rtos/zephyr/commit/56c9760834da05465ef45cc9b071eadd1f72f927) arch: arm: use stored value for MMFAR
- [6399cb6b](https://github.com/zephyrproject-rtos/zephyr/commit/6399cb6b27f6db30d27aca6177e202283b28a1ea) arch: arm: force MpuFaultHandler to inspect multiple error conditions
- [45b75dd7](https://github.com/zephyrproject-rtos/zephyr/commit/45b75dd7ffff76e8a9a4b2b32bcb41966065d447) arch: arm: Fix zero interrupt latency priority level
- [7b77a25f](https://github.com/zephyrproject-rtos/zephyr/commit/7b77a25f14fb236e531566e97af71666e49ffdd3) arch: arm: coding and comment style fixes
- [0967f11f](https://github.com/zephyrproject-rtos/zephyr/commit/0967f11f6d0beeb5ae033f951823337cec8bd165) arch: arm: enhance internal function documentation
- [25c211d2](https://github.com/zephyrproject-rtos/zephyr/commit/25c211d25258f3415d17292df6ef595b5c235ecd) arch: arm: implement internal function to disable MPU region
- [7f643677](https://github.com/zephyrproject-rtos/zephyr/commit/7f643677be789687540e8ee8f06c8a3a8b0209f1) arch: arm: add additional sanity checks before MPU config change
- [e76ef30a](https://github.com/zephyrproject-rtos/zephyr/commit/e76ef30aca6b4b03c1a230ac303943fa786f9ebb) arch: arm: mpu: minor comment style fixes
- [ed33f43e](https://github.com/zephyrproject-rtos/zephyr/commit/ed33f43e4856305529ce685844b764ecd3b2d7ac) arch: xtensa: intel_s1000: Reference clock API
- [9f4702b3](https://github.com/zephyrproject-rtos/zephyr/commit/9f4702b3b4c425ae41e9cc97c28d59f6bc6d7666) arch: soc: intel_s1000: set M/N divider ownership
- [997a49ad](https://github.com/zephyrproject-rtos/zephyr/commit/997a49ade95cbc3d78baa805d25deb7946acfa5f) arm: userspace: Do not overwrite r7 during syscall.
- [7a18b083](https://github.com/zephyrproject-rtos/zephyr/commit/7a18b083ebe4712fbb258d09c0f53a71b7f46678) x86: align stack buffer sizes
- [0d56036f](https://github.com/zephyrproject-rtos/zephyr/commit/0d56036f04deaa42f70499e6c5ae29eb46bb02c4) arch/x86: Rename a legacy network Kconfig option
- [b829bc78](https://github.com/zephyrproject-rtos/zephyr/commit/b829bc78c1b365b4d77f5d82a7f99bd50771a430) arch: arc: refactor the arc stack check support
- [b09b6b6e](https://github.com/zephyrproject-rtos/zephyr/commit/b09b6b6ee8584952c07c7d80a93c14864c25a07a) arch: arc: add comments for _load_stack_check_regs

Bluetooth (6):

- [f7a1ffe6](https://github.com/zephyrproject-rtos/zephyr/commit/f7a1ffe614d1822861f3f2a4e6f6400c222c574f) Bluetooth: GATT: Change attribute count from u16_t to size_t
- [8e57097e](https://github.com/zephyrproject-rtos/zephyr/commit/8e57097eac24314a7851b654778e00c791589c94) bluetooth: disable user mode for one test
- [20a2b7a7](https://github.com/zephyrproject-rtos/zephyr/commit/20a2b7a79d7d729291aec0688f41121490be7e57) Bluetooth: Mesh: Fix reference to CONFIG_BT_MESH_FRIEND
- [8d1f67c6](https://github.com/zephyrproject-rtos/zephyr/commit/8d1f67c605995996f2ddeb7a096c86040373e32b) Bluetooth: Remove references to non-existing Kconfig symbols
- [c4b0f1c5](https://github.com/zephyrproject-rtos/zephyr/commit/c4b0f1c5b451bc6a0cc3c2d13950383b45e37469) Bluetooth: Mesh: Fix build error when LPN is not enabled
- [a59f544f](https://github.com/zephyrproject-rtos/zephyr/commit/a59f544fb417bd9469a9c378dc23bb54ff1e395d) bluetooth: controller: Handle non-priority events correctly

Boards (38):

- [b5db62ca](https://github.com/zephyrproject-rtos/zephyr/commit/b5db62ca94a0110718e9fb591a06e616e0ca196b) frdm_kl25z: Remove incorrect references to spi
- [1d1bd60d](https://github.com/zephyrproject-rtos/zephyr/commit/1d1bd60d16c53e45c972031b646553b157fb8f0f) boards: arduino_101: Fix separated-line interrupt Kconfig setting
- [df9e95e5](https://github.com/zephyrproject-rtos/zephyr/commit/df9e95e50024784e795cbee60d2af6886b380ad7) boards: arm: Remove nonexistent Kconfig symbols
- [c1908c3d](https://github.com/zephyrproject-rtos/zephyr/commit/c1908c3d0be1147345c9565d7d892ecdd70b031e) boards: arm: Fixup comment related to CONFIG_USB_DC_STM
- [3689359f](https://github.com/zephyrproject-rtos/zephyr/commit/3689359fec5778062b17ffa1efbcfaa98070b34a) board: frdm_kl25z: Remove undefined Kconfig symbol from defconfig
- [3b83ccdb](https://github.com/zephyrproject-rtos/zephyr/commit/3b83ccdb8cbf8e7c361d9253b2ae33ac1cda2931) boards: stm32_mini_a15: fix PLL source selection
- [9c1a2b51](https://github.com/zephyrproject-rtos/zephyr/commit/9c1a2b515c572685d804d8b4ee6344a009efb571) boards: disco_l475_iot1: Remove used pinmux configuration
- [7213ceb3](https://github.com/zephyrproject-rtos/zephyr/commit/7213ceb378ae4cc71a821f2c9d59d9cb4a5d63d2) boards: cc2650_sensortag: Remove Kconfig FLASH/SRAM address assignments
- [e09484f7](https://github.com/zephyrproject-rtos/zephyr/commit/e09484f793f7b794ec76a73c0bb107783fd28a62) boards: arm: lpcxpresso54114: Remove sample specific defconfig setting
- [a85c5462](https://github.com/zephyrproject-rtos/zephyr/commit/a85c5462034349d1ec1a99395485618082dd37da) boards: x86: minnowboard: Unset CONFIG_X86_NO_SPECTRE_V4 by default
- [65e79fd5](https://github.com/zephyrproject-rtos/zephyr/commit/65e79fd5c2c3b8db14b42815297d5499a574eabd) boards: exp432p401r_launchxl: Remove Flash base address Kconfig setting
- [b028a515](https://github.com/zephyrproject-rtos/zephyr/commit/b028a5154265d9e68948491926383cecef78d353) boards: cc2650_sensortag: Remove TRNG and PINMUX prio Kconfig settings
- [9d2f370d](https://github.com/zephyrproject-rtos/zephyr/commit/9d2f370ddb29c7b00ffbc1945e368d4f402544ad) boards: cc3220sf_launchxl: Make cc3220sf XIP by default
- [e0d02d94](https://github.com/zephyrproject-rtos/zephyr/commit/e0d02d94205ced48a2554f2cabb44a8e0f800d61) boards: cc3220sf_launchxl: Enable standard flash/debug build targets
- [5fe0f7df](https://github.com/zephyrproject-rtos/zephyr/commit/5fe0f7df441a45f57297b87716dac9036af3d945) boards: cc3220sf_launchxl: Update board documentation for flash/debug
- [1d7bd566](https://github.com/zephyrproject-rtos/zephyr/commit/1d7bd5665fefccf8a8283fd1057829641f056cea) boards: cc3220sf_launchxl: Fix documentation links
- [fa153a00](https://github.com/zephyrproject-rtos/zephyr/commit/fa153a000305d6f2e60146b08f20d2aec34de1d9) boards: nucleo_l432kc: fix GPIO definitions
- [2ef42b7a](https://github.com/zephyrproject-rtos/zephyr/commit/2ef42b7abe4305929f038aaaa21e4d93c241964b) boards: arm: add support for NUCLEO-L053R8
- [2568e839](https://github.com/zephyrproject-rtos/zephyr/commit/2568e83905964125bf9962ab1f1a1188170871e5) boards: stm32f3_disco: Add usb_device to supported features
- [a3128e6a](https://github.com/zephyrproject-rtos/zephyr/commit/a3128e6a2c1369435b058f4c2261be00a9322802) boards: defconfig: Consistently quote string defaults
- [41826fdc](https://github.com/zephyrproject-rtos/zephyr/commit/41826fdcbd2ea1c0cf12ca4059967c209b655f7f) boards: arm: cc2650: Remove CONFIG_FLASH from defconfig.
- [53a924b3](https://github.com/zephyrproject-rtos/zephyr/commit/53a924b3904758fe0eb8a58131d29a9761709ad6) boards: arm: cc3220sf: Remove CONFIG_FLASH from defconfig.
- [c2b2add1](https://github.com/zephyrproject-rtos/zephyr/commit/c2b2add1d0a018440ee0f6d3a668e2232fa6e3ee) boards: arm: msp_exp432p401r: Remove CONFIG_FLASH from defconfig.
- [6350de3a](https://github.com/zephyrproject-rtos/zephyr/commit/6350de3ae29a9c563a8441196d2199559e6aea19) boards: arm: Remove CONFIG_{FLASH,SRAM}_BASE_ADDRESS assignments
- [10d54e2b](https://github.com/zephyrproject-rtos/zephyr/commit/10d54e2b22219b4d3d0b413672a0aefda528dcd0) boards: arm: argonkey: Properly set choice default
- [af411f31](https://github.com/zephyrproject-rtos/zephyr/commit/af411f316e8c79678122fffa233f6c25a09d06ae) boards/x86: Fix support for w25qxxdv on arduino_101
- [547128e3](https://github.com/zephyrproject-rtos/zephyr/commit/547128e328cb55c8969dbb0ee983b218e4c28eac) boards: frdm_k64f: add USB comment to documentation
- [55494c3f](https://github.com/zephyrproject-rtos/zephyr/commit/55494c3f0a9c9ea6ddd2ab20940dd2afafd16c71) boards: usb_kw24d512: add USB comment to documentation
- [90e00088](https://github.com/zephyrproject-rtos/zephyr/commit/90e000880af7c82688102a1433359cc2929691e2) boards: intel_s1000: Fix runner invocation
- [cddd9e79](https://github.com/zephyrproject-rtos/zephyr/commit/cddd9e796ea9131943c26d748e50276fd00b8217) boards: intel_s1000: move runner config out of boards/common
- [538db998](https://github.com/zephyrproject-rtos/zephyr/commit/538db99882197b7192b4a9dd3ed23af77e1b3ee2) boards/x86: Removing undefined Kconfig symbol in quark_se_c1000_devboard
- [b2522d44](https://github.com/zephyrproject-rtos/zephyr/commit/b2522d44cbcb8483fb67094e38f566da66bbbef5) mimxrt1050: remove app specific code from soc file
- [3fd25c64](https://github.com/zephyrproject-rtos/zephyr/commit/3fd25c64c779ee06e43bfc7c8fb304cbe01d8e5d) boards: mimxrt1050_evk: add condition to initialize different PLL
- [282d95f6](https://github.com/zephyrproject-rtos/zephyr/commit/282d95f6559a990fa57cf77ccb360b0e8f4e72e5) boards: mimxrt1050_evk: move iomuxc to soc folder
- [5757b448](https://github.com/zephyrproject-rtos/zephyr/commit/5757b4482e89c8f5202452d2aa6e56caff2d3ff0) mimxrt1050: fix dcdc value change process
- [5c6a3991](https://github.com/zephyrproject-rtos/zephyr/commit/5c6a3991b55fccd18f211358502235dd3a9bee55) mimxrt1050: check if D-cache is enabled before enabling it.
- [4a693c3c](https://github.com/zephyrproject-rtos/zephyr/commit/4a693c3c388db6cea3f19e8171c4964dc562e91f) boards: common: bossac: Fix bossac flash script.
- [9611002f](https://github.com/zephyrproject-rtos/zephyr/commit/9611002f7a79fc09af1c402dc4066b8378b440e7) boards/x86: Use right GPIO names for CC2520

Build (9):

- [cde6bef7](https://github.com/zephyrproject-rtos/zephyr/commit/cde6bef77825e8a240b146fd12437bfe0f4c2095) kconfig: Drop support for CONFIG_TOOLCHAIN_VARIANT
- [59b2c743](https://github.com/zephyrproject-rtos/zephyr/commit/59b2c743121ed976bcb6abc42dd9b9bbe2386bd9) cmake: Remove dead logic related to CONFIG_DEBUG_SECTION_MISMATCH
- [411686f0](https://github.com/zephyrproject-rtos/zephyr/commit/411686f02b575083e73641dae3215c395f1f7c8b) build: suppress asserts warning if forced off
- [8364b223](https://github.com/zephyrproject-rtos/zephyr/commit/8364b223e485c331f99c0c55c8064bce80dd857e) Fix struct offsets (DWARF v2 compatibility)
- [5d22834e](https://github.com/zephyrproject-rtos/zephyr/commit/5d22834e9a3f5046ddece9caf1d4121946ba41a4) cmake: extensions: Remove macro zephyr_library_ifdef.
- [5405f688](https://github.com/zephyrproject-rtos/zephyr/commit/5405f6887802803292737b9be65d5da6392ea23a) kconfig: Remove remaining 'option env' bounce symbols
- [ddba3d66](https://github.com/zephyrproject-rtos/zephyr/commit/ddba3d667d82cf9f1ef9aba0295d58a84173056b) kconfig: Define the IRQ priorities for CAVS & DW ICTL
- [f90416c6](https://github.com/zephyrproject-rtos/zephyr/commit/f90416c680d19170baf4eb3a3d716f37bc5b124b) cmake: fix warning message
- [420bfc1f](https://github.com/zephyrproject-rtos/zephyr/commit/420bfc1f2da975637e1d8f0025c9ee0a1e61feff) cmake: toolchain: Don't warn of both ZEPHYR_*_VARIANT envvars defined

Continuous Integration (8):

- [dec163fe](https://github.com/zephyrproject-rtos/zephyr/commit/dec163fe835f69a8bcd965606ca125e1d5966bcd) sanitycheck: Disable parallel builds with Ninja
- [a3a7e8e7](https://github.com/zephyrproject-rtos/zephyr/commit/a3a7e8e781f1c55ad01712ce6604e060510db3c2) sanitycheck: Add support for _bt_settings_area linker section
- [0a9a505e](https://github.com/zephyrproject-rtos/zephyr/commit/0a9a505e7307bd522df5a134f9d67cd5769425b7) sanitycheck: update script arguments
- [1c7ba097](https://github.com/zephyrproject-rtos/zephyr/commit/1c7ba097b50c37a6d0553ccd6476528373ec5557) sanitycheck: document --device-testing feature
- [333a315f](https://github.com/zephyrproject-rtos/zephyr/commit/333a315f7bf38fcdd6c8061c786d8f7af612e203) sanitycheck: improve help message
- [29599f6d](https://github.com/zephyrproject-rtos/zephyr/commit/29599f6d80bb595459f65372d4f620b3a3dd83fa) sanitycheck: deprecate assertion options
- [fac7108e](https://github.com/zephyrproject-rtos/zephyr/commit/fac7108ecc4491e90d866f84260dd6ab74600534) ci: remove ext/ from coverage
- [386b3e6d](https://github.com/zephyrproject-rtos/zephyr/commit/386b3e6d54cb12f6ef2e57c3d268a7fa7eea00bb) ci: increase ccache size

Device Tree (12):

- [6701d449](https://github.com/zephyrproject-rtos/zephyr/commit/6701d449675f082ec331e2bb3bdfcd3532cd4fc2) dts: xtensa: Fix build error due to dts changes for ns16550 driver.
- [22231601](https://github.com/zephyrproject-rtos/zephyr/commit/2223160144da4fd346c7512cb509cefcbed28641) dts/bindings: Make use of RTC base in QMSI bindings
- [76676651](https://github.com/zephyrproject-rtos/zephyr/commit/76676651f48d179705de5febefdfc8883530f805) dts: intel_s1000: Enable generating IRQ priority.
- [2ebb6a1f](https://github.com/zephyrproject-rtos/zephyr/commit/2ebb6a1feee008ff8fd21e16e7039a259d299894) dts: intel_s1000: use dts to set i2c0 priority.
- [22fc6008](https://github.com/zephyrproject-rtos/zephyr/commit/22fc6008ead7708d8c3b0fbb247f8e5afe156dd9) dts/nxp: Fix dtc v1.4.6 warning: Missing property '#clock-cells' in node
- [4e90bd36](https://github.com/zephyrproject-rtos/zephyr/commit/4e90bd36bb2d0a90fab4c0cf9cc588eec915bcad) dts/nxp: Fix dtc v1.4.6 warning: Aliases property name is not valid
- [2d6c48bf](https://github.com/zephyrproject-rtos/zephyr/commit/2d6c48bf168c9a3fb82beb2757b146ff5f358ab5) dts/nxp: Fix dtc v1.4.6 warning: Node has a reg but not unit name
- [9faa26db](https://github.com/zephyrproject-rtos/zephyr/commit/9faa26dbc55cd5b3300ef5cb0badaa6107c5683f) dts/nxp: Fix dtc v1.4.6 warning: Node has a unit name, but no reg prop
- [95fc141a](https://github.com/zephyrproject-rtos/zephyr/commit/95fc141ae55ddbcb65963c2d71cf97f6ef62f10d) dts: x86: Fix wrong interrupt number for I2C
- [922490d3](https://github.com/zephyrproject-rtos/zephyr/commit/922490d3bb4465214363c532dcc6aab5ae007cea) dts/bindings: Remove superfluous property definition
- [5fae3731](https://github.com/zephyrproject-rtos/zephyr/commit/5fae37310704e7ffbb963f7ad3865625677ff26f) dts: nxp: fix typo in usbd bindings
- [05063ede](https://github.com/zephyrproject-rtos/zephyr/commit/05063ede5528dcd72ef002684972850c3e9ac1e2) dts: arc: Fix IRQ priorities for quark_se_c1000_ss

Documentation (31):

- [3fb20eb8](https://github.com/zephyrproject-rtos/zephyr/commit/3fb20eb8ed128ecea693ae48621569af0b234423) doc: updated doc for Zephyr release 1.12.
- [a129f19b](https://github.com/zephyrproject-rtos/zephyr/commit/a129f19beaa12f932386cd2289b044302d8e673e) doc: CODEOWNERS for .rst files
- [dcc9cefe](https://github.com/zephyrproject-rtos/zephyr/commit/dcc9cefe094a838d4c3e811d48deea5df70eae56) doc: i.MX7 updated doc for Zephyr release 1.12
- [81b964b6](https://github.com/zephyrproject-rtos/zephyr/commit/81b964b619674b474acb679ce9c578caeb501504) doc: Update description of BT_RECV_IS_RX_THREAD.
- [8e7a0051](https://github.com/zephyrproject-rtos/zephyr/commit/8e7a00512bd5ed964e96d8e636cb395be1268721) doc: Makefile: Use phony targets and remove unneeded prereqs
- [071b1bd6](https://github.com/zephyrproject-rtos/zephyr/commit/071b1bd6b62ce962e49e7999e2a0ac84271b29a0) doc: fix misspellings in test documentation
- [fcbd8fb6](https://github.com/zephyrproject-rtos/zephyr/commit/fcbd8fb631aa6d9a3843ebca5285f51910cd3782) doc: fix misspellings in API doxygen comments
- [44383a39](https://github.com/zephyrproject-rtos/zephyr/commit/44383a394ba14c47f2716ca3122a19e32a0ddd09) doc: fix misspellings in Kconfig files
- [6c6cf23d](https://github.com/zephyrproject-rtos/zephyr/commit/6c6cf23d4dac2ea0af467644ae18c84b41bea5a5) doc: fix misspellings in docs
- [1fd8b139](https://github.com/zephyrproject-rtos/zephyr/commit/1fd8b139c84492401785e1c21d0f719e2669725f) doc: update syscall docs to new handler APIs
- [9e4f25bb](https://github.com/zephyrproject-rtos/zephyr/commit/9e4f25bbad80b3577f973fcd262133e8087e1005) doxygen: reference requirements
- [a50a388b](https://github.com/zephyrproject-rtos/zephyr/commit/a50a388b2d8e9f9fc9220146caf6c5416f4613ee) doc: build with CONFIG_USERSPACE enabled
- [993f6db7](https://github.com/zephyrproject-rtos/zephyr/commit/993f6db76da6cec550a9d93feee2c5ccc89ec88f) doc: Add networking information to 1.12 release note
- [11c6306f](https://github.com/zephyrproject-rtos/zephyr/commit/11c6306f76c382d351df16d17afdcc5e1d1c15f5) doc: tweak CSS for option table display
- [a7ffc83b](https://github.com/zephyrproject-rtos/zephyr/commit/a7ffc83bcc920b9f14a0161ae6043755893700f6) doc: Create a sensor threat model doc
- [92b9d960](https://github.com/zephyrproject-rtos/zephyr/commit/92b9d9606de32f319513d9989e56e7acf7ba1d58) doxygen: enable more option for docs
- [ce78d16b](https://github.com/zephyrproject-rtos/zephyr/commit/ce78d16b736b3e4b69b284fe6bc7dd4210f9cee6) doc: document kernel APIs with doxygen
- [a541e93d](https://github.com/zephyrproject-rtos/zephyr/commit/a541e93d9afe3ec3a0226c5c25c9fbc8a3a0a878) doc: document thread options
- [47420d04](https://github.com/zephyrproject-rtos/zephyr/commit/47420d04f0bede27c74d9c5cc34aa8670d2b4574) doc: add requirement IDs
- [cf8ee737](https://github.com/zephyrproject-rtos/zephyr/commit/cf8ee7372dd89009aa0e7e8a70ce2d6ec70072e7) doc: updated doc for Zephyr release 1.12.
- [c4bbdc70](https://github.com/zephyrproject-rtos/zephyr/commit/c4bbdc70d173204e9cb399efc8845ba5596a029c) doc: Update doc for posix feature
- [9d8c630b](https://github.com/zephyrproject-rtos/zephyr/commit/9d8c630bcd9788af1dd4701fad605e69e09218af) doc: release notes: Add details to various sections for 1.12 release
- [5d50d136](https://github.com/zephyrproject-rtos/zephyr/commit/5d50d13667dcbbeb9b8596b6cb7b718fbf4c3d81) doc: Update doc for POSIX feature
- [f1eda7b9](https://github.com/zephyrproject-rtos/zephyr/commit/f1eda7b9e03637d772a6824f7fbc039d26c84eb2) doc: updated doc for Zephyr release 1.12.
- [d07d5e87](https://github.com/zephyrproject-rtos/zephyr/commit/d07d5e870080bff95b2deedc9948a71e41d5609d) doc: fix broken table display
- [e5be22fa](https://github.com/zephyrproject-rtos/zephyr/commit/e5be22fab2c78f229015c501a59476a88ad5bfd5) doc: net: Add information about VLANs
- [d58efe77](https://github.com/zephyrproject-rtos/zephyr/commit/d58efe7724236efc72c1022a155db293f3106d40) doc: net: Add information about network traffic classification
- [7760b941](https://github.com/zephyrproject-rtos/zephyr/commit/7760b941f91b22b013d93c1875190f47cfd82c23) doc: fix misspellings in docs
- [972386d7](https://github.com/zephyrproject-rtos/zephyr/commit/972386d7a3882874915225c9ecf3ad701dae0d57) genrest: Highlight Kconfig as Kconfig, not Python
- [d96205f6](https://github.com/zephyrproject-rtos/zephyr/commit/d96205f609d068f22a5d746e01858c78e960e08a) doc: fix early closing of GPIO doxygen defgroup
- [711adb89](https://github.com/zephyrproject-rtos/zephyr/commit/711adb89babb31f2362b98bb55e4649cac7ccc6a) doc: Update release note for 1.12

Drivers (59):

- [30e558f3](https://github.com/zephyrproject-rtos/zephyr/commit/30e558f333dcf75e63764157133847b88acf7cf6) devices: entropy: Initialize drivers during PRE_KERNEL_1 stage
- [fcc56e31](https://github.com/zephyrproject-rtos/zephyr/commit/fcc56e315f1dcc0c25422cb528662fe8dfe0b059) subsys: random: xoroshiro128: Use SYS_INIT hook to initialize properly
- [c9dd05b9](https://github.com/zephyrproject-rtos/zephyr/commit/c9dd05b92d25639284e452a2c33ca6a757613313) drivers: net: loopback: Fix setting of SYS_LOG_LEVEL
- [682455ec](https://github.com/zephyrproject-rtos/zephyr/commit/682455ec89caffda722c582ad048038eceda75be) drivers: crypto_ataes132a: Fix typo in Kconfig symbol
- [08438630](https://github.com/zephyrproject-rtos/zephyr/commit/084386302f2960adde294a9ab898164bf8774cad) drivers: sensor: bmm150: Fix typo in Kconfig symbol
- [4a3f5e5c](https://github.com/zephyrproject-rtos/zephyr/commit/4a3f5e5c7de94a48abb1e02d1beed43c4dc45175) drivers: sensor: pms7003: Rename CONFIG_PMS7003_SERIAL_TIMEOUT
- [5013cca6](https://github.com/zephyrproject-rtos/zephyr/commit/5013cca6764509fd0d2a7efa72317a08eed064e7) usb: rndis: Rename CONFIG_RNDIS_TX_BUF_* and CONFIG_RNDIS_CMD_BUF_*
- [1ea03316](https://github.com/zephyrproject-rtos/zephyr/commit/1ea0331636f25cfc54c31383eaf4ef3aef55960d) drivers: pinmux: Remove dead logic
- [192833a8](https://github.com/zephyrproject-rtos/zephyr/commit/192833a828693bb3577859c0443b9c86d16b3262) drivers: usb_dc_kinetis: fix out-of-bounds write/read
- [134b7484](https://github.com/zephyrproject-rtos/zephyr/commit/134b74844e04ea9e75b832c057de4ca3d0c4191a) drivers: clock_control: remove reference unknown config flag
- [2bd15aa7](https://github.com/zephyrproject-rtos/zephyr/commit/2bd15aa774a6ba8e76bd04f41314aad331d389dc) drivers: clock_control: stm32: Remove unsupported clock configuration
- [80a9b022](https://github.com/zephyrproject-rtos/zephyr/commit/80a9b022008bc84ab33d87c2859cfe31cf576d08) drivers: usb_dc_stm32: enable VDDUSB on STM32L4x2
- [45221a97](https://github.com/zephyrproject-rtos/zephyr/commit/45221a97064d2735a63a9375e56e5d2f863bdb67) serial: nsim: Fix impossible-to-enable CONFIG_UART_NSIM
- [668e31f7](https://github.com/zephyrproject-rtos/zephyr/commit/668e31f7dba2e149693edde068e9eb9fa326643f) drivers: entropy: Introduce ISR-specific entropy function
- [6f534e45](https://github.com/zephyrproject-rtos/zephyr/commit/6f534e45519a07fe49492e53cee7ccae23adf8ac) drivers: entropy: nrf5: Implement standard ISR-specific call
- [8e415727](https://github.com/zephyrproject-rtos/zephyr/commit/8e41572774ec72d623d48b1a69e362b00771ff03) drivers: spi: remove dead references to CONFIG_SPI_QMSI{_SS}
- [23bf9426](https://github.com/zephyrproject-rtos/zephyr/commit/23bf9426ada1ed74eec1ff2c598c931898308862) drivers: serial: uart_fe310: Match Kconfig defines in comment
- [b0e697cc](https://github.com/zephyrproject-rtos/zephyr/commit/b0e697cc4358d72d3846eb6fde99545b914d5442) subsys: usb: Remove undefined CONFIG_USB_DEVICE_HID_BOOTP
- [f245ef2a](https://github.com/zephyrproject-rtos/zephyr/commit/f245ef2aebf29e48910ccee662b15fd9ac778458) drivers: i2s: i2s_cavs: Fix typo in IRQ priority
- [7f4608cc](https://github.com/zephyrproject-rtos/zephyr/commit/7f4608cc61f6aa6b2804f32859246c1b0c4f7cc8) gpio: Fix imx driver edge selection when configuring by port
- [6632ffa6](https://github.com/zephyrproject-rtos/zephyr/commit/6632ffa60f7e0f85b0a624414c7b73cf1905610f) drivers: serial: stm32: remove HAL driver legacy
- [fd26514a](https://github.com/zephyrproject-rtos/zephyr/commit/fd26514a4d40bc54be40bb294bd03b105d674c40) drivers: serial: stm32: rework macros and fixups
- [967c31bc](https://github.com/zephyrproject-rtos/zephyr/commit/967c31bc07fa3844ef25eec09f13df561a7efb9d) drivers: serial: stm32: enable LBD only for UARTs with LIN support
- [1e6d827a](https://github.com/zephyrproject-rtos/zephyr/commit/1e6d827a53372457d3b8f97a4aafb65d38f9d7f2) drivers: serial: stm32: add LPUART support for L0/L4 series
- [bb9fe428](https://github.com/zephyrproject-rtos/zephyr/commit/bb9fe428d8e1791ecc1644ffa01ca48d8000f691) spi: spi_ll_stm32: Fix transceive() ret value in spi_slave case
- [d8fd97ab](https://github.com/zephyrproject-rtos/zephyr/commit/d8fd97abe0ff209d58ca8e568507477d609601ef) drivers/ethernet: stm32: Don't exit driver init on HAL timeout
- [5135a733](https://github.com/zephyrproject-rtos/zephyr/commit/5135a733914bcda5c02a50206027e15e159db725) usb: netusb: Add subsys/usb to include list
- [34977913](https://github.com/zephyrproject-rtos/zephyr/commit/3497791372d9cd368a289db840054daba996ddad) usb: netusb: Use function - defined status callbacks
- [851195bf](https://github.com/zephyrproject-rtos/zephyr/commit/851195bfe3e5d0d9dd67a5d9667305e3fce58982) usb: netusb: Implement status callback for ECM
- [1d5692a7](https://github.com/zephyrproject-rtos/zephyr/commit/1d5692a7b6419bb49d65d19efc96b9202fca3d8e) usb: netusb: Implement status callback for EEM
- [7a6f1c98](https://github.com/zephyrproject-rtos/zephyr/commit/7a6f1c98840f12098753ffdd7c4599ebe41e874a) usb: netusb: Implement status callback for RNDIS
- [fc8bcb9a](https://github.com/zephyrproject-rtos/zephyr/commit/fc8bcb9a1bb4182944f34c3220c8b26541409e8d) usb: netusb: Refactor function's status callbacks
- [8e15353d](https://github.com/zephyrproject-rtos/zephyr/commit/8e15353de532b72e965622217772f8916e6386bd) i2c: i2c_gpio: fix typos in Kconfig file
- [373a0212](https://github.com/zephyrproject-rtos/zephyr/commit/373a02126e1bbc5eee3d6e2549f1046a25d6c1cc) drivers: serial: nrf: Fix interrupts enabling/disabling
- [7fb245f9](https://github.com/zephyrproject-rtos/zephyr/commit/7fb245f9c6f5d87f0df54fc3891e9d5419b7fec6) spi: spi_ll_stm32: fix slave frame shifting
- [a8d93406](https://github.com/zephyrproject-rtos/zephyr/commit/a8d934069e171535f61284917a7efd91d54282f0) eth_stm32_hal: fix dev_data->mac_addr typo
- [cb0dd0cc](https://github.com/zephyrproject-rtos/zephyr/commit/cb0dd0cc93747751884dd13992ffb384dafcf4a1) usb: function_eem: fix eem_read_cb
- [62004146](https://github.com/zephyrproject-rtos/zephyr/commit/62004146e4f48e187bd121a6bf0257a01a23ac0b) drivers: sensors: Remove usage of zephyr_library_ifdef
- [5f5e9fb9](https://github.com/zephyrproject-rtos/zephyr/commit/5f5e9fb96806c0c6aba7206151153c272188a92d) drivers: flash: Remove usage of zephyr_library_ifdef
- [963a0bee](https://github.com/zephyrproject-rtos/zephyr/commit/963a0bee8d9cc4e8b9c768e3d1b75917f06f73d5) drivers: serial: Remove usage of zephyr_library_ifdef
- [8c812900](https://github.com/zephyrproject-rtos/zephyr/commit/8c812900e1f259fa144b81e80deeabdd51aaa0ba) drivers: entropy: Remove usage of zephyr_library_ifdef
- [8eb652bf](https://github.com/zephyrproject-rtos/zephyr/commit/8eb652bfd51fbda40e100896220bb0dc51976f9b) drivers: apds9960: Always default on I2C_0
- [a6d83783](https://github.com/zephyrproject-rtos/zephyr/commit/a6d8378377dfba7392f7632bc7acc3438fcefdb4) drivers/flash: A support for SPI gpio-cs logic into w25qxxdv driver
- [002031d8](https://github.com/zephyrproject-rtos/zephyr/commit/002031d87ff89e13678a0bfb9b49b5ae123844a7) drivers/flash: Cleaning up Kconfig
- [33e3ae71](https://github.com/zephyrproject-rtos/zephyr/commit/33e3ae711ef68a13f7e6b8dfa03c0c040153ecdc) drivers/spi: Handle the case when tx buf/len is NULL/>0 in DW driver
- [13e1c3c2](https://github.com/zephyrproject-rtos/zephyr/commit/13e1c3c2f84d0a124d531a0fd747752073722ca8) uart_console: delete char using BS(08H) or DEL(7FH)
- [73009d05](https://github.com/zephyrproject-rtos/zephyr/commit/73009d05ce2c87d26f3920a4dd74fa3dc3adcfb0) usb: cdc_acm: Set bInterfaceProtocol to No Protocol (0)
- [4d0a1912](https://github.com/zephyrproject-rtos/zephyr/commit/4d0a1912a6acbc9455d8a00daa34da35678cfb3e) drivers: usb_dc_kinetis: fix usb_dc_ep_read_continue
- [29b7cdc8](https://github.com/zephyrproject-rtos/zephyr/commit/29b7cdc8de0478aa2e50c5a9213cae678e08f62e) drivers: eth: native_posix: Fix malformed echo response
- [9a7538b9](https://github.com/zephyrproject-rtos/zephyr/commit/9a7538b95d9750ecd7cc714092588f988b384847) drivers: dma_cavs: separate callbacks per channel
- [30dbf3c0](https://github.com/zephyrproject-rtos/zephyr/commit/30dbf3c0e550a8e0cac2a2d72709dfb6fbc9ef07) drivers: eth: mcux: use CONFIG_SYS_LOG_ETHERNET_LEVEL for syslog level
- [f2719501](https://github.com/zephyrproject-rtos/zephyr/commit/f27195017a50b11cab03770855d44e005ea011da) drivers/gpio: stm32 fix gpio device init prio
- [f36edc6c](https://github.com/zephyrproject-rtos/zephyr/commit/f36edc6c29570f5af00c5a1160c493d0435745f5) drivers: i2s: intel_s1000: Fractional bit-clock
- [b97dd472](https://github.com/zephyrproject-rtos/zephyr/commit/b97dd472fbedaa424eb1a94929efce378820cebc) drivers: can: Move bit timing and clock to device tree
- [eefeb2b0](https://github.com/zephyrproject-rtos/zephyr/commit/eefeb2b0503f52ed2e656c4cb6d11a1c808309c3) drivers: watchdog: esp32: Use common Kconfig option to disable at boot
- [158ea970](https://github.com/zephyrproject-rtos/zephyr/commit/158ea970eacf136aae5a95aeccd17838db5d827c) drivers: watchdog: Use common name configuration for all drivers
- [a88a9866](https://github.com/zephyrproject-rtos/zephyr/commit/a88a98665bd375f618811876aec8290fb2d71bb3) drivers/flags: W25QXXDW internal erase logic fix
- [b4d0850d](https://github.com/zephyrproject-rtos/zephyr/commit/b4d0850d5cbb34477e35e3b469481f9de602425d) drivers/rtc: Fix how prescaler is used in QMSI driver
- [c7053643](https://github.com/zephyrproject-rtos/zephyr/commit/c7053643d598f3ea97f8d5a1cc32ae32c5d57b70) spi: spi_ll_stm32: (fix) Clear OVR bit condition

External (12):

- [57637029](https://github.com/zephyrproject-rtos/zephyr/commit/576370295723f117a5bac771035fa6e5b3ec6a8b) ext: simplelink: Fix minor typo in CONFIG_NUM_IRQs
- [bdf2f4ef](https://github.com/zephyrproject-rtos/zephyr/commit/bdf2f4ef31fbbae3c1d8706de8994df04d409076) ext: move libmetal to hal
- [6a2c371f](https://github.com/zephyrproject-rtos/zephyr/commit/6a2c371fe79bb38a63347db17a1f2c309f025de2) ext: libmetal: Update import of libmetal
- [f6fb8b8a](https://github.com/zephyrproject-rtos/zephyr/commit/f6fb8b8aee265b8e70385fc482b743e9f49199c0) ext: libmetal: Change build integration so its not recursive
- [6a86b026](https://github.com/zephyrproject-rtos/zephyr/commit/6a86b02642058401590a1a2c699a7f0db0146258) ext: open-amp: move open-amp down one dir
- [e3e8c83b](https://github.com/zephyrproject-rtos/zephyr/commit/e3e8c83bd9382c5c546d47b7b7e1446fdf46d5ac) ext: open-amp: Update import of open-amp
- [4e8438bc](https://github.com/zephyrproject-rtos/zephyr/commit/4e8438bc0e1f856765f4e556d66685e65607388e) ext: open-amp: Change build integration so its not recursive
- [b66ecc57](https://github.com/zephyrproject-rtos/zephyr/commit/b66ecc57653ae3f293c90a372f063eefbfee772e) ext: hal: stm32cube: fix stm32l4xx VDDUSB supply control
- [e91b5802](https://github.com/zephyrproject-rtos/zephyr/commit/e91b5802088a32b2615d77e109d01c5c07a9a7c9) ext: hal: libmetal: Allow for libmetal source to be external
- [9a89f39b](https://github.com/zephyrproject-rtos/zephyr/commit/9a89f39b494c1d09eb052d7e40d18421b1e25de7) ext: hal: open-amp: Allow for open-amp source to be external
- [1cd6373f](https://github.com/zephyrproject-rtos/zephyr/commit/1cd6373f21b721831c1501e82fbc46e19576fddc) ext: lib: crypto: Update mbedTLS to 2.9.0
- [9550a7b1](https://github.com/zephyrproject-rtos/zephyr/commit/9550a7b17fecccdb021b69838c443d71206af9d2) ext: lib: crypto: Restore config macros removed in mbedTLS 2.9.0

Kernel (20):

- [72c7ded5](https://github.com/zephyrproject-rtos/zephyr/commit/72c7ded5612870c20a3efc3f36a9688ff85a4418) kernel: prepare threads after PRE_KERNEL*
- [1856e220](https://github.com/zephyrproject-rtos/zephyr/commit/1856e2206d1286ede9c8b25a5702f8c40d8bccd6) kernel/sched: Don't preempt cooperative threads
- [7aa25fa5](https://github.com/zephyrproject-rtos/zephyr/commit/7aa25fa5eb2092d5806d3f55936158a6071f38fc) kernel: Add "meta IRQ" thread priorities
- [4a2e50f6](https://github.com/zephyrproject-rtos/zephyr/commit/4a2e50f6b0a76086f7c812597156e748d21825fc) kernel: Earliest-deadline-first scheduling policy
- [4afc6c9f](https://github.com/zephyrproject-rtos/zephyr/commit/4afc6c9ff2f600085970b57375c007413bc2b69c) kernel: remove STACK_ALIGN checks
- [982d5c8f](https://github.com/zephyrproject-rtos/zephyr/commit/982d5c8f5500eaa3914559f6ad0f095d6aa2142b) init: run kernel_arch_init() earlier
- [389c3643](https://github.com/zephyrproject-rtos/zephyr/commit/389c36439acf2369b7ac3a857290c4646ca64447) kernel: init: Use entropy API directly to initialize stack canary
- [177bbbd3](https://github.com/zephyrproject-rtos/zephyr/commit/177bbbd35f6322749c8f8ca04bc7df9b88c760c7) kernel: Fix trivial typo in CONFIG_WAIT_Q_FAST
- [c8e0d0ce](https://github.com/zephyrproject-rtos/zephyr/commit/c8e0d0cebc77a8ea49386db8fdbc73ef8d66e398) kernel: add requirement Ids to implementation
- [538754cb](https://github.com/zephyrproject-rtos/zephyr/commit/538754cb28fd3c8073f504a825c44e16aa50bce0) kernel: handle early entropy issues
- [b5464491](https://github.com/zephyrproject-rtos/zephyr/commit/b54644913d5b2b2cb5983683cc13963a3aa3237b) kernel: Use IS-specific entropy function when available
- [3a0cb2d3](https://github.com/zephyrproject-rtos/zephyr/commit/3a0cb2d35d9499e5f8757bf07260160c448be02e) kernel: Remove legacy preemption checking
- [df55524d](https://github.com/zephyrproject-rtos/zephyr/commit/df55524d6a046bcff3f050e55c1ce017e31550eb) userspace: align _k_object to 4 bytes
- [75398d2c](https://github.com/zephyrproject-rtos/zephyr/commit/75398d2c38d7edab6695d7c5746e1caa8dbd4545) kernel/mempool: Handle transient failure condition
- [eace1df5](https://github.com/zephyrproject-rtos/zephyr/commit/eace1df539c72d22e00841e4f58a9928dd7aa564) kernel/sched: Fix SMP scheduling
- [43553da9](https://github.com/zephyrproject-rtos/zephyr/commit/43553da9b2bb9e537185695899fb5184c3b17ebe) kernel/sched: Fix preemption logic
- [f669a08e](https://github.com/zephyrproject-rtos/zephyr/commit/f669a08eea877d5d2814d2a95fb25ea85c483ab4) kernel: thread: fix _THREAD_DUMMY check in _check_stack_sentinel()
- [e2d77915](https://github.com/zephyrproject-rtos/zephyr/commit/e2d779159f122da8542abde35083ec98f2fcae01) kernel: update stack macro documentation
- [b85ac3e5](https://github.com/zephyrproject-rtos/zephyr/commit/b85ac3e58f736f4f599b8f71b027abab52faf897) kernel: clarify thread->stack_info documentation
- [6c95dafd](https://github.com/zephyrproject-rtos/zephyr/commit/6c95dafd826014e2b07d490ecce9f48ebbc46ce4) kernel: sched: use _is_thread_ready() in should_preempt()

Libraries (3):

- [dd78ab05](https://github.com/zephyrproject-rtos/zephyr/commit/dd78ab0513048eb49b7118e83eaa192e9efc3c67) newlib: Fix typo in Kconfig related to NEWLIB_LIBC_ALIGNED_HEAP_SIZE
- [817e3cd9](https://github.com/zephyrproject-rtos/zephyr/commit/817e3cd9522e39642a2d809442fd269c4712844c) lib: posix: Make sure the name string is NULL terminated
- [03a3c992](https://github.com/zephyrproject-rtos/zephyr/commit/03a3c992b8b7ac6c8cb2823eba0124941e86bfbe) lib: posix: clock: Use k_uptime_get() to compute tv_nsec

Miscellaneous (5):

- [0b708185](https://github.com/zephyrproject-rtos/zephyr/commit/0b7081859da590b2bbb50935682370110b84d727) misc: improve description of BOOTLOADER_SRAM_SIZE
- [c40b9e04](https://github.com/zephyrproject-rtos/zephyr/commit/c40b9e04e846b6381b6c8fc53f18adfd93b4b7b0) codeowner: Fix wildcard issue for arch/arm/soc/st_stm32/
- [d93ecda4](https://github.com/zephyrproject-rtos/zephyr/commit/d93ecda4c590d674e1cccdc65fb3501ae80a2055) release: Move version to 1.12.0-rc2
- [98fcaf29](https://github.com/zephyrproject-rtos/zephyr/commit/98fcaf29ec4f658027e65750a57cc81cc7f1fd3f) release: Update release notes with CAVS ICTL info
- [718a4cd2](https://github.com/zephyrproject-rtos/zephyr/commit/718a4cd24597853c9151ff57978a0b3de05c5329) include/toolchain/gcc.h: Fix static assert detection

Networking (15):

- [4dd5867a](https://github.com/zephyrproject-rtos/zephyr/commit/4dd5867a79b8919c89e1f19544480446af51d6d8) net: conn: Fix is_invalid_packet
- [b1e06f2b](https://github.com/zephyrproject-rtos/zephyr/commit/b1e06f2b3bb4cf113e8463e05c7b5a2957772fd0) net: lwm2m: remove silent fail for bad endpoint data in rd_client
- [6586dba3](https://github.com/zephyrproject-rtos/zephyr/commit/6586dba3341de61ef0e5584e5c1cef1c3cc3b309) net: coap: Fix CoAP observer helper function
- [6180b904](https://github.com/zephyrproject-rtos/zephyr/commit/6180b904af54e51586fb7245eafc07eb1fe111f3) net: Too long timeout was passed to k_sleep
- [5ec569df](https://github.com/zephyrproject-rtos/zephyr/commit/5ec569dfd2cec804f61d882ace0cf966c5fc1e56) net: Fix dependency to offload driver in Kconfig
- [c5cfb462](https://github.com/zephyrproject-rtos/zephyr/commit/c5cfb462f9a4d9f5a03247ab88e80ed155cba885) net: rpl: fix null pointer dereference
- [2facf33f](https://github.com/zephyrproject-rtos/zephyr/commit/2facf33f2852d2e019b5947e091e0acab411036c) net: ieee802154: Remove old cc2520 AUTO_ACK assignments
- [4c58ffb5](https://github.com/zephyrproject-rtos/zephyr/commit/4c58ffb5ab7cfedf84a991cabe6b33eebd9a604c) net: lwm2m: dont release reply for duplicate block transfer
- [8f5929dd](https://github.com/zephyrproject-rtos/zephyr/commit/8f5929ddf01169f6c70f248daa3316a658e7dafa) net: Too long timeout for k_sleep
- [8670e8a1](https://github.com/zephyrproject-rtos/zephyr/commit/8670e8a1f75c9d67263645833e337183a6b993f4) net: Convert MSEC_PER_SEC to K_SECONDS()
- [48ac4a37](https://github.com/zephyrproject-rtos/zephyr/commit/48ac4a372c957279b855b51081023f14964239f1) net: Convert raw timeout values to use K_MSEC() macro
- [201a1b40](https://github.com/zephyrproject-rtos/zephyr/commit/201a1b402a60bc7b8e41daae8f04106f4629ed7b) net/ieee802154: Security session must be initialized with a valid key
- [dcb0ac12](https://github.com/zephyrproject-rtos/zephyr/commit/dcb0ac1256878e21e43b0091b1111b0eba23a3bf) net: tc: dont yield during net_rc tx/rx workq init
- [c84b37b0](https://github.com/zephyrproject-rtos/zephyr/commit/c84b37b086da2f9ee4ebde53bef22c772861a35c) net: icmpv4: fix incorrect IP header checksum
- [9ab9a835](https://github.com/zephyrproject-rtos/zephyr/commit/9ab9a835968203861e6010d66c74cff453093c71) net/ethernet: Fix ethernet net mgmt interface layer code

Samples (27):

- [ac3c6ba9](https://github.com/zephyrproject-rtos/zephyr/commit/ac3c6ba9901050bda7a5fa41a1216048cb871011) samples: net: Fix coap-server sample
- [55680f88](https://github.com/zephyrproject-rtos/zephyr/commit/55680f884a75cd5ef07b5569694e8e93989f9a6d) samples: net: Fix coap-client sample
- [2c305d2c](https://github.com/zephyrproject-rtos/zephyr/commit/2c305d2cc51f2e61b543873227194c76ae3baae7) samples: net: Remove unwanted code from coap-server
- [d5df6472](https://github.com/zephyrproject-rtos/zephyr/commit/d5df64722be44f47c51a2c7b6f44cccec234b0b6) samples: net: rpl_br: Fix coverity issues
- [e0e188d3](https://github.com/zephyrproject-rtos/zephyr/commit/e0e188d3d370344efdac13b3a0d4f7dac209044b) samples: xtensa_asm2: Cleanup stray IS_TEST reference
- [02d9cc17](https://github.com/zephyrproject-rtos/zephyr/commit/02d9cc171c22ec22e35c30fa56068956f7c0c94a) samples: subsys: debug: Remove CONFIG_SEGGER_RTT assignment
- [4a54005e](https://github.com/zephyrproject-rtos/zephyr/commit/4a54005e7bf38431538641cd5ac4da7a31becb46) samples: net: Remove undefined references to CONFIG_NET_LOG_ENABLED
- [e7468fb5](https://github.com/zephyrproject-rtos/zephyr/commit/e7468fb583b224e51611e9210a939b97942b9969) samples: net: Fix VLAN tag name in prj.conf file
- [1a7ae583](https://github.com/zephyrproject-rtos/zephyr/commit/1a7ae583af26295c33e53bfa9108748cbdf068b9) samples: net: mqtt: Remove CONFIG_BT_MAX_CMD_LEN assignment
- [7bb6eb62](https://github.com/zephyrproject-rtos/zephyr/commit/7bb6eb62f26597f801742278ede8b889d0168f90) samples: wifi: remove dead Kconfig symbol
- [91d80445](https://github.com/zephyrproject-rtos/zephyr/commit/91d80445f9ba173d81dbfbbf5559d9a3cf1c0d67) samples: net: zperf: Remove dead Kconfig symbol from galileo conf
- [27f05e39](https://github.com/zephyrproject-rtos/zephyr/commit/27f05e3929e1eba34a09093bb73357f9fe9104b9) samples: board: 96b_argonkey: Remove dead code
- [2dbde4a1](https://github.com/zephyrproject-rtos/zephyr/commit/2dbde4a1fa8c2b161ab4f66923823e95a3e2847d) samples: net: zperf: Remove config files for Galileo board
- [f346c7ae](https://github.com/zephyrproject-rtos/zephyr/commit/f346c7aeaf5cad7088b20cc0f49de908f5f7f45b) samples: grove: Remove CONFIG_GROVE_LCD_RGB_INIT_PRIORITY assignment
- [d154060a](https://github.com/zephyrproject-rtos/zephyr/commit/d154060a64cdb767f09371636b03f38af5888bfa) samples: grove: Fix CONFIG_GROVE_TEMPERATURE_SENSOR_V1_X assignment
- [9a06d119](https://github.com/zephyrproject-rtos/zephyr/commit/9a06d119a88a7ffba7d5fa282a092a917e6e86d2) samples: mcp9808: Fix CONFIG_MCP9808_TRIGGER_GLOBAL_THREAD assignment
- [40777af7](https://github.com/zephyrproject-rtos/zephyr/commit/40777af71e4b713eff025a247cbd0e0cd9e05138) samples: openamp: Cleanup CMakeLists.txt files
- [31c5a83e](https://github.com/zephyrproject-rtos/zephyr/commit/31c5a83e7fd69fdef74826672147857c5558af00) samples: hci_uart: Remove NRF5 Kconfig baud rate setting
- [cbdfdf9e](https://github.com/zephyrproject-rtos/zephyr/commit/cbdfdf9e77614845afa4c0ea8401eadd55f254ff) samples: bmm150: Remove assignment to missing CONFIG_BMM150_SET_ATTR
- [544f8271](https://github.com/zephyrproject-rtos/zephyr/commit/544f827173938c20199fb0a42bc4a92c736824c2) samples: mbedTLS server: Remove CONFIG_NET_SLIP_TAP assignment
- [ee4a4175](https://github.com/zephyrproject-rtos/zephyr/commit/ee4a417586c2e8e2dec51b11398e65d2ee8425aa) samples: echo_server: Remove conflicting option from conf file
- [7d01bf8c](https://github.com/zephyrproject-rtos/zephyr/commit/7d01bf8cb5ca26e914811b3213fa4b07bd072d31) samples: openamp: Update docs
- [b0ffe06f](https://github.com/zephyrproject-rtos/zephyr/commit/b0ffe06f7a2d419f398b5645d1aec27b5cfe867f) samples: openamp: add some comments to the code
- [c5fda143](https://github.com/zephyrproject-rtos/zephyr/commit/c5fda14358e5bb8b39e6337bb77319822983e80d) samples: Quote BOARD value in custom board definition
- [337832d1](https://github.com/zephyrproject-rtos/zephyr/commit/337832d193b3c6e1811ec0e312d086a2cccf9202) samples: hci_uart: Remove CONFIG_UART_NRF5_BAUD_RATE assignment
- [659c241e](https://github.com/zephyrproject-rtos/zephyr/commit/659c241e3a5fca21089e79f3aecd7a55f3be1279) samples: net: big_http_download: Ignore close() return value.
- [61f91f8f](https://github.com/zephyrproject-rtos/zephyr/commit/61f91f8fecbf8ffc67c2b9f8db2989bb07de1831) samples: sensor : mcp9808: check return value

Scripts (12):

- [e0477756](https://github.com/zephyrproject-rtos/zephyr/commit/e047775664eb785bfa2d4c63dd2b0fcf5fc6f605) scripts: west: downgrade missing ZEPHYR_BASE to a warning
- [b45e152f](https://github.com/zephyrproject-rtos/zephyr/commit/b45e152ff00866e1a7d45b2a9072b68f168a64f4) menuconfig/genrest: Exclude implicit submenus from menu paths
- [06ecb287](https://github.com/zephyrproject-rtos/zephyr/commit/06ecb287fcd81db3aaf26a424c8b84feb99e05ea) genrest: Move from doc/scripts/genrest/ to doc/scripts/
- [e144a68f](https://github.com/zephyrproject-rtos/zephyr/commit/e144a68f54e33adbc87c0b2e6d6e29bb19e70dca) elf_helper: fix member offset calculation
- [f20efcfb](https://github.com/zephyrproject-rtos/zephyr/commit/f20efcfbe79737a10f92bd3e2e95ee659dd82366) scripts: generalize kobject -> enum naming
- [d44fee35](https://github.com/zephyrproject-rtos/zephyr/commit/d44fee359df3bb809f81f3e36752fb681a989b42) menuconfig: Add search and save/load improvements from upstream
- [a06b14f2](https://github.com/zephyrproject-rtos/zephyr/commit/a06b14f29b9925435ebed629b952d053fc980fff) scripts: check-compliance: Allow to run from any path
- [58967c7d](https://github.com/zephyrproject-rtos/zephyr/commit/58967c7d3c8adf23992a102a11f6f1f2ee4cc9eb) scripts: extract_dts_includes.py: fix multiple include in bindings
- [6eabea3a](https://github.com/zephyrproject-rtos/zephyr/commit/6eabea3a7e6f1e4417f44dc293cbbbd5d9aca003) Kconfiglib: Warn for unquoted string defaults
- [163dec6d](https://github.com/zephyrproject-rtos/zephyr/commit/163dec6dc3c9fbcd5ce53859214fe374fba36bf1) menuconfig: Add show-name mode + small help dialog improvement
- [1d27ee0b](https://github.com/zephyrproject-rtos/zephyr/commit/1d27ee0b099ca3dbe889da4b99f331dfaf58f763) scripts: extract_dts_includes: fix recursion in extract_controller
- [63f2cf57](https://github.com/zephyrproject-rtos/zephyr/commit/63f2cf579d9e152e9203699f35d8e77ee8849161) scripts: west: update to upstream 894aedbc0

Storage (9):

- [2f074783](https://github.com/zephyrproject-rtos/zephyr/commit/2f074783c47d826dddc4ea9483c4cdb4404a2ded) subsys: disk: Fix NULL pointer checks for disk operations
- [83ac3f8b](https://github.com/zephyrproject-rtos/zephyr/commit/83ac3f8bd5d7dcfa7b53282a901f9f4f5dbcb48f) subsys: fs/nvs: explicitly pad flash writes up to the write block size
- [7acd3399](https://github.com/zephyrproject-rtos/zephyr/commit/7acd339974356d16ba2dbf0ee23c746d9ffe0404) subsys: fs/nvs: never read more than the destination buffer
- [154e6ea7](https://github.com/zephyrproject-rtos/zephyr/commit/154e6ea72f1b20f5132123c8a3a5f3748c58c5d0) subsys: fs/nvs: never write more than the source buffer
- [14aae1a1](https://github.com/zephyrproject-rtos/zephyr/commit/14aae1a1898d84f4ef4b035831e4ae1fc6b75e2b) subsys: fs/nvs: remove explicit padding from structures
- [4795b79e](https://github.com/zephyrproject-rtos/zephyr/commit/4795b79e9ddf57ce2a09572012a702a2634d5d32) subsys: fs/nvs: kill a warning
- [131c4a4f](https://github.com/zephyrproject-rtos/zephyr/commit/131c4a4f745de487cf86c1f8b05145ae186900af) subsys: fs/nvs: do not assume the flash is mapped at address 0
- [4089602f](https://github.com/zephyrproject-rtos/zephyr/commit/4089602f3a6671f6e015e276102a030e4a6518b2) subsys: fs/nvs: fix _nvs_sector_is_used
- [ae2f419b](https://github.com/zephyrproject-rtos/zephyr/commit/ae2f419b568cf7c3db207f4f1fd31008edffc4e6) subsys: disk: Fix log level issues

Testing (80):

- [c182520e](https://github.com/zephyrproject-rtos/zephyr/commit/c182520ee18b8826b8dcdd164de0263914ce12e6) tests: kernel: Add description for test cases
- [4c7a44b5](https://github.com/zephyrproject-rtos/zephyr/commit/4c7a44b56d1c4cb6563beca6ff700db0d6f762e9) tests: posix: Fix pthread attribute initialization
- [9f30a6ca](https://github.com/zephyrproject-rtos/zephyr/commit/9f30a6caedfa4395756231b5de1b45fc31363242) tests: mem_protect: fix off-by-one
- [136687d2](https://github.com/zephyrproject-rtos/zephyr/commit/136687d26c5c011bfcddcd4cff996d988d2c1ed2) test_build_sensors_a_m: disable app memory
- [5b8da206](https://github.com/zephyrproject-rtos/zephyr/commit/5b8da206c1005ff1f547b2a8a2b58b2df0d92263) tests: fatal: fix several issues
- [efe0c4b7](https://github.com/zephyrproject-rtos/zephyr/commit/efe0c4b7647c5e5aa53af47679bb8625fb387b19) tests: enable user mode by default
- [5414a7de](https://github.com/zephyrproject-rtos/zephyr/commit/5414a7de5f1df5524e1036514610e320d9c45948) tests: mqtt: Fix CONFIG_NET_BUF_DATA_SIZE assignments
- [4190f61c](https://github.com/zephyrproject-rtos/zephyr/commit/4190f61c28e12cd3c3b0844e49a994d26b8e946c) tests: net: Fix misspelled CONFIG_DNS_NUM_CONCUR_QUERIES assignments
- [cf227f36](https://github.com/zephyrproject-rtos/zephyr/commit/cf227f3681c42616f5050d1d01d4085696ed4119) tests: drivers: build_all: Fix CONFIG_ETH_ENC28J60_0_MAC2 reference
- [ac13bedc](https://github.com/zephyrproject-rtos/zephyr/commit/ac13bedc84929c731fe32dda9557414bea74138d) tests: net: all: Fix COAP enablement in prj.conf
- [24b0b3c1](https://github.com/zephyrproject-rtos/zephyr/commit/24b0b3c1d012059885e9c64943993d2108debe14) tests: Remove CONFIG_COMMAND_STACK_SIZE assignments
- [7a3ace35](https://github.com/zephyrproject-rtos/zephyr/commit/7a3ace35ddead6c9e3a8a68fcb2b81d33ca4f1b1) tests: Remove newline character
- [dccd2753](https://github.com/zephyrproject-rtos/zephyr/commit/dccd2753492da0fd33e30536752c0145f1ce1b5e) tests: posix: fs: Free dirp resource in case error
- [a1492325](https://github.com/zephyrproject-rtos/zephyr/commit/a1492325c050f645f627af913e88121b3b81091c) tests: kernel: fifo: Do NULL pointer check before accessing data
- [14fe2727](https://github.com/zephyrproject-rtos/zephyr/commit/14fe2727b8f08b91d83eb6cb02b8372c66709e42) tests: unfold nffs_fs_api
- [17998888](https://github.com/zephyrproject-rtos/zephyr/commit/179988888cb0ff8659f798cde9749da2422bce6c) tests: footprint: only use user mode for max
- [2348daa8](https://github.com/zephyrproject-rtos/zephyr/commit/2348daa874a974f77d717720720fefbda952e85c) tests: crypto: disable user mode on 2 tests
- [e1fab4c3](https://github.com/zephyrproject-rtos/zephyr/commit/e1fab4c3102179e83d2cf7b465a85fea546c8f29) tests: kernel: timer: timer_api: Remove nonexistent config option
- [6f40b533](https://github.com/zephyrproject-rtos/zephyr/commit/6f40b5330aeeb56527a662d246987699b270646f) tests: semaphore: improve test documentation
- [c2be4417](https://github.com/zephyrproject-rtos/zephyr/commit/c2be44171267c1a2de02adf97b466c52e56936c7) tests: alert: improve test documentation
- [12d47cc5](https://github.com/zephyrproject-rtos/zephyr/commit/12d47cc5534deba42cb15d4412e90a8a9e9fee2c) tests: fifo: improve test documentation
- [e989283f](https://github.com/zephyrproject-rtos/zephyr/commit/e989283f3577a1d7cbf436ca041d7ae5e0645ec4) tests: lifo: improve test documentation
- [234484fd](https://github.com/zephyrproject-rtos/zephyr/commit/234484fda832a9fa1b0f68870fdeb7637ee874dd) tests: msgq: improve test documentation
- [876195de](https://github.com/zephyrproject-rtos/zephyr/commit/876195de4da958f0223eb63f9b08e7ac0d854650) tests: pipe: improve test documentation
- [d73e9700](https://github.com/zephyrproject-rtos/zephyr/commit/d73e970084c5e8a0f1ded28af42c64938d72341d) tests: stack: improve test documentation
- [f8ef918d](https://github.com/zephyrproject-rtos/zephyr/commit/f8ef918d06709b26a74fe6cce6ffa9293df6c149) tests/lib/c_lib: Turn off too-clever compiler warning
- [e9174c6d](https://github.com/zephyrproject-rtos/zephyr/commit/e9174c6ddeddf58d8aebba5c89e50965731899e6) tests/kernel/common: Add rigorous integer typing test
- [d6b11e15](https://github.com/zephyrproject-rtos/zephyr/commit/d6b11e15be0d5cf2ffa3f1af98046e3e4c4bc863) tests: net: arp: Check NULL in unicast test
- [ba8c8c3c](https://github.com/zephyrproject-rtos/zephyr/commit/ba8c8c3cebe114980604da70c44f8616ad910e4b) tests: mslab_threadsafe: Check for return value
- [843ad8b0](https://github.com/zephyrproject-rtos/zephyr/commit/843ad8b07efe703c970e71903562e882dfaeb6a4) tests: semaphore: Check return value
- [dda7befd](https://github.com/zephyrproject-rtos/zephyr/commit/dda7befdba433215e47a089c133e264c8259ae39) tests: benchmarks: force assertions off
- [bc40f934](https://github.com/zephyrproject-rtos/zephyr/commit/bc40f9340db2232830b8ac9eb5bd2e2c41dc9509) debug: enable assertions for all tests
- [f3f767a2](https://github.com/zephyrproject-rtos/zephyr/commit/f3f767a2ae276fc6a12fbec1ca8fca312b80342d) tests: power: multicore: Remove CONFIG_UART_{0,1}=n assignments
- [e8182fa0](https://github.com/zephyrproject-rtos/zephyr/commit/e8182fa03d9e90ea49f5e3a46f6448d9940980bf) test: kernel: remove workaround for arm_mpu (keep for nxp_mpu)
- [d96dbadd](https://github.com/zephyrproject-rtos/zephyr/commit/d96dbadd7587b8ca67ae59f825f725a55d46279a) tests: adc_simple: Change ADC_DEBUG=y to SYS_LOG_ADC_LEVEL=4
- [637ad4cc](https://github.com/zephyrproject-rtos/zephyr/commit/637ad4cc498afa7bc8274e3d615a7bfae38d48a6) tests: net: all: Remove redundant/misspelled NET_RPL assignments
- [77658137](https://github.com/zephyrproject-rtos/zephyr/commit/7765813787e9e579381085323ec9c2f8df0fb8c8) tests: net: all: Fix assignments to old TIME_WAIT Kconfig symbols
- [f6bdcb71](https://github.com/zephyrproject-rtos/zephyr/commit/f6bdcb71eab2426aaf15d63ae9515d3d967daac3) tests: net: all: Fix assignments to old nbuf API Kconfig symbols
- [3c8e033e](https://github.com/zephyrproject-rtos/zephyr/commit/3c8e033e6920880220f1ae4f997db168372a702a) tests: net: all: Remove CONFIG_HTTP_HEADER_FIELD_ITEMS assignment
- [21792fa0](https://github.com/zephyrproject-rtos/zephyr/commit/21792fa020037675024c0a87b1e32fff753e8e3e) tests: posix: timer: Fix integer handling issues
- [86b53643](https://github.com/zephyrproject-rtos/zephyr/commit/86b53643350f4883d5ed70219db37d14c92489b6) tests/kernel: Add preemption priority test
- [6a014b63](https://github.com/zephyrproject-rtos/zephyr/commit/6a014b6321fc82121f33c78b66ee2f92cfcf3d71) tests: spi: Check for return value
- [ba2c44e4](https://github.com/zephyrproject-rtos/zephyr/commit/ba2c44e4839af520008cbb5ee8a31983e2f967b8) tests: enable HW stack protection by default
- [0a438983](https://github.com/zephyrproject-rtos/zephyr/commit/0a4389839f536263c00e45a3dd4298c64d99e69a) tests: kernel: document thread tests for RTM
- [fa4aa9fe](https://github.com/zephyrproject-rtos/zephyr/commit/fa4aa9fec0524941d10e19dcd173fd172d5a28e2) tests: threads: fold systemthread tests into main test
- [fe4693bd](https://github.com/zephyrproject-rtos/zephyr/commit/fe4693bd9fd5ff264fb1256dd0dd7bb7f4d0af36) tests: threads: fold customdata tests into main test
- [eeae0eef](https://github.com/zephyrproject-rtos/zephyr/commit/eeae0eeffb9df2fd9a61f0eb7eaff4d285304bd2) tests: kernel: put all thread tests on one level
- [43293b90](https://github.com/zephyrproject-rtos/zephyr/commit/43293b901640c28b5297f89cb16862a87392a13d) tests: critical: fix naming and comments
- [c5be083d](https://github.com/zephyrproject-rtos/zephyr/commit/c5be083df5bd776ac4ec3b280bad2a3e20dc0f19) tests: move schedule_api under sched/
- [20e969b8](https://github.com/zephyrproject-rtos/zephyr/commit/20e969b8f1adf50686ef3c69704424466a91cd5e) tests: schedule_api: fix references to tested APIs
- [f0f11289](https://github.com/zephyrproject-rtos/zephyr/commit/f0f11289ad9a9d08d733242e35a85ac98e04f30c) tests: schedule_api: change category to sched
- [6faf5b86](https://github.com/zephyrproject-rtos/zephyr/commit/6faf5b8608479dbd377d9ae5f17344e20d4659e9) test: early_sleep: cleanup test
- [9a28c87b](https://github.com/zephyrproject-rtos/zephyr/commit/9a28c87b42c0f359f16258cffa7570f1eb2fc228) tests: posix: rename entry file to main.c
- [c2e9eef8](https://github.com/zephyrproject-rtos/zephyr/commit/c2e9eef8b05586e9aabfda1a45b51a1d76049160) tests: kernel context: rewrite test to use ztest correctly
- [8c8ddb81](https://github.com/zephyrproject-rtos/zephyr/commit/8c8ddb81969d19a0b8f022d3db0bf0e805666107) tests: workqueue: add API references and doxygen group
- [4317a181](https://github.com/zephyrproject-rtos/zephyr/commit/4317a181c924e71fd7b6e3fcca85111721808927) tests: net: all: Increase NET_MAX_CONTEXTS from 4 to 5
- [b20cc63d](https://github.com/zephyrproject-rtos/zephyr/commit/b20cc63d81f55271fd826be8bf261dae37b32f69) tests: power states: Remove CONFIG_GPIO_QMSI_1_{NAME,PRI} assignments
- [12f87f7a](https://github.com/zephyrproject-rtos/zephyr/commit/12f87f7a94f70bb25a9a19b54932e9806073c87e) tests: net: Fix assignments to CONFIG_NET_DEBUG_6LO
- [aa26d992](https://github.com/zephyrproject-rtos/zephyr/commit/aa26d9926af7e1e31da0b39b4a89a8c11d0ff42e) tests: mbedtls: don't use stdout console
- [e63cccdc](https://github.com/zephyrproject-rtos/zephyr/commit/e63cccdc4165bf2e6aa048ab73844ee763677f66) tests: fixes for ARC
- [467f8fbe](https://github.com/zephyrproject-rtos/zephyr/commit/467f8fbe3d6a9f31ecb50471f9114661b1ee5223) tests: fixes for ARC
- [92a3c41d](https://github.com/zephyrproject-rtos/zephyr/commit/92a3c41dd5866afe29913c47ecda0f5d8f64f0fe) tests: necessary fixes for ARC
- [22838e8b](https://github.com/zephyrproject-rtos/zephyr/commit/22838e8b509baeffc77e3ba28b4ae3406cc85cef) benchmarks: object_footprint: Disable userspace for benchmarks
- [6663286f](https://github.com/zephyrproject-rtos/zephyr/commit/6663286fd8abf7508c6044c9a61a1fed694430d6) benchmarks: app_kernel: Disable userspace for benchmarks
- [a5988f81](https://github.com/zephyrproject-rtos/zephyr/commit/a5988f811ab7937a4edf397bf5a466e790b2614c) benchmarks: latency_measure: Disable userspace for benchmarks
- [e8626d71](https://github.com/zephyrproject-rtos/zephyr/commit/e8626d71ac2b01b447d2a51d75f8928e7494db52) benchmarks: boot_time: Disable userspace for benchmarks
- [a9dda77f](https://github.com/zephyrproject-rtos/zephyr/commit/a9dda77f618a81163721027855f9cc1a9229e22a) benchmarks: footprint: Disable userspace for benchmarks
- [2182178b](https://github.com/zephyrproject-rtos/zephyr/commit/2182178baeae3185d84b0dd34a61e19111233519) benchmarks: sys_kernel: Disable userspace for benchmarks
- [8bbf0fd7](https://github.com/zephyrproject-rtos/zephyr/commit/8bbf0fd732a82258fd95c53501f5dad222268f72) benchmarks: timing_info: Disable userspace for benchmarks
- [c782d07a](https://github.com/zephyrproject-rtos/zephyr/commit/c782d07a1ce5ee0895dc3ab97a79c9fa8ec69f63) tests/kernel/smp: Properly synchronize CPU counters at test start
- [bed0ac68](https://github.com/zephyrproject-rtos/zephyr/commit/bed0ac6877e2dac7fb8adb2a42f046f21536ec7e) tests: workqueue: fix doxygen group
- [2f7fe7e2](https://github.com/zephyrproject-rtos/zephyr/commit/2f7fe7e252f5e9edfe20e06c408111ed6f8dd258) tests: mem_pool: organise test documentation
- [4ef36a4b](https://github.com/zephyrproject-rtos/zephyr/commit/4ef36a4b54705238511bfab96a90b606ba1bf1fe) tests/kernel/mem_slab: Fix memory overcommit
- [338f4519](https://github.com/zephyrproject-rtos/zephyr/commit/338f45198132402d5cf73fe909ff568601313c11) tests: kernel: profiling: Fix _sys_soc_suspend logic
- [66e84540](https://github.com/zephyrproject-rtos/zephyr/commit/66e84540f7712bec9bc5eff76b31763f6b0ce325) tests: subsys: settings: fcb: Fix failure on nrf52_pca10040
- [f5bf2816](https://github.com/zephyrproject-rtos/zephyr/commit/f5bf2816dfd133409c5247a729ed2e6bc5acce59) tests: posix: Function call return values need to be validated.
- [2d03b552](https://github.com/zephyrproject-rtos/zephyr/commit/2d03b5529359bc34655bba98aeba810395a955d3) tests/kernel/mem_slab: Fix memory overcommit for real
- [75e2af20](https://github.com/zephyrproject-rtos/zephyr/commit/75e2af20eaa3dbd28cd60b3a6fdfd4bdd8cdf59a) tests: fifo_timeout : Dereference after null check
- [2237ce6b](https://github.com/zephyrproject-rtos/zephyr/commit/2237ce6b56b428f7feed4e6bde3925a88224abbc) tests: mem_protect: use better stack size arg
- [b5a3ddf7](https://github.com/zephyrproject-rtos/zephyr/commit/b5a3ddf7d73e42ac9551f66414df82b7779cff2c) tests: ieee802154/crypto: use console harness

