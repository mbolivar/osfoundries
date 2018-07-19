+++
title = "microPlatform update 0.24"
date = "2018-07-12"
tags = ["linux", "zephyr", "update", "cve", "bugs"]
categories = ["updates", "microPlatform"]
banner = "img/banners/update.png"
+++

# Summary

## Zephyr microPlatform changes for 0.24

New console and logging implementations for Zephyr, and an MCUboot
heading to v1.2.0.


## Linux microPlatform changes for 0.24

No significant changes have gone into this update. The previous update
included updates to containers and the sources weren't published. The
URL used for authentication in lmp-device-register was updated.

<!--more-->
# Zephyr microPlatform

## Summary

New console and logging implementations for Zephyr, and an MCUboot
heading to v1.2.0.

## Highlights

- Zephyr from v1.13
- MCUboot based on the 1.2.0 release candidate series
- Minor cleanups to the sample applications

## Components


### MCUboot


#### Features

##### New default PEM file selection: 
- For Zephyr, the default signature file is now set to
the root-rsa-2048.pem file in the root of the MCUboot
project.  This avoids a cryptic error when compiling
MCUboot out-of-the-box.


##### Temporarily enable IRQs in boot_uart_fifo_init(): 
- Due to recent scheduler changes, if
CONFIG_MULTITHREADING is disabled, main() is called
with interrupts locked.  Nordic has introduced a
temporary patch for boot_uart_fifo_init() which
unconditionally enables interrupts to allow the serial
recovery mode UART to receive characters. This change
will be reverted when the issue in Zephyr is
addressed.


##### CONFIG_SYS_POWER_MANAGEMENT disabled by default: 
- Power management requires multithreading and other
kernel features that are disabled in MCUboot, so
it was disabled to avoid interrupts being confused.


##### Use of k_fifo replaced with sys_slist: 
- The k_fifo_* primitives are not available when
multithreading is disabled, and were replaced with
sys_slist_* equivalents.


##### Several changes to serial boot support: 
- The serial boot common code was refactored to allow
better platform abstraction, text size reductions and
fixed unit tests for MyNewt.  A buffer overflow, build
issues with ECDSA enabled, and a left over timer
getting triggered post image load were also addressed.


#### Bugs

##### Zephyr build fix with ECDSA: 
- A Zephyr build error with ECDSA enabled was fixed.



##### Several __ASSERT() checks fixed: 
- When CONFIG_MCUBOOT_SERIAL was enabled, several
__ASSERT() checks were looking for incorrect
values. This has been fixed.



### Zephyr


#### Features

##### Redundant "default n" removed from Kconfig: 
- A series of Kconfig-related patches removed all
redundant default "n" settings across the entire
Zephyr tree.  This change *shouldn't* affect behavior;
however, it will make any out of tree patches
affecting Kconfig files a bit more difficult to merge
for this cycle.


##### Console subsystem refactoring: 
- The console driver/subsystem went through a fairly
large refactor to remove the dependency on a FIFO-
based console input abstraction. This allows
supporting Segger's RTT technology as a console
backend. The CONFIG_CONSOLE_PULL knob was renamed to
CONFIG_CONSOLE_SUBSYS as part of these changes. This
signifies that the subsystem is intended to cover all
of Zephyr's console handling (existing and new).
Applications using the old configuration name will
need updates.


##### Arches: 
- Initial Cortex M4 support was added for the i.MX
6SoloX SoC. It's a hybrid multi-core processor
composed by one Cortex A9 core and one Cortex M4 core.
The low level drivers come from the NXP FreeRTOS BSP
and are located at ext/hal/nxp/imx.  More details can
be found in ext/hal/nxp/imx/README.

Microsemi Mi-V RISC-V softcore CPU support was added
for running on the M2GL025 IGLOO2 FPGA development
board.  This required moving some code from the fe310
platform into the RISC-V privilege common folder.

Zephyr support was added for Nordic's nRF52810 SoC.
This is a low-cost variant of the nRF52832, with a
reduced set of peripherals and memory. Since Nordic
does not offer a development kit for the nRF52810, the
nrf52810_pca10040 board definition can be used with
the nRF52832-DK (nrf52_pca10040).  Using this board
definition enforces the limitations imposed by the
nRF52810 IC. For more information, see:

http://www.nordicsemi.com/eng/Products/nRF52810

An nRF5x peripheral list was created that can be used
to describe each nRF5x SoC. Kconfig can use this
description to help configure only drivers that are
available for a particular SoC.

Support was added for the STM32F7 and STM32F2 series
of STM32 SoCs. This includes clock control, entropy,
GPIO, flash, pinmux, and UART drivers, as well as
several device trees and board definitions for STM32F7
Discovery, STM32F207XG, and STM32F207XE development
hardware.

