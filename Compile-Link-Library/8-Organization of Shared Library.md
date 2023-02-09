
## 1. 共享库的兼容性
### 1.1. 导致C语言的共享库ABI改变的行为
1. 导出函数的行为发生改变
2. 导出函数被删除
3. 导出数据结构发生改变，例如结构体的成员布局改变，成员删除
4. 导出函数的接口改变，例如返回值、参数被更改

由于C++对ABI接口没有准确的定义，不同的编译器对类、模板、虚函数有不同的实现，导致ABI兼容很困难。**最好不要使用C++导出ABI**。

### 1.2. 共享库版本命名

**lib*name*.so.*x*.*y*.*z***

* x: 主版本号(Major)，不同主版本号的库之间不兼容；
* y: 次版本号(Minor)，表示库的增量升级，原有符号不变，高的次版本号兼容低的次版本号；
* z: 发布版本号(Release)，表示库的修正、性能的改进，不修改任何接口。

**相同主版本号、次版本号的共享库，不同发布版本号之间完全兼容。**

### 1.3. SO-NAME

共享库的文件名只保留主版本号，例如libfoo.so.2.6.1->libfoo.so.2；使用libfoo.so.2软链接到具体的文件。

共享库中的`.dynamic`使用SO-NAME表示共享链接器的版本。

在链接时使用参数`-lc`，链接器会根据输出文件的（动态/静态）选择合适版本的库；例如ld使用`-static`参数时会查找libc.a，使用`-Bdynamic`会查找libc.so.x.y.z。

## 2. 共享库的搜索路径

* /lib
* /usr/lib
* /usr/local/lib
* /etc/ld.so.conf文件中的目录

Linux的`ldconfig`程序会更新共享库SO-NAME的软链接，同时把这些共享库的路径保存到/etc/ld.so.cache文件中，建立SO-NAME的缓存。

## 3. 环境变量

* LD_LIBRARY_PATH: 由若干路径组成，冒号分隔。

## 4. 共享库的创建

```bash
$ gcc -shared -Wl,-soname,my_soname -o library_name source_files library_files
```

`-shared`: 表示输出结果是共享库类型的；
`-fPIC`: 地址无关技术生成代码；
`-Wl,-soname,my_soname`: GCC将`-soname,my_soname`传递给链接器，用来指定输出共享库的SO-NAME。

例如有libfoo1.c和libfoo2.c，想要产生libfoo.so.1.0.0，这个共享库依赖libbar1.so和libbar2.so，可以需要使用如下指令：

```bash
$ gcc -shared -fPIC -Wl,-soname,libfoo.so.1 -o libfoo.so.1.0.0 libfoo1.c libfoo2.c -lbar1 -lbar2
```

## 5. 清除符号信息

```bash
$ strip libfoo.so
```

## 6. 共享库的安装

* 如果有root权限，可以运行`ldconfig`；
* 如果没有root权限，可以运行`ldconfig -n output_directory`，则共享库输出到`output_directory`。编译程序时，加上参数`-L`和`-l`分别指定共享库的搜索目录和搜索路径。

## 7. 共享库的构造和析构函数

共享库被装载时如果需要进行初始化工作，例如打开文件或网络连接，则在函数声明前加上`__attribute__((constructor))`表示该共享库的构造函数。

```c
void __attribute((constructor)) init_fun1(void);
void __attribute((constructor(2))) init_fun2(void);
void __attribute((destructor(2))) fini_fun2(void);
void __attribute((destructor)) fini_fun1(void);
```