## 1. CMake Folder Organization: Related Marcos
* CMAKE_RUNTIME_OUTPUT_DIRECTORY or EXECUTABLE_OUTPUT_PATH

    path to binary file

        set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

* CMAKE_LIBRARY_OUTPUT_DIRECTORY or LIBRARY_OUTPUT_PATH

    path to shared libraries(.dll or .so)

* CMAKE_ARCHIVE_OUTPUT_DIRECTORY or ARCHIVE_OUTPUT_PATH

    path to static libraries(.a or .lib)


Table of some macros.
| Variable | Info |
| :- | :--: |
| CMAKE_SOURCE_DIR | root source directory |
| CMAKE_CURRENT_SOURCE_DIR | The current source directory if using sub-projects and directories |
| PROJECT_SOURCE_DIR | The source directory of the current cmake project |
| CMAKE_BINARY_DIR | The root binary / build directory. This is the directory where you ran the cmake command |
| CMAKE_CURRENT_BINARY_DIR | The build directory you are currently in |
| PROJECT_BINARY_DIR | The build directory for the current project |
| CMAKE_RUNTIME_OUTPUT_DIRECTORY / EXECUTABLE_OUTPUT_PATH | path to binary file |
|CMAKE_LIBRARY_OUTPUT_DIRECTORY / LIBRARY_OUTPUT_PATH | path to shared libraries, .dll, .so |
| CMAKE_ARCHIVE_OUTPUT_DIRECTORY  / ARCHIVE_OUTPUT_PATH | path to static libraries, .a, .lib |


## 2. Building a Library with CMake
### 2.1 Building with target
* add_executable

    create executable file and dependent source files

        add_executable(HelloWorld helloworld.cpp lib/oper.cpp)

### 2.2 Building Static or Shared Library
* add_library

    set the name of library, type(STATIC/SHARED) and dependent source files.

    STATIC: create .a for Linux, .lib for Windows  
    SHARED: create .so for Linux, .dll for Windows

        set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/lib)
        add_library(math SHARED lib/oper.cpp)
        add_library(math STATIC lib/oper.cpp)

* target_link_libraries

    link the libraries to executable binary object

        add_executable(HelloWorld helloworld.cpp)
        target_link_libraries(HelloWorld math)

### 2.3 Building Library as Sub-Module CMake
generate CMakeLists.txt in subdirectory lib/, create library in the new CMakeLists.txt.

        cmake_minimum_required(VERSION 3.24)
        set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/lib)
        add_library(math SHARED operations.cpp)
        target_include_directories(math INTERFACE {CMAKE_CURRENT_SOURCE_DIR})   // export current .h files

## 3. Finding Existing Library with CMake
* find_package

*find_package* command with check if library exists before building excutable, when a package found, following variables will be initialized automatically.

* *<NAME>_FOUND*: Flag to show if it is found
* *<NAME>_INCLUDE_DIRS* or *<NAME>_INCLUDES*: Header directories
* *<NAME>_LIBRARIES* or *<NAME>_LIBS*: library files
* *<NAME>_DEFINITIONS*

When a library *Boost* is found, the command line look like:

    g++ main.cpp -o main -I/home/library/boost/include -L/home/library/boost/lib -lBoost


## 4. Target System Configurations

## 5. Install

1. Install bin, lib, headers, config to the specific path.

```cmake
    install(TARGETS hello_world DESTINATION bin): binary
    install(TARGETS hello_world_lib DESTINATION lib): library
    install(DIRECTORY hello/include DESTINATION include): header directory
    install(FILES hello_world.conf DESTINATION etc): some config files
```

2. Marco CMAKE_INSTALL_PREFIX is used to specify the install path.

```cmake
    cmake .. -DCMAKE_INSTALL_PREFIX=~/.local
```

We can set prefix in CMakeLists.txt
```cmake
    if( CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT )
        message (STATUS "Setting default CMAKE_INSTALL_PREFIX path to ${CMAKE_BINARY_DIR}/install")
        set( CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/install" CACHE STRING "The path to use for make install" FORCE )
    endif()
```

## 6. Compile Flags, Definition Flags

1. CMAKE_C_FLAGS, CMAKE_CXX_FLAGS
   
```cmake
    set( CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DEX2" CACHE STRING "Set c++ compiler flags" FORCE )
```

其中, CACHE STRING "Set c++ compiler flags" FORCE的意思是强制改变CMAKE_CXX_FLAGS，如果没有FORCE属性，那么如果CMAKE_CXX_FLAGS出现, 他则不会被再次修改.

