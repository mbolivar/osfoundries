+++
title = "microPlatform update 0.23"
date = "2018-06-29"
tags = ["linux", "zephyr", "update", "cve", "bugs"]
categories = ["updates", "microPlatform"]
banner = "img/banners/update.png"
+++

# Summary

## Zephyr microPlatform changes for 0.23

Zephyr's first batch of v1.13 patches; code cleanups to the sample
applications.


## Linux microPlatform changes for 0.23

OSF Unified Linux Kernel updated to the 4.16.18 stable release.
Default GCC version was updated to the latest upstream 8.1 release.

<!--more-->
# Zephyr microPlatform

## Summary

Zephyr's first batch of v1.13 patches; code cleanups to the sample
applications.

## Highlights

- Zephyr from the v1.13 timeline
- No MCUboot pull
- Minor cleanups to the sample applications

## Components


### MCUboot


#### Features
- Not addressed in this update

#### Bugs
- Not addressed in this update

### Zephyr


#### Features

##### CONF_FILE can now be a CMake list: 
- Most Zephyr users will likely recognize the CMake
variable CONF_FILE, which can be used to set the path
to the top-level application Kconfig fragment.
(Normally, this defaults to prj.conf.)

A longstanding but lesser-known feature is that
CONF_FILE can also be a whitespace-separated list of
fragments; these will all be merged into the final
configuration. Some samples use this feature to add
board-specific "mix-ins" to the top-level prj.conf;
see the led_ws2812 CMakeLists.txt for an example.

The "whitespace-separated" part of this feature is a
holdover from when Zephyr used the Linux kernel's
Makefile build system, Kbuild. Since moving to CMake,
the whitespace separation has been a little bit less
convenient, as CMake uses semicolon-separated strings
as its internal "list" data type.

To make this feature cleaner in the new world order,
CONF_FILE now also supports separation via semicolons.
The old whitespace separation behavior is not affected
to keep backwards compatibility. For example, setting
the following at the CMake command line would merge
the three fragments hello.conf, world.conf, and
zephyr.conf into the final .config:

```
  -DCONF_FILE="hello.conf;world.conf zephyr.conf"
```


##### PWM on STM32: 
- Device tree bindings were added for timers and PWM
devices on STM32 targets.  A large variety of STM32
targets (F0, F1, F3, F4, and L4 families) now have
such nodes added on a per-SoC basis. Many of the
official boards produced by STMicroelectronics now
have PWM enabled.

The old Kconfig options (CONFIG_PWM_STM32_x_DEV_NAME,
etc.) have been removed. Applications using PWM on
STM32 may need updates to reflect this switch to
device tree.


##### UART on nRF: 
- The UART driver for nRF devices has been refactored to
use the vendor HAL. This change was followed by a
large tree-wide rename of the Kconfig options:
CONFIG_UART_NRF5 was renamed to CONFIG_UART_NRFX, and
CONFIG_UART_NRF5_xxx options were renamed to
CONFIG_UART_0_NRF_xxx.

Applications using this driver may need updates.


##### Many Kconfig warnings are now errors: 
- The tree-wide cleanups and improvements to Zephyr's
usage of Kconfig continues as Kconfiglib grows more
features. Notably, many warnings are now errors,
improving the rate at which CI catches Kconfig issues.


##### Arches: 
- The work to enable Arm v8-M SoCs, some of which
include support for "secure" and "non-secure"
execution states, continues. There is a new
CONFIG_ARM_NONSECURE_FIRMWARE option, which signals
that the application being built is targeting the non-
secure execution state. This depends on a new hidden
CONFIG_ARMV8_M_SE option, which SoCs can select to
signal that hardware support for this feature is
present. This was followed with infrastructure APIs
related to address accessibility and interrupt
management in secure and non-secure contexts.

The native POSIX "architecture" now supports -rt and
-no-rt command line options, which allow deferring the
decision for whether execution should be slowed down
to real time to runtime. (The option
CONFIG_NATIVE_POSIX_SLOWDOWN_TO_REAL_TIME now
determines the default value.)


##### Bluetooth: 
- There is a new choice option for controlling the
transmit power.

