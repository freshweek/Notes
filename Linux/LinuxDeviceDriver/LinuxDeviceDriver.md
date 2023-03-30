## Chapter02: Buiding and Running
### Loading and Unloading Modules
* `insmod`: 加载module
* `modprobe`: 加载某个module, 同时加载该module依赖的其他modules；从标准安装目录中(`/lib/modules/$(shell uname -r)/`)搜索其他modules
* `rmmod`: 移除module
* `lsmod`: 列出当前加载到kernel的modules

### Kernel Symbol Table

Module被加载之后，Module中符号表成为kernel符号表的一部分。

Module可以导出符号(Symbols)，导出的符号可以被其他Module使用；导出的符号位于特定的ELF section中。
```c
EXPORT_SYMBOL(name);
EXPORT_SYMBOL_GPL(name);        // 只导出到GPL标准的Modules
```

### Preliminaries

* `MODULE_LICENSE("GPL)`: 代码使用的license, 包括"GPL", "GPL v2", "GPL and additional rights", "Dual BSD/GPL", "Dual MPL/GPL", "Proprietary"
* `MODULE_AUTHOR("...")`: Author
* `MODULE_DESCRIPTION("...")`: Module简单的描述
* `MODULE_VERSION("...")`: 版本号
* `MODULE_ALIAS("...")`: Module别名
* `MODULE_DEVICE_TABLE("...")`: 支持的设备


### Initialization and Shutdown

#### Initialization

```c
static int __init init_func1(void){}
module_init(func1);
```

`__init`描述符表示`init_func1`仅在初始化期间使用，Module loader可以在完成初始化后丢弃该函数；`__initdata`表示数据仅在初始化时使用。

#### Cleanup

```c
static int __exit exit_func1(void) {}
module_exit(exit_func1);
```

`__exit`表示函数仅在module退出时使用。

#### Error Handing During Initialization

在init过程中出现错误时，需要注意将申请的内存释放，注册的设备清除，防止内存溢出。

#### Module-Loading Races

在完成registration之后，kernal就可能调用module。因此，需要注意要在初始化工作完全完成之后，再将module注册到kernel中。

#### Module Parameters

Module传参方式：`insmod`, `modprobe`或配置文件`/etc/modprobe`。

```bash
$ insmod helloworld param1=10 param2="our"
```
```c
static int param1;
static char *param2;
module_param(param1, int, S_IRUGO);
module_param(param2, charp, S_IRUGO);
```

支持的参数类型：
* `bool`
* `invbool`
* `charp`: 字符串
* `int`
* `long`
* `short`
* `uint`
* `ulong`
* `ushort`

## Chapter03: Char Driver

### Major and Minor Numbers

Major number标识设备关联的驱动，Minor number表示特定的设备。
```c
MAJOR(dev_t dev);   // 获取major number
MINOR(dev_t dev);   // 获取minor number

MKDEV(int major, int minor);   // make dev_t from major and minor number
```

### Allocating and Freeing Device Numbers

```c
int register_chrdev_region(dev_t first, unsigned int count, char* name);
// 注册char device number到kernel中

int alloc_chrdev_region(dev_t *dev, unsigned int firstminor, unsigned int count, char *name);
// 由kernel分配minor number给module

void unregister_chrdev_region(dev_t first, unsigned int count);
// 注销设备号
```

`register_chrdev_region`需要人为提供设备号，有可能设备号被占用导致注册失败。`alloc_chrdev_region`由kernel分配设备号，有可能每次分配的设备号不一致，可以通过`awk`查询`/proc/devices`中的设备获取分配的设备号。
```bash
major=$(awk "\\$2==\"module\" {print \\$1}" /proc/devices)
```

### Some Important Data Structures

#### File Operations

`file_operations`结构体注册了driver支持的操作，包括`owner`, `read`, `write`, `ioctl`等。

```c
int (*open)(struct inode *inode, struct file *filp);

ssize_t (*read)(struct file *filp, char __user *buff, size_t count, loff_t *offp);
// 返回证书，且等于count，表示完全读取
// 返回正数，且小于count，表示未完全读取；caller再次尝试读取
// 返回负数，表示出错
// 返回0，表示无数据传输


ssize_t (*write)(struct file *filp, const char __user *buff, size_t count, loff_t *offp);
// 返回正数，且等于count，表示完全写
// 返回正数，且小于count，表示未完全写；caller再次尝试写
// 返回0，表示未写入；caller再次尝试写
// 返回负数，表示出错


unsigned long copy_to_user(void __user *to, const void *from, unsigned long count);
unsigned long copy_from_user(void *to, const void __user *from, unsigned long count);


ssize_t (*readv)(struct file *filp, const struct iovec *iov, unsigned long count, loff_t *ppos);
ssize_t (*write)(struct file *filp, const struct iovec *iov, unsigned long count, loff_t *ppos);
struct iovec{
    void __user *iov_base;
    __kernel_size_t iov_len;
};
// 成组地读取或写入

```

#### The file Structure

