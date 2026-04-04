// ============================================================================
// CUDA Kernel 调试测试用例：常见启动失败场景
// 用于 benchmark_code_quality.py - Task 3
// ============================================================================

#include <cuda_runtime.h>
#include <stdio.h>

#define CUDA_CHECK(call) \
    do { \
        cudaError_t err = call; \
        if (err != cudaSuccess) { \
            printf("CUDA error at %s:%d: %s\n", __FILE__, __LINE__, \
                   cudaGetErrorString(err)); \
            exit(EXIT_FAILURE); \
        } \
    } while(0)

// ============================================================================
// 场景 1: 共享内存超限
// ============================================================================

__global__ void kernelSharedMemoryOverrun(float* output, int size) {
    // 🔴 声明超大共享内存 - 可能超过 GPU 限制
    __shared__ float sharedMem[1024 * 1024];  // 4MB - 多数 GPU 限制 48KB-164KB
    
    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    if (tid < size) {
        sharedMem[threadIdx.x] = output[tid];
        output[tid] = sharedMem[threadIdx.x] * 2.0f;
    }
}

void testSharedMemoryOverrun() {
    printf("\n=== 场景 1: 共享内存超限 ===\n");
    
    int size = 1024;
    float *d_output;
    cudaMalloc(&d_output, size * sizeof(float));
    
    // 🔴 启动配置 - 每个 block 请求 4MB 共享内存
    kernelSharedMemoryOverrun<<<10, 256, 1024*1024*sizeof(float)>>>(d_output, size);
    
    // 可能错误：cudaErrorInvalidConfiguration
    CUDA_CHECK(cudaGetLastError());
    CUDA_CHECK(cudaDeviceSynchronize());
    
    cudaFree(d_output);
}

// ============================================================================
// 场景 2: 线程块维度超限
// ============================================================================

__global__ void kernelInvalidBlockSize(float* output) {
    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    output[tid] = tid * 2.0f;
}

void testInvalidBlockSize() {
    printf("\n=== 场景 2: 线程块维度超限 ===\n");
    
    float *d_output;
    cudaMalloc(&d_output, 1024 * sizeof(float));
    
    // 🔴 每 block 线程数超限 - 多数 GPU 最大 1024 线程/block
    int invalidBlockSize = 2048;  // 超限
    kernelInvalidBlockSize<<<1, invalidBlockSize>>>(d_output);
    
    // 可能错误：cudaErrorInvalidConfiguration
    CUDA_CHECK(cudaGetLastError());
    CUDA_CHECK(cudaDeviceSynchronize());
    
    cudaFree(d_output);
}

// ============================================================================
// 场景 3: Grid 维度超限
// ============================================================================

__global__ void kernelInvalidGridSize(float* output) {
    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    if (tid < 1024) output[tid] = tid;
}

void testInvalidGridSize() {
    printf("\n=== 场景 3: Grid 维度超限 ===\n");
    
    float *d_output;
    cudaMalloc(&d_output, 1024 * sizeof(float));
    
    // 🔴 Grid 维度超限 - 依赖 GPU 计算能力
    // Compute Capability 7.5: 最大 gridDim.x = 2^31 - 1
    int invalidGridSize = 0x7FFFFFFF + 1;  // 超限
    kernelInvalidGridSize<<<invalidGridSize, 256>>>(d_output);
    
    CUDA_CHECK(cudaGetLastError());
    CUDA_CHECK(cudaDeviceSynchronize());
    
    cudaFree(d_output);
}

// ============================================================================
// 场景 4: Kernel 内除零错误
// ============================================================================

__global__ void kernelDivisionByZero(float* output, int divisor) {
    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    
    // 🔴 divisor 可能为 0
    output[tid] = 100.0f / divisor;
}