On Linux hosts, the native POSIX target can now access
the kernel Bluetooth stack via a new HCI driver, which
can be enabled with CONFIG_BT_USERCHAN.

The Bluetooth mesh sample application
samples/boards/nrf52/mesh/onoff-app now supports the
persistent storage API introduced in v1.12. This
allows the application to rejoin the same network if
the board is reset.

The host stack now supports more flexible choices for
how to pass attributes to bt_gatt_notify().


##### Boards: 
- The frdm_kl25z board now supports USB.

Nordic board Kconfig files can now select
CONFIG_BOARD_HAS_DCDC, which will enable the DC/DC
converter.


##### Build: 
- There is a new CONFIG_SPEED_OPTIMIZATIONS flag, which
requests the build system to optimize for speed. (The
default is to optimize for binary size.)

The warning output for when the value a user sets for
a Kconfig option differs from the actual value has
been improved.


##### Documentation: 
- Zephyr's Kconfig documentation now includes output for
choices.


##### Device Tree: 
- The RISCV32 QEMU target now has DT support for flash,
SRAM, and UART.

nRF52 SoCs now have device tree support for GPIO.


##### Drivers: 
- A variety of nRF peripheral accesses throughout the
tree were replaced with calls to inline accessors in
the vendor HAL. The stated reason given is to enable
easier testing.

The nRF PWM driver now has prescaler support.

The mcux Ethernet driver now uses the carrier
detection API calls described below in the new
networking features.

A new driver for the TI SimpleLink WiFi offload chip
was merged; so far, this only supports the network
management commands related to WiFi which were
introduced for v1.12 (see include/net/wifi_mgmt.h for
details).

A variety of USB-related changes were merged.

The USB subsystem now sports new USBD_DESCR_xxx_DEFINE
macros for declaring descriptors of various types;
behind the scenes, these use linker magic to ensure
that the defined descriptors end up in contiguous
memory. This allowed migrating descriptors formerly
defined in an increasingly large
subsys/usb/usb_descriptor.c into the files for the
individual USB classes, etc. that defined them.

As all Zephyr USB controllers support USB v2.0, the
USB protocol version reported in the device descriptor
has been updated to that value, increasing it from its
former setting of v1.1.

The HID interrupt endpoint size configuration option
CONFIG_HID_INTERRUPT_EP_MPS is now visible and thus
configurable by applications.

Interface descriptors are now configurable at runtime.


##### Networking: 
- Ethernet drivers can now signal detection and loss of
a carrier via new net_eth_carrier_on() and
net_eth_carrier_off() routines. This is used by the
network management APIs to generate interface "up" and
"down" events.

The DHCP implementation uses these events to obtain
new addresses when a network interface reappears after
going down.

The network shell's conn command now unconditionally
prints the state of each TCP connection.

A variety of performance improvements were merged into
the networking layer; these speed things up by
avoiding unnecessary work, like duplicated filling in
of packet headers and checksums. Better management of
some internal caches when multiple networking
interfaces are running on board was also merged.


##### Samples: 
- The BBC micro:bit now supports servomotors; see
samples/basic/servo_motor.


##### Scripts: 
- A variety of updates were merged to the Kconfiglib
dependency vendored into Zephyr, along with its users;
these are mostly related to hardening warnings into
errors and improving error and warning output.


##### Testing: 
- The long-ranging work on issue 6991 continues with
several samples being refactored, moved or otherwise
cleaned up to better fit in a test management system.


#### Bugs

##### Arches: 
- The PendSV interrupt handler on ARM now prevents other
operating system interrupts from running before
accessing kernel state, preventing races.



##### Bluetooth: 
- The USB Bluetooth device class implementation saw a
few fixes. Notably, it now has a transmit thread as
well as a receive thread, fixing an issue where
bt_send() was incorrectly called from interrupt
context, and properly reserves some headroom needed in
its net_buf structures.



##### Build: 
- The CONFIG_COMPILER_OPT option now allows setting
multiple compiler options, separated by whitespace.

Numerous fixes and updates were merged affecting usage
of Kconfig options throughout the tree.

