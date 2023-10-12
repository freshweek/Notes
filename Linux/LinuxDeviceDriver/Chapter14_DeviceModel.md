# Ksets

将kobjects组织到一起，构成链表。

```c
int kobject_add(struct kobject *kobj)
// 将kobj注册到kernel，包括插入到kset中，生成sys目录等

void kobject_del(struct kobject *kobj);
// kobject_add的反函数，释放kobj

void kset_init(struct kset *kset);
int kset_add(struct kset *kset);

int kset_register(struct kset *kset);
int kset_unregister(struct kset *kset);

struct kset* kset_get(struct kset *kset);
void kset_put(struct kset *kset);
```

# kobject与sysfs的关系

## sysfs目录：kobject与sysfs的目录一一对应

1. 在对kobject对象调用`kobject_add()`操作时，都会根据`kobj`创建一个目录，目录的名字是`kobj`的`name`属性。
2. `kobj`的`parent`表示在sysfs中的父目录。

---

## sysfs文件：kobj_type的default_attrs成员与sysfs中的文件一一对应

```c
struct kobj_type {
	void (*release)(struct kobject *kobj);
	const struct sysfs_ops *sysfs_ops;
	struct attribute **default_attrs;	/* use default_groups instead */
};

struct attribute {
	const char		*name;
	umode_t			mode;
};

struct sysfs_ops {
	ssize_t	(*show)(struct kobject *, struct attribute *, char *);
	ssize_t	(*store)(struct kobject *, struct attribute *, const char *, size_t);
};

int sysfs_create_file(struct kobject *kobj, struct attribute *attr);
int sysfs_remove_file(struct kobject *kobj, struct attribute *attr);
```

1. 每个`struct attribute`表示一个文件属性，其中的`name`成员表示文件名，`mode`成员表示文件的读写权限。
2. 每次从用户空间读取`attribute`时，都会调用`struct sysfs_ops`的`show()`成员函数，内核需要实现`show()`函数，完成`attribute`的读取操作。
3. 每次在用户空间写`attribute`时，都会调用`store()`函数。
4. 实际上，`attribute`可以作为基类继续派生出子类，在子类中包含更丰富的信息。
4. 每个`struct attribute`通过`sysfs_create_file`创建sysfs文件，通过`sysfs_remove_file()`删除文件。

## sysfs软链接

```c
int sysfs_create_link(struct kobject *kobj, struct kobject *target, char *name);
void sysfs_remove_link(struct kobject *kobj, char *name);
```

1. 通过`sysfs_create_link()`将`kobj`指向`target`，`name`表示软链接的名字。

---


# 热拔插事件

热拔插事件(hotplug event)用于在系统配置出现改变时，由内核向用户空间发送通知。例如USB设备的插入等。

```c
struct kset_uevent_ops {
	int (* const filter)(struct kset *kset, struct kobject *kobj);
	const char *(* const name)(struct kset *kset, struct kobject *kobj);
	int (* const uevent)(struct kset *kset, struct kobject *kobj,
		      struct kobj_uevent_env *env);
};
```

1. 在kernel为`kobj`生成event事件后，都会调用`filter()`函数，由其表明是否过滤生成的event.
2. `hotplug()`函数用于生成热拔插事件。

# Bus

## struct bus_type
1. Bus是处理器和设备之间的通道，devices挂载在Bus上，drivers注册在Bus上。

```c
struct bus_type {
	char *name;
	struct device *dev_root;
	int (*match)(struct device *dev, struct device_driver *drv);
	// match函数用于判断device和driver是否匹配

	int (*probe)(struct device *dev);
	......
};

int __must_check bus_register(struct bus_type *bus);
void bus_unregister(struct bus_type *bus);

int bus_for_each_dev(struct bus_type *bus, struct device *start, void *data,
		     int (*fn)(struct device *dev, void *data));
// 从start开始遍历bus上所有的device，并执行fn函数；如果start为NULL，则从第一个开始遍历

int bus_for_each_drv(struct bus_type *bus, struct device_driver *start,
		     void *data, int (*fn)(struct device_driver *, void *));
// 从start开始遍历bus所有的driver,并执行fn函数

```

## struct bus_attribute

```c
struct bus_attribute {
	struct attribute	attr;
	ssize_t (*show)(struct bus_type *bus, char *buf);
	ssize_t (*store)(struct bus_type *bus, const char *buf, size_t count);
};

int __must_check bus_create_file(struct bus_type *bus,
					struct bus_attribute *bus_attr);
// 为bus添加bus_attr属性文件

void bus_remove_file(struct bus_type *, struct bus_attribute *);
// 移除bus的属性文件

```

**Example:**
```c
static ssize_t show_bus_version(struct bus_type *bus, char *buf)
{
	return snprintf(bus, PAGE_SIZE, "%s\n", Version);
}
static BUS_ATTR(version, S_IRUGO, show_bus_version, NULL);

if(bus_create_file(&ldd_bus_type, &bus_attr_version)) {
	printk(KERN_NOTICE "Unable to create version attribute\n");
}

// 本样例创建了/sys/bus/ldd/version文件，用于查看bus版本号
```

# Devices

1. Device描述了一个设备，通常Device不会单独地使用，而是作为“基类”派生出“子类”，在子类中添加附加信息。通过container_of就可以得到device“派生的子类”。

2. Device包含kobject成员变量，表示他可以被kobject成员链接。
3. Device包含device_driver*成员变量，表示设备关联的driver。
4. Device包含bus_type*成员变量，表示他所处的bus位置。

```c
struct device {
	struct kobject obj;
	struct device *parent;
	struct bus_type *bus;
	struct device_driver *driver;
	void *driver_data;

	struct class *class;
};

int device_register(struct device *dev);
void device_unregister(struct device *dev);

struct device_attribute {
	struct attribute	attr;
	ssize_t (*show)(struct device *dev, struct device_attribute *attr,
			char *buf);
	ssize_t (*store)(struct device *dev, struct device_attribute *attr,
			 const char *buf, size_t count);
};
// struct device_attribute表示device相关的属性，也就是sysfs中的文件

#define DEVICE_ATTR(_name, _mode, _show, _store) \
	struct device_attribute dev_attr_##_name = __ATTR(_name, _mode, _show, _store);

int device_create_file(struct device *device,
		       const struct device_attribute *entry);
// 创建属性/sysfs文件

void device_remove_file(struct device *dev,
			const struct device_attribute *attr);
// 移除属性/sysfs文件

```
