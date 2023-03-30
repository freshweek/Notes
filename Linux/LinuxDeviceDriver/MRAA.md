### 优势
1. 平台无关的方式访问IO
2. 不同平台提供统一的API和访问方式


封装技术：MRAA presents a façade which makes the relationship between I/O and the hardware more intuitive to developers.

仿真技术：Currently MRAA implements this feature using a mock platform, allowing developers to write and run applications even on systems that have no exposed I/Os.

基于String的初始化：The MRAA library offers a string initializer feature for the I/O classes. This eliminates the precondition for data type knowledge from higher level frameworks or services
init_io