The "minimal" C library that ships with Zephyr is no
longer built as part of the "app" target, which is
reserved as much as possible for user applications.
Any applications that may have been relying on this
behavior may need updates, as the C library is now
part of its own Zephyr library.



##### Drivers: 
- Bluetooth drivers now have access to bt_hci_cmd_send()
and bt_hci_cmd_send_sync() routines via <hci.h>;
allowing them to, well, send HCI commands. HCI drivers
can now also declare "quirks", or deviations from
standard behavior, with BT_QUIRK_NO_RESET being the
first user.

The Nordic RTC timer driver saw a fix for the number
of hardware cycles per tick; the PWM driver also has
improved accuracy after a clock frequency fix.

A build issue in the Bluetooth HCI implementation
using SPI as a transport was fixed.

The lis2dh accelerometer driver seems to be working
again, after seeing build breakage and I2C protocol
usage fixes.



##### Kernel: 
- A fix was merged partially restoring the behavior of
CONFIG_MULTITHREADING=n following the scheduler
rewrite. (Some former behavior related to semaphores
was not restored, forcing flash drivers elsewhere in
the tree to behave differently depending on whether
this option is enabled.)

A race condition which could cause k_poll() to return
NULL when a timeout is set has been fixed.



##### Networking: 
- The TCP stack now properly responds to Zero Window
Probe segments.

Some use-after free bugs in network statistics
calculations were fixed.

IPv4 and UDP checksums are now calculated only when
needed in the DHCPv4 core.



##### Samples: 
- The mbedtls_sslclient networking sample now uses a
hardware entropy source at system startup to seed the
random number generator when one is available, rather
than relying on sys_rand32_get(), which doesn't
guarantee cryptographically strong output.



### hawkBit and MQTT sample application


#### Features
- Not addressed in this update

#### Bugs

##### Kconfig fixes: 
- A variety of Kconfig warnings generated by Zephyr's
build system have been addressed. Zephyr is growing
increasingly strict about turning these warnings into
errors, so this may avoid future problems.



##### Removal of old include path: 
- A long-deleted Zephyr include path has been removed.
Its presence didn't cause any issues, but its removal
is a cleanup.



### LWM2M sample application


#### Features
- Not addressed in this update

#### Bugs

##### Kconfig fixes: 
- A variety of Kconfig warnings generated by Zephyr's
build system have been addressed. Zephyr is growing
increasingly strict about turning these warnings into
errors, so this may avoid future problems.



##### Removal of old include path: 
- A long-deleted Zephyr include path has been removed.
Its presence didn't cause any issues, but its removal
is a cleanup.


# Linux microPlatform

## Summary

OSF Unified Linux Kernel updated to the 4.16.18 stable release.
Default GCC version was updated to the latest upstream 8.1 release.

## Highlights

- OSF Unified Linux Kernel updated to 4.16.18.
- GCC updated to the latest 8.1 release.

## Components


### OpenEmbedded-Core Layer


#### Features

##### Layer Update: 
- Acpid updated to 2.0.29.
Bluez5 updated to 5.50.
Cronie updated to 1.5.2.
GCC updated to 7.3.
Gstreamer1.0 updated to 1.14.1.
Mc updated to 4.8.21.
Musl updated to the latest upstream master.
Yocto-uninative updated to 2.1.


#### Bugs

##### cpio: 
- The cpio_safer_name_suffix function in util.c in cpio 2.11
allows remote attackers to cause a denial of service
(out-of-bounds write) via a crafted cpio file.

 - [CVE-2016-2037](http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2016-2037)

##### glibc: 
- Multiple issues.

 - [CVE-2017-18269](http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2017-18269)
 - [CVE-2018-11236](http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2018-11236)

### Meta RISC-V


#### Features

##### Layer Update: 
- PIE disable as glibc still needs work.
Qemu-riscv updated to the master branch.


#### Bugs
- Not addressed in this update

### Meta OSF Layer


#### Features

##### Layer Update: 
- Lmp-device-register updated to the latest git revision.
OSF Unified Linux Kernel updated to 4.16.18.
Uart serial only enabled on raspberrypi3 if ENABLE_UART is set.
U-boot-toradex now uses distro boot on internal eMMC.


#### Bugs
- Not addressed in this update
