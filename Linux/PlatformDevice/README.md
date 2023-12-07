# Introduction

The platform drivers are that belong to a part of SOC, some of them are non-removable, non-discoverable, such as USB, I2C, UART, SPI, PCI, SATA, and so on.

**Physical bus:**
From an SoC point of view, those devices (buses) are connected internally through dedicated buses, and are specific to the manufacturer.

**Pseudo platform bus**
*pseudo platform bus* is a virtual bus for devices that are not seated on a physical bus.

# Platform Drivers

The platform driver must implement a `probe` function, called by the kernel when the module is inserted or when a device claims it.

```c
static struct platform_driver mypdrv = { 
    .probe    = my_pdrv_probe, 
    .remove   = my_pdrv_remove, 
    .driver   = { 
        .name     = "my_platform_driver", 
        .owner    = THIS_MODULE, 
    }, 
};
```

## Enable platform driver
#### `platform_driver_register`

registers and puts the driver into a list of drivers maintained by the kernel, so that its `probe()` function can be called on demand whenever a new match occurs.

#### `platform_driver_probe`

immediately runs the match loop, checks if there is a platform device with the matching name, and then calls the driver's `probe()` if a match occurred. **If not, the driver is ignored.**

The probe function is placed in an __init section, which is freed when the kernel boot has completed.

## Registering helper

### `module_platform_driver`
*module_platform_driver()* automatically do *platform_driver_register/release* work in `init/exit` function.

```c
#define module_platform_driver(__platform_driver) \ 
    module_driver(__platform_driver, platform_driver_register, \ 
            platform_driver_unregister) 
```

This macro will be responsible for registering our module with the platform driver core. No need for `module_init` and `module_exit` macros, nor `init` and `exit` functions anymore.

Relating call:
* `module_spi_driver(struct spi_driver)`
* `module_i2c_driver(struct i2c_driver)`
* `module_pci_driver(struct pci_driver)`
* `module_usb_driver(struct usb_driver)`
* `module_mdio_driver(struct mdio_driver)`

# Platform Devices

```c
struct platform_device { 
   const char *name; 
   u32 id; 
   struct device dev; 
   u32 num_resources; 
   struct resource *resource; 
};
```

# Device Resources

Resources represent all the elements that characterize the device from the hardware point of view, and that the device needs in order to be set up and work properly.

There are only six types of resources in the kernel, all listed in *include/linux/ioport.h*.
```c
#define IORESOURCE_IO  0x00000100  /* PCI/ISA I/O ports */ 
#define IORESOURCE_MEM 0x00000200  /* Memory regions */ 
#define IORESOURCE_REG 0x00000300  /* Register offsets */ 
#define IORESOURCE_IRQ 0x00000400  /* IRQ line */ 
#define IORESOURCE_DMA 0x00000800  /* DMA channels */ 
#define IORESOURCE_BUS 0x00001000  /* Bus */ 
```

```c
struct resource { 
    resource_size_t start; 
    resource_size_t end; 
    const char *name; 
    unsigned long flags; 
};
```
* `start/end`: This represents where the resource begins/ends. For I/O or memory regions, it represents where they begin/end. For IRQ lines, buses or DMA channels, start/end must have the same value.
* `flags`: This is a mask that characterizes the type of resource, for example `IORESOURCE_BUS`.
* `name`: This identifies or describes the resource.

```c
struct resource *platform_get_resource(struct platform_device *dev, unsigned int type, unsigned int num); 
```
`platform_get_resource` will look up the `resource` array, and find the `num`th `resource` of specific type.

If the resource is an IRQ, we **must use** `platform_get_irq`
```c
int platform_get_irq(struct platform_device *dev, unsigned int num);
```

**Example**:
```c
static int my_driver_probe(struct platform_device *pdev) 
{ 
    struct my_gpios *my_gpio_pdata = 
            (struct my_gpios*)dev_get_platdata(&pdev->dev); 
    [...]

    struct resource *res1, *res2; 
    void *reg1, *reg2; 
    int irqnum; 
 
    res1 = platform_get_resource(pdev, IORESSOURCE_MEM, 0); 
    if((!res1)){ 
        pr_err(" First Resource not available"); 
        return -1; 
    } 
    res2 = platform_get_resource(pdev, IORESSOURCE_MEM, 1); 
    if((!res2)){ 
        pr_err(" Second Resource not available"); 
        return -1; 
    } 
 
    /* extract the irq */ 
    irqnum = platform_get_irq(pdev, 0); 
    pr_info("IRQ number of Device: %d\n", irqnum); 

    [...]
    return 0; 
} 
```

# Platform Data

Any other data whose type is not a part of the resource types enumerated in the preceding section falls here (for example, GPIO).

