### CBFS

Bootblock位于CBFS最后20KB ROM空间中。Bootblock包含master header和加载Firmware的entry point。

### 执行过程

1. Bootblock: Reset Vector中包含一条跳转指令，可以跳转到Bootblock的16-bit的入口代码。Coreboot之后立刻进入32-bit的flat protected mode。
Reset Vector和Bootblock的代码都直接从ROM中运行，这种方式被称为XIP(execute in place)。此处可以执行受限的C代码，需要通过ROMCC编译器将C转为无栈的代码，由于ROMCC使用寄存器保存数据，所以C代码中的变量及调用链受限。

2. Romstage: 进入Romstage之后，首先需要设置"Cache as RAM(CAR)"。具体地，设置CAR的过程由Intel FSP等完成。完成CAR之后，可以执行C代码。

在此阶段，完成一般的硬件初始化(PCI, Memory I/O, System I/O)之前的初始化工作，例如可以配置串口输出debug信息，内存初始化等。

涉及两个过程：1. 设置CAR: 通过FSP完成； 2.初始化RAM: 在CAR完成后可以调用C代码，通过C代码完成RAM初始化，初始化RAM的工作仍旧由FSP完成。

3. Ramstage: 进入Ramstage之后，内存已经完成初始化，Ramstage的代码也已经加载到内存中，并且已经可以完整地使用内存和CPU，包括堆栈/全局变量等。

Ramstage的目的是初始化I/O设备，additional application processors，SMM，同时配置传递给payloads或OS一些表(如ACPI等)。

PCI设备和legacy设备的初始化和device tree有关，device tree中注册了初始化相关的函数和数据结构。

Ramstage过程: 1. 遍历所有的设备，2. 调用FspNotifyPhase(AfterPCIEnumeration)，3.设置SMM，4.设置legacy table，5. 设置ACPI table，6. 调用FspNotifyPhase(ReadyToBoot), 在次过程中保护SMM和其他敏感的寄存器，7. 搜索payload，并调用执行payload。

Ramstage阶段本身是一个状态机，该状态机涉及pre_device, init_chips, dev_enumerate, dev_init, dev_enable, write_tables, payload_load, payload_boot等各个阶段。用户可以从一组状态机中，自定义设置启动的状态。


![CorebootStage](images/02_coreboot_stage.svg)
![BootPhase](images/01_BootPhase.png)

### coreboot源码分析

在获取`romstage`或`ramstage`时，会从头至尾搜索整个Flash，搜索到文件Header时，进一步判断是否为需要的stage file。搜索过程中步长为64B。搜索函数位于src/commonlib/bsd/cbfs_private.c:153(`cbfs_lookup()`)，及`cbfs_walk()`。


- 1. bootblock的启动
bootblock启动函数位于src/lib/bootblock.c中，`main()`及`bootblock_main_with_timestamp()`负责启动。在line 68中启动romstage(`run_romstage()`)。

在启动romstage时，涉及到函数`prog_run()`。


- 2. romstage的启动

在src/arch/x86/assembly_entry.S中完成"Cache as RAM(CAR)"的设置。
在设置完CAR之后，进入`car_stage_entry()`函数，位于src/arch/x86/romstage.c:8。在此函数内，执行初始化工作(src/cpu/intel/car/romstage.c:18 `romstage_main()`)，并调用postcar stage。

- 3. postcar的启动

完成CAR的销毁工作等。

postcar位于src/arch/x86/postcar.c:17 `main()`中，函数结尾调用`run_ramstage()`，启动ramstage阶段。

- 4. ramstage的启动

启动函数位于src/lib/hardwaremain.c:425 `main()`中。

### devicetree

devicetree是coreboot用于表示设备结构，同时用于定义设备的标准。devicetree.cb文件最终会被转化为ACPI SSDT table文件。

### Firmware Interface Table(FIT)

FIT包含每个microcode update的指针。