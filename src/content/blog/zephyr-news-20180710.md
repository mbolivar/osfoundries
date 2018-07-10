+++
title = "Zephyr Development News 10 July 2018"
date = "2018-07-10"
tags = ["zephyr"]
categories = ["zephyr-news"]
banner = "img/banners/zephyr.png"
author = "Michael Scott"
+++

This is the 10 July 2018 newsletter tracking the latest
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

The past 2 weeks have seen a lot of activity, which is to
be expected this early in the Zephyr 1.13 development cycle.
Commits in the Drivers, Arches and Networking areas accounted
for over 50% of the changes.

This newsletter covers the following inclusive commit range:

- [3bdb52f1](https://github.com/zephyrproject-rtos/zephyr/commit/3bdb52f1ad577b7e77b10c4cd83807196d97e479) doc: improved error reporting for non-UTF8 docs
- [25b0212f](https://github.com/zephyrproject-rtos/zephyr/commit/25b0212fc36a4d6414bb20f06a794ebe89f91f0f) subsys: usb: class: add loopback function

Important Changes
-----------------

**Kconfig removal of all redundant default "n" settings:**

A series of Kconfig-related patches removed all redundant default
"n" settings across the entire Zephyr tree.  This change *shouldn't*
affect behavior; however, it will make any out of tree patches
affecting Kconfig files a bit more difficult to merge for this
cycle.

**New functionality for the console driver/subsystem:**

The console driver/subsystem went through a fairly large refactor
to remove the dependency on a FIFO-based console input abstraction.
This allows supporting Segger's RTT technology as a console backend.
The `CONFIG_CONSOLE_PULL` knob was renamed to `CONFIG_CONSOLE_SUBSYS` as
part of these changes. This signifies that the subsystem is intended
to cover all of Zephyr's console handling (existing and new).

Applications using the old configuration name will need updates.

Features
--------

**Arches:**

Initial Cortex M4 support was added for the i.MX 6SoloX SoC. It's a
hybrid multi-core processor composed of one Cortex A9 core and one
Cortex M4 core.  The low level drivers come from the NXP FreeRTOS BSP
and are located at [ext/hal/nxp/imx](https://github.com/zephyrproject-rtos/zephyr/blob/master/ext/hal/nxp/imx/).  More details can be found in
[ext/hal/nxp/imx/README](https://github.com/zephyrproject-rtos/zephyr/blob/master/ext/hal/nxp/imx/README).

Microsemi Mi-V RISC-V softcore CPU support was added for running
on the M2GL025 IGLOO2 FPGA development board.  This required moving
some code from the fe310 platform into the RISC-V privilege common
folder.

Zephyr support was added for Nordic's nRF52810 SoC.  This is a low-cost
variant of the nRF52832, with a reduced set of peripherals and memory.
Since Nordic does not offer a development kit for the nRF52810,
the `nrf52810_pca10040` board definition can be used with the nRF52832-DK
(`nrf52_pca10040`).  Using this board definition enforces the limitations
imposed by the nRF52810 IC.
For more information, see
[http://www.nordicsemi.com/eng/Products/nRF52810](http://www.nordicsemi.com/eng/Products/nRF52810)

An nRF5x peripheral list was created that can be used to describe
each nRF5x SoC. Kconfig can use this description to help configure
only drivers that are available for a particular SoC.

Support was added for the STM32F7 and STM32F2 series of STM32 SoCs.
This includes clock control, entropy, GPIO, flash, pinmux, and UART
drivers, as well as several device trees and board definitions for
STM32F7 Discovery, STM32F207XG, and STM32F207XE development hardware.

The ESP32 IDF bootloader now has a Kconfig option for compilation during
the Zephyr build.  At flash time, the bootloader will be flashed with
the Zephyr image.

Nordic and STM32 SoCs can now use Segger's RTT protocol for console
output, in addition to UART.

**Bluetooth:**

Controller support was added for the Nordic nRF52810.

A new Bluetooth Mesh node sample was added in
[samples/boards/nrf52/mesh/onoff_level_lighting_vnd_app](https://github.com/zephyrproject-rtos/zephyr/tree/master/samples/boards/nrf52/mesh/onoff_level_lighting_vnd_app).
It demonstrates several generic and light models.

The BLE controller Kconfig options were reorganized. `CONFIG_BT_CTLR`
means that a controller is implemented, with additional options
(currently just `CONFIG_BT_LL_SW`) selecting a specific implementation.
This allows adding alternative controller implementations in the future.

If the Bluetooth device is neither an observer or has central role
selected, the scan related code is excluded from the HCI core.
This results in smaller image sizes for peripheral- or broadcasting-only
roles.

A Kconfig option `CONFIG_BT_CTLR_CRYPTO` was added to allow
flexibility in choosing to use host cryptographic functions or the ones
provided by the BT controller.

**Boards:**

A new "shields" configuration was added to establish connector flags
for compatibility checks.  Arduino compatible serial, I2C and SPI
were the first shield compatibility additions, with ST's nucleo_f429zi
board making use of them.  Expect more on this front as time goes on.

Several new boads were added: i.MX's UDOO Neo Full SBC and ST's
STM32F746G-DISCO, STM32F723E-DISCO and STM32F769I-DISCO.

The I2C ports of several nRF-based boards were enabled.

**Build:**

An LLVM backend and a clang toolchain variant were added to support
building with llvm (included with many popular Linux distributions).
Initial testing was done on quark_d2000_crb and
quark_se_c1000_devboard/Arduino 101. To enable this, set
`ZEPHYR_TOOLCHAIN_VARIANT` to `clang` in your environment.

Architectures, boards, and apps can now override the C standard version,
which was previously set to `-std=c99`.  Currently, the native POSIX
port uses this feature in [boards/posix/native_posix/CMakeLists.txt](https://github.com/zephyrproject-rtos/zephyr/blob/master/boards/posix/native_posix/CMakeLists.txt)

`set_property(GLOBAL PROPERTY CSTD c11)`

**Device Tree:**

Nordic boards moved I2C enablement, SDA and SCL pin configuration,
and LED / button definitions into DTS.

STM32F7-pinctrl added definitions for USART/UARTs.

**Documentation:**

Information about the websocket server API was added to Zephyr's
documentation. For details, see
[http://docs.zephyrproject.org/api/networking.html#websocket](http://docs.zephyrproject.org/api/networking.html#websocket)

Intel S1000 developers will be happy to note that the docs
now include instructions for obtaining the toolchain from:
[https://tensilicatools.com/platform/intel-sue-creek](https://tensilicatools.com/platform/intel-sue-creek).

As part of Zephyr's security development process, certain external
requirements require justification that threats in a threat model have
been mitigated. To make this process traceable, the threats must be
enumerated and given labels. For this purpose, labels were added to
the threats in Zephyr's sensor threat model. See the model itself
for more details
[http://docs.zephyrproject.org/security/sensor-threat.html](http://docs.zephyrproject.org/security/sensor-threat.html)

Ever wonder how DTS relates to Kconfig options? Wonder no more!
Some clarification was added to the Device Tree documentation at
[http://docs.zephyrproject.org/devices/dts/device_tree.html#dt-vs-kconfig](http://docs.zephyrproject.org/devices/dts/device_tree.html#dt-vs-kconfig)

The "Getting Started" document did not clearly state how to use
a custom cross compiler.  This was remedied with a new section
"Using Custom Cross Compilers".  See the details at
[http://docs.zephyrproject.org/getting_started/getting_started.html](http://docs.zephyrproject.org/getting_started/getting_started.html)

Information on the newly-supported gPTP protocol was added to the
networking documentation.

**Drivers:**

STM32F2 and STM32F7 received clock_control, flash, GPIO, pinmux,
UART, entrophy and interrupt_controller drivers.

The native POSIX Ethernet driver now has support for gPTP.

A generic I2C EEPROM slave driver was added.

USB drivers received several additions, such as high-speed support for
DesignWare USB controllers, and an API for USB BOS (Binary Object
Store) descriptors.

USB HID payload size is now configurable via
`CONFIG_USB_HID_MAX_PAYLOAD_SIZE` (the previous value of 64 is still the
default).

Shims for nRFx TWI, TWIM and PWM drivers were added and the now
redundant i2c_nrf5 shim was removed.

A PTP clock driver was introduced which can be implemented in
those network interface drivers that provide gPTP support.

An LED driver for NXP PCA9633 (I2C 4-bit LED) was added which supports
a blink period from 41ms to 10667ms and a brightness value from 0 to 100%.

**External:**

The NXP iMX6 FreeRTOS BSP was imported to add Zephyr support on
iMX6SX processors (exclusively on the Cortex M4 core), and to speed
up the development process.

The Nordic nRFX HAL was updated to support the nRF52810.

STM32cube updates for all STM32 families (including the addition of
STM32F2x HAL) were also merged.

The Segger RTT debug code was updated to version 6.32d.

MCUMGR external sources were updated to external commit a837a731 from
[https://github.com/apache/mynewt-mcumgr](https://github.com/apache/mynewt-mcumgr).

**Kernel:**

Back in Zephyr 1.12, the old scheduler's thread queueing code was replaced
with the choice of a "dumb" list or a balanced tree.  The old multi-queue
algorithm is still useful in some use cases, such as applications
with large-ish numbers of runnable threads that don't need or want
fancy features like EDF or SMP affinity.  To fill this gap, the old
implementation was reintroduced, and can be enabled using
`CONFIG_SCHED_MULTIQ`.

**Miscellaneous:**

The logging subsystem saw many new features merged, including:
support for multiple backends, improving real-time performance by deferring
logging to a separate runtime context, timestamps, and filtering
options (which are compile time, runtime, module level, instance level).
The console backend was added as the first backend example.

**Networking:**

gPTP (Precision Time Protocol) support was added to according to
the IEEE 802.1AS-2011 standard.  To enable it, use `CONFIG_NET_GPTP`.
Note: at this time, gPTP is only supported for boards that have
Ethernet ports which support collecting timestamps for sent and
received Ethernet frames.  A gPTP sample was added at
[samples/net/gptp](https://github.com/zephyrproject-rtos/zephyr/tree/master/samples/net/gptp).

Also new to Zephyr is the LLMNR (Link Local Multicast Name Resolution)
client and responder from RFC 4795.  LLMNR is used in Windows
networks.  A caller can be set up to resolve DNS resource records
using multicast DNS, as well as configured to listen for LLMNR DNS
queries and respond to them.  Related Kconfig options
are `CONFIG_LLMNR_RESOLVER` and `CONFIG_LLMNR_RESPONDER`. The implementation
is in [subsys/net/lib/dns](https://github.com/zephyrproject-rtos/zephyr/tree/master/subsys/net/lib/dns).

**Samples:**

Socket API-based samples for echo_client and echo_server were added
to Zephyr as well as a simple logger sample illustrating the new
capabilities of the logger subsystem additions.

LLMNR client support was added to the DNS resolver sample.

A sample application for testing the NXP PCA9633 LED driver was added.

**Scripts:**

The Kconfiglib project in Zephyr saw a couple of updates.
1) Dependency loop detection.  Until now, dependency loops have
raised a hard-to-debug Python `RecursionError` during evaluation.
Now, a `Kconfiglib` exception is raised instead, with a message
that lists all the items in the loop.
2) `MenuNode.referenced()` was converted to a property, making
the API more consistent (read-only values are accessed with properties).
3) Warnings for choice overrides were eliminated.

The nrfjprog runner script was updated to accept a `--snr` parameter
specifying the serial number of the device to be operated on.

Device tree now allows the use of a new element of DTC grammar called
overriding nodes.  It looks like this in a board's dts file
`arduino_i2c: &i2c1 {};`
This overriding node information is used during the DTS include
file generation like so
`#define ARDUINO_I2C_LABEL ST_STM32_I2C_V1_40005400_LABEL`

In this way, `ARDUINO_I2C_LABEL` could be used as a generic binding name.
This change is derived from a dtc commit in version v1.4.2.

Bug Fixes
---------

**Arches:**

The ARM/NXP MPU code was cleaned up a bit to avoid configuring
out-of-bound MPU regions.  Also, the ARM MPU code had several
Zephyr defines replaced with direct uses of CMSIS defines.

When compiling, both cortex-m0 and cortex-m0plus will now use
`-march=armv6s-m` instead of `-march=armv6-m` to to ensure the svc
directive exists.

**Bluetooth:**

Bluetooth Mesh now depends on `CONFIG_BT_BROADCASTER` and `CONFIG_BT_OBSERVER`,
as they are necessary to implement Mesh devices.  Several other
Mesh-related bugfixes landed to solve initialization order during
node reset, redundant model publication clearing, cyclic rewriting
to flash when restoring state, checking for a model subscription
address, and ignoring prohibited element addresses.

For the Bluetooth Controller core, LE Extended Scanner Filter Policy
now depends on `CONFIG_BT_OBSERVER` and the time to transmit an empty
packet was raised from 40 microseconds to 44 microseconds on a 2M PHY,
due to an additional byte of preamble.

The BlueNRG-MS HCI driver received a pair of changes. In the first, it
now reads from the controller as long as the IRQ is high. In the
second, it makes sure to configure the BlueNRG-MS to controller mode
just after it's ready by disabling "HCI reset" via a quirk.

**Boards:**

The BlueNRG-MS Bluetooth configuration had to be fixed on the
`disco_l475_iot1` board.  This includes SPI3 usage, SYSCLK adjustments,
and a few build warnings.

**Build:**

The gen_isr_tables script received several updates for
simplification and dead code removal.

Python script "process_gperf.py" used in the Zephyr build system
will now be invoked via "python" instead of called directly.
This avoids non-portable shebang logic and/or "default application"
behaviour.

**Device Tree:**

STM32F4 saw corrected pin assignment of node `usart6@0`.

**Drivers:**

RTC syscall changes required a build error fix.

A build error was addressed for `intel_s1000` which uses
DesignWare USB. It doesn't inherit qmsi header which
has several definitions used in the driver.  Instead make
sure those definitions exist in a a DesignWare specific
header.

A build error in uart_handler.c was fixed when `CONFIG_UART_LINE_CTRL`
is defined.

Fixes were applied to the nRF UART driver for broken hardware
flow control and interrupt driven APIs.

For the USB/DFU subsystem, bcdUSB had been previously updated
from 1.1 to 2.0 in the default device descriptor, but not in the
DFU class. After USB bus reset performed by dfu-util, this alternative
descriptor registered with bcdUSB was set to 1.1. This mismatch caused
a communication failure.  The DFU descriptor's bcdUSB was
updated to match the default value.

The STM32 clock control driver received a fix to HCLK calculation
when using MSI.  The MSI clock signal can be selected in several ranges.
These ranges should be taken into account for calculating its
frequency and hence global system frequency.  This change is
used when enabling Bluetooth on the `disco_l475_iot1` board.

A long-standing issue where the K64F-FRDM board would generate a
random MAC address on every boot (which would lead to DHCP address
exhaustion) has been solved. The existing Kconfig option
`CONFIG_ETH_MCUX_0_RANDOM_MAC`, which dynamically chooses a random MAC
address, is now one choice among many in the new
`CONFIG_ETH_MCUX_0_MAC_SELECT` option. The other choices are
`CONFIG_ETH_MCUX_0_UNIQUE_MAC` (the new default), which uses the MCU
unique identification register to generate a stable MAC address which
is persistent over reboots, and `CONFIG_ETH_MCUX_0_MANUAL_MAC`, which
allows setting a fixed MAC address. For details, see
[http://docs.zephyrproject.org/reference/kconfig/choice_55.html?highlight=eth_mcux_0_mac_select](http://docs.zephyrproject.org/reference/kconfig/choice_55.html?highlight=eth_mcux_0_mac_select)

NETUSB and STM32 ethernet hardware apparently never called
`ethernet_init()`.  This was revealed when the `net_arp_init()`
function was moved into `ethernet_init()` and ARP tables stopped
being initialized correctly, and has been fixed.

**External:**

PWM related nrfx_config entries for nRF52840 needed to have their
#ifdef logic reversed in order to enable properly.

For STM32F4xx and STM32F7xx, the I2SR field needed to be shifted
by `RCC_PLLI2SCFGR_PLLI2SR_Pos` when the `PLLI2SCFGR` register is read
or written.  Previously, the configuration was not done properly
(R and M params were badly set) and the `PLLI2S` was generating a
bad clock waveform.

**Networking:**

The "net app" layer has historically been the combination of 2
separate but useful parts: 1) a library to set up client and server
connections (`CONFIG_NET_APP`) and 2) a library to set up/configure
networking on application startup (`CONFIG_NET_APP_SETTINGS`).
As this second functionality is useful in almost every circumstance,
it has been split out into a new top-level networking library
under [subsys/net/lib/config](https://github.com/zephyrproject-rtos/zephyr/tree/master/subsys/net/lib/config).  In the future, this would also allow other
networking frameworks such as sockets to use these configuration
options.  This move will cause issues for out of tree patches to
the net app layer.

The layer 2 networking code was also moved as having it under
subsys/net/ip/l2 didn't make much logical sense.  The new location
is [subsys/net/l2](https://github.com/zephyrproject-rtos/zephyr/tree/master/subsys/net/l2).  Hopefully, this movement didn't result in any
functional changes, but only time will tell.  Developers should
note that any local patches to the old layer 2 location will need
to be refactored.

Zephyr's ARP table implementation was cleaned up slightly and
optimized for memory usage through the use of a single linked
list, smaller ARP entries, and handling request timeouts
in a single `k_delayed_work` structure.

**Samples:**

Several changes were applied to the Bluetooth Mesh nRF52
on/off level lighting sample at
[samples/boards/nrf52/mesh/onoff_level_lighting_vnd_app](https://github.com/zephyrproject-rtos/zephyr/tree/master/samples/boards/nrf52/mesh/onoff_level_lighting_vnd_app).

The 96 Boards ArgonKey sample added support for the
TI LP3943 LED controller to test the 12 on-board LEDs.

**Scripts:**

The extract_dts_includes script was refactored for better
maintainability; some false information messages were also removed.

Individual Changes
==================

Patches by area (417 patches total):

- Arches: 63
- Bluetooth: 24
- Boards: 33
- Build: 17
- Continuous Integration: 7
- Device Tree: 12
- Documentation: 15
- Drivers: 107
- External: 16
- Firmware Update: 2
- Kernel: 11
- Libraries: 3
- Maintainers: 1
- Miscellaneous: 4
- Networking: 50
- Samples: 21
- Scripts: 8
- Testing: 23

Arches (63):

- [687355c9](https://github.com/zephyrproject-rtos/zephyr/commit/687355c9af5ab8bd5f739e22eba26d94f75d615c) arch: arm: nrf: Use SystemInit() from MDK in SoC initialization
- [1fa9d843](https://github.com/zephyrproject-rtos/zephyr/commit/1fa9d84332b92503ab84cc45537c9afff1015f34) arch: arm: nrf: add hardware description for nrf Kconfig files
- [eb84eff2](https://github.com/zephyrproject-rtos/zephyr/commit/eb84eff27f91658b5d091ae0884890d1fc64f764) arch: arm: nrf: modification of config parameter: SOC_SERIES_NRF52X
- [0a41e23a](https://github.com/zephyrproject-rtos/zephyr/commit/0a41e23ac04e26431444ec4976554e3ccdbb6ec5) arch: arm: use CMSIS macro defines for MPU_CTRL register bit setting
- [8d52c171](https://github.com/zephyrproject-rtos/zephyr/commit/8d52c17166810085776fde7f4ba332d25023ada0) arch: arm: use CMSIS defines for MPU_RBAR register bit setting
- [1547abb5](https://github.com/zephyrproject-rtos/zephyr/commit/1547abb57d079e7a5fc9f81479da0a912208273c) arch: arm: use CMSIS defines for MPU_RASR register bit setting
- [bf159885](https://github.com/zephyrproject-rtos/zephyr/commit/bf15988510496ca0fc40ee5190751029709fee61) arch: arm: beetle: duplicate CMSIS MPU-related macros
- [631eedd3](https://github.com/zephyrproject-rtos/zephyr/commit/631eedd33480b2cfbfea61bab433a7c8bef178d4) arch: Add imx6sx m4 soc support
- [23a5b5d1](https://github.com/zephyrproject-rtos/zephyr/commit/23a5b5d171c87d354a4204111ccd6ab95c87e39f) riscv32: riscv-privilege: integrate common code
- [1765d75f](https://github.com/zephyrproject-rtos/zephyr/commit/1765d75ff4360659c7dab133ca6c7a689e3a7162) riscv32: riscv-privilege: Microsemi Mi-V support
- [5204fd70](https://github.com/zephyrproject-rtos/zephyr/commit/5204fd7061d0e6aa529d455bc430cb0a19962d0b) arch: arm: Set Zero Latency IRQ to priority level zero:
- [92778e44](https://github.com/zephyrproject-rtos/zephyr/commit/92778e4438a989771c680871252850b4a3ea62d5) arch: soc: nrf52: add UART1 to dts fixup
- [071f5153](https://github.com/zephyrproject-rtos/zephyr/commit/071f5153acb043784abdf3142219379183c17b0d) arch: arm: mpu: include CMSIS header in arm_mpu.h
- [aee97be7](https://github.com/zephyrproject-rtos/zephyr/commit/aee97be7107b478ca0f88e1d09624615a1de54b0) arch: arm: soc: remove core zephyr header inclusions from soc.h
- [985f43e3](https://github.com/zephyrproject-rtos/zephyr/commit/985f43e38be62d0697e10424f61ea38e43dbb38b) native_posix: Let users use math functions
- [54d1a608](https://github.com/zephyrproject-rtos/zephyr/commit/54d1a608ff12b1086adc6e5b9c972651c24e0b4b) imxrt1050: Disable low-power modes
- [0f6bd5c8](https://github.com/zephyrproject-rtos/zephyr/commit/0f6bd5c891251cafac5c0a9f14be8815ca0850da) arch: arm: nrf: Add support for the nRF52810
- [aed5e360](https://github.com/zephyrproject-rtos/zephyr/commit/aed5e360ee89fe73bd7679957c85ce30776bd333) arch/Kconfig: Remove redundant 'default n' properties
- [87ecbe7f](https://github.com/zephyrproject-rtos/zephyr/commit/87ecbe7f48a1605d87c34c002ee3aef03ab65d88) arch: x86: Kconfig: Remove redundant 'default n' properties
- [81d61601](https://github.com/zephyrproject-rtos/zephyr/commit/81d61601a810cea0741657656a943021199793e8) arch: riscv32: Kconfig: Remove redundant 'default n' properties
- [b0156b2c](https://github.com/zephyrproject-rtos/zephyr/commit/b0156b2c48fcb01c5e7ad0b0f9d5c35bed3a27b1) arch: nios: Kconfig: Remove redundant 'default n' properties
- [8cb6fb72](https://github.com/zephyrproject-rtos/zephyr/commit/8cb6fb722348ce99ed4de7d03ca39742a81dd2f4) arch: xtensa: Kconfig: Remove redundant 'default n' properties
- [f428d8da](https://github.com/zephyrproject-rtos/zephyr/commit/f428d8dacf218d8737f98434b10b6fd04085c0c2) arch: arc: Kconfig: Remove redundant 'default n' properties
- [f1f1fb41](https://github.com/zephyrproject-rtos/zephyr/commit/f1f1fb41bd9ed644fa45e8206ba90ee0f5a608a4) arch: arm: Kconfig: Remove redundant 'default n' properties
- [30529da0](https://github.com/zephyrproject-rtos/zephyr/commit/30529da0e4ab6ff967ccdd18dcae4f161de7be24) arch: arm: stm32: correct include issue
- [8bcffefb](https://github.com/zephyrproject-rtos/zephyr/commit/8bcffefb33d3926f9f2e59b8be8a8e446f34a522) arch: arm: clean up MPU code for ARM and NXP
- [e7205be0](https://github.com/zephyrproject-rtos/zephyr/commit/e7205be03dffeabb7769241219a35736b7908f22) arch: stm32: Enable HAS_SEGGER_RTT on all stm32 SoCs
- [7d8d280d](https://github.com/zephyrproject-rtos/zephyr/commit/7d8d280db3396c2075e2cb899762993231500d04) arch: arm: stm32: Basic STM32F7 family support
- [58643f3d](https://github.com/zephyrproject-rtos/zephyr/commit/58643f3d8612ed31cab2812f62f377b5a3698225) arm: stm32: STM32F7 family device tree
- [e8607758](https://github.com/zephyrproject-rtos/zephyr/commit/e8607758731eda7845047c96a1e655b0ff708a8c) Revert "arch: arm: stm32: correct include issue"
- [2889f5f0](https://github.com/zephyrproject-rtos/zephyr/commit/2889f5f02ce32ea511d86764b23eeeb1f66af189) native: Do not ignore format-truncation warnings
- [fa83a4d1](https://github.com/zephyrproject-rtos/zephyr/commit/fa83a4d1312fb61672962a2b39bf4c8d16c4df96) arch: arm: stm32f7: remove core zephyr header inclusions from soc.h
- [7c9a1f0f](https://github.com/zephyrproject-rtos/zephyr/commit/7c9a1f0f76ecca4974a9554c5c03d56dc8061a23) arch: arm: soc: add explanatory comment for kernel headers' inclusion
- [52ed3799](https://github.com/zephyrproject-rtos/zephyr/commit/52ed37991281096c2990ec91c2fdf7f9fce4ccdb) esp32: add ESP-IDF bootloader option
- [5ed26a5c](https://github.com/zephyrproject-rtos/zephyr/commit/5ed26a5cc807d21074c53c0e5adb0fba2a56c90f) esp32: Re-order bootloader condition in Kconfig
- [4a8393dd](https://github.com/zephyrproject-rtos/zephyr/commit/4a8393dd6647e7b0e8857f0a0040ea1311cdfbca) esp32: add abitily to flash bootloader
- [06778129](https://github.com/zephyrproject-rtos/zephyr/commit/067781291067046b4b4d1c683e333b937434b74e) arch: arm: nrf: remove kernel_includes.h from nRF5x soc.h inclusions
- [e325510d](https://github.com/zephyrproject-rtos/zephyr/commit/e325510d596d7923389e2dfc4ec78f46e1fc6201) arch: arm: nrf: minor header files' clean up in soc/nrfx
- [bdab07a2](https://github.com/zephyrproject-rtos/zephyr/commit/bdab07a2fd72d28daba34443413a8d7476eefbbc) native_posix: Do not select COVERAGE by default
- [97adff57](https://github.com/zephyrproject-rtos/zephyr/commit/97adff57f1d86e27f57a49a25cb88f196f8a5083) arch: arm: nrf: Enable SEGGER RTT on all Nordic SoCs
- [059952c8](https://github.com/zephyrproject-rtos/zephyr/commit/059952c8e185994c4cb166ce8f6b07c68f2028f3) arch: arm: update compile options for DSP
- [6ee562b7](https://github.com/zephyrproject-rtos/zephyr/commit/6ee562b7542d27f34160c0c0e72144aec143995a) arch: arm: stm32: add basic support for STM32F723 SoC
- [33d3f14b](https://github.com/zephyrproject-rtos/zephyr/commit/33d3f14b156f4d2fef63e16ba50141c07347f7fb) arch: arm: add compile-time guards for arm_mpu code
- [d20dac82](https://github.com/zephyrproject-rtos/zephyr/commit/d20dac825470eb0ac9438ff40c0fa32a4a4ff424) arch: arm: minor refactor in arm_core_mpu_configure_user_context
- [559249ee](https://github.com/zephyrproject-rtos/zephyr/commit/559249ee01a00f04a00180736bf0cbf7702760ca) arch: arm: Remove redundant HAL definition for ARM MPU
- [816100a6](https://github.com/zephyrproject-rtos/zephyr/commit/816100a6329f0a63b95db1f0adff4d94aefced03) arch: arm: use CMSIS bitset flags for MPU attribute definitions
- [1ed37e77](https://github.com/zephyrproject-rtos/zephyr/commit/1ed37e77cee83f65360fbac3f1ea201bf713667f) arch: arm: beetle: duplicate ARM MPU registers' definition
- [ca6b21b9](https://github.com/zephyrproject-rtos/zephyr/commit/ca6b21b907c8cc99dcc9319b9821ee4ddd40eb18) arch: arm: move ARMv7-m specific content in corresponding header file
- [e202e044](https://github.com/zephyrproject-rtos/zephyr/commit/e202e0449963098dc5dff0426e761d77e5daf206) arch: arm: nrf: conditionally compile mpu_regions.c
- [2b79fceb](https://github.com/zephyrproject-rtos/zephyr/commit/2b79fceb84c95a7544cf2a3a5b6c0564301eb062) arch: arm: refactor _region_init(..) function
- [d1944109](https://github.com/zephyrproject-rtos/zephyr/commit/d1944109a9a85bf5b550c4116752e644559fb7b9) arch: arm: abstract MPU attribute generation in inline function
- [df41ed88](https://github.com/zephyrproject-rtos/zephyr/commit/df41ed885ab950a45718f3133315aee783259def) arch: arm: mpu: replace literals with CMSIS bitsets
- [a36bd915](https://github.com/zephyrproject-rtos/zephyr/commit/a36bd915af7f21442ad599ab2366912838d5e7da) arch: ARM: Change the march used by cortex-m0 and cortex-m0plus
- [6511c412](https://github.com/zephyrproject-rtos/zephyr/commit/6511c4122d8938657ad8aa02c5c1f2aac1c959dd) arm: stm32f2: Add support for stm32f2 series
- [85d2633a](https://github.com/zephyrproject-rtos/zephyr/commit/85d2633af2ed8f225ac7453d74eceace94830f09) stm32f2: add stm32f207xg soc
- [7e2f6ebc](https://github.com/zephyrproject-rtos/zephyr/commit/7e2f6ebc7b4f9440b11723976070ad2ffb8deb55) stm32f2: add stm32f207xe soc
- [0a5de7df](https://github.com/zephyrproject-rtos/zephyr/commit/0a5de7df718eaa7304cffee7ca1e63d386157fe6) native_posix: override C standard version to 2011
- [889b290a](https://github.com/zephyrproject-rtos/zephyr/commit/889b290a98f83aa900554fc01f9e373a069d6dde) arch: arm: beetle: Pull in CMSDK header for CMSIS support on Beetle
- [41dd6622](https://github.com/zephyrproject-rtos/zephyr/commit/41dd6622cedf64388f850869773b729056b3d817) arm: Print NXP MPU error information in BusFault dump
- [54fbcc08](https://github.com/zephyrproject-rtos/zephyr/commit/54fbcc08a98acfbc1108bcfd485a3d11fd1a7c80) arch: arm: mpu: get REGION_SIZE_<X> defines directly from ARM CMSIS
- [4e26f9c3](https://github.com/zephyrproject-rtos/zephyr/commit/4e26f9c3a65a29e8f38f22516f8aa029573e0222) arch: stm32f0/f1/f3/l0: remove core zephyr header inclusions
- [5aaf827a](https://github.com/zephyrproject-rtos/zephyr/commit/5aaf827a3ea96dd99f12e391ab1fd7811878bf61) arch: arm: stm32f2: remove core zephyr header inclusions from soc.h
- [8776835b](https://github.com/zephyrproject-rtos/zephyr/commit/8776835bd62062c6e6df0bd35b540c6a4787a79f) arch: arm: stm32: add basic support for STM32F769 SoC

Bluetooth (24):

- [b35ed7e7](https://github.com/zephyrproject-rtos/zephyr/commit/b35ed7e79ca3139018876b5585921934cf62ce63) Bluetooth: Fix central from failing to start encryption
- [938f12e9](https://github.com/zephyrproject-rtos/zephyr/commit/938f12e99d799fdc99315b9e821c5561b713348a) Bluetooth: Mesh: Gen. OnOff, Gen. Level, Lighting & Vendor Models
- [88182449](https://github.com/zephyrproject-rtos/zephyr/commit/881824495939a8b27091c69900f21d5fcf8d4aaf) Bluetooth: Add helper for parsing advertising data
- [d41d9bd1](https://github.com/zephyrproject-rtos/zephyr/commit/d41d9bd112c26512b091b3649dd4ef0343a40789) Bluetooth: Convert sample code to use the new bt_data_parse() API
- [85c15226](https://github.com/zephyrproject-rtos/zephyr/commit/85c15226990212dbe98f5026fea207afb81667b4) Bluetooth: UUID: add UUIDs for missing HIDS characteristics
- [f3ba6e38](https://github.com/zephyrproject-rtos/zephyr/commit/f3ba6e3806857f09382f07725675acabcc35e059) Bluetooth: hci_core: Exclude conn creation related code for non-central
- [4e6495c8](https://github.com/zephyrproject-rtos/zephyr/commit/4e6495c8326446d6083f511bee1dee384725f4ad) Bluetooth: mesh_demo: Enable missing options in configuration file
- [8a501601](https://github.com/zephyrproject-rtos/zephyr/commit/8a50160198b3a46fb222b8bb430c4c942b02c3ca) Bluetooth: Mesh: Depend Mesh upon Observer and Broadcaster roles
- [76d0dd41](https://github.com/zephyrproject-rtos/zephyr/commit/76d0dd41f9e17ec4f599fa79b05774eaa7235a10) Bluetooth: hci_core: Exclude scan related code if non-observer
- [becbfa22](https://github.com/zephyrproject-rtos/zephyr/commit/becbfa2243d1383b18278b4eeefeddb79cc11a9e) Bluetooth: att: Do not build Signed Write cmd handler if SMP disabled
- [698311d2](https://github.com/zephyrproject-rtos/zephyr/commit/698311d2209bb77862bac24e194dd52eaec3c4d1) Bluetooth: att: Add Kconfig option to disable Multiple Read operation
- [5e3c48f4](https://github.com/zephyrproject-rtos/zephyr/commit/5e3c48f43c54c2d62c25f17b3d64c2207944c8fe) bluetooth: Make controller crypto functions optional
- [310320c4](https://github.com/zephyrproject-rtos/zephyr/commit/310320c4d173b4c8786cab2c549c9a63849d869a) Bluetooth: Mesh: Fix initialization order during node reset
- [f23e808e](https://github.com/zephyrproject-rtos/zephyr/commit/f23e808ed03d6e4cb696e52893cff806447f70dd) Bluetooth: Mesh: Fix redundant model publication clearing
- [59bbab99](https://github.com/zephyrproject-rtos/zephyr/commit/59bbab99a862210451bab1651b8f558ca8b69a6a) Bluetooth: Mesh: Fix cyclic rewriting to flash when restoring state
- [cea4b318](https://github.com/zephyrproject-rtos/zephyr/commit/cea4b31866743800b173a02effbd42a7c3b86daa) Bluetooth: controller: Add support for the nRF52810
- [fdedc49a](https://github.com/zephyrproject-rtos/zephyr/commit/fdedc49a61b1f88b9508fd6f0bb878b53979041d) Bluetooth: tests: exclude btshell/mesh_shell on NRF52810_PCA10040
- [e69b735a](https://github.com/zephyrproject-rtos/zephyr/commit/e69b735a5a4e2ec45badf3e202e05c2c7c779a32) Bluetooth: Mesh: Fix checking for model subscription address
- [387e91a7](https://github.com/zephyrproject-rtos/zephyr/commit/387e91a76b94e1deb281ee75c5362b29e419fd60) Bluetooth: Mesh: cfg_srv: Ignore Prohibited element addresses
- [8f6ebc53](https://github.com/zephyrproject-rtos/zephyr/commit/8f6ebc532272c9862c2285af08ebc5a358468f76) Bluetooth: controller: Fix LE Extended Scanner Filter Policy dependency
- [7b02e6dc](https://github.com/zephyrproject-rtos/zephyr/commit/7b02e6dc551cba9d30b29b9b6ee5ddc61ae5471d) bt: hci driver over spi: BlueNRG-MS read until IRQ pin goes low
- [b0c294ce](https://github.com/zephyrproject-rtos/zephyr/commit/b0c294ce48744d31d0ecb1c6da7519ba90b19786) bt: hci driver over spi: Configure BlueNRG-MS in controller mode
- [c6dea9e0](https://github.com/zephyrproject-rtos/zephyr/commit/c6dea9e068636b39dbe2da7ff0f80e33fe07ae10) Bluetooth: Reorganize Kconfig options for BLE controller
- [dbc00ba3](https://github.com/zephyrproject-rtos/zephyr/commit/dbc00ba37479e640f676a81d4203c6849f8a56d8) Bluetooth: controller: Fix empty_pkt_us_get for 2M phy.

Boards (33):

- [52e120ed](https://github.com/zephyrproject-rtos/zephyr/commit/52e120ed91d622eb69c41b3e100bc1502eac0edc) boards/arm: add support for udoo_neo_full_m4 board
- [8792c5c9](https://github.com/zephyrproject-rtos/zephyr/commit/8792c5c9365bb95a185c06c9c5bf42f2dd78c839) boards: intel_s1000: Config for USB PHY 2.0
- [9c619d77](https://github.com/zephyrproject-rtos/zephyr/commit/9c619d77e2355f9490f9c02752031c0f572e609e) boards: nrf: Use i2c drivers from nrfx
- [dc1c2742](https://github.com/zephyrproject-rtos/zephyr/commit/dc1c2742b677cbfde6ba6e7d20685e25c53a7c29) boards: nrf: Moved SDA and SCL pin configuration to DTS for nRF boards
- [546d19a7](https://github.com/zephyrproject-rtos/zephyr/commit/546d19a7cfaa7a2347ccae8309a418e52ade11e1) boards: nrf: Fix nrf52_pca20020 board for benchmark test.
- [f5ddc99c](https://github.com/zephyrproject-rtos/zephyr/commit/f5ddc99c4fa8589ce6915c991ce136ab0cadd82b) boards: nrf52_blenano2: Add i2c's to nrf52_blenano2 board dts.
- [0cac3630](https://github.com/zephyrproject-rtos/zephyr/commit/0cac36303b56ce3e63d8e66419ec1c5e09f1d196) boards: 96_nitrogen: Specify the IC
- [5029760c](https://github.com/zephyrproject-rtos/zephyr/commit/5029760c5378462e1596884fa63f19de4d40c955) boards: arm: Add Nordic nRF52810 board
- [21826a5a](https://github.com/zephyrproject-rtos/zephyr/commit/21826a5a7df739c9a5475bc6e7364ce8ea2e9187) boards: arm: nrf: add directive for nrf52810_pca10040 initialization
- [2b7c854a](https://github.com/zephyrproject-rtos/zephyr/commit/2b7c854a653d929dee6c2ccf83573002f9bea247) boards: arm: nrf: move LED and Button definitions in DTS
- [237aef18](https://github.com/zephyrproject-rtos/zephyr/commit/237aef18680287f4f3a2f434438edbecc06e6895) boards: arm: nrf: update I2C-related defines for nrf52810
- [fb4befb0](https://github.com/zephyrproject-rtos/zephyr/commit/fb4befb0d41b9596001f1471a689edc29c0c927a) boards: arm: nrf: select HAS_DTS_I2C for nrf52_pca10040
- [66986c69](https://github.com/zephyrproject-rtos/zephyr/commit/66986c698f10fc60f5cbf9f4bc5f08be6f26c569) boards: arm: nrf: select HAS_DTS_I2C for nrf52_blenano2
- [24047dea](https://github.com/zephyrproject-rtos/zephyr/commit/24047dea23efa9345ed60646d7d2c43db5503592) boards: arm: bbc_microbit: select HAS_DTS_I2C for bbc_microbit
- [086d839e](https://github.com/zephyrproject-rtos/zephyr/commit/086d839ea599f823529efd410f243b2a51758608) nucleo_f070rb: Enable USART1 ports on nucleo_f070rb
- [d1054f78](https://github.com/zephyrproject-rtos/zephyr/commit/d1054f78f031d7359173e14ff0d43f186145f877) nucleo_f070rb: Add JLink tools for debug and download support
- [fb0366b3](https://github.com/zephyrproject-rtos/zephyr/commit/fb0366b339ed3d93c3cb893e4f568e2296dd8d0b) boards: Kconfig: Remove redundant 'default n' properties
- [e69c0589](https://github.com/zephyrproject-rtos/zephyr/commit/e69c05895808177f92f5c5e3610b04ddf467a127) boards: arm: stm32: Basic support for STM32F746G-DISCO board
- [a603e707](https://github.com/zephyrproject-rtos/zephyr/commit/a603e7071ecb95307a0da3aa2bbb09d0b2e69777) boards: disco_l475_iot1: update BT configuration
- [093b7e9c](https://github.com/zephyrproject-rtos/zephyr/commit/093b7e9cf1acd66f6709320c3aa0877a16051a42) boards: arm: nrf52_pca10040: Enable DC/DC by default
- [d4996293](https://github.com/zephyrproject-rtos/zephyr/commit/d499629344d03dbc35b43d9ab1edeabe27f3789f) boards: arm: nrf52810_pca10040: Enable DC/DC by default
- [8d2df577](https://github.com/zephyrproject-rtos/zephyr/commit/8d2df577975b9c99c30518fb7b5da1a823ce58ee) boards: arm: nrf52840_pca10056: Align DC/DC option
- [ef33b79d](https://github.com/zephyrproject-rtos/zephyr/commit/ef33b79d5895cc1d884e60fd1dfef49193d8c9b9) boards: stm32: argonkey: Add support to led controller
- [3ed763aa](https://github.com/zephyrproject-rtos/zephyr/commit/3ed763aabe4abe5faf4c6603ee651f7ab7345833) boards: disco_l475_iot1: Move BT_SPI_BLUENRG selection to avoid warning
- [e07a1ad2](https://github.com/zephyrproject-rtos/zephyr/commit/e07a1ad2544f17a497bad56afbfce21e9f965eaa) boards: arm: stm32: basic support for STM32F723E-DISCO board
- [91220ba6](https://github.com/zephyrproject-rtos/zephyr/commit/91220ba640447b7cdb355fd8ed9ccaafa6bcd81e) boards: native_posix: Add option to build with Address Sanitizer
- [57dcb53a](https://github.com/zephyrproject-rtos/zephyr/commit/57dcb53a94ed067b2f3254cb7dd5c313d0ce10b5) boards/qemu_cortex_m3: Use SCHED_MULTIQ by default
- [fe018a87](https://github.com/zephyrproject-rtos/zephyr/commit/fe018a87162d7f4c7cd32e7c49e643b671632be1) boards: curie_ble: add board.cmake
- [157b3dcb](https://github.com/zephyrproject-rtos/zephyr/commit/157b3dcb3adc62790f3fb49cc7daa9b92f13de9d) boards: arm: add st nucleo-f207zg
- [2a490fd0](https://github.com/zephyrproject-rtos/zephyr/commit/2a490fd030af9f7f8096c2ef98cef8524038aba5) boards: Set nucleo_f429zi compatible with configuration guidelines
- [10fc37d7](https://github.com/zephyrproject-rtos/zephyr/commit/10fc37d78e44b702eb76af4ade75584655180b04) boards/shields: Add connector flags for compatibility checks
- [ff0c5a2a](https://github.com/zephyrproject-rtos/zephyr/commit/ff0c5a2afd1dcf5dbce5051620978d1bade93880) boards: nucleo_f429zi: state compatibility with Arduino connectors
- [cc5ae491](https://github.com/zephyrproject-rtos/zephyr/commit/cc5ae49133b48d4a7b3372f0bf22f942416debb7) boards: arm: stm32: basic support for STM32F769I-DISCO board

Build (17):

- [080e32ef](https://github.com/zephyrproject-rtos/zephyr/commit/080e32efc55208a1b6569691892ad960bec2a625) cmake: Using symlinks on unix like os'es for dependencies
- [8f321b48](https://github.com/zephyrproject-rtos/zephyr/commit/8f321b48acd56ad7625e7712afdefcf9fac1b295) isr_tables: Simplify how the spurious irq function address is found
- [5e7e1cba](https://github.com/zephyrproject-rtos/zephyr/commit/5e7e1cba69020aacaf1ab3c3167f2b7c4a52fce6) cmake: fix git describe command line
- [aed0b6c4](https://github.com/zephyrproject-rtos/zephyr/commit/aed0b6c4bd85f95a3efd772a6ca5b06fa428715b) isr_tables: Simplify how the sw_irq_handler function is used
- [608778a4](https://github.com/zephyrproject-rtos/zephyr/commit/608778a4de8f1441b86d03147ec61fcf7a0d98ac) cmake: Support specifying Kconfig options on the CLI
- [c1c25dea](https://github.com/zephyrproject-rtos/zephyr/commit/c1c25dea1ad3143687525f7d65c2e1d07f6cb7ee) cmake: Remove stray CMakeLists.txt file
- [1b600706](https://github.com/zephyrproject-rtos/zephyr/commit/1b6007067d801027468a6ffa7081c4ff8076d8c9) cmake: Invoke 'python' instead of py scripts directly
- [a1e806bf](https://github.com/zephyrproject-rtos/zephyr/commit/a1e806bf44178aabcff5e1ac08bb10627e4c10f2) gen_isr_tables: Delete the dead code accompanying .intList.num_isrs
- [35ec18ac](https://github.com/zephyrproject-rtos/zephyr/commit/35ec18ac08928e15be90511d7bb9659adc2ae947) genrest: Mention implicit default values
- [2bcfb88a](https://github.com/zephyrproject-rtos/zephyr/commit/2bcfb88aed3784404dde128ded470f8cd5da2186) cmake: Remove duplicate invocations of target_link_libraries on app
- [aa2beb9f](https://github.com/zephyrproject-rtos/zephyr/commit/aa2beb9f10b96b463ecca7c3972901755f920787) kconfig: Stop whitelisting "undefined symbol SSE" warning
- [6c6a6662](https://github.com/zephyrproject-rtos/zephyr/commit/6c6a66623a989ddc89bd74086490878b5282ef47) toolchain: gcc: check if __weak is defined
- [72edc4e1](https://github.com/zephyrproject-rtos/zephyr/commit/72edc4e15ff61410555073bcad626014461598b3) clang/llvm: add initial configuration file for clang
- [bebda565](https://github.com/zephyrproject-rtos/zephyr/commit/bebda565b53fdfa85918e68080e6ed8899d2f945) clang: fix for x86 iamcu
- [ff6dbc59](https://github.com/zephyrproject-rtos/zephyr/commit/ff6dbc599c999ca040e184ed1d7fb5bdac97a0a6) build: fix git describe call on older Git versions
- [347f9a0a](https://github.com/zephyrproject-rtos/zephyr/commit/347f9a0a2d560bb7c23df6f699183426693090bf) cmake: LD: Specify the entry point in the linker scripts
- [c2882410](https://github.com/zephyrproject-rtos/zephyr/commit/c2882410ed83bfce1918d53601ac1a5d67624e85) cmake: Allow C standard version to be overriden

Continuous Integration (7):

- [3efd2693](https://github.com/zephyrproject-rtos/zephyr/commit/3efd2693b3a4ebea003353e2091e52fbdf7edaa8) sanitycheck: fix spammy build output
- [90e8d678](https://github.com/zephyrproject-rtos/zephyr/commit/90e8d6784884e551a7c50e05bc485da64c97f600) check-compliance: Fix list_undef_kconfig_refs.py for external projects
- [0b685604](https://github.com/zephyrproject-rtos/zephyr/commit/0b68560463f723556e048440aec26029cdbaa215) sanitycheck: whitelist logging sections
- [7e69e9a4](https://github.com/zephyrproject-rtos/zephyr/commit/7e69e9a441380afe67b86af193883ee15173c086) ci: remove tests and samples from coverage reports
- [c026c2ed](https://github.com/zephyrproject-rtos/zephyr/commit/c026c2ed82f5a86d749335f77a2ada84fde42bb2) sanitycheck: control coverage from command line
- [1545b378](https://github.com/zephyrproject-rtos/zephyr/commit/1545b378c850996263a46dd5ce8ef0a938377cac) CI: explicitly enable compiling w coverage in sanitycheck
- [8cf49371](https://github.com/zephyrproject-rtos/zephyr/commit/8cf49371afd3cc2eca05c3cf0b4418af6c16a506) ci: use latest docker image v0.4-rc7

Device Tree (12):

- [06f4daf8](https://github.com/zephyrproject-rtos/zephyr/commit/06f4daf8479cb3a48c790007eb76ee76a084cf82) dts: add parentheses around argument in macro __SIZE_K
- [37028baf](https://github.com/zephyrproject-rtos/zephyr/commit/37028baf3870a938d71978d943c5b3ecb8a0b22f) dts/bindings: Remove redundant clock properties in st,stm32-i2c...
- [b63a5928](https://github.com/zephyrproject-rtos/zephyr/commit/b63a5928bc570033b1f9e6a713dd12186b1738ec) dts: kconfig: Remove redundant 'default n' properties
- [3d53ddd4](https://github.com/zephyrproject-rtos/zephyr/commit/3d53ddd4351b3d9c81f735d3805f17f1ee316ea1) dts/arm/st: Fix OTG_FS endpoint number for STM32F4 SoCs
- [c32681f7](https://github.com/zephyrproject-rtos/zephyr/commit/c32681f78d3c370cf76a27233e61398b23120f7f) dts: arm: st: Correct pin assignment of node usart6@0
- [9b046ec0](https://github.com/zephyrproject-rtos/zephyr/commit/9b046ec08a1ea506830b62c1370b3595be032ebd) dts/stm32: add clock property to spi nodes
- [d5100d79](https://github.com/zephyrproject-rtos/zephyr/commit/d5100d792f3a28eee54fee0e8a91bf7cecb0335c) dts/st: add clock property to i2c nodes
- [dbf11bef](https://github.com/zephyrproject-rtos/zephyr/commit/dbf11bef81cef6d62ab96ed526d8104907ca9d77) dts: stm32f7-pinctrl Add definitions for F7 USART/UARTs
- [db1075e4](https://github.com/zephyrproject-rtos/zephyr/commit/db1075e4e5930d2c651660d4a975c930935fd661) dts: Fix warning related to arm,v{6,7,8}m-nvic yaml files
- [ce983e77](https://github.com/zephyrproject-rtos/zephyr/commit/ce983e77c876bc4404b4c031fa727a160e663211) dts/arm/st: Fix I2C1 clock property
- [ebc5e51e](https://github.com/zephyrproject-rtos/zephyr/commit/ebc5e51ef6d4cc8ef7bc1010207aa099840e5f29) dts/arm/st: Fix I2C3 clock property on L0 series
- [1af5ce40](https://github.com/zephyrproject-rtos/zephyr/commit/1af5ce40cdc8b04310ec64aefcb5a2f5bd3c4431) dts/arm/st: Fix SPI1 clock property on F0 series

Documentation (15):

- [3bdb52f1](https://github.com/zephyrproject-rtos/zephyr/commit/3bdb52f1ad577b7e77b10c4cd83807196d97e479) doc: improved error reporting for non-UTF8 docs
- [934a4d2b](https://github.com/zephyrproject-rtos/zephyr/commit/934a4d2b1353896a5b362ca37273462a05caf612) doc: fix genrest.py to use utf-8 encoding
- [cf9bfb20](https://github.com/zephyrproject-rtos/zephyr/commit/cf9bfb20f1dc072cf893a79a1b2bf8d8ec6d07f6) doc: net: Add information about websocket server API
- [90380730](https://github.com/zephyrproject-rtos/zephyr/commit/90380730b3affc588d61a29ad94004fe7678e63c) doc: fix misspelling in watchdog Kconfig
- [ca16b6f8](https://github.com/zephyrproject-rtos/zephyr/commit/ca16b6f8ee3083cbce0f032832537ab6a90c71f9) doc: fix misspelling in hci API docs
- [a9e0d14b](https://github.com/zephyrproject-rtos/zephyr/commit/a9e0d14bee45670a896d04cd5205322b13f6a625) doc: fix misspelling in vlan document
- [c7388348](https://github.com/zephyrproject-rtos/zephyr/commit/c738834854849adad705dee38770aef61bd1b4a2) doc: intel_s1000: Procedure to obtain toolchain
- [00ef6b5e](https://github.com/zephyrproject-rtos/zephyr/commit/00ef6b5e3cafaaf51d5768502826badce226ec9f) doc: Enumerate threats in model
- [45745052](https://github.com/zephyrproject-rtos/zephyr/commit/457450522e7084884214589958882b75a3303c4d) doc: dt: Clarify the relationship between DT and Kconfig
- [63ef7465](https://github.com/zephyrproject-rtos/zephyr/commit/63ef746544e7da27edab7ef6294c6a0334c0a912) doc: boards: arm: Update datasheet link
- [af05ff6c](https://github.com/zephyrproject-rtos/zephyr/commit/af05ff6c55cbf90ae31e52d0c7560e0c5ff9e8bd) doc: Introduct debugging and downloading using Jlink on stm32 boards
- [8c5c111c](https://github.com/zephyrproject-rtos/zephyr/commit/8c5c111c9743d0c946e51b118d8a8833b273ba68) doc: net: Add information about gPTP
- [e1af33b4](https://github.com/zephyrproject-rtos/zephyr/commit/e1af33b4289b4c11d6f0a1fa737b7e55e8c150cc) doc: native_posix: Add paragraph about ASan
- [8c94b535](https://github.com/zephyrproject-rtos/zephyr/commit/8c94b5353a143ea0dfdaee6764735b8839003042) doc: device: dts: Fix the error in the doc.
- [e09af5f0](https://github.com/zephyrproject-rtos/zephyr/commit/e09af5f008ca19eb28c4722e5edb0faf0e3b43c6) doc: enhance cross compile section in getting started

Drivers (107):

- [a313e5c7](https://github.com/zephyrproject-rtos/zephyr/commit/a313e5c74f01750411bf65e9903278f913328585) drivers: eth: gmac: Fix cache support for SAM GMAC
- [0a6046cf](https://github.com/zephyrproject-rtos/zephyr/commit/0a6046cf316ae8037459fab06c6c0280a6107d41) drivers: eth: gmac: Ensure caches are enabled before using them
- [fab8246b](https://github.com/zephyrproject-rtos/zephyr/commit/fab8246bc5b883d3eac343d77a967487cc2fcf35) drivers: serial: simplify Kconfig.nrfx by using HAS_HW_NRF_UART0
- [e682652d](https://github.com/zephyrproject-rtos/zephyr/commit/e682652d8c7fdd30ad90b72007035732e96e9ad5) drivers: usb: Fix build error for intel_s1000.
- [1b0641e2](https://github.com/zephyrproject-rtos/zephyr/commit/1b0641e2e2e353e9a4e9ec8ec23c25779b11e2e9) drivers: usb: Add High Speed support for DesignWare USB
- [a3095087](https://github.com/zephyrproject-rtos/zephyr/commit/a3095087aac219cecbfd7301642769b3f48d0429) subsys: usb: Make HID payload size configurable
- [6f61f098](https://github.com/zephyrproject-rtos/zephyr/commit/6f61f098037b9b8b88a80d33814ecec26f112d51) drivers: can: Set a initial state to the can device before HAL_CAN_Init
- [1edc29c4](https://github.com/zephyrproject-rtos/zephyr/commit/1edc29c47f21ae5a9132db36698199f4df7f49bd) drivers: i2c: Add shims for nrfx TWI and TWIM drivers
- [1aa61d60](https://github.com/zephyrproject-rtos/zephyr/commit/1aa61d60c5363ab0f644b4967d914da3ee9e181c) drivers: i2c: Removed redundant i2c_nrf5 shim
- [5417f29d](https://github.com/zephyrproject-rtos/zephyr/commit/5417f29def9dbde6166ea31f5131c74620ee9984) drivers: plic: do not compile plic for qemu target
- [2b10dd8a](https://github.com/zephyrproject-rtos/zephyr/commit/2b10dd8a0b565ce24abe8dfe707acb29475bff16) drivers: rtc: Fix build
- [b25567ea](https://github.com/zephyrproject-rtos/zephyr/commit/b25567eab8c9954967663c7129b44fdb7639a472) usb: Allow to enable stack on native_posix arch
- [7eb05cd1](https://github.com/zephyrproject-rtos/zephyr/commit/7eb05cd11398f337b6adebb826bf27ca0c020063) usb: webusb: Correct total length
- [2be6594d](https://github.com/zephyrproject-rtos/zephyr/commit/2be6594d3f96ca697d8a8555e356971da1f8af53) usb: bos: Add linker sections for USB BOS descriptor
- [f07275e6](https://github.com/zephyrproject-rtos/zephyr/commit/f07275e6e6d23f8fd983b7086b76c03eeafdf087) usb: trivial: Remove unneeded braces
- [c1724f65](https://github.com/zephyrproject-rtos/zephyr/commit/c1724f65bfae94ff8db4ad424c170c3cfc2af32f) usb: bos: Add USB BOS descriptors API
- [c6b38a2a](https://github.com/zephyrproject-rtos/zephyr/commit/c6b38a2a865823c4cc9be45f7ff28355ccb1c5ee) usb: tests: Add usb_bos_desc to sanitycheck table
- [b9c82121](https://github.com/zephyrproject-rtos/zephyr/commit/b9c82121c6014e1db9066397206b7c4fab8f1465) usb: bos: unit: Add unit test for BOS testing
- [0d895c8a](https://github.com/zephyrproject-rtos/zephyr/commit/0d895c8aa3a1a95516304cfb9566826d8e6da209) usb: webusb: Refactor WebUSB using BOS API
- [d930c21e](https://github.com/zephyrproject-rtos/zephyr/commit/d930c21e121901fc9facbd24c44ed0e9a331c3fd) drivers: spi: Fix SPI_2_NRF_SPIS-related dependency loop
- [f6d8ab82](https://github.com/zephyrproject-rtos/zephyr/commit/f6d8ab828916fea77f1003075faad902465c4817) subsys: console: Factor out fifo-based console input abstraction
- [5acb7fc9](https://github.com/zephyrproject-rtos/zephyr/commit/5acb7fc9a9ef7b9abf11553f7ca05438b4d6426e) subsys: console: Make CONSOLE_GETCHAR and *_GETLINE optional
- [cfc18f21](https://github.com/zephyrproject-rtos/zephyr/commit/cfc18f2102d7fd1045da9a46267cdf598d128ae6) drivers: pwm: Add shim for nrfx PWM HW driver
- [23ce6f44](https://github.com/zephyrproject-rtos/zephyr/commit/23ce6f44b5b9d71134f5e5af3b3cd0b72734fc9d) drivers: flash: w25qxxdv: Add options for delay and device ID
- [5ea637d2](https://github.com/zephyrproject-rtos/zephyr/commit/5ea637d23b42aff5a6fd6656ef9270ed24242f3b) drivers: entropy: native: implement standard ISR-specific call
- [48ff1175](https://github.com/zephyrproject-rtos/zephyr/commit/48ff11752cf8a5f3ef5743151ef8083f3b6219ed) usb: webusb: Strip CDC ACM function from the code
- [c36e800e](https://github.com/zephyrproject-rtos/zephyr/commit/c36e800e8e96a881a3e4b8628502a5412c3b247e) usb: remove all CONFIG_*_EP_ADDR options
- [daef3cc5](https://github.com/zephyrproject-rtos/zephyr/commit/daef3cc5bebe99f43f48513d5d4ebff1e0ddeae5) drivers: uart: nrf: fixing hardware flow control
- [ed25a16a](https://github.com/zephyrproject-rtos/zephyr/commit/ed25a16a3b44a2e106ab77cfc9a001912ae3a29c) driver: ptp_clock: PTP clock driver definition
- [9e82ef13](https://github.com/zephyrproject-rtos/zephyr/commit/9e82ef13af27de13e5e19f3e2a526ae30bbe01e2) drivers: entropy: nrf5: Use nrf_rng hal for registers w sideeffects
- [f3d1b224](https://github.com/zephyrproject-rtos/zephyr/commit/f3d1b22487309409cdd2d737bd4b062cf10e3031) subsys: usb: Fixes USB DFU class by updating the bcdUSB value.
- [ff41ef47](https://github.com/zephyrproject-rtos/zephyr/commit/ff41ef477eac7756c850c998fcdb1567f2bbd659) drivers: eth: gmac: Cast to type expected by HAL
- [19d78035](https://github.com/zephyrproject-rtos/zephyr/commit/19d78035460638054bf6c4c182b32774f48d6d3a) drivers: sensor: Kconfig: Remove redundant 'default n' properties
- [4df673f3](https://github.com/zephyrproject-rtos/zephyr/commit/4df673f3fc6cb521f038ae56b4ea347391022071) drivers: clock_control: STM32F7 family clock control
- [cfb25c74](https://github.com/zephyrproject-rtos/zephyr/commit/cfb25c74a0cf3ab85ba73aebdbb49e4364023e7b) drivers: flash: stm32: STM32F7 flash memory suport
- [a229500d](https://github.com/zephyrproject-rtos/zephyr/commit/a229500d237d01cbc844ab9eb3e31a5c5fb598a3) drivers: gpio: stm32: STM32F7 GPIO support
- [7482969d](https://github.com/zephyrproject-rtos/zephyr/commit/7482969da6341d53a038821aeeda269b5fb45b78) drivers: pinmux: stm32: STM32F7 pinmux support
- [1fdc790c](https://github.com/zephyrproject-rtos/zephyr/commit/1fdc790ca2158b30af51df0a59b3b91a393718a3) serial: stm32: STM32F7 UART support
- [75d3d94c](https://github.com/zephyrproject-rtos/zephyr/commit/75d3d94c90a596a990f4bc26bc13e74d2e271a5a) drivers: interrupt_controller: stm32: STM32F7 EXTI support
- [5a1313f8](https://github.com/zephyrproject-rtos/zephyr/commit/5a1313f80401cfb61127fb8c360aca9e49ef9c0b) drivers: console: rtt: RTT session awareness
- [0ba41f5b](https://github.com/zephyrproject-rtos/zephyr/commit/0ba41f5b466837ae5e048dbe6f774331367ebd17) drivers: serial: Fix syntax error
- [cd0a8216](https://github.com/zephyrproject-rtos/zephyr/commit/cd0a8216e9d58d7533f0da2c9f2ac8a19ecf2970) drivers/clock_control: stm32: fix HCLK calculation when using MSI
- [964979f5](https://github.com/zephyrproject-rtos/zephyr/commit/964979f5394438c4aabf58e4b95e5ab51ba590af) usb: mark unused arguments correctly
- [197740bd](https://github.com/zephyrproject-rtos/zephyr/commit/197740bdfe3fe1d9ac00e22bfb5c20d4a65edb1b) drivers: uart: nrf: fixing interrupt driven API
- [1ce259d1](https://github.com/zephyrproject-rtos/zephyr/commit/1ce259d1491cc94b13a1fc7b2f46ef56b9bdd789) drivers: i2c: nrfx: Move device tree selection to driver Kconfig
- [ac1a9c4e](https://github.com/zephyrproject-rtos/zephyr/commit/ac1a9c4ef2cde62c4ba4b7340229770a71786b5d) drivers: led: Add LED driver support for NXP PCA9633
- [536d77ab](https://github.com/zephyrproject-rtos/zephyr/commit/536d77ab515068a4e3b18ced390197de2552a125) drivers: eth: stm32: Added missing ethernet_init() call
- [9e97e5b5](https://github.com/zephyrproject-rtos/zephyr/commit/9e97e5b5fd001aa2957b89d487c600cf0ddb1833) include: i2c: replace num_bytes type u8_t with u32_t
- [5fa89ae1](https://github.com/zephyrproject-rtos/zephyr/commit/5fa89ae16413857c72a4a71a4a07beec7f187f63) drivers: pinmux: stm32f4: Added pinmux macros for I2S master
- [06ac62ed](https://github.com/zephyrproject-rtos/zephyr/commit/06ac62ed32b07ea3685350889a4ca71c8efc7e83) usb: usb_descriptor: fix null pointer dereference
- [ec6b6c9f](https://github.com/zephyrproject-rtos/zephyr/commit/ec6b6c9f0c51a5e15ec7dd50ea8ee68f5322fe4e) eth: mcux: Add an option for randomized, but stable MAC address
- [13cb4cbb](https://github.com/zephyrproject-rtos/zephyr/commit/13cb4cbb5f29b434a0eda266b5b8f95c5c78a1a4) drivers: interrupt_controller: Remove redundant 'default n' properties
- [f7b441a8](https://github.com/zephyrproject-rtos/zephyr/commit/f7b441a8af860a3d55831d0f5f48dafe935ab347) drivers: grove: Kconfig: Remove redundant 'default n' properties
- [cddca708](https://github.com/zephyrproject-rtos/zephyr/commit/cddca70860f46d9744d02ef347d2c1dc73c68219) drivers: rtc: Kconfig: Remove redundant 'default n' properties
- [7cdd946d](https://github.com/zephyrproject-rtos/zephyr/commit/7cdd946d2d17fad5a54224bc9bb93d3edcbea7b6) drivers: usb: Kconfig: Remove redundant 'default n' properties
- [bfed59c1](https://github.com/zephyrproject-rtos/zephyr/commit/bfed59c1d4d58e574f7e7fa6ad558a6feef78478) drivers: led: Kconfig: Remove redundant 'default n' properties
- [d7fa8b25](https://github.com/zephyrproject-rtos/zephyr/commit/d7fa8b25aa88e5c9607a5bbb3ff6b13c5521994b) drivers: pinmux: Kconfig: Remove redundant 'default n' properties
- [8308a519](https://github.com/zephyrproject-rtos/zephyr/commit/8308a51930c3593c07496de4627f3f57ce04aec1) drivers: counter: Kconfig: Remove redundant 'default n' properties
- [31a0763a](https://github.com/zephyrproject-rtos/zephyr/commit/31a0763ad69bd6af24d41dbdc0f0b57dbf21e9d7) drivers: net: Kconfig: Remove redundant 'default n' properties
- [d77663ac](https://github.com/zephyrproject-rtos/zephyr/commit/d77663ac0559199e6839d4d49bfbff0763cd2f31) drivers: spi: Kconfig: Remove redundant 'default n' properties
- [04cc6bff](https://github.com/zephyrproject-rtos/zephyr/commit/04cc6bff210508103d4a7c9ddce2117e85cf2a8f) drivers: clock_control: Remove redundant 'default n' properties
- [86c46864](https://github.com/zephyrproject-rtos/zephyr/commit/86c46864eeb1cd5ec4d65ed2b1264735cd26b210) drivers: ethernet: Kconfig: Remove redundant 'default n' properties
- [00f363e4](https://github.com/zephyrproject-rtos/zephyr/commit/00f363e4c8f473787f2b1495d52b6edc24015fb9) drivers: flash: Kconfig: Remove redundant 'default n' properties
- [2713e445](https://github.com/zephyrproject-rtos/zephyr/commit/2713e445946b33089c071b7817dabdbb0b2add3d) drivers: adc: Kconfig: Remove redundant 'default n' properties
- [f30b1636](https://github.com/zephyrproject-rtos/zephyr/commit/f30b1636248432811d04a3846b93d8cee9fd9a92) drivers: pwm: Kconfig: Remove redundant 'default n' properties
- [09acea9f](https://github.com/zephyrproject-rtos/zephyr/commit/09acea9f03790e198acce4f510701a45db011aad) drivers: watchdog: Kconfig: Remove redundant 'default n' properties
- [27b9c05d](https://github.com/zephyrproject-rtos/zephyr/commit/27b9c05d4d5ed579931f154a2206967b8afcb31e) drivers: can: Kconfig: Remove redundant 'default n' properties
- [120b8fc3](https://github.com/zephyrproject-rtos/zephyr/commit/120b8fc3a61303607d27ecf4b647cf1286def61c) drivers: timer: Kconfig: Remove redundant 'default n' properties
- [133a299b](https://github.com/zephyrproject-rtos/zephyr/commit/133a299b50ed0f3e3d672238bb2dd0ac199045d2) drivers: i2c: Kconfig: Remove redundant 'default n' properties
- [f912dfeb](https://github.com/zephyrproject-rtos/zephyr/commit/f912dfebea4508abca8a3c366eaf00e958f7804b) drivers: gpio: Kconfig: Remove redundant 'default n' properties
- [a816d105](https://github.com/zephyrproject-rtos/zephyr/commit/a816d105a9568a1b660bb2661200977d0d03bfc4) drivers: crypto: Kconfig: Remove redundant 'default n' properties
- [2d50da70](https://github.com/zephyrproject-rtos/zephyr/commit/2d50da70a132d9d7c0cb8e886be55589c83b4926) drivers: ipm: Kconfig: Remove redundant 'default n' properties
- [38185db8](https://github.com/zephyrproject-rtos/zephyr/commit/38185db8fdf75af9051ce6ffd09eb0f37ed8575d) drivers: display: Kconfig: Remove redundant 'default n' properties
- [cc74397a](https://github.com/zephyrproject-rtos/zephyr/commit/cc74397a17359e35352cb677496f617c5c02fda1) drivers: dma: Kconfig: Remove redundant 'default n' properties
- [7b0f00cf](https://github.com/zephyrproject-rtos/zephyr/commit/7b0f00cf1683ff47737b6b7b2230721be0dc878b) drivers: pci: Kconfig: Remove redundant 'default n' properties
- [6d954487](https://github.com/zephyrproject-rtos/zephyr/commit/6d95448772b4f670a349f560ccecb6adc1d2cb9c) drivers: ptp_clock: Kconfig: Remove redundant 'default n' properties
- [3e0a900a](https://github.com/zephyrproject-rtos/zephyr/commit/3e0a900a3102b877d9cfdf880e0c31a9fa5869ac) drivers: bluetooth: Kconfig: Remove redundant 'default n' properties
- [21d4adef](https://github.com/zephyrproject-rtos/zephyr/commit/21d4adef9377d17dbf0e150948de455048292424) drivers: wifi: Kconfig: Remove redundant 'default n' properties
- [a81bc326](https://github.com/zephyrproject-rtos/zephyr/commit/a81bc326774391c490ab11f4f43c4d2f02a9d9b9) drivers: ieee802154: Kconfig: Remove redundant 'default n' properties
- [78fdf692](https://github.com/zephyrproject-rtos/zephyr/commit/78fdf6925da7c54f1325fcf9c5729cedad05961c) drivers: aio: Kconfig: Remove redundant 'default n' properties
- [3ec8dd57](https://github.com/zephyrproject-rtos/zephyr/commit/3ec8dd5744a964ae41211644ffa16cc4aa7eed6d) drivers: led_strip: Kconfig: Remove redundant 'default n' properties
- [00ab5ed2](https://github.com/zephyrproject-rtos/zephyr/commit/00ab5ed22aac895b491635aed9cb67bb00b9a2b2) drivers: entropy: Kconfig: Remove redundant 'default n' properties
- [dc9c0f12](https://github.com/zephyrproject-rtos/zephyr/commit/dc9c0f121159adfdb71409889d5f34f807d21d1a) drivers: i2c: Kconfig: Remove redundant 'default n' properties
- [44e5b05f](https://github.com/zephyrproject-rtos/zephyr/commit/44e5b05fb16bfe731809c07214070c95a6356a52) drivers: gpio: nrfx: Move device tree selection to driver Kconfig
- [5aa09c6b](https://github.com/zephyrproject-rtos/zephyr/commit/5aa09c6baab8f65052c58221555e483993b547cb) drivers: entropy: stm32: add support for STM32F7
- [cc419166](https://github.com/zephyrproject-rtos/zephyr/commit/cc4191666bdbf434e4b0047715fa7d7e0a55d353) i2c: stm32: check messages before starting transmission
- [81cfdec3](https://github.com/zephyrproject-rtos/zephyr/commit/81cfdec3a9df54b400368211c70a9a1494a8c3da) i2c: stm32_v2: restructure interrupt handling
- [d55a6aa3](https://github.com/zephyrproject-rtos/zephyr/commit/d55a6aa32da18b0ba2214b0d30f8c907bf4c4f53) i2c: Add new I2C Slave syscalls
- [9a73cdfe](https://github.com/zephyrproject-rtos/zephyr/commit/9a73cdfe9ecc86c7f92cd67c0d1ca1b561dc7ef6) i2c: slave: Add EEPROM I2C Slave driver
- [c7875b75](https://github.com/zephyrproject-rtos/zephyr/commit/c7875b75aa51ee60264201aa1778ceed67a04d69) i2c: stm32_v2: implement slave support
- [6e15dc78](https://github.com/zephyrproject-rtos/zephyr/commit/6e15dc789ac8119c4379981179843cfce738e4f4) usb: tests: Fix BOS test related to linker order
- [16f31f1d](https://github.com/zephyrproject-rtos/zephyr/commit/16f31f1d3c58cef59e77db6bdde96a288d8d90d4) drivers: eth: native_posix: Enable gPTP support
- [28bf2812](https://github.com/zephyrproject-rtos/zephyr/commit/28bf281231e1cd97a0fe291110c7569512f0132d) drivers: pwm: nrf: Add nrfx_pwm.c to the build when PWM_NRFX is enabled
- [7cb86893](https://github.com/zephyrproject-rtos/zephyr/commit/7cb868939793de91523512fbd3b063dfd3521f75) usb: netusb: Add ethernet_init()
- [8a75e43b](https://github.com/zephyrproject-rtos/zephyr/commit/8a75e43bad7506d131b362fc77a06a9b82ec7d51) drivers: dma_cavs: preserve DMA LLIs on stop
- [6c0d0895](https://github.com/zephyrproject-rtos/zephyr/commit/6c0d089594c63afef36f27356ad35992c68ac1ce) drivers: usb_dc_stm32: don't wait for semaphore in ISR context
- [b6da8be3](https://github.com/zephyrproject-rtos/zephyr/commit/b6da8be316a7af12795fcbd0efb5b21ad70f17ee) drivers: pinmux: stm32: STM32F7 added ETH support to pinmux
- [86de2048](https://github.com/zephyrproject-rtos/zephyr/commit/86de2048520fd2942274233a857e73c76f077b2f) drivers/dma: dma_stm32f4x: Fix Peripheral To Memory case
- [b29dabaf](https://github.com/zephyrproject-rtos/zephyr/commit/b29dabaf57eaba38dec785108584830f529a5500) drivers/dma: dma_stm32f4x: use dma_slot to select peripheral
- [6091a7fd](https://github.com/zephyrproject-rtos/zephyr/commit/6091a7fd50fbbd30ec1a76c106d912a2ab783317) drivers: clock_control: Add support for stm32f2
- [6fb7b044](https://github.com/zephyrproject-rtos/zephyr/commit/6fb7b04461177e1ac69927743870c0a99566b4c6) drivers: stm32-gpio: Provide GPIO driver for stm32f2
- [6488ab21](https://github.com/zephyrproject-rtos/zephyr/commit/6488ab21a39d8a8f4d1a5b1522de88e4acddfe7a) driver: pinmux: Add pinmux driver for stm32f2
- [dffac9ab](https://github.com/zephyrproject-rtos/zephyr/commit/dffac9ab744d97811c2dfb39f47132223b3de785) driver: interrupt_controller: Add support for stm32f2
- [bdeece01](https://github.com/zephyrproject-rtos/zephyr/commit/bdeece01b8757307f689f4d255be54788e50df10) driver: uart_stm32: add support for stm32f2 series
- [1b577524](https://github.com/zephyrproject-rtos/zephyr/commit/1b5775249d7b05b46cc6c822d8e89b257dee3a09) usb: add callback codes for Set/Clear Feature ENDPOINT_HALT
- [3a471e32](https://github.com/zephyrproject-rtos/zephyr/commit/3a471e3240552e41e89887043c2e0c6a267353db) subsys: usb: stall if there is no data buffer
- [25b0212f](https://github.com/zephyrproject-rtos/zephyr/commit/25b0212fc36a4d6414bb20f06a794ebe89f91f0f) subsys: usb: class: add loopback function

External (16):

- [1112f252](https://github.com/zephyrproject-rtos/zephyr/commit/1112f252742289e14c57b6f6c85eeb8327e48b64) ext/hal/nxp/imx: Import the nxp imx6 freertos bsp
- [13eba397](https://github.com/zephyrproject-rtos/zephyr/commit/13eba3970dfd4904afe99943c7ca5615c716d2f5) ext: nordic: Correct CMakeLists.txt
- [f0df45dd](https://github.com/zephyrproject-rtos/zephyr/commit/f0df45dd5b2d9250b863d99fe42b6f6c53defcaf) ext: hal: nordic: nrfx: Add nRF52810 configuration
- [7eb2276a](https://github.com/zephyrproject-rtos/zephyr/commit/7eb2276a4934ed5d252aa8b2abaad0c9eadc2c49) ext: stm32cube: update stm32f1xx cube version
- [5347dc1a](https://github.com/zephyrproject-rtos/zephyr/commit/5347dc1a072a7a44c1eef7812dd48a91e741cbb1) ext: stm32cube: update stm32f3xx cube version
- [176042ff](https://github.com/zephyrproject-rtos/zephyr/commit/176042ff3485a20d75496a5ad2cf419b8fe18bc1) ext: stm32cube: update stm32f4xx cube version
- [875afddb](https://github.com/zephyrproject-rtos/zephyr/commit/875afddb28f3cf5d5e2cc1d8215a448d391f6338) ext: stm32cube: update stm32f7xx cube version
- [b3127629](https://github.com/zephyrproject-rtos/zephyr/commit/b3127629c7d67db85d10fbf60816707362c63ac2) ext: stm32cube: update stm32l4xx cube version
- [e1ff7cef](https://github.com/zephyrproject-rtos/zephyr/commit/e1ff7cef127ed0ae3a6a8c7f24b3d56deeab9bdd) ext: debug: segger: Move RTT configuration to KConfig
- [e892ca08](https://github.com/zephyrproject-rtos/zephyr/commit/e892ca08f1563676b90572916af1ba823a9f39c3) ext: debug: segger: Updating Segger RTT to 6.32d
- [414291cc](https://github.com/zephyrproject-rtos/zephyr/commit/414291cc12d14265bfb0f0af4d2eb1d4dfc7daeb) ext: lib: mgmt: mcumgr: update to latest master
- [f0abb24a](https://github.com/zephyrproject-rtos/zephyr/commit/f0abb24a51bf58988e50486c7fd39e896bfe2b5d) ext: nordic: Fix PWM related nrfx_config entries for nRF52840
- [396bf477](https://github.com/zephyrproject-rtos/zephyr/commit/396bf4770b00541af75856fbecd2290696852410) hal: stm32f2x: Add HAL for the STM32F2x series
- [40f7a024](https://github.com/zephyrproject-rtos/zephyr/commit/40f7a024ce9f8f5c369c5663069a14a051a3bca2) ext: debug: segger: Fix CONFIG_SEGGER_RTT_MODE generation.
- [71ba2de7](https://github.com/zephyrproject-rtos/zephyr/commit/71ba2de75c080ce5ed65a12c4c0b928f0f2ce712) ext: stm32cube: stm32f4xx: shift I2SR field in PLLI2SCFGR register
- [9a893202](https://github.com/zephyrproject-rtos/zephyr/commit/9a8932024a0f144e4abc6c4ae967b5d5184a1f11) ext: stm32cube: stm32f7xx: shift I2SR field in PLLI2SCFGR register

Firmware Update (2):

- [cd1111e1](https://github.com/zephyrproject-rtos/zephyr/commit/cd1111e16f6f5edb48e23a5d8acd9dd54727bd97) mgmt: Reduce net_buf user data requirement
- [4535b944](https://github.com/zephyrproject-rtos/zephyr/commit/4535b9443d9c5b06dd99b9df3c9892cdc2861e20) subsys: dfu: img_util: Fix warning with ERR log

Kernel (11):

- [92b8a41f](https://github.com/zephyrproject-rtos/zephyr/commit/92b8a41f206e5aec50eda784d4479ff533d64f29) include: create kernel_includes.h header to hold kernel includes
- [7727d1a4](https://github.com/zephyrproject-rtos/zephyr/commit/7727d1a48e18519f6f62061ace69b69dfd37926c) kernel: Kconfig: Remove redundant 'default n' properties
- [80e6a978](https://github.com/zephyrproject-rtos/zephyr/commit/80e6a978a663509896947517612c4245bcc11e51) kernel/drivers: fix compile warnings
- [d4dd928e](https://github.com/zephyrproject-rtos/zephyr/commit/d4dd928eaa3ecab05e5d11d90b15edebc7a01b06) kernel/stack: Introduce K_THREAD_STACK_LEN macro
- [225c74bb](https://github.com/zephyrproject-rtos/zephyr/commit/225c74bbdfae09984d31233299dabcbcca625406) kernel/Kconfig: Reorgnize wait_q and sched algorithm choices
- [9f06a354](https://github.com/zephyrproject-rtos/zephyr/commit/9f06a3545044110ec5666f764b041aa1aac216a6) kernel: Add the old "multi queue" scheduler algorithm as an option
- [fe2ac39b](https://github.com/zephyrproject-rtos/zephyr/commit/fe2ac39bf23fafd6a8e466401504859f24809049) kernel: Cleanup _ms_to_ticks().
- [e995c27b](https://github.com/zephyrproject-rtos/zephyr/commit/e995c27b426280f43dede60fa1d696560e76c459) kernel: Do not use fixed list of "good" sys_clock_ticks_per_sec values.
- [91fe22ec](https://github.com/zephyrproject-rtos/zephyr/commit/91fe22ec7d630d17c570b126db915c3a9099c077) kernel: Improve tick <-> ms conversion.
- [77f42f83](https://github.com/zephyrproject-rtos/zephyr/commit/77f42f8312605b3f4bb84f1d4538d77afe265102) kernel: Move _ms_to_ticks() and __ticks_to_ms() close to each other.
- [3808ca8e](https://github.com/zephyrproject-rtos/zephyr/commit/3808ca8e6e98fdffe97c2f0ee85bfdc8e92f2f3f) syscall: Add support for syscall_ret64_arg2

Libraries (3):

- [2d71236a](https://github.com/zephyrproject-rtos/zephyr/commit/2d71236a36fcb37b34ae2a54840b1e19db947b55) lib: libc: minimal: Get rid of the bit (256-byte) charmap table
- [0785b79e](https://github.com/zephyrproject-rtos/zephyr/commit/0785b79ebe1af39725446fbd2984f30cf6dbf3bd) lib: kconfig: Remove redundant 'default n' properties
- [5193b557](https://github.com/zephyrproject-rtos/zephyr/commit/5193b5576fbe316efc43382347dfa3a6c44b03d5) lib: posix: Fix Out-of-bound write to char array

Maintainers (1):

- [567be49a](https://github.com/zephyrproject-rtos/zephyr/commit/567be49aa9d16d33255b38d7bbac03cbc1a0c8f4) CODEOWNERS: fix due to username change

Miscellaneous (4):

- [7a7e4f58](https://github.com/zephyrproject-rtos/zephyr/commit/7a7e4f58320c436d177a2b30a4dbc47ff84c6614) misc: kconfig: Remove redundant 'default n' properties
- [b26ca136](https://github.com/zephyrproject-rtos/zephyr/commit/b26ca136726aee3927c50b17241405fa93b36b64) shell: Fix command completion logic
- [bbeef415](https://github.com/zephyrproject-rtos/zephyr/commit/bbeef4155c53c3e3bfd4340fd7a58076ddf71255) logging: subsystem major redesign
- [fdecc2b2](https://github.com/zephyrproject-rtos/zephyr/commit/fdecc2b2a77b5eeabeebe04362edc0abe11f4ab1) mailmap: add entry for ruuddw

Networking (50):

- [e6a746ea](https://github.com/zephyrproject-rtos/zephyr/commit/e6a746ea6f2b409c85633ded670c9d907cd9085e) net: ieee802154: fix csma-ca backoff
- [c60df131](https://github.com/zephyrproject-rtos/zephyr/commit/c60df131101a4cd288a6b16e419f9d3abe4e3198) net: app: Split code for configuring network to a separate lib, "config"
- [83b3f84d](https://github.com/zephyrproject-rtos/zephyr/commit/83b3f84d6f3cc52bc2fc90e11e4ed5662f9c592a) net: lib: app: Convert CMakeLists.txt to avoid library
- [580596c3](https://github.com/zephyrproject-rtos/zephyr/commit/580596c30a8c9e7e5c075daad4c828cca2433da4) net: if: Add TX timestamp callback support
- [23526e4f](https://github.com/zephyrproject-rtos/zephyr/commit/23526e4f93954af7d1b8ed00afbf37de53261e0f) net: if: vlan: Implement packet priority to PCP conversion
- [59df651c](https://github.com/zephyrproject-rtos/zephyr/commit/59df651ceea25737f03610e53f1221f91a176de7) include: Remove unused header
- [099fe7b9](https://github.com/zephyrproject-rtos/zephyr/commit/099fe7b98f3b0980c51223e0a91ee80a0e4832dd) net/ethernet: Let's use the same parameter names everywhere
- [8ae6bad2](https://github.com/zephyrproject-rtos/zephyr/commit/8ae6bad21d807f34aa37dc408fee34a3dacf9d8a) net: l2: Move the layer 2 code into subsys/net/
- [98238527](https://github.com/zephyrproject-rtos/zephyr/commit/982385277b9ce2cdfed13b7602da967bde1cecc9) net: buf: Make net_buf_user_data() parameter const
- [45b06a25](https://github.com/zephyrproject-rtos/zephyr/commit/45b06a252f93211fe4c31c7b11acd1a0b2560ff3) net: gptp: Initial core IEEE 802.1AS support
- [066edbb2](https://github.com/zephyrproject-rtos/zephyr/commit/066edbb23322de497c42c0cf8e129f17f8faf3a1) net: shell: Add gptp command
- [89eeba42](https://github.com/zephyrproject-rtos/zephyr/commit/89eeba4250049a54a2a9ee720221b4258cea399c) net/arp: No need to expose publicly arp header
- [0025a3fc](https://github.com/zephyrproject-rtos/zephyr/commit/0025a3fce262ea03eb923e389d69b54e425edda2) net/arp: Optimize ARP table by switching to various single list
- [35a7804c](https://github.com/zephyrproject-rtos/zephyr/commit/35a7804cdfe9fb8de62834b6b728ede928e12cdb) net/arp: Centralize ARP request timeout through one k_delayed_work
- [2df23f56](https://github.com/zephyrproject-rtos/zephyr/commit/2df23f567b1d921d44163c3143ffdc0d1d3dae85) net/arp: Let's reduce the size of each ARP entry
- [922d63ce](https://github.com/zephyrproject-rtos/zephyr/commit/922d63cee5813be11e50c042c74f1e70800a8a89) net/arp: Normalize all function names
- [837ed14a](https://github.com/zephyrproject-rtos/zephyr/commit/837ed14a0d58f517dfda802d4481c10a0b6f077b) net: llmnr: Add link-local mcast name resolution client support
- [b833d010](https://github.com/zephyrproject-rtos/zephyr/commit/b833d010eb5809fe0a94b727fc4df65175c5cf70) net: llmnr: Add LLMNR responder support
- [a8d4b324](https://github.com/zephyrproject-rtos/zephyr/commit/a8d4b32412529b24771ebf15fa53f628d27ec82e) net: fix header guard
- [0738ab3e](https://github.com/zephyrproject-rtos/zephyr/commit/0738ab3e09a427102496855854b099963fe0e1f0) net: shell: Check link address when printing iface info
- [68f7e969](https://github.com/zephyrproject-rtos/zephyr/commit/68f7e969166cd754c103d9c413c209420445770d) net/ipv4: Properly separate what belongs to ipv4 from the rest
- [d309c870](https://github.com/zephyrproject-rtos/zephyr/commit/d309c870c7fca7244119c5eac8dae62a405aa2b1) net/ipv6: Properly separate what belongs to ipv6 from the rest
- [c89a06db](https://github.com/zephyrproject-rtos/zephyr/commit/c89a06dbc1ca3443821762b06f3073343a984b08) net: config: Introduce a dedicated header for the library
- [7ba7119f](https://github.com/zephyrproject-rtos/zephyr/commit/7ba7119f82b9ae3ccd6d6e5ee4025986667505e8) net: l2: Fixed wifi can not connect to open AP.
- [70b60cca](https://github.com/zephyrproject-rtos/zephyr/commit/70b60cca1d52b7607d9d7e4bdc6b08865d2348d7) net: gptp: Set priority of the sent gPTP packets
- [cf272e66](https://github.com/zephyrproject-rtos/zephyr/commit/cf272e6667f37b8613786a606eeb32773a74a88f) net: gptp: Use the ptp clock instead of zephyr uptime
- [b422d386](https://github.com/zephyrproject-rtos/zephyr/commit/b422d38650b265cad645471d89f200a18a4ca524) net: gptp: Fix sync follow up packets content
- [7e545c99](https://github.com/zephyrproject-rtos/zephyr/commit/7e545c998c78e079129c1fa2b61d4c998c9b6274) net: gptp: Do not handle multiple pdelay requests at once
- [93fe54d1](https://github.com/zephyrproject-rtos/zephyr/commit/93fe54d14878fe466cd830df2a0d1d4fc487c843) net: gptp: Fix sync timestamp callback registration
- [5e3ea84e](https://github.com/zephyrproject-rtos/zephyr/commit/5e3ea84e64b0d9acd7433d4c068df7a11b7f3498) net: gptp: Use calculated neighbor ratios only once
- [f3146c09](https://github.com/zephyrproject-rtos/zephyr/commit/f3146c09ab19f5dc76257028e1c840fd39ac34ba) net: gptp: Fix buf leak in PDELAY_REQ send
- [58e40cb0](https://github.com/zephyrproject-rtos/zephyr/commit/58e40cb029d55306afd1fcb835e0572b1c561698) net: gptp: Fix shell statistics output
- [2b6e70d1](https://github.com/zephyrproject-rtos/zephyr/commit/2b6e70d10d941862d8f681c80cfd71c6070cc116) net: icmpv4: Merge process_icmpv4_pkt() into net_icmpv4_input()
- [dadc5293](https://github.com/zephyrproject-rtos/zephyr/commit/dadc5293aa5a61e190e096d39cd71e64808ebb30) net: icmpv4: Simplify the flow at net_icmpv4_get_hdr()
- [3fd2d53e](https://github.com/zephyrproject-rtos/zephyr/commit/3fd2d53e5696198f7d51cefbae42be83c27fc013) net: mgmt: Add VLAN enabled / disabled event support
- [65b15c32](https://github.com/zephyrproject-rtos/zephyr/commit/65b15c322699cc024b2371cb485ca1e7b7cbbb12) net: eth: Add helper to return VLAN info for an interface
- [e9228a39](https://github.com/zephyrproject-rtos/zephyr/commit/e9228a396449fd63850633d1edfa0c6c4eb4790b) net: gptp: Allow gPTP to run over VLAN
- [5356ee5d](https://github.com/zephyrproject-rtos/zephyr/commit/5356ee5d20172651138f2df2e73da7fb9806b44c) net: gptp: Init only the ports we have configured
- [b51f1ccc](https://github.com/zephyrproject-rtos/zephyr/commit/b51f1ccce840c270a3a18cbf90e746b7cc01616d) net: gptp: Fix validation of non-numeric inputs from net shell
- [214aebc6](https://github.com/zephyrproject-rtos/zephyr/commit/214aebc6e118f81d9766573c480dbf9562ca349c) net: gptp: Fix gptp port number validation
- [fb6223b8](https://github.com/zephyrproject-rtos/zephyr/commit/fb6223b89338a0bf00edfec47a4acb10963345f2) net: gptp: Drop the older pdelay req after receiving a new one
- [65e9177a](https://github.com/zephyrproject-rtos/zephyr/commit/65e9177a27af8bbee033bcafa2d1ae3c52edb3eb) net: gptp: Print port state change information
- [2ca3b1e3](https://github.com/zephyrproject-rtos/zephyr/commit/2ca3b1e3c46677f29b6065e926b424af0929c934) net: if: Fix TX timestamp callbacks invocation
- [fd62617c](https://github.com/zephyrproject-rtos/zephyr/commit/fd62617ce202f1ddb5bd76be607b7d70567cba8a) net: gptp: Fix memcpy calls on arrays
- [1a0968bd](https://github.com/zephyrproject-rtos/zephyr/commit/1a0968bd749a253725f4bce7d79a29b6275f386b) net: gptp: Normalize seconds and nanoseconds differences
- [22ba08fa](https://github.com/zephyrproject-rtos/zephyr/commit/22ba08faa338afa89d4bf2b0e7f024d36e201e42) net: gptp: Send Announce messages with correct GM info
- [226fa973](https://github.com/zephyrproject-rtos/zephyr/commit/226fa97304ec09d209edabdede2b77c419f57bd3) net: ethernet: Add 802.1Qav settings to eth mgmt api
- [37125781](https://github.com/zephyrproject-rtos/zephyr/commit/37125781aa8f0814de19a753aff2685cf5ca870d) net: gptp: Fix debug prints and use correct modifier
- [354c50e8](https://github.com/zephyrproject-rtos/zephyr/commit/354c50e8ed5bb11c289a58e1b367f3d3ded6778e) net: add bound checking in net_addr_pton()
- [48802024](https://github.com/zephyrproject-rtos/zephyr/commit/48802024f2ffaaa8699bcfe36374530307a9c6dd) net: icmpv4: Set the ICMPv4 header correctly

Samples (21):

- [11cb462d](https://github.com/zephyrproject-rtos/zephyr/commit/11cb462df59c053d7297a9a8c8d306f809cd2d8b) samples: mesh/onoff_level_lighting_vnd_app: States binding corrections
- [3c6eb7d0](https://github.com/zephyrproject-rtos/zephyr/commit/3c6eb7d024828b590242f7aa0b55180c36e9b4f6) samples: smp_svr: Disable GATT Multiple Read
- [f01b8173](https://github.com/zephyrproject-rtos/zephyr/commit/f01b81731bd92c9ee96a7f001790e0669a71eb01) samples: net: Socket based echo_client
- [b8135020](https://github.com/zephyrproject-rtos/zephyr/commit/b813502077627ee0a7ee7402aadcb6dbf549fe18) samples: net: Socket based echo_server
- [67b4c5d5](https://github.com/zephyrproject-rtos/zephyr/commit/67b4c5d5d4a804bf437e3059dff9ac4a3b28af87) samples: net: gptp: Sample application for gPTP support
- [3a7d4ef4](https://github.com/zephyrproject-rtos/zephyr/commit/3a7d4ef4cbd63c11fd118e4686d808070075ac29) samples: subsys: logging: Add logger example
- [f4715151](https://github.com/zephyrproject-rtos/zephyr/commit/f47151513ce56c6078f42644c3a8a4d467736f3b) samples: net: dns: Add LLMNR client support to DNS resolver
- [f8c6894f](https://github.com/zephyrproject-rtos/zephyr/commit/f8c6894f154f90ee7005a528e6806130b02a68d6) samples: net: dns: Cross reference mDNS config option
- [8fe9f432](https://github.com/zephyrproject-rtos/zephyr/commit/8fe9f432d29d7c1a5851c8808ccbc1e8a43a5438) samples: sysview: limit to systems with enough ram
- [b3e7a8f6](https://github.com/zephyrproject-rtos/zephyr/commit/b3e7a8f67bb3b9fccb702886f9ca01b8d2c4d6e4) samples: mesh/onoff_level_lighting_vnd_app: update publication context
- [54df5b51](https://github.com/zephyrproject-rtos/zephyr/commit/54df5b519a5b0e6d0081583dccaec33a986794a4) samples: mesh/onoff_level_lighting_vnd_app: update handlers mapping
- [34d475ff](https://github.com/zephyrproject-rtos/zephyr/commit/34d475ff4e8e26e2ab251fbebe66f5bfc1c6c7b6) samples: mesh/onoff_level_lighting_vnd_app: fix bug in state binding
- [e8ddd6de](https://github.com/zephyrproject-rtos/zephyr/commit/e8ddd6def86973ed8ab8eada19f4f5cbe2aa8c20) samples: mesh/onoff_level_lighting_vnd_app: edited message handlers
- [2ef1e726](https://github.com/zephyrproject-rtos/zephyr/commit/2ef1e7260788e31420481111bb0a3e19495b3caa) samples: drivers: Add sample application for PCA9633
- [a7e2c58a](https://github.com/zephyrproject-rtos/zephyr/commit/a7e2c58af5088118aed6d73d16f74cfade7aa654) samples: sysview: Update memory requirements
- [2ad2d07c](https://github.com/zephyrproject-rtos/zephyr/commit/2ad2d07ce8e284773299c299df38809b2acee737) samples: board: 96b_argonkey: Add testing of 12 on-board leds
- [ad150569](https://github.com/zephyrproject-rtos/zephyr/commit/ad150569b6646b29de35e15bef607f0a84e59b43) samples: net: gptp: Allow running gPTP over VLAN
- [0febf03d](https://github.com/zephyrproject-rtos/zephyr/commit/0febf03dc87f786d99c0864947f872b8c729c0d5) samples: mesh/onoff_level_lighting_vnd_app: Vendor Model upgrade
- [182be3b4](https://github.com/zephyrproject-rtos/zephyr/commit/182be3b49a3ee5e805cd04ce5372b2946f9d0822) samples: mesh/onoff_level_lighting_vnd_app: fix buffers length
- [31cf5672](https://github.com/zephyrproject-rtos/zephyr/commit/31cf5672dc4fd5794c8bf03d99584181872e9f84) samples: mesh/onoff_level_lighting_vnd_app: corrected printk message
- [c789662f](https://github.com/zephyrproject-rtos/zephyr/commit/c789662f77086cab1f1ffaf3b7b7eb77a87deaf4) samples: mesh/onoff_level_lighting_vnd_app: improved state binding

Scripts (8):

- [54a5997f](https://github.com/zephyrproject-rtos/zephyr/commit/54a5997f5c604d02f2999e20aac114d416938e3e) kconfiglib: Add dependency loop detection
- [d317a0e6](https://github.com/zephyrproject-rtos/zephyr/commit/d317a0e6b4b28f1152988f167f2d22f753b307a2) kconfiglib: Update to use redesigned 'referenced' API
- [60e97de5](https://github.com/zephyrproject-rtos/zephyr/commit/60e97de58321adf6febd0aec5c35938511c92a2b) scripts: runner: nrfjprog: Allow specifying serial number of nrfjprog
- [08216f5e](https://github.com/zephyrproject-rtos/zephyr/commit/08216f5ef4364faca18015efe41ff85bbf39f2e2) scripts: extract_dts_includes.py: refactor for better maintenance
- [53f41890](https://github.com/zephyrproject-rtos/zephyr/commit/53f4189075fd3a28548228973b21a6ce8c07e397) scripts: kconfig: Do not print warnings for choice overriding
- [ca7fc2ad](https://github.com/zephyrproject-rtos/zephyr/commit/ca7fc2adbc8e8865bd576de16567e09fc2202fed) scripts: extract_dts_includes.py: fix false info message
- [fa5d6ec3](https://github.com/zephyrproject-rtos/zephyr/commit/fa5d6ec36399d7a58c2202b1687fc0c049f027e8) scripts: devicetree.py: get alternate labels from dt
- [deb0941c](https://github.com/zephyrproject-rtos/zephyr/commit/deb0941cd532da1b2685ccb0692fc7c0e0551c91) scripts/extract/globals: treat node alternate names as 'aliases'

Testing (23):

- [064608b4](https://github.com/zephyrproject-rtos/zephyr/commit/064608b4295f60e962bf9fd7b33a2fd970158b69) include: remove unused macros from include/arch/*/arch.h
- [c6336371](https://github.com/zephyrproject-rtos/zephyr/commit/c63363711d50276251c38859f2a02d4fcbefe5c2) tests: net: Add unit test for network pkt timestamping
- [34e11f0c](https://github.com/zephyrproject-rtos/zephyr/commit/34e11f0c45c401c0cf61f72648b186a9f12b7ee0) tests: kconfig: Remove redundant 'default n' properties
- [6eeeb2a3](https://github.com/zephyrproject-rtos/zephyr/commit/6eeeb2a3e5795a5e30c15ee4ee5d8f8015b23011) tests: Fix sizing for several test for chips with 24KB of RAM
- [c4123643](https://github.com/zephyrproject-rtos/zephyr/commit/c4123643b5ae527da3a442de9bbe16d5fa516eff) tests: fp_sharing: Extract x86 configs to separate .conf
- [2c8c1310](https://github.com/zephyrproject-rtos/zephyr/commit/2c8c1310fbbed3eceb48b04665154a71b7db5dd0) tests: net: ptp: Add ptp clock driver tests
- [c52439a6](https://github.com/zephyrproject-rtos/zephyr/commit/c52439a6f40b3f2fe6b7e68a51b4a7c8bbfdc854) tests: ztest: fixed off-by-one in sys_bitfield_find_first_clear
- [80e02a93](https://github.com/zephyrproject-rtos/zephyr/commit/80e02a93d3ff294289f3ca6c6fb8b8f4aefed568) tests: ztest: added test case for multiple mock expects
- [2b02f8d3](https://github.com/zephyrproject-rtos/zephyr/commit/2b02f8d316b75c6182189a9af3a84e2a9c9e77f8) tests: sprintf: suppress Wformat-truncation warning
- [0b00493d](https://github.com/zephyrproject-rtos/zephyr/commit/0b00493d864b34b201a9d070e9d0b499c697850a) tests: drivers: adc: fix failing test for frdm_k64f
- [17ae882b](https://github.com/zephyrproject-rtos/zephyr/commit/17ae882b43010f401ef44665562e8b59775a3269) tests: subsys: logging: Add tests for log_msg and log_list
- [1a125714](https://github.com/zephyrproject-rtos/zephyr/commit/1a125714828a751b2c6f931beb4b3a375af237dc) tests/net: Fix L2 directory lookup for header inclusion
- [9127c4b3](https://github.com/zephyrproject-rtos/zephyr/commit/9127c4b3b1bd55113360f952a470d274cb4b3ee9) tests: Cleanup converting int result to string
- [305ec675](https://github.com/zephyrproject-rtos/zephyr/commit/305ec6751b40863b73a749c1d22d090ccab3fe54) tests: fix struct initialization
- [dd33b37e](https://github.com/zephyrproject-rtos/zephyr/commit/dd33b37eff4da7eedf67851eed4970c6ed2b3c2d) tests/sched/scheduler_api: samples/philosophers: Use SCHED_SCALABLE
- [94d31565](https://github.com/zephyrproject-rtos/zephyr/commit/94d3156540d27392236044eebcb4c3a6e6065185) test: i2c: Add i2c_slave_api test
- [482865c4](https://github.com/zephyrproject-rtos/zephyr/commit/482865c4c44c3e91f28017e404e94980cca1412c) tests: net: ptp: Make sure we check clock increment properly
- [8a74e705](https://github.com/zephyrproject-rtos/zephyr/commit/8a74e7056dc6e405b1336e047957d143af5b72d9) tests: ztest: ztest_mock to support multiple calls to same mock
- [b4dae007](https://github.com/zephyrproject-rtos/zephyr/commit/b4dae007410d7a6cee9b6ca42686cb967f82e836) tests: net: tx_timestamp: Check max number of interfaces
- [01c11c17](https://github.com/zephyrproject-rtos/zephyr/commit/01c11c172a1c025cc348bb432883aabd6cbc41be) tests: net: Add 802.1Qav test
- [2f5fea0e](https://github.com/zephyrproject-rtos/zephyr/commit/2f5fea0eec96c25cea8c1455e647131fa0d2d7ac) benchmarks: app_kernel: Fixed coverity issue.
- [0de49e5d](https://github.com/zephyrproject-rtos/zephyr/commit/0de49e5d402eaf7cbcb6e121f90c827ac4dd49dc) tests: kernel: Add description for test case
- [f5ec5674](https://github.com/zephyrproject-rtos/zephyr/commit/f5ec56747ea19d3f51e24e0e4610fa3a20711c78) tests: net: trickle: Initialize test variables earlier