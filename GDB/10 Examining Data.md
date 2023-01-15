## 10.3 Program Variables

    print *file::variable*
    print *function::variable*

输出某个文件或某个函数中的变量

**Example**:

    print 'test.c'::a
    printf func1::a

---

    print *variable*@entry

输出变量*variable*在函数入口时的值

---

    print *array@len
    --> print *arr1@5
打印数组*array*之后的*len*长度的内容

---

## 10.5 Output Formats

    p/x: 十六进制
    p/d: 十进制
    p/u: 无符号十进制数
    p/o: 八进制
    p/t: 二进制
    p/a: 打印地址，并显示地址所处的函数名
    p/c: 转为十进制，并显示ASCII内容
    p/f: 打印float
    p/s: 打印字符串
    p/z: 打印十六进制，并填充前缀0
    p/r: 打印'raw'格式

## 10.6 Examing Memory

检查内存的内容，包括指令和数据，数据可以以特殊进制或字符串的方式展示。

    x/*nfu* *addr*: 检查(examine)地址addr的内容，并以特定格式*nfu*展示，
    
    其中：
    n: 重复数量，表示检查多少个addr后的内容
    f: 展示的格式，包括x, d, u, o, t, a, c, f, s, i(指令), m(内存tag); 默认为x格式
    u: 单个元素的大小, 包括:
        b(byte)
        h(halfwords, two bytes)
        w(words, four bytes)
        g(eight bytes)
**注意**：该指令中的*addr*是地址值，如果写为变量，则会将变量值作为地址. 

**Example**:

    x/3uh 0x54320: 查看从0x54320开始的3个halfwords的值，并打印为unsigned decimal.

    x/5i $pc: 查看$pc之后的5个指令的值.

    x/-4xw $sp: 查看栈指针$sp之前4个words的值，并打印为hexadecimal.

## 10.8 Automatic Display

设置为automatic display的变量，在每次执行完毕时，都会显示值。

    display *expr*

    display/*fmt* *expr*: 显示表达式*expr*的值;
    其中*fmt*可以是: x, d, u, o, t, a, c, f, s, z, r;
    和10.5 Output Format小节中的内容相同.

    display/*fmt* *addr*: 显示地址*addr*指向的内容;
    其中*fmt*是*nfu*, 和10.6 Examing Memory的格式相同.

---

    undisplay *dnums*...
    or
    delete display *dnums*...

    删除*dnums*表示的display

---

    disable display *dnums*...
    enable display *dnums*...

    无效或生效display

---
    display: 展示当前所有的display的内容
    info display: 输出当前display表示


## 10.9 Print Settings

    set print address
    set print address on
    set print address off
    show print address

是否打印栈帧、结构体、指针、断点等的内存地址, 默认on

Example:

    set print address on
    (gdb) f
    #0 set_quotes(lq=0x34c78 "<<") at input.c:530

    set print address off
    (gdb) f
    #0 set_quotes(lq="<<") at input.c:530

---

    set print symbol-filename on
    set print symbol-filename off
    show print symbol-filename
    set print max-symbolic-offset *max-offset*
    set print max-symbolic-offset unlimited
    show print max-symbolic-offset

在打印符号地址时，显示符号地址所处的文件, 默认off

---

    set print array
    set print array on
    set print array off
    show print array
    是否以更松散的方式打印数组, 添加额外的空格, 默认off

    set print array-indexes
    set print array-indexes on
    set print array-indexes off
    show print array-indexes
    是否打印数组的index, 默认off

---

    set print nibbles
    set print nibbles on
    set print nibbles off
    show print nibbles
    以二进制方式打印数据时，将4个二进制聚到一起, 默认off

---

    set print elements *number-of-elements*
    set print elements unlimited
    show print elements
    打印数组或字符串时，最多可以打印多少个元素，默认为200

---

    set print frame-arguments *value*
    打印栈帧时, 参数如何输出, 默认为scalars
        all: 所有参数都输出
        scalars: 只输出标量数据, func(a=0, car=...)
        none: 每个参数都用...替代, func(a=..., car=...)
        presence: 用...占位所有参数, func(...)

    show print frame-arguments

---

    set print raw-frame-arguments on
    set print raw-frame-arguments off
    show print raw-frame-arguments
    是否用Pretty printing的方式打印栈帧参数, 默认为on

---

    set print symbol on
    set print symbol off
    show print symbol
    是否打印地址对应的symbol，默认off
    类似于自动添加p/a

**Example**:

    int* pa = &ga

    set print symbol off
    (gdb) p pa
    $0 = (int *) 0x555555558014
    (gdb) p/a pa
    $1 = 0x555555558014 <ga>

    set print symbol on
    (gdb) p pa
    $0 = (int *) 0x555555558014 <ga>

---

    set print repeats *number-of-repeats*
    set print repeats unlimited
    show print repeats
    当数组出现重复的元素时，通过"repeats n times"这种方式进行打印，默认为off

    set print max-depth *depth*
    set print max-depth unlimited
    show print max-depth
    输出结构体时，最多输出的嵌套层数

---

    set print pretty on
    set print pretty off
    show print pretty
    是否使用Pretty方式打印

---

    set print union on
    set print union off
    show print union
    是否输出整个union的内容, 默认on

Example:

    typedef enum {Tree, Bug} Species;
    typedef enum {Big_tree, Acorn, Seedling} Tree_forms;
    typedef enum {Caterpillar, Cocoon, Butterfly} Bug_forms;
    struct thing {

    Species it;
    union {
        Tree_forms tree;
        Bug_forms bug;
    } form;
    };

    struct thing foo = {Tree, {Acorn}};

    set print union on:
    $1 = {it = Tree, form = {tree = Acorn, bug = Cocoon}}

    set print union off:
    $1 = {it = Tree, form = {...}}
---

    set print object
    set print object off
    show print object
    如果object是派生类型，是否用虚表判断其真正类型; 而不是其声明类型, 默认off

    set print static-members
    set print static-members on
    set print static-members off
    show print static-members
    是否打印static member, 默认on