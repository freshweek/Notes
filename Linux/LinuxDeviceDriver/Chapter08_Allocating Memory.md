# kmalloc

### 函数原型
```c
#include <linux/slab.h>

void *kmalloc(size_t size, int flags);
```

* `int flags`
```c

GFP_KERNEL: allocate kernel memory; may sleep

GFP_ATOMIC: allocate from interrupt handlers and other code out of process context, **Never Sleep**

GFP_USER: allocate memory for user-space pages; may sleep

GFP_HIGHUSER: allocate high memory

GFP_NOIO / GFP_NOFS: GFP_NOIO不允许启用IO，GFP_NOFS不允许任何filesystem calls

```

GFP_KERNEL内部调用`__get_free_pages`获取内存，获取GFP_KERNEL类型的内存时，不能运行在atomic context，可能会sleep。

GFP_ATOMIC使用系统预留的free page。

### 分配大小

一般来说，`kmalloc`分配的最大最小空间与平台相关，最小空间为32B或64B，最大最好不要超过128KB。

# kmem_cache_t

内核中通常需要分配大量size相同的type，可以通过一些方式将这些size相同的变量组织到相邻的位置，从而高效地使用他们，`kmem_cache_t`完成这项工作。

```c
kmem_cache_t *kmem_cache_create(const char *name, size_t size, size_t offset,
                            unsigned long flags, 
                            void (*constructor)(void *, kmem_cache_t *, unsigned long flags),
                            void (*destrutor)(void *, kmem_cache_t *, unsigned long flags))
其中, name为region名字，size为变量的大小，offset为第一个对象的页偏移量

void *kmem_cache_alloc(kmem_cache_t *cache, int flags)
从cache区域中分配一个大小为size的内存区域，size在kmem_cache_create中指定

void kmem_cache_free(kmem_cache_t *cache, const void *obj)
释放内存区域obj

int kmem_cache_destroy(kmem_cache_t *cache)
destroy cache
```