`file`结构体描述了kernel中打开的文件，其成员包括：
* `mode_t f_mode`: `FMODE_READ`, `FMODE_WRITE`
* `loff_t f_pos`: 标识`file`读写的位置
* `unsigned int f_flags`: `O_RDONLY`, `ONONBLOCK`, `O_SYNC`
* `struct file_operations *f_op`
* `void *private_data`: 可以在`open`函数中设置`private_data`描述的内容
* `struct dentry *f_dentry`

#### The inode Structure

kernel通过`inode`表示一个文件，`file`表示一个打开的文件，`inode`和`file`是一对多的关系。


### Char Device

```c
void cdev_init(struct cdev *cdev, struct file_operations *fops);
// 初始化

int cdev_add(struct cdev *dev, dev_t num, unsigned int count);
// 注册char device到kernel中

void cdev_del(struct cdev *cdev);
```

## Chapter04: Debugging Techniques

## Chapter05: Concurrency and Race

Race conditions来自于共同访问资源的情况。

### Semaphore and Mutex

```c
DECLARE_MUTEX(name);
DECLARE_MUTEX_LOCKED(name);     // 声明时即lock

void init_MUTEX(struct semaphore *sem);
void init_MUTEX_LOCKED(struct semaphore *sem);

void down(struct semaphore *sem);                   // 持续等待信号量直至可用，不可中断，进程不可kill
void down_interruptible(struct semaphore *sem);     // 持续等待信号量，可中断，需要通过返回值判断是否成功申请
void down_trylock(struct semaphore *sem);           // 尝试获取，立即返回

void up(struct semaphore *sem);


/* 读写信号量 **/
void init_rwsem(struct rw_semaphore *sem);

void down_read(struct rw_semaphore *sem);           // 等待，不可中断
int down_read_trylock(struct rw_semaphore *sem);    // 尝试，立即返回
void up_read(struct rw_semaphore *sem);

void down_write(struct rw_semaphore *sem);          // 等待，不可中断
int down_write_trylock(struct rw_semaphore *sem);
void up_write(struct rw_semaphore *sem);
void downgrade_write(struct rw_semaphore *sem);     // 可以使后续的read立即开始
```

读写信号量可能会导致read饿死。

### Spinlocks

* Spinlock不可中断，不可sleep
* 持有spinlock期间，需要将操作原子化
* 需要关注持有spinlock期间调用的函数，防止callee陷入sleep
* 持有spinlock期间，需要禁用中断
* 持有spinlock的时间尽可能短
  
```c
void spin_lock(spinlock_t *lock);       // 循环等待spinlock
void spin_lock_irqsave(spinlock_t *lock, unsigned long flags);  // 循环等待spinlock, 关中断，并将中断状态保存到flags
void spin_lock_irq(spinlock_t *lock);   // 循环等待spinlock, 关中断
void spin_lock_bh(spinlock_t *lock);    // 循环等待spinlock, 仅关闭软件中断

void spin_unlock(spinlock_t *lock);
void spin_unlock_irqrestore(spinlock_t *lock);
void spin_unlock_irq(spinlock_t *lock);
void spin_unlock_bh(spinlock_t *lock);

int spin_trylock(spinlock_t *lock);
int spin_trylock_bh(spinlock_t *lock);
```

**Reader/Writer Spinlocks**
读写spinlock可能会饿死reader。

```c
rwlock_t lock;
rwlock_init(&lock);

void read_lock(rwlock_t *lock);
void read_lock_irqsave(rwlock_t *lock);
void read_lock_irq(rwlock_t *lock);
void read_lock_bh(rwlock_t *lock);

void read_unlock(rwlock_t *lock);
void read_unlock_irqrestore(rwlock_t *lock);
void read_unlock_irq(rwlock_t *lock);
void read_unlock_bh(rwlock_t *lock);
// 没有read_trylock()

void write_lock(rwlock_t *lock);
void write_lock_irqsave(rwlock_t *lock, unsigned long flags);
void write_lock_irq(rwlock_t *lock);
void write_lock_bh(rwlock_t *lock);
void write_trylock(rwlock_t *lock);

void write_unlock(rwlock_t *lock);
void write_unlock_irqrestore(rwlock_t *lock);
void write_unlock_irq(rwlock_t *lock);
void write_unlock_bh(rwlock_t *lock);
```

### Locking Traps

* 防止嵌套的函数申请lock，否则可能会导致deadlock
    * 在static internal函数中，在需要锁时最好添加注释说明锁已经被lock，防止多次申请lock
* 在external函数中处理锁申请相关事务，static internal函数不处理semaphore
* 在需要多个锁时，保证锁的申请顺序一致，防止deadlock
* 优先申请local code相关的锁，再申请kernel相关的锁
* 先申请semaphore，再申请spinlock。防止spinlock在semaphore申请中sleep
* 不要太早地设计细粒度的锁，性能限制可能并不是锁相关，可是使用lockmeter查看申请锁的耗时

### Lock-Free Algorithms
#### Atomic Variables
#### Bit Operations
#### Seqlocks
#### Read-Copy-Update(RCU)


## Chapter09: Communicating with Hardware