2. target_compile_definitions, target_compile_options

```cmake
    target_compile_definitions(hello_world PRIVATE EX2): 为hello_world添加definition
    add_compile_definitions(EX2): 为所有target添加definition

    target_compile_options(hello_world PRIVATE -g): 为hello_world添加option
    add_compile_options(-g): 为所有target添加option
```

## 7. Cache Variable

被Cache的变量通常保存在CMakeCache.txt文件中，在当前Scope没有set变量时，则会从CMakeCache.txt文件中读取变量。
另外，即使CMakeCache中存在某些变量，CMakeLists.txt仍然可以覆盖定义这些变量。

**Purpose**:
1. Store user's selections and choices, such as `option` variable

```cmake
    option(USE_JPEG "Do you want to use the jpeg library" ON)
    set(USE_JPEG ON CACHE BOOL "Do you want to use the jpeg library")
```

2. Allow to persistently store values.

3. 有些变量被标记为Advance类型，Advance类型的变量不会显示在`cmake-gui`中。Software project可以把variable定义为commonly cached的变量和Advance cached变量，从而隐藏高级属性。
可以使用`mark_as_advanced`标记高级类型的变量。

4. 

## 8. Set

设置normal, cache, environment变量。
如果`<value>`为空，那么variable将为空，与`unset`功能相同。

### 8.1 Set Normal Variable

```cmake
    set(<variable> <value>... [PARENT_SCOPE])
```

`<value>`如果包含多个参数，可以使用';'合并。

如果指定`PARENT_SCOPE`，则将变量定义到当前scope的上层。每个new directory或`function()`, `block()`都可以创建新的scope。

### 8.2 Set Cache Entry

```cmake
    set(<variable> <value>... CACHE <type> <docstring> [FORCE])
```

`<type>`的类型包括：
```cmake
    BOOL:       Boolean ON/OFF value
    FILEPATH:   File path on disk
    PATH:       Directory path on disk
    STRING:     A line of text, visible to user
    INTERNAL:   A line of text, not visible to user
```
用户可以通过在cmake command line之后加上-D<var>=<value>设置变量的值

### 8.3 Set Environment Variable

```cmake
    set(ENV {<variable>} [<value>])
```
之后可以使用`$ENV{varaible}`使用环境变量。环境变量只会影响当前的CMake过程，当前CMake调用的其他process不会受到影响。

如果`<value>`为空或者空字符串，则会清除当前environment variable。

## 9. Policy

### 9.1 cmake_policy and cmake_minimum_required

CMake编译项目时存在两个问题：
    1. CMake版本太旧
    2. CMake版本太新
   
通过引入`cmake_policy`设置使用的策略版本，每个策略版本对应一个标识号，格式为`CMP<NNNN>`，其中`NNNN`为4个数字组成的ID。

```cmake
    cmake_policy(VERSION <min>[...<max>]) # 指定使用的策略号
    cmake_minimum_required(VERSION <min>[...<max>]) # 可以设置使用的CMake版本号
```

```cmake
    cmake_minimum_required(VERSION 3.0)
    # 相当于隐式调用
    cmake_policy(VERSION 3.0)
```

同样，可以同时指定CMake的版本和Policy版本

```cmake
    cmake_minimum_required(VERSION 3.0)
    cmake_policy(VERSION 3.0...3.5)
```

### 9.2 显示设置策略

```cmake
    # 设置 NEW 强制使用策略
    cmake_policy(SET CMP<NNNN> NEW)
    # 设置 OLD 强制关闭策略
    cmake_policy(SET CMP<NNNN> OLD)
```

在指定`cmake_policy(VERSION 3.0)`时，默认将`MINIMUM(2.4) -- VERSION3.0`的策略设置为NEW，其他版本设置为OLD，表示启用`2.4-3.0`版本的policy。

在指定`cmake_policy(VERSION 3.0...3.5)`时，`MINIMUM(2.4) ~ 3.5`版本的Policy设置为NEW，用以表示使用，3.5之后的Policy设置为OLD，表示不生效。

```cmake
    cmake_policy(GET CMP<NNNN> <variable>)
    # 获取当前的policy状态(NEW or OLD or empty)

    if(POLICY CMP<NNNN>)
    # 检查当前cmake版本是否支持某policy
```

### 9.3 作用范围

Policy默认只在当前Scope生效，可以通过`cmake_policy(PUSH)`和`cmake_policy(POP)`临时设置policy的作用域。

```cmake
    cmake_policy(PUSH)
    # do something
    cmake_policy(POP)
```