void testDivisionByZero() {
    printf("\n=== 场景 4: Kernel 内除零错误 ===\n");
    
    float *d_output;
    cudaMalloc(&d_output, 256 * sizeof(float));
    
    kernelDivisionByZero<<<1, 256>>>(d_output, 0);  // 🔴 divisor = 0
    
    // 注意：CUDA 异步执行，错误可能在后续操作中才被发现
    CUDA_CHECK(cudaGetLastError());
    CUDA_CHECK(cudaDeviceSynchronize());
    
    cudaFree(d_output);
}

// ============================================================================
// 场景 5: 未检查设备初始化
// ============================================================================

__global__ void kernelSimple(float* output) {
    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    output[tid] = tid;
}

void testNoDeviceInit() {
    printf("\n=== 场景 5: 未检查设备初始化 ===\n");
    
    float *d_output;
    
    // 🔴 没有 cudaSetDevice() 或检查设备可用性
    // 如果系统没有 GPU 或 GPU 被占用，会失败
    
    cudaMalloc(&d_output, 1024 * sizeof(float));
    kernelSimple<<<10, 102>>>(d_output);
    
    CUDA_CHECK(cudaGetLastError());
    CUDA_CHECK(cudaDeviceSynchronize());
    
    cudaFree(d_output);
}

// ============================================================================
// 场景 6: 内存访问越界
// ============================================================================

__global__ void kernelOutOfBounds(float* output, int size) {
    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    
    // 🔴 没有边界检查 - 可能访问越界
    output[tid] = tid * 2.0f;  // tid 可能 >= size
}

void testOutOfBounds() {
    printf("\n=== 场景 6: 内存访问越界 ===\n");
    
    int size = 100;
    float *d_output;
    cudaMalloc(&d_output, size * sizeof(float));  // 只分配 100 个 float
    
    // 🔴 启动 10*256=2560 线程，但只分配了 100 个元素
    kernelOutOfBounds<<<10, 256>>>(d_output, size);
    
    CUDA_CHECK(cudaGetLastError());
    CUDA_CHECK(cudaDeviceSynchronize());
    
    cudaFree(d_output);
}

// ============================================================================
// 场景 7: Kernel 执行时间过长 (Watchdog Timeout)
// ============================================================================

__global__ void kernelLongRunning(float* output, int iterations) {
    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    float result = 0.0f;
    
    // 🔴 循环次数过多 - 在 WDDM 模式下可能触发 TDR
    for (int i = 0; i < iterations; i++) {
        result += sqrtf(i * tid);
    }
    
    output[tid] = result;
}

void testLongRunningKernel() {
    printf("\n=== 场景 7: Kernel 执行时间过长 ===\n");
    
    float *d_output;
    cudaMalloc(&d_output, 256 * sizeof(float));
    
    // 🔴 10 亿次迭代 - 在消费级 GPU 上可能超过 2 秒 TDR 限制
    kernelLongRunning<<<1, 256>>>(d_output, 1000000000);
    
    CUDA_CHECK(cudaGetLastError());
    CUDA_CHECK(cudaDeviceSynchronize());
    
    cudaFree(d_output);
}

int main() {
    printf("CUDA Kernel 调试测试套件\n");
    printf("========================\n");
    
    // 注意：这些测试会触发各种 CUDA 错误
    // 实际使用时应逐个测试，并捕获错误类型
    
    // testSharedMemoryOverrun();
    // testInvalidBlockSize();
    // testInvalidGridSize();
    // testDivisionByZero();
    // testNoDeviceInit();
    // testOutOfBounds();
    // testLongRunningKernel();
    
    printf("\n测试完成\n");
    return 0;
}

// ============================================================================
// 调试要点总结：
// 1. 共享内存超限: 检查 device properties.sharedMemPerBlock
// 2. 线程块超限：检查 device props.maxThreadsPerBlock
// 3. Grid 超限：检查 device props.maxGridSize
// 4. 除零错误：使用 cuda-memcheck 或检查输入验证
// 5. 设备初始化：先调用 cudaGetDeviceCount()
// 6. 访问越界：添加边界检查，使用 cuda-memcheck
// 7. 执行超时：WDDM 模式 2 秒 TDR，服务器模式无限制
// ============================================================================
