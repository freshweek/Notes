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

### 4. Bash test: what does "=~" do?

The ~ is actually part of the operator =~, which performs a regular expression match of the string to its left to the extended regular expression on its right.

    [[ "string" =~ pattern ]]

Note that the string should be quoted, and the regular expression shouldn't be quoted (unless you want to match literal strings).


https://unix.stackexchange.com/questions/340440/bash-test-what-does-do

### 5. What does "${!var}" mean in shell script? [duplicate]

It's like a pointer.
```bash
$ hello="this is some text"   # we set $hello
$ var="hello"                 # $var is "hello"
$ echo "${!var}"              # we print the variable linked by $var's content
this is some text
```

https://stackoverflow.com/questions/40928492/what-does-var-mean-in-shell-script