The ESP32 IDF bootloader now has a Kconfig option for
compilation during the Zephyr build.  At flash time,
the bootloader will be flashed with the Zephyr image.

Nordic and STM32 SoCs can now use Segger's RTT
protocol for console output, in addition to UART.


##### Bluetooth: 
- Controller support was added for the Nordic nRF52810.

A new Bluetooth Mesh node sample was added in
samples/boards/nrf52/mesh/onoff_level_lighting_vnd_app.
It demonstrates several generic and light models.

The BLE controller Kconfig options were reorganized.
CONFIG_BT_CTLR means that a controller is implemented,
with additional options (currently just
CONFIG_BT_LL_SW) selecting a specific implementation.
This allows adding alternative controller
implementations in the future.

If the Bluetooth device is neither an observer or has
central role selected, the scan related code is
excluded from the HCI core. This results in smaller
image sizes for peripheral- or broadcasting-only
roles.

A Kconfig option "CONFIG_BT_CTLR_CRYPTO" was added to
allow flexibility in choosing to use host
cryptographic functions or the ones provided by the BT
controller.


##### Boards: 
- A new "shields" configuration was added to establish
connector flags for compatibility checks.  Arduino
compatible serial, I2C and SPI were the first shield
compatibility additions, with ST's nucleo_f429zi board
making use of them.  Expect more on this front as time
goes on.

Several new boads were added: i.MX's UDOO Neo Full SBC
and ST's STM32F746G-DISCO, STM32F723E-DISCO and
STM32F769I-DISCO.

The I2C ports of several nRF-based boards were
enabled.


##### Build: 
- An LLVM backend and a clang toolchain variant were
added to support building with llvm (included with
many popular Linux distributions). Initial testing was
done on quark_d2000_crb and
quark_se_c1000_devboard/Arduino 101. To enable this,
set ZEPHYR_TOOLCHAIN_VARIANT to "clang" in your
environment.

Architectures, boards, and apps can now override the C
standard version, which was previously set to
-std=c99.  Currently, the native POSIX port uses this
feature in boards/posix/native_posix/CMakeLists.txt,
like so:

set_property(GLOBAL PROPERTY CSTD c11)


##### Device Tree: 
- Nordic boards moved I2C enablement, SDA and SCL pin
configuration, and LED / button definitions into DTS.

STM32F7-pinctrl added definitions for USART/UARTs.


##### Documentation: 
- Information about the websocket server API was added
to Zephyr's documentation. For details, see:

http://docs.zephyrproject.org/api/networking.html#websocket

Intel S1000 developers will be happy to note that the
docs now include instructions for obtaining the
toolchain from:

https://tensilicatools.com/platform/intel-sue-creek

As part of Zephyr's security development process,
certain external requirements require justification
that threats in a threat model have been mitigated. To
make this process traceable, the threats must be
enumerated and given labels. For this purpose, labels
were added to the threats in Zephyr's sensor threat
model. See the model itself for more details:

http://docs.zephyrproject.org/security/sensor-threat.html

Ever wonder how DTS relates to Kconfig options? Wonder
no more! Some clarification was added to the Device
Tree documentation:

http://docs.zephyrproject.org/devices/dts/device_tree.html#dt-vs-kconfig

The "Getting Started" document did not clearly state
how to use a custom cross compiler.  This was remedied
with a new section "Using Custom Cross Compilers".
For details, see:

http://docs.zephyrproject.org/getting_started/getting_started.html

Information on the newly-supported gPTP protocol was
added to the networking documentation.


##### Drivers: 
- STM32F2 and STM32F7 received clock_control, flash,
GPIO, pinmux, UART, entrophy and interrupt_controller
drivers.

The native POSIX Ethernet driver now has support for
gPTP.

A generic I2C EEPROM slave driver was added.

USB drivers received several additions, such as high-
speed support for DesignWare USB controllers, and an
API for USB BOS (Binary Object Store) descriptors.

USB HID payload size is now configurable via
CONFIG_USB_HID_MAX_PAYLOAD_SIZE (the previous value of
64 is still the default).

Shims for nRFx TWI, TWIM and PWM drivers were added
and the now redundant i2c_nrf5 shim was removed.

A PTP clock driver was introduced which can be
implemented in those network interface drivers that
provide gPTP support.

An LED driver for NXP PCA9633 (I2C 4-bit LED) was
added which supports a blink period from 41ms to
10667ms and a brightness value from 0 to 100%.


##### External: 
- The NXP iMX6 FreeRTOS BSP was imported to add Zephyr
support on iMX6SX processors (exclusively on the
Cortex M4 core), and to speed up the development
process.

The Nordic nRFX HAL was updated to support the
nRF52810.

STM32cube updates for all STM32 families (including
the addition of STM32F2x HAL) were also merged.

