# Some Interrupt API

![interrupts](./images/interrupt_types.png)

There are some method to close interrupt.

1. at the device level
program the device control registers to close interrupt of the device.
&nbsp;

2. at the PIC level
PIC can be programed to disable a given IRQ line.

```c
disable_irq(unsigned int irq);
enable_irq(unsigned int irq);
```

3. at the CPU level.
* `cli`: clear the interrupt flag
* `sti`: set interrupt flag

```c
// disable irq on current processor, it wraps `cli`
local_irq_save(unsigned int flag);
local_irq_restore(unsigned int flag);

local_irq_disable();
local_irq_enable();


// disable softirqs bottom half process
//   Softirqs are processed on either, interrupt return path,
//   or by the ksoftirqd-(per cpu)-thread that will be woken up if the system suffers of heavy softirq-load. 
local_bh_disable();
local_bh_enable();


// disable preemption
// it means a thread that executes in <preempt_diable>--<preempt_enable> scope will not be put
// to sleep by the scheduler.
preempt_disable();
preempt_enable();

```