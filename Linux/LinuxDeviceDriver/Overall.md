# Bus

A bus is a channel link between devices and processors. A bus is represented in the kernel by the `struct bus_type` structure. 

```c
struct bus_type { 
   const char *name; 
   const char *dev_name; 
   struct device *dev_root; 
   struct device_attribute  *dev_attrs; /* use dev_groups instead */ 
   const struct attribute_group **bus_groups; 
   const struct attribute_group **dev_groups; 
   const struct attribute_group **drv_groups; 
 
   int (*match)(struct device *dev, struct device_driver *drv); 
   int (*probe)(struct device *dev); 
   int (*remove)(struct device *dev); 
   void (*shutdown)(struct device *dev); 
 
   int (*suspend)(struct device *dev, pm_message_t state); 
   int (*resume)(struct device *dev); 
 
   const struct dev_pm_ops *pm; 
 
   struct subsys_private *p; 
   struct lock_class_key lock_key; 
}; 
```

**The bus controller is a device itself. It's the parent of all devices registered on the bus.**

the bus controller driver must define a bus-specific driver structure that extends the generic struct device_driver,

and a bus-specific device structure that extends the generic struct device structure, both part of the device model core.

The bus controller driver is responsible for initializing the `bus` and `parent` field of the device.

```c
/* 
 * This function allocate a bus specific device structure 
 * One must call packt_device_register to register 
 * the device with the bus 
 */ 
struct packt_device * packt_device_alloc(const char *name, int id) 
{ 
   struct packt_device *packt_dev; 
   int status; 
 
   packt_dev = kzalloc(sizeof *packt_dev, GFP_KERNEL); 
   if (!packt_dev) 
         return NULL; 
 
    /* new devices on the bus are son of the bus device */ 
    strcpy(packt_dev->name, name); 
    packt_dev->dev.id = id; 
    dev_dbg(&packt_dev->dev, 
      "device [%s] registered with packt bus\n", packt_dev->name); 
 
    return packt_dev; 
 
out_err: 
    dev_err(&adap->dev, "Failed to register packt client %s\n", packt_dev->name); 
    kfree(packt_dev); 
    return NULL; 
} 
EXPORT_SYMBOL_GPL(packt_device_alloc); 
 
int packt_device_register(struct packt_device *packt) 
{ 
    packt->dev.parent = &packt_bus; 
   packt->dev.bus = &packt_bus_type; 
   return device_register(&packt->dev); 
} 
EXPORT_SYMBOL(packt_device_register); 
```

## Bus Registration

```c
/* 
 * This is our bus structure 
 */ 
struct bus_type packt_bus_type = { 
   .name      = "packt", 
   .match     = packt_device_match, 
   .probe     = packt_device_probe, 
   .remove    = packt_device_remove, 
   .shutdown  = packt_device_shutdown, 
}; 

/* 
 * Bus device, the master. 
 *  
 */ 
struct device packt_bus = { 
    .release  = packt_bus_release, 
    .parent = NULL, /* Root device, no parent needed */ 
}; 
 
static int __init packt_init(void) 
{ 
    int status; 
    status = bus_register(&packt_bus_type); 
    if (status < 0) 
        goto err0; 
 
    status = class_register(&packt_master_class); 
    if (status < 0) 
        goto err1; 
 
    /* 
     * After this call, the new bus device will appear 
     * under /sys/devices in sysfs. Any devices added to this 
     * bus will shows up under /sys/devices/packt-0/. 
     */ 
    device_register(&packt_bus); 
 
   return 0; 
 
err1: 
   bus_unregister(&packt_bus_type); 
err0: 
   return status; 
}
```

# Device driver

`struct device_driver` defines a simple set of operations for the core to perform these actions on each device:

```c
struct device_driver { 
    const char *name; 
    struct bus_type *bus; 
    struct module *owner; 
 
    const struct of_device_id   *of_match_table; 
    const struct acpi_device_id  *acpi_match_table; 
 
    int (*probe) (struct device *dev); 
    int (*remove) (struct device *dev); 
    void (*shutdown) (struct device *dev); 
    int (*suspend) (struct device *dev, pm_message_t state); 
    int (*resume) (struct device *dev); 
    const struct attribute_group **groups; 
    const struct dev_pm_ops *pm; 
}; 
```

