# Kobject

### 基本功能
1. 持有ojbect的引用计数
2. 每个sysfs底层都有kobject，与kernel交互
3. 数据结构glue
4. 处理热拔插事件，通知user space硬件的拔插

kobject通常以成员变量的方式存在与其他structure中，很少单独使用。kobject服务于派生的类型。

### 初始化

```c
memset(kobj, 0, sizeof(kobj));

kobject_init(struct kobject *kobj, struct kobj_type *ktype);

kobject_set_name(struct kobject *kobj, const char *format, ...);
// 设置kobj的名字
```

### 引用计数修改

```c
struct kobject *kobject_get(struct kobject *kobj);

void kobject_put(struct kobject *kobj);
```

由于kobject释放的时机不可控，可能在任意时刻引用计数变为0。需要在引用计数变为0时将kobject对象release。
具体的release方法存在于kobj_type的release成员中。

### Parent成员

kobject中的parent成员表示该kobject的上一级对象，用于组成多层架构。

# Kset

### 