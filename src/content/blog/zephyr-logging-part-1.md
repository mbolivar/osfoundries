+++
title = "Zephyr Logging Survival Guide, Part 1: SYS_LOG"
date = "2018-07-23"
tags = ["zephyr", "zmp"]
categories = ["zephyr"]
banner = "img/banners/zephyr.png"
author = "Marti Bolivar"
+++

An overview of Zephyr's longstanding SYS_LOG API, or: *Blog Drops
Zephyr Log Bombs Without Qualms*.

<!--more-->

Until recently, logging in Zephyr was fairly straightforward: do a
little configuration, pull in a header, get a blocking UART logging
API called SYS_LOG. The SYS_LOG API provides:

- printf()-like behavior
- "levels", for verbosity control
- "domains", for separation of messages from different areas of code

In this post, the first in a two-part series, we'll give you a
detailed look at the basic SYS_LOG API. We'll compare that to the
newly merged Logger subsystem -- which is much less simple and more
powerful -- in part 2.

# TODO update ALL links

Complete Zephyr applications for each source code sample are here:

https://github.com/mbolivar/zephyr-logging-examples

Upstream Zephyr SYS_LOG documentation:

http://docs.zephyrproject.org/subsystems/logging/system_log.html

## Basic Usage

To use SYS_LOG, set `CONFIG_SYS_LOG=y` in your prj.conf.

Then, in each source file that needs to log messages:

1. Define `SYS_LOG_LEVEL` to the minimum verbosity level to print logs
   for. This is one of `SYS_LOG_LEVEL_OFF`, `SYS_LOG_LEVEL_ERROR`, `.._WARNING`,
   `..._INFO`, `..._DEBUG`.
2. Define `SYS_LOG_DOMAIN` to an arbitrary string that identifies the
   source of messages in that file. Some examples from the mainline tree are
   `"bt"` for Bluetooth and `"net/xxx"` for networking.
3. Include `<logging/sys_log.h>`
4. Log all the things!

The header `logging/sys_log.h` provides the following printf-like log
macros, in decreasing order of verbosity:

- `SYS_LOG_DBG()`
- `SYS_LOG_INF()`
- `SYS_LOG_WRN()`
- `SYS_LOG_ERR()`