## Device driver registration

`driver_register()` is the low-level function used to register a device driver with the bus. It adds the driver to the bus's list of drivers.

When a device driver is registered with the bus, the core walks through the bus's list of devices and calls the bus's match callback for each device that does not have a driver associated with it.

When a match occurs, the device and the device driver are bound together. The process of associating a device with a device driver is called binding.

This helper iterates over the bus's list of drivers, and calls the fn callback for each driver in the list.

```c
int bus_for_each_drv(struct bus_type * bus, 
                struct device_driver * start,  
                void * data, int (*fn)(struct device_driver *, 
                void *)); 
```

# Device

The struct device is the generic data structure used to describe and characterize each device on the system, whether it is physical or not.

```c
struct device { 
    struct device *parent; 
    struct kobject kobj; 
    const struct device_type *type; 
    struct bus_type      *bus; 
    struct device_driver *driver; 
    void    *platform_data; 
    void *driver_data; 
    struct device_node      *of_node; 
    struct class *class; 
    const struct attribute_group **groups; 
    void (*release)(struct device *dev); 
}; 
```

## Device registration

`device_register` is the function provided by the LDM core to register a device with the bus. After this call, the bus list of drivers is iterated over to find the driver that supports this device, and then this device is added to the bus's list of devices. `device_register()` internally calls `device_add()`.

Whenever a device is added, the core invokes the match method of the bus driver `(bus_type->match)`. If the match function says there is a driver for this device, the core will invoke the probe function of the bus driver `(bus_type->probe)`. Then up to the bus driver to invoke the probe method of the device's driver `(driver->probe)`.


The helper function provided by the kernel to iterate over the bus's list of devices is `bus_for_each_dev`:
```c
int bus_for_each_dev(struct bus_type * bus, 
                    struct device * start, void * data, 
                    int (*fn)(struct device *, void *)); 
```


# kobject

`kobject` is the core of the device model, is mainly used for reference counting and to expose devices hierarchies and relationships between them.


```c
struct kobject { 
    const char *name; 
    struct list_head entry; 
    struct kobject *parent; 
    struct kset *kset; 
    struct kobj_type *ktype; 
    struct sysfs_dirent *sd; 
    struct kref kref; 
    /* Fields out of our interest have been removed */ 
}; 
```
* `sd` points to a `struct sysfs_dirent` structure that represents this kobject in sysfs inode inside this structure for sysfs.
* `ktype` describes the object.
* `kset` tells us which set (group) of objects this object belongs to.

```c
struct kobject *kobject_create(void);
void kobject_init(struct kobject *kobj, struct kobj_type *ktype);
int kobject_add(struct kobject *kobj, struct kobject *parent, const char *fmt, ...); 

kobject_create_and_add == kobject_create + kobject_add
```

***If a kobject has a NULL parent, then kobject_add sets the parent to kset. If both are NULL, the object becomes a child-member of the top-level sys directory.***

# kobj_type

A `struct kobj_type` structure describes the behavior of kobjects. It will control what happens when the `kobject` is created and destroyed, and when attributes are read or written to.

```c
struct kobj_type { 
   void (*release)(struct kobject *); 
   const struct sysfs_ops sysfs_ops; 
   struct attribute **default_attrs; 
}; 
```

A `struct kobj_type` structure allows kernel objects to share common operations `(sysfs_ops)`, whether those objects are functionally related or not.

`sysfs_ops` is a set of callbacks (sysfs operation) called when a sysfs attribute is accessed. `default_attrs` is a pointer to a list of struct attribute elements that will be used as default attributes for each object of this type.

```c
struct sysfs_ops { 
    ssize_t (*show)(struct kobject *kobj, 
                    struct attribute *attr, char *buf); 
    ssize_t (*store)(struct kobject *kobj, 
                     struct attribute *attr,const char *buf, 
                     size_t size); 
}; 
```