**Example**:
```c
/*our platform data*/ 
static struct my_gpios needed_gpios = { 
    .reset_gpio = 47, 
    .led_gpio   = 41, 
}; 
 
/* Our resource array */ 
static struct resource needed_resources[] = { 
   [0] = { /* The first memory region */ 
         .start = JZ4740_UDC_BASE_ADDR, 
         .end   = JZ4740_UDC_BASE_ADDR + 0x10000 - 1, 
         .flags = IORESOURCE_MEM, 
         .name  = "mem1", 
   }, 
   [1] = { 
         .start = JZ4740_UDC_BASE_ADDR2, 
         .end   = JZ4740_UDC_BASE_ADDR2 + 0x10000 -1, 
         .flags = IORESOURCE_MEM, 
         .name  = "mem2", 
   }, 
}; 
 
static struct platform_device my_device = { 
    .name = "my-platform-device", 
    .id   = 0, 
    .dev  = { 
        .platform_data      = &needed_gpios, 
    }, 
    .resource              = needed_resources, 
    .num_resources = ARRY_SIZE(needed_resources), 
}; 
```

Use `dev_get_platdata` to get platform data.
```c
void *dev_get_platdata(const struct device *dev);

struct my_gpios *picked_gpios = dev_get_platdata(&pdev->dev);
```

# Matching among platform devices and drivers

At compilation time, the build process extracts `MODULE_DEVICE_TABLE` out of the driver and builds a human readable file called `modules.alias`, and located in the directory `/lib/modules/kernel_version/`.

***If the driver can be compiled as a module, the `driver.name` field should match the module name.*** If it does not match, the module won't be automatically loaded, unless we have used the `MODULE_ALIAS` macro to add another name for the module.

```c
#define MODULE_DEVICE_TABLE(type, name) 
```
* `type`: This can be either `i2c`, `spi`, `acpi`, `of`, `platform`, `usb`, `pci` or any other bus you may find in `include/linux/mod_devicetable.h`.
* `name`: This is a pointer on a `XXX_device_id` array, used for device matching, such as `i2c_device_id`, `pci_device_id`, etc.


**Time to load a device driver**:
When the kernel has to find the driver for a device (when a matching needs to be performed), the device table is walked through by the kernel. If an entry is found matching the `compatible` (for device tree), `device/vendor id`, or `name` (for device ID table or name) values of the added device, then the module providing that match is loaded (running the module's `init` function), and the `probe` function is called.

**Example**:
```c
struct platform_device_id { 
   char name[PLATFORM_NAME_SIZE]; 
   kernel_ulong_t driver_data; 
};

static int platform_match(struct device *dev, struct device_driver *drv) 
{ 
   struct platform_device *pdev = to_platform_device(dev); 
   struct platform_driver *pdrv = to_platform_driver(drv); 
 
   /* When driver_override is set, only bind to the matching driver */ 
   if (pdev->driver_override) 
        return !strcmp(pdev->driver_override, drv->name); 
 
   /* Attempt an OF style match first */ 
   if (of_driver_match_device(dev, drv)) 
        return 1; 
 
   /* Then try ACPI style match */ 
   if (acpi_driver_match_device(dev, drv)) 
        return 1; 
 
   /* Then try to match against the id table */ 
   if (pdrv->id_table) 
        return platform_match_id(pdrv->id_table, pdev) != NULL; 
 
   /* fall-back to driver name match */ 
   return (strcmp(pdev->name, drv->name) == 0); 
} 
static const struct platform_device_id *platform_match_id( 
                        const struct platform_device_id *id, 
                        struct platform_device *pdev) 
{ 
    while (id->name[0]) { 
        if (strcmp(pdev->name, id->name) == 0) { 
                pdev->id_entry = id; 
                return id; 
        } 
        id++; 
    } 
    return NULL; 
}

struct device_driver { 
    const char *name; 
    [...] 
    const struct of_device_id       *of_match_table; 
    const struct acpi_device_id     *acpi_match_table; 
}; 

struct bus_type platform_bus_type = {
    .match = platform_match,
    [...]
}
```

**`of_match_table` is related to device_tree, `acpi_match_table` is related to `acpi_device_id`.**


# ID table matching

`struct platform_device_id` declares the supported devices of current driver, and `driver_data` in `platform_device_id` can be used to pass device-dedicated data.

```c
static const struct platform_device_id imx_uart_devtype[] = { 
    { 
        .name = "imx1-uart", 
        .driver_data = (kernel_ulong_t) &imx_uart_devdata[IMX1_UART], 
    },{ 
        .name = "imx21-uart", 
        .driver_data = (kernel_ulong_t) &imx_uart_devdata[IMX21_UART], 
    },{ 
        /* sentinel */ 
    } 
}; 

static void serial_imx_probe_pdata(struct imx_port *sport, 
         struct platform_device *pdev) 
{ 
   struct imxuart_platform_data *pdata = dev_get_platdata(&pdev->dev); 
 
   sport->port.line = pdev->id; 
   sport->devdata = (structimx_uart_data *) pdev->id_entry->driver_data; 
 
   if (!pdata) 
         return; 
   [...] 
} 

static struct platform_driver mypdrv = { 
    .probe    = my_pdrv_probe, 
    .remove   = my_pdrv_remove, 
    .id_table = imx_uart_devtype,
    .driver   = { 
        .name     = "my_platform_driver", 
        .owner    = THIS_MODULE, 
    }, 
};
```

