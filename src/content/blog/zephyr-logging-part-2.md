+++
title = "Zephyr Logging Survival Guide, Part 2: Logger Subsystem"
date = "2018-07-24"
tags = ["zephyr", "zmp"]
categories = ["zephyr"]
banner = "img/banners/zephyr.png"
author = "Marti Bolivar"
+++

An overview of the new logging system merged for v1.13, or: *Can't Get
Enough of your Logs, Zephyr*.

<!--more-->

In [part one]({{< ref "zephyr-logging-part-1.md" >}}) of this series,
we described Zephyr's venerable SYS_LOG logging API. While it has
(mostly) served us well, there's a brand new alternative: a "Logger"
subsystem was recently merged into master, and will be part of the
v1.13 release. We'll explore it here in part 2, comparing and
contrasting it to SYS_LOG.

# TODO update ALL links

Complete Zephyr applications for each source code sample are here:

https://github.com/mbolivar/zephyr-logging-examples

Upstream Zephyr Logger documentation:

http://docs.zephyrproject.org/subsystems/logging/logger.html

## Basic Usage

At first blush, using Logger isn't that different from SYS_LOG:

1. set a log level and "module" name
2. include `<logging/log.h>`
3. perform some module-specific initialization
4. log the logs!

Logger has printf()-like macros `LOG_DBG`, `LOG_INF`, `LOG_WRN`, and
`LOG_ERR`, which work the way you'd expect.