The Segger RTT debug code was updated to version
6.32d.

MCUMGR external sources were updated to external
commit a837a731 from the upstream repository,
available here:

https://github.com/apache/mynewt-mcumgr


##### Kernel: 
- Back in Zephyr 1.12, the old scheduler's thread
queueing code was replaced with the choice of a "dumb"
list or a balanced tree.  The old multi-queue
algorithm is still useful in some use cases, such as
applications with large-ish numbers of runnable
threads that don't need or want fancy features like
EDF or SMP affinity.  To fill this gap, the old
implementation was reintroduced, and can be enabled
using CONFIG_SCHED_MULTIQ.


##### Miscellaneous: 
- The logging subsystem saw many new features merged,
including: support for multiple backends, improving
real-time performance by deferring logging to a
separate runtime context, timestamps, and filtering
options (which are compile time, runtime, module
level, instance level). The console backend was added
as the first backend example.


##### Networking: 
- gPTP (Precision Time Protocol) support was added to
according to the IEEE 802.1AS-2011 standard.  To
enable it, use CONFIG_NET_GPTP. Note: at this time,
gPTP is only supported for boards that have Ethernet
ports which support collecting timestamps for sent and
received Ethernet frames.  A gPTP sample was added at
samples/net/gptp.

Also new to Zephyr is the LLMNR (Link Local Multicast
Name Resolution) client and responder from RFC 4795.
LLMNR is used in Windows networks.  A caller can be
set up to resolve DNS resource records using multicast
DNS, as well as configured to listen for LLMNR DNS
queries and respond to them.  Related Kconfig options
are CONFIG_LLMNR_RESOLVER and CONFIG_LLMNR_RESPONDER.
The implementation is in subsys/net/lib/dns.


##### Samples: 
- Socket API-based samples for echo_client and
echo_server were added to Zephyr as well as a simple
logger sample illustrating the new capabilities of the
logger subsystem additions.

LLMNR client support was added to the DNS resolver
sample.

A sample application for testing the NXP PCA9633 LED
driver was added.


##### Scripts: 
- The Kconfiglib project in Zephyr saw a couple of
updates:

1) Dependency loop detection.  Until now,
   dependency loops have raised a hard-to-debug Python
   RecursionError during evaluation. Now, a Kconfiglib
   exception is raised instead, with a message that lists
   all the items in the loop.

2) MenuNode.referenced() was converted to a property,
   making the API more consistent (read-only values
   are accessed with properties).

3) Warnings for choice overrides were eliminated.

The nrfjprog runner script was updated to accept a
--snr parameter specifying the serial number of the
device to be operated on.

Device tree now allows the use of a new element of DTC
grammar called overriding nodes.  It looks like this
in a board's dts file:

```
arduino_i2c: &i2c1 {};
```

This overriding node information is used during the
DTS include file generation like so In this way,
ARDUINO_I2C_LABEL could be used as a generic binding
name. This change is derived from a dtc commit in
version v1.4.2.


#### Bugs

##### Arches: 
- The ARM/NXP MPU code was cleaned up a bit to avoid
configuring out-of-bound MPU regions.  Also, the ARM
MPU code had several Zephyr defines replaced with
direct uses of CMSIS defines.

When compiling, both cortex-m0 and cortex-m0plus will
now use -march=armv6s-m instead of -march=armv6-m to
to ensure the svc instruction exists.



##### Bluetooth: 
- Bluetooth Mesh now depends on CONFIG_BT_BROADCASTER
and CONFIG_BT_OBSERVER, as they are necessary to
implement Mesh devices.  Several other Mesh-related
bugfixes landed to solve initialization order during
node reset, redundant model publication clearing,
cyclic rewriting to flash when restoring state,
checking for a model subscription address, and
ignoring prohibited element addresses.

For the Bluetooth Controller core, LE Extended Scanner
Filter Policy now depends on CONFIG_BT_OBSERVER and
the time to transmit an empty packet was raised from
40 microseconds to 44 microseconds on a 2M PHY, due to
an additional byte of preamble.

The BlueNRG-MS HCI driver received a pair of changes.
In the first, it now reads from the controller as long
as the IRQ is high. In the second, it makes sure to
configure the BlueNRG-MS to controller mode just after
it's ready by disabling "HCI reset" via a quirk.



##### Boards: 
- The BlueNRG-MS Bluetooth configuration had to be fixed
on the disco_l475_iot1 board.  This includes SPI3
usage, SYSCLK adjustments, and a few build warnings.



##### Build: 
- The gen_isr_tables script received several updates for
simplification and dead code removal.

Python script "process_gperf.py" used in the Zephyr
build system will now be invoked via "python" instead
of called directly. This avoids non-portable shebang
logic and/or "default application" behaviour on Windows.



