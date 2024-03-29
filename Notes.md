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


### 6. In Bash scripting, what's the meaning of " $! "?

$! contains the process ID of the most recently executed background pipeline. From man bash:

https://unix.stackexchange.com/questions/85021/in-bash-scripting-whats-the-meaning-of


### 7. make submodule

```bash
cd /usr/src/kernel-sources
make SUBDIRS=drivers/staging/ft1000/ft1000-usb modules
# Enable the ft1000 module: CONFIG_FT1000=m  on the config with 
make xconfig # or "make menuconfig" then save
make prepare
make modules_prepare
make SUBDIRS=scripts/mod
make SUBDIRS=drivers/staging/ft1000/ft1000-usb modules
make SUBDIRS=drivers/staging/ft1000/ft1000-usb modules_install
```
https://askubuntu.com/questions/168279/how-do-i-build-a-single-in-tree-kernel-module


### 8. enable linux kernel driver dev_dbg debug messages

https://askubuntu.com/questions/1482728/debugging-kernel-module-with-dynamic-debug

https://stackoverflow.com/questions/50504516/enable-linux-kernel-driver-dev-dbg-debug-messages

https://www.kernel.org/doc/html/v4.11/admin-guide/dynamic-debug-howto.html

### 9. Out Of Band (OOB) management

https://en.wikipedia.org/wiki/Out-of-band_management


### 10. The x86 processor family is capable of addressing up to, but no more than, 64KB of IO address space

### 11. cut

cut each line with specific rule, and output the result.
```bash
cut  [-bn] [file] OR cut [-c] [file]  OR  cut [-df] [file]
```

```
    -b: cut by bytes, and output target field
    -c: cut by char, and output target field

    -d: cut by delimeter
    -f: and output target field

    -n: with -b, don't split multibyte characters
```
Example:
```bash
    cut -b 3,5-7 test.txt
    cut -c 3,5-7 test.txt
    cut -d : -f 3,5-7 test.txt
```

    `cut -f` default with delimiter '-d \t'

**Disadvantages**:
cut cannot deal with the circumstance of multi-spaces. It can only use ONE space as the delimeter.

https://www.cnblogs.com/dong008259/archive/2011/12/09/2282679.html

### 12. Setup kgdboc for kernel debugging

https://www.adityabasu.me/blog/2020/03/kgdboc-setup/

https://serverfault.com/questions/499942/virsh-attach-device-for-serial-device

### 13. Install deb package

```bash
sudo dpkg -i /path/to/deb/file
sudo apt-get install -f
```
https://unix.stackexchange.com/questions/159094/how-to-install-a-deb-file-by-dpkg-i-or-by-apt


### 14. ASM in C

https://dmalcolm.fedorapeople.org/gcc/2015-08-31/rst-experiment/how-to-use-inline-assembly-language-in-c-code.html