Example code ([full source on GitHub](https://github.com/mbolivar/zephyr-logging-examples/tree/1.13/sys_log_basics)):

```c
/* Display all messages, including debugging ones: */
#define SYS_LOG_LEVEL SYS_LOG_LEVEL_DEBUG

/* Set the domain for messages in this file: */
#define SYS_LOG_DOMAIN "foundries.io/basics"

#include <logging/sys_log.h>

void main(void)
{
	SYS_LOG_DBG("verbose debug %d", 3);
	SYS_LOG_INF("everything is fine, mask=0x%x", 0xa1);
	SYS_LOG_WRN("warning: %s was seen", "something bad");
	SYS_LOG_ERR("error %d", 3);
}
```

This outputs:

```
[foundries.io/basics] [DBG] main: verbose debug 3
[foundries.io/basics] [INF] main: everything is fine, mask=0xa1
[foundries.io/basics] [WRN] main: warning: something bad was seen
[foundries.io/basics] [ERR] main: error 3
```

The default format is as follows. Note the newline is appended automatically:

```
[DOMAIN] [LEVEL] function_name: formatted_message + \n
```

Output is printed with `printk()` by default. This typically means
execution halts while the output is sent to the UART, a character at a
time. That's slow, but like the US Post Office, will get the message
there, even if your core has double-faulted and everything is on fire.

## Colorized Output

If `CONFIG_SYS_LOG_SHOW_COLOR=y`, SYS_LOG output is colored using
[ANSI escape codes](https://en.wikipedia.org/wiki/ANSI_escape_code).

Example code ([full source on
GitHub](https://github.com/mbolivar/zephyr-logging-examples/tree/1.13/sys_log_color)):

prj.conf:

```
CONFIG_SYS_LOG=y
CONFIG_SYS_LOG_SHOW_COLOR=y
```

main.c:

```c
#define SYS_LOG_LEVEL SYS_LOG_LEVEL_DEBUG
#define SYS_LOG_DOMAIN "foundries.io/color"

#include <logging/sys_log.h>

void main(void)
{
	SYS_LOG_DBG("verbose debug %d", 3);
	SYS_LOG_INF("everything is fine, mask=0x%x", 0xa1);
	SYS_LOG_WRN("warning: %s was seen", "something bad");
	SYS_LOG_ERR("error %d", 3);
}
```

Output screenshot:

![](/uploads/2018/07/23/color.png)

Ooh, ANSI colors! Everybody loves those. Except maybe Windows
consoles? We don't know, to be honest.

## Verbosity Filtering

You can decrease the verbosity of SYS_LOG's messages by setting
`SYS_LOG_LEVEL` to something lower than `SYS_LOG_LEVEL_DEBUG`.

Example code ([full source on GitHub](https://github.com/mbolivar/zephyr-logging-examples/tree/1.13/sys_log_filtering)):

```c
/* Filter out any messages more verbose than the WARNING level. */
#define SYS_LOG_LEVEL SYS_LOG_LEVEL_WARNING
#define SYS_LOG_DOMAIN "foundries.io/filtered"
#include <logging/sys_log.h>

void main(void)
{
	SYS_LOG_DBG("this message will not appear; DBG is too verbose");
	SYS_LOG_WRN("this warning appears (WRN is the minimum verbosity)");
	SYS_LOG_ERR("this error appears too (ERR is less verbose than WRN)");
}
```

Output:

```
[foundries.io/filtered] [WRN] main: this warning appears (WRN is the minimum verbosity)
[foundries.io/filtered] [ERR] main: this error appears too (ERR is less verbose than WRN)
```

We don't need no stinking debug messages, anyway. They're way too noisy.

Filtering is done at compile time. This can save space, since programs
contain no code for any messages that are too verbose to output. The
tradeoff, of course, is that changing the verbosity requires a
reflash, which may not be possible for devices in the field.

## Filtering Mainline Subsystems

As of version 1.12, many of Zephyr's subsystems provide Kconfig
options for setting their log level. Here are a few random examples
(links are to Zephyr v1.12 documentation, in case Logger ends up
replacing these):

- [CONFIG_SYS_LOG_NET_LEVEL](http://docs.zephyrproject.org/1.12.0/reference/kconfig/CONFIG_SYS_LOG_NET_LEVEL.html):
  controls the SYS_LOG log level of the networking stack
- [CONFIG_SYS_LOG_GPIO_LEVEL](http://docs.zephyrproject.org/1.12.0/reference/kconfig/CONFIG_SYS_LOG_GPIO_LEVEL.html):
  controls GPIO driver logging level
- [CONFIG_SYS_LOG_FS_LEVEL](http://docs.zephyrproject.org/1.12.0/reference/kconfig/CONFIG_SYS_LOG_FS_LEVEL.html):
  controls logging level for file system drivers

You can increase the verbosity on these types of options in your
application's prj.conf to tweak the logs when debugging a problem in a
particular subsystem. (In fact, upstream maintainers will often ask
you to do exactly that when submitting bugs, to get extra information,
so you can often get answers faster if you dig around and submit
verbose logs too from the outset.)

## Quirks and Pitfalls

SYS_LOG has a few quirks, and there are some common pitfalls. In no
particular order:

- If
  [CONFIG_SYS_LOG](http://docs.zephyrproject.org/reference/kconfig/CONFIG_SYS_LOG.html)
  is `n` (the default), SYS_LOG is disabled. You can still include
  `logging/sys_log.h` and use the `SYS_LOG_xxx()` macros in your
  source files, but they will all be compiled out. This is in keeping
  with Zephyr's miserly default resource consumption, but is yet
  another knob to remember to turn on during development.
- Subsystem-specific logging Kconfig options take different and
  inconsistent approaches to enabling `CONFIG_SYS_LOG`. For example,
  `NET_LOG` selects `SYS_LOG`, so setting `CONFIG_NET_LOG=y` silently
  sets `CONFIG_SYS_LOG=y`, causing networking logs to appear. However,
  `NVS_LOG` depends on `SYS_LOG`, so simply setting `CONFIG_NVS_LOG=y`
  won't log any NVS messages (unless `CONFIG_SYS_LOG` is already `y`
  for some other reason).
- Notice how in the above examples, `SYS_LOG_LEVEL` and
  `SYS_LOG_DOMAIN` are set **before** including
  `logging/sys_log.h`. Doing it after has no effect, resulting in the
  default behavior, which is (you guessed it) not to log anything --
  yes, even if `CONFIG_SYS_LOG=y`.
- As with assertions, code with side effects should be kept out of
  SYS_LOG calls, since it can be compiled out depending on the
  configuration.
- Since disabled log messages are compiled out, enabling too much
  logging can make your program too big to fit on your board.

## Additional Features

SYS_LOG provides additional customization through the following extra
features:

- Default log levels can be tweaked with
  [CONFIG_SYS_LOG_DEFAULT_LEVEL](http://docs.zephyrproject.org/reference/kconfig/CONFIG_SYS_LOG_DEFAULT_LEVEL.html)
  and
  [CONFIG_SYS_LOG_OVERRIDE_LEVEL](http://docs.zephyrproject.org/reference/kconfig/CONFIG_SYS_LOG_OVERRIDE_LEVEL.html).
- Use of `printk()` can be overridden by enabling
  [CONFIG_SYS_LOG_EXT_HOOK](http://docs.zephyrproject.org/reference/kconfig/CONFIG_SYS_LOG_EXT_HOOK.html)
  and calling `syslog_hook_install(some_printf_like_function)` (likely
  in some very early initialization code using the `<init.h>` APIs).
- The output format can be configured with
  [CONFIG_SYS_LOG_SHOW_COLOR](http://docs.zephyrproject.org/reference/kconfig/CONFIG_SYS_LOG_SHOW_COLOR.html)
  and
  [CONFIG_SYS_LOG_SHOW_TAGS](http://docs.zephyrproject.org/reference/kconfig/CONFIG_SYS_LOG_SHOW_TAGS.html)
  (which maybe should have been named `CONFIG_SYS_LOG_SHOW_LEVEL`
  instead).
- Individual source files can disable automatic printing of newlines
  after each log message by defining `SYS_LOG_NO_NEWLINE` before
  including `logging/sys_log.h`.

## Summary

By default, the SYS_LOG APIs are just wrappers around `printk()`,
which (on real hardware) usually blocks until the entire message is
emitted a character at a time on the UART console.

This has important benefits:

- **Simplicity**: it's about as simple as it gets and hard to break,
  even if the rest of the system has let the magic smoke out.
- **Predictability**: messages are printed in the exact places the
  logging calls are inserted. You have access to all your local
  variables, statics, etc.

It also has important drawbacks:

- **Latency**: blocking on a UART takes time, which adds latency. Bugs can
  disappear due to timing when attempts to log them are inserted, or
  appear if the code is latency-sensitive. This can be great fun.
- **Thread safety**: there is none! Logs can conflict with the console
  (and each other).
- **Simplicity**: there can be too much of a good thing. If you want
  SYS_LOG to add timestamps, do network logging, etc., have fun implementing
  that with external hooks on your own.

# Next Up: Logger Subsystem

In part 2 of the Zephyr Logging Survival Guide, we'll explore the new
[Logger](http://docs.zephyrproject.org/subsystems/logging/logger.html)
subsystem, which at its most basic supports the same levels (error,
warning, info, and debug) as the venerable SYS_LOG, as well as
something called "modules" that looks roughly like SYS_LOG domains.

The new subsystem boasts a wealth of additional features compared to
SYS_LOG and promises of future expansion, though. These can be used to
avoid some of the pitfalls and caltrops of the simpler API. However,
as we'll see, they're not without tradeoffs of their own.