```c
static struct sysfs_ops s_ops = { 
    .show = show, 
    .store = store, 
}; 
 
static struct kobj_type k_type = { 
    .sysfs_ops = &s_ops, 
    .default_attrs = d_attrs, 
}; 

static ssize_t show(struct kobject *kobj, struct attribute *attr, char *buf) 
{ 
    struct d_attr *da = container_of(attr, struct d_attr, attr); 
    printk( "LDM show: called for (%s) attr\n", da->attr.name ); 
    return scnprintf(buf, PAGE_SIZE, 
                     "%s: %d\n", da->attr.name, da->value); 
} 
 
static ssize_t store(struct kobject *kobj, struct attribute *attr, const char *buf, size_t len) 
{ 
    struct d_attr *da = container_of(attr, struct d_attr, attr); 
    sscanf(buf, "%d", &da->value); 
    printk("LDM store: %s = %d\n", da->attr.name, da->value); 
 
    return sizeof(int); 
} 
```

# ksets

Kernel object sets (ksets) mainly group related kernel objects together.

ksets are a collection of kobjects. In other words, a kset gathers related kobjects into a single place, for example, all block devices.

```c
struct kset { 
   struct list_head list;  
   spinlock_t list_lock; 
   struct kobject kobj; 
 }; 
```

```c
struct kset * kset_create_and_add(const char *name, 
                                const struct kset_uevent_ops *u, 
                                struct kobject *parent_kobj); 
void kset_unregister (struct kset * k); 
```

```c
static struct kobject foo_kobj, bar_kobj; 
 
example_kset = kset_create_and_add("kset_example", NULL, kernel_kobj); 
/* 
 * since we have a kset for this kobject, 
 * we need to set it before calling the kobject core. 
 */ 
foo_kobj.kset = example_kset; 
bar_kobj.kset = example_kset; 
    
retval = kobject_init_and_add(&foo_kobj, &foo_ktype, NULL, "foo_name"); 
retval = kobject_init_and_add(&bar_kobj, &bar_ktype, NULL, "bar_name");
```

# attributes


Attributes are sysfs files exported to the user space by kobjects.

An attribute represents an object property that can be readable, writable, or both, from the user space.

```c
struct attribute { 
        char * name; 
        struct module *owner; 
        umode_t mode; 
};

int sysfs_create_file(struct kobject * kobj, 
                      const struct attribute * attr); 
void sysfs_remove_file(struct kobject * kobj, 
                        const struct attribute * attr); 
```

## The attribute group

We have seen how to individually add attributes and call `sysfs_create_file()` on each of them. The group is just a helper wrapper that makes it easier to manage multiple attributes.

```c
struct attribute_group { 
   struct attribute  **attrs; 
}; 
```

```c
int sysfs_create_group(struct kobject *kobj, const struct attribute_group *grp);
void sysfs_remove_group(struct kobject * kobj, const struct attribute_group * grp);
```

# sysfs

Sysfs is a non-persistent virtual filesystem that provides a global view of the system and exposes the kernel object's hierarchy (topology) by means of their kobjects.

* **block** contains a directory per-block device on the system, each of which contains subdirectories for partitions on the device.
* **bus** contains the registered bus on the system.
* **dev** contains the registered device nodes in a raw way (no hierarchy), each being a symlink to the real device in the /sys/devices directory.
* **devices** gives a view of the topology of devices in the system.
* **firmware** shows a system-specific tree of low-level subsystems, such as: ACPI, EFI, OF (DT).
* **fs** lists filesystems actually used on the system.
* **kernel** holds kernel configuration options and status info.
* **Modules** is a list of loaded modules.

One can create/remove symbolic links on existing objects (directories).
```c
int sysfs_create_link(struct kobject * kobj, 
                      struct kobject * target, char * name);
void sysfs_remove_link(struct kobject * kobj, char * name);
```
The create function will create a symlink named name pointing to the target kobject sysfs entry.

## sysfs files and attributes

The default set of files is provided through the `ktype` field in kobjects and ksets, through the `default_attrs` field of `kobj_type`.

```c
int sysfs_create_file(struct kobject *kobj, const struct attribute *attr); 
void sysfs_remove_file(struct kobject *kobj, const struct attribute *attr); 
int sysfs_create_group(struct kobject *kobj, const struct attribute_group *grp); 
void sysfs_remove_group(struct kobject * kobj, const struct attribute_group * grp); 
```

## Device attributes

```c
struct device_attribute { 
    struct attribute attr; 
    ssize_t (*show)(struct device *dev, 
                    struct device_attribute *attr, 
                   char *buf); 
    ssize_t (*store)(struct device *dev, 
                     struct device_attribute *attr, 
                     const char *buf, size_t count); 
}; 

#define DEVICE_ATTR(_name, _mode, _show, _store) \ 
   struct device_attribute dev_attr_##_name = __ATTR(_name, _mode, _show, _store)

int device_create_file(struct device *dev,  
                      const struct device_attribute * attr); 
void device_remove_file(struct device *dev, 
                       const struct device_attribute * attr); 
```

We used to define the same set of store/show callbacks for all attributes of the same kobject/ktype. 

```c
static ssize_t dev_attr_show(struct kobject *kobj, 
                            struct attribute *attr, 
                            char *buf) 
{ 
   struct device_attribute *dev_attr = to_dev_attr(attr); 
   struct device *dev = kobj_to_dev(kobj); 
   ssize_t ret = -EIO; 
 
   if (dev_attr->show) 
         ret = dev_attr->show(dev, dev_attr, buf); 
   if (ret >= (ssize_t)PAGE_SIZE) { 
         print_symbol("dev_attr_show: %s returned bad count\n", 
                     (unsigned long)dev_attr->show); 
   } 
   return ret; 
} 
 
static ssize_t dev_attr_store(struct kobject *kobj, struct attribute *attr, 
                     const char *buf, size_t count) 
{ 
   struct device_attribute *dev_attr = to_dev_attr(attr); 
   struct device *dev = kobj_to_dev(kobj); 
   ssize_t ret = -EIO; 
 
   if (dev_attr->store) 
         ret = dev_attr->store(dev, dev_attr, buf, count); 
   return ret; 
} 
 
static const struct sysfs_ops dev_sysfs_ops = { 
   .show = dev_attr_show, 
   .store      = dev_attr_store, 
}; 
```


## Bus attributes

```c
struct bus_attribute { 
   struct attribute attr; 
   ssize_t (*show)(struct bus_type *, char * buf); 
   ssize_t (*store)(struct bus_type *, const char * buf, size_t count); 
}; 

#define BUS_ATTR(_name, _mode, _show, _store)      \ 
    struct bus_attribute bus_attr_##_name = __ATTR(_name, _mode, _show, _store) 

int bus_create_file(struct bus_type *, struct bus_attribute *); 
void bus_remove_file(struct bus_type *, struct bus_attribute *); 
```

## Device driver attributes

```c
struct driver_attribute { 
        struct attribute attr; 
        ssize_t (*show)(struct device_driver *, char * buf); 
        ssize_t (*store)(struct device_driver *, const char * buf, 
                         size_t count); 
}; 

#define DRIVER_ATTR(_name, _mode, _show, _store) \ 
    struct driver_attribute driver_attr_##_name = __ATTR(_name, _mode, _show, _store) 

int driver_create_file(struct device_driver *, const struct driver_attribute *); 
void driver_remove_file(struct device_driver *, const struct driver_attribute *); 
```

## Class attributes

```c
struct class_attribute { 
        struct attribute        attr; 
        ssize_t (*show)(struct device_driver *, char * buf); 
        ssize_t (*store)(struct device_driver *, const char * buf, 
                         size_t count); 
}; 

#define CLASS_ATTR(_name, _mode, _show, _store) \ 
    struct class_attribute class_attr_##_name = __ATTR(_name, _mode, _show, _store) 


int class_create_file(struct class *class, const struct class_attribute *attr); 
void class_remove_file(struct class *class, const struct class_attribute *attr); 
```

***Notice that `device_create_file()`, `bus_create_file()`, `driver_create_file()`, and `class_create_file()` all make an internal call to `sysfs_create_file()`. As they all are kernel objects, they have a kobject embedded into their structure. That kobject is then passed as a parameter to `sysfs_create_file`, as you can see in the following code.***