Example code ([full source on GitHub](https://github.com/mbolivar/zephyr-logging-examples/tree/1.13/logger_basics)):

```c
/* Display all messages, including debugging ones: */
#define LOG_LEVEL LOG_LEVEL_DBG

/* Set the "module" for these log messages: */
#define LOG_MODULE_NAME foundries_io_basics

#include <logging/log.h>

/* Initialize module-specific magic state: */
LOG_MODULE_REGISTER();

void main(void)
{
	LOG_DBG("verbose debug %d", 3);
	LOG_INF("everything is fine, mask=0x%x", 0xa1);
	LOG_WRN("warning: %s was seen", "something bad");
	LOG_ERR("error %d", 3);
}
```

Output screenshot:

![](/uploads/2018/07/23/logger_basics.png)

The output is formatted as follows:

```
[TIMESTAMP] <LEVEL> <MODULE>: formatted_message + \n
```

Like SYS_LOG, the Logger subsystem's output (by default):

- goes to the console UART
- includes the formatted message
- automatically appends a newline
- prints the "module" (which is somewhat similar to a SYS_LOG domain)

**Unlike SYS_LOG**, however:

- By default, output includes timestamps and is colorized (hurray!).
  This can be configured -- as we'll see later -- on a per-backend basis.
- **Module names must be valid C identifiers** (that may additionally
  begin with a digit), rather than arbitrary strings: so
  `foundries_io_basics` is OK, but `foundries.io/basics` will cause a
  cryptic compilation error. This is a "gotcha" for SYS_LOG users,
  since upstream Zephyr uses a slash (`/`) for namespacing in SYS_LOG
  domains.

Yawn... OK, so what's the big deal? That's not a huge difference; why
introduce a whole new subsystem?

## So Many Fancy Features

Logger has several features not present in the more basic
SYS_LOG. We'll dig into these in particular:

- Data dumping APIs
- Deferred logging
- Timestamps
- Per-"instance" logging
- Compile time and run time filtering
- "Panic" mode
- Logger as a printk() backend

There are a few additional Logger features we won't evaluate here:

- Multiple backends: at time of writing, only UART logging is
  supported. Additional logging destinations (like network or flash
  logging) may be added to Zephyr later on.
- Multi-domain/multi-processor readiness: the Logger subsystem was
  designed for use with those newfangled multi-core environments
  Zephyr has been adding support for lately. We've only got Zephyr running on
  humble single-core MCUs on our desk, though. And anyways, multi-core is for
  running Linux, right?

## Data Dumping APIs

**TODO** print out buffers. SHOW THE QUIRKS HERE -- be careful

## Interlude: Who Will Time the Timestamps Themselves?

Before we dig deeper into Logger's plethora of features, let's take a
close look at its output timing, comparing it with that [equivalent SYS_LOG
example](https://github.com/mbolivar/zephyr-logging-examples/tree/1.13/sys_log_basics)
we mentioned earlier.

### Logger Timestamps vs. Message Print Times

First, let's take a close look at the timestamps Logger printed:

![](/uploads/2018/07/23/logger_basics_tstamps.png)

Wait... the four messages all "happened" in the **very same
microsecond**? (Readers who need further convincing regarding the
decimal separator format are referred to
[log_output.c](https://github.com/zephyrproject-rtos/zephyr/blob/7fe2c3b14fde28419dbd0e877c98c0ccf576d3da/subsys/logging/log_output.c#L112).)

The above screenshot is of output from a UART console at the usual
115200 baud, 8N1 setting. It takes at least 86 microseconds to output
a single character at that speed, so the `LOG_XXX` macros definitely
aren't sitting around polling the UART, the way their SYS_LOG
equivalents do: the timestamp calculation has to be happening before
anything gets printed.

Readers who are playing along at home will also have noticed a
significant delay between Zephyr's boot banner and the appearance of
the first log message. This can be seen by capturing the serial output
using [grabserial](https://elinux.org/Grabserial) in timestamp mode,
like so:

```
$ grabserial -t -b 115200 -d /dev/serial-port-device
```

On this system, the output was (with ASCII art notes on the grabserial
timestamps):

```
 +-- Rough timestamp since first character, in seconds
 |
 |        +--- Relative timestamp since last line, in seconds
 |        |
 v        v
[0.000001 0.000001] ***** Booting Zephyr OS v1.12.0-921-g7fe2c3b14 *****

          +--- Huh?! Over a second elapses between boot banner and first log!
          |
          v
[1.008154 1.008153] [00:00:00.004,638] <dbg> foundries_io_basics: verbose debug 3

          +--- Next log messages appear quickly thereafter.
          |
          v
[1.013183 0.005029] [00:00:00.004,638] <inf> foundries_io_basics: everything is fine, mask=0xa1
[1.020086 0.006903] [00:00:00.004,638] <wrn> foundries_io_basics: warning: something bad was seen
[1.028012 0.007926] [00:00:00.004,669] <err> foundries_io_basics: error 3
```

What's up with that **entire extra second** of delay after
`Booting Zephyr OS` but before the first log message? Why is that so
much different than the timestamps Logger printed? Did I accidentally
run this on a pocket calculator?

### Comparison with SYS_LOG

Though SYS_LOG doesn't print timestamps, we can capture print times
with grabserial. Note that the extra delay after the boot banner is
not there; log messages start printing right away:

```
[0.000001 0.000001] ***** Booting Zephyr OS v1.12.0-921-g7fe2c3b14 *****
          +--- No significant delay here.
          |
          v
[0.004896 0.004895] [foundries.io/basics] [DBG] main: verbose debug 3
[0.009100 0.004204] [foundries.io/basics] [INF] main: everything is fine, mask=0xa1
[0.014265 0.005165] [foundries.io/basics] [WRN] main: warning: something bad was seen
[0.020167 0.005902] [foundries.io/basics] [ERR] main: error 3
```

### What the heck?

At this point, you might start to wonder if something has gone
wrong. Is the Logger subsystem misconfigured? Slow? Or is there some
sort of post-processing thread that's taking a while to wake up?
Hrm...

Explaining what's going on takes us into a deep dive of the major
difference between Logger and SYS_LOG:

**Unlike SYS_LOG, Logger captures timestamps and prepares log messages
for later printing in another thread.**

This is described in the official documentation as follows:

"Logger is designed to be thread safe and minimizes time needed to log
the message. Time consuming operations like string formatting or
access to the transport are not performed by default when logger API
is called. When logger API is called a message is created and added to
the list. Dedicated, configurable pool of log messages is used."

In other words, macros like `LOG_ERR()` don't print anything; instead,
they make a note of information to be printed at some point later on,
minimizing execution time costs at the call site at the cost of extra
overhead and deferred action.

Let's see this in action by generating some pulses on a GPIO pin at
the same time as doing some Logger calls:

- One pulse with a few NOPs in between, as a baseline
- Two consecutive pulsess wrapping a `LOG_DBG("")` invocation

The following waveform resulted; testing was done on `nrf52840_pca10056`:

![](/uploads/2018/07/23/logger_pulses_timing.png)

Pulse generation ([full source on GitHub](https://github.com/mbolivar/zephyr-logging-examples/tree/1.13/logger_gpio_pulse)):

```c
	/*
	 * The first pulse is done with a few NOPs in between,
	 * just to get a rough idea of pulse behavior.
	 */
	NRF_P0->OUTSET = 1U << PIN;
	__NOP();
	__NOP();
	__NOP();
	NRF_P0->OUTCLR = 1U << PIN;

	/*
	 * The next two pulses wrap LOG_DBG("") macro invocations
	 * as follows.
	 *
	 * This may underestimate the true cost of this LOG_DBG("")
	 * call, since the compiler could move some code outside of
	 * the OUTSET/OUTCLR lines, but it's a rough approximation.
	 */
	NRF_P0->OUTSET = 1U << PIN;
	LOG_DBG("");
	NRF_P0->OUTCLR = 1U << PIN;
```

Output:

```
[00:00:00.000,030] <dbg> M: 
[00:00:00.000,030] <dbg> M: 
```

Very, very generously, the first pulse is in the neighborhood of 100
ns, which still puts it in the noise:

![](/uploads/2018/07/23/logger_pulses_timing_first.png)

Subsequent pulses are a bit over 4 microseconds:

![](/uploads/2018/07/23/logger_pulses_timing_dbg.png)

so, at least on this board, there are about 4 microseconds of overhead to
prepare and buffer a basic log message.

That doesn't account for why the messages are appearing at the same
microsecond in the UART output. We've reached out to the subsystem's
author looking for clarification on this question and will update this
blog as we go.

Speaking of that there UART output... where is it? Taking out the
logic analyzer, sure enough, it appears about a second later (the thin
line on channel 0 is the sequence of three pulses from earlier):

![](/uploads/2018/07/23/logger_pulses_uart.png)

## Controlling Logger Processing

Things you might be thinking to yourself at this point:

- **A second is way too long to wait! I need my logs NOW! What if my
  system crashes?**
- **I'm mad, I hate change, and I want my SYS_LOG back!**

You might not be alone... and you'll (hopefully) be glad to hear that
Logger output can be fine-tuned to suit application requirements.

**TODO**

Knobs are: CONFIG_LOG_PROCESS_TRIGGER_THRESHOLD, CONFIG_LOG_PROCESS_THREAD_SLEEP_MS, forcing a flush (?), rolling your own logging handler thread (?)

## Panic mode

TODO

## Module and Instance Logging

## Filtering

Example code ([full source on GitHub](https://github.com/mbolivar/zephyr-logging-examples/tree/1.13/logger_filtering)):

```c
```

Output:

```
```

TODO: COMPARE/CONTRAST here

## Filtering Mainline Subsystems

TODO: are any of them converted?

## Logger-as-printk()

TODO

## Quirks

Like SYS_LOG, the Logger subsystem has a few quirks.

- TODO

## Summary

By default, the SYS_LOG APIs are just wrappers around `printk()`,
which (on real hardware) usually blocks until the entire message is
emitted a character at a time on the UART console.

This has important benefits:

- **TODO**: blah blah blah
- **TODO**: blah blah blah

It also has important drawbacks:

- **TODO**: blah blah blah
- **TODO**: blah blah blah
