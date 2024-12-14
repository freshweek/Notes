该文档主要总结了CUDA的programming guide部分。
https://docs.nvidia.com/cuda/cuda-c-programming-guide/index.html

### 3.2.1 Initialization

`cudaInitDevice()`和`cudaSetDevice()`用来初始化runtime和设置程序运行的设备。在用户未调用这两个函数时，默认会初始化device0以使用。

在初始化过程中，runtime会为device创建*primary context*，这个context会用于所有的kernels.

`cudaResetDevice`用来重置设备。

### 3.2.2 Device Memory

用户通过两种方式申请Device Memory：*linear memory*和*CUDA arrays*。*linear memory*用于绝大多数的kernel中，*CUDA arrays*用于texture fetching.

Linear memory通过unified address space进行寻址。所以host可以通过指针寻址device memory.地址空间的大小如下：

![322-linear_memory_address_space](./images/322-linear_memory_address_space.png)

可以通过多个API申请Device Memory：
* `cudaMalloc()`, `cudaFree()`
* `cudaMallocPitch()`
* `cudaMalloc3D()`

#### # `cudaMalloc()`, `cudaFree()`

`cudaMalloc`申请一维的memory.

```c++
__global__ void vecAdd(float *vec, uint32_t size)
{
    int i = blockDim.x * blockIdx.x + threadIdx.x;
    if(i < size) {
        vec[i] += 1;
    }
}

int main()
{
    int N = 32;
    uint32_t size = N * sizeof(float);

    float *h_A;
    h_A = (float*)malloc(size);

    float *d_A;
    cudaMalloc(&d_A, size);

    cudaMemcpy(d_A, h_A, size, cudaMemcpyHostToDevice);
    vecAdd<<<1, 32>>>(d_A, size);
    cudaMemcpy(h_A, d_A, size, cudaMemcpyDeviceToHost);

    cudaFree(d_A);
    free(h_A);

    return 0;
}
```

#### # `cudaMallocPitch()`, `cudaMalloc3D`

`cudaMallocPitch()`及`cudaMalloc3D`申请2D或3D的memory. 这两个API申请memory时可以保证对row的对齐访问，因此通过`cudaMemcpy2D()`和`cudaMemcpy3D`复制时可以保证有良好的性能。在对`cudaMallocPitch()`申请的memory进行读写时需要使用返回的pitch.

```c++
// Host code
int width = 64, height = 64;
float* devPtr;
size_t pitch;
cudaMallocPitch(&devPtr, &pitch,
                width * sizeof(float), height);
MyKernel<<<100, 512>>>(devPtr, pitch, width, height);

// Device code
__global__ void MyKernel(float* devPtr,
                         size_t pitch, int width, int height)
{
    for (int r = 0; r < height; ++r) {
        float* row = (float*)((char*)devPtr + r * pitch);
        for (int c = 0; c < width; ++c) {
            float element = row[c];
        }
    }
}
```

另外，也可以使用`cudaMemcpyToSymbol()`和`cudaMemcpyFromSymbol()`进行`__constant__`和`__device__`声明的内存的读写。

```c++
__constant__ float constData[256];
float data[256];
cudaMemcpyToSymbol(constData, data, sizeof(data));
cudaMemcpyFromSymbol(data, constData, sizeof(data));

__device__ float devData;
float value = 3.14f;
cudaMemcpyToSymbol(devData, &value, sizeof(float));

__device__ float* devPointer;
float* ptr;
cudaMalloc(&ptr, 256 * sizeof(float));
cudaMemcpyToSymbol(devPointer, &ptr, sizeof(ptr));
```

### 3.2.3 Device Memory L2 Access Management

如果CUDA kernel多次访问global memory，这样的memory就是`persisting memory`。如果kernel只访问一次，这样的就是`streaming` memory.

CUDA支持将`persisting memory`放到L2 cache中。


#### 设置L2 Cache中用于persisting memory的大小

```c++
cudaGetDeviceProperties(&prop, device_id);
size_t size = min(int(prop.l2CacheSize * 0.75), prop.persistingL2CacheMaxSize);
cudaDeviceSetLimit(cudaLimitPersistingL2CacheSize, size); /* set-aside 3/4 of L2 cache for persisting accesses or the max allowed*/
```

#### 设置放置在persisting的global memory

在下述示例中，kernel访问`[ptr, ptr+num_bytes]`区域的global memory时，优先将其放置到persisting memory中。`hitRatio`表示是否放置到persisting的概率(当`hitProp`为`cudaAccessPropertyPersisting`).

设置`hitRatio`的优势是可以避免persisting memory的抢占。比如persisting memory的总大小是32KB，而且有两个stream对应的`num_bytes`都是32KB，如果他们的`hitRatio`都是1.0，就会导致互相之间逐出对方的persisting,但是如果是0.5,就不会有这种情况。

```c++
cudaStreamAttrValue stream_attribute;                                         // Stream level attributes data structure
stream_attribute.accessPolicyWindow.base_ptr  = reinterpret_cast<void*>(ptr); // Global Memory data pointer
stream_attribute.accessPolicyWindow.num_bytes = num_bytes;                    // Number of bytes for persistence access.
                                                                              // (Must be less than cudaDeviceProp::accessPolicyMaxWindowSize)
stream_attribute.accessPolicyWindow.hitRatio  = 0.6;                          // Hint for cache hit ratio
stream_attribute.accessPolicyWindow.hitProp   = cudaAccessPropertyPersisting; // Type of access property on cache hit
stream_attribute.accessPolicyWindow.missProp  = cudaAccessPropertyStreaming;  // Type of access property on cache miss.

//Set the attributes to a CUDA stream of type cudaStream_t
cudaStreamSetAttribute(stream, cudaStreamAttributeAccessPolicyWindow, &stream_attribute);
```

#### L2 Cache的类型

* `cudaAccessPropertyPersisting`
* `cudaAccessPropertyStreaming`
* `cudaAccessPropertyNormal`

#### 重置L2 Cache的类型

* 将`hitProp`设置为`cudaAccessPropertyNormal`
* 调用`cudaCtxResetPersistingL2Cache()`
* 依靠系统自动设置（不推荐）