##### Device Tree: 
- STM32F4 saw corrected pin assignment of node usart6@0.



##### Drivers: 
- RTC syscall changes required a build error fix.

A build error was addressed for intel_s1000 which uses
DesignWare USB. It doesn't inherit a qmsi header which
has several definitions used in the driver.  Instead
those definitions are provided via a DesignWare
specific header.

A build error in uart_handler.c was fixed when
CONFIG_UART_LINE_CTRL is defined.

Fixes were applied to the nRF UART driver for broken
hardware flow control and interrupt driven APIs.

For the USB/DFU subsystem, bcdUSB had been previously
updated from 1.1 to 2.0 in the default device
descriptor, but not in the DFU class. After USB bus
reset performed by dfu-util, this alternative
descriptor registered with bcdUSB was set to 1.1. This
mismatch caused a communication failure.  The DFU
descriptor's bcdUSB was updated to match the default
value.

The STM32 clock control driver received a fix to HCLK
calculation when using MSI.  The MSI clock signal can
be selected in several ranges. These ranges should be
taken into account for calculating its frequency and
hence global system frequency.  This change is used
when enabling Bluetooth on the disco_l475_iot1 board.

A long-standing issue where the K64F-FRDM board would
generate a random MAC address on every boot (which
would lead to DHCP address exhaustion) has been
solved. The existing Kconfig option
CONFIG_ETH_MCUX_0_RANDOM_MAC, which dynamically
chooses a random MAC address, is now one choice among
many in the new CONFIG_ETH_MCUX_0_MAC_SELECT option.
The other choices are CONFIG_ETH_MCUX_0_UNIQUE_MAC
(the new default), which uses the MCU unique
identification register to generate a stable MAC
address which is persistent over reboots, and
CONFIG_ETH_MCUX_0_MANUAL_MAC, which allows setting a
fixed MAC address. For details, see:

http://docs.zephyrproject.org/reference/kconfig/choice_55.html?highlight=eth_mcux_0_mac_select

NETUSB and STM32 ethernet hardware apparently never
called ethernet_init().  This was revealed when the
net_arp_init() function was moved into ethernet_init()
and ARP tables stopped being initialized correctly,
and has been fixed.



##### External: 
- PWM related nrfx_config entries for nRF52840 were
merged.

For STM32F4xx and STM32F7xx, the I2SR field needed to
be shifted by RCC_PLLI2SCFGR_PLLI2SR_Pos when the
PLLI2SCFGR register is read or written.  Previously,
the configuration was not done properly (R and M
params were badly set) and the PLLI2S was generating a
bad clock waveform.



##### Networking: 
- The "net app" layer has historically been the
combination of 2 separate but useful parts: 1) a
library to set up client and server connections
(CONFIG_NET_APP) and 2) a library to set up/configure
networking on application startup
(CONFIG_NET_APP_SETTINGS). As this second
functionality is useful in almost every circumstance,
it has been split out into a new top-level networking
library under subsys/net/lib/config.  In the future,
this would also allow other networking frameworks such
as sockets to use these configuration options.  This
move will cause issues for out of tree patches to the
net app layer.

The layer 2 networking code was also moved as having
it under subsys/net/ip/l2 didn't make much logical
sense.  The new location is subsys/net/l2.  Hopefully,
this movement didn't result in any functional changes,
but only time will tell.  Developers should note that
any out of tree patches to the old layer 2 location will
need to be refactored.

Zephyr's ARP table implementation was cleaned up
slightly and optimized for memory usage through the
use of a single linked list, smaller ARP entries, and
handling request timeouts in a single k_delayed_work
structure.



##### Samples: 
- Several changes were applied to the Bluetooth Mesh
nRF52 on/off level lighting sample at
samples/boards/nrf52/mesh/onoff_level_lighting_vnd_app.

The 96 Boards ArgonKey sample added support for the TI
LP3943 LED controller to test the 12 on-board LEDs.



##### Scripts: 
- The extract_dts_includes script was refactored for
better maintainability; some false information
messages were also removed.



### hawkBit and MQTT sample application


#### Features
- Not addressed in this update

#### Bugs
- Not addressed in this update

### LWM2M sample application


#### Features

##### WCN14A2A support as modem-overlay.conf: 
- Support for the WCN14A2A LTE-M modem was refactored
into a configuration fragment file named
modem-overlay.conf.


#### Bugs

##### Stack overflow fixed with DTLS enabled: 
- An overflow of the network management stack observed
with DTLS enabled has been fixed by increasing its
stack size to 1024B in that configuration.


# Linux microPlatform

## Summary

No significant changes have gone into this update. The previous update
included updates to containers and the sources weren't published. The
URL used for authentication in lmp-device-register was updated.

## Highlights

- lmp-device-register updated to use app.foundries.io.
- Updated sources of published containers.

## Components


