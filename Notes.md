### 1. 在WSL中设置proxy：https://developpaper.com/wsl2-connects-to-the-network-proxy-settings-of-the-host-windows-program/

### 2. difference between %ms and %s scanf

https://stackoverflow.com/questions/38685724/difference-between-ms-and-s-scanf

使用`%ms`会自动申请存储空间，因此在使用完毕后需要手动free；`%s`不会自动申请。

```c
char *p;
scanf("%ms", p);
free(p)

char buf[20];
scanf("%19s", buf);
```

    An optional 'm' character. This is used with string conversions (%s, %c, %[), and relieves the caller of the need to allocate a corresponding buffer to hold the input: instead, scanf() allocates a buffer of sufficient size, and assigns the address of this buffer to the corresponding pointer argument, which should be a pointer to a char * variable (this variable does not need to be initialized before the call). The caller should subsequently free(3) this buffer when it is no longer required.

### 3. writing udev rules

http://www.reactivated.net/writing_udev_rules.html

