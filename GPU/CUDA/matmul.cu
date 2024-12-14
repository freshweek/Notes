// #include <stdio.h>
#include <iostream>


#define BLOCK_SIZE 32

typedef struct {
    int width;
    int stride;
    int height;
    float* elements;
}Matrix;

__device__ void SetElement(Matrix &mat, int row, int col, float v)
{
    if(row >= mat.height) {
        return ;
    }
    if(col >= mat.width) {
        return ;
    }
    mat.elements[row * mat.stride + col] = v;
}

__device__ float GetElement(Matrix &mat, int row, int col)
{
    if(row >= mat.height) {
        return 0;
    }
    if(col >= mat.width) {
        return 0;
    }
    return mat.elements[row * mat.stride + col];
}

__device__ Matrix GetSubMatrix(Matrix &mat, int idx, int idy)
{
    Matrix sub;

    if (idx*BLOCK_SIZE > mat.width) {
        sub.width = 0;
        return sub;
    }

    if (idy*BLOCK_SIZE > mat.height) {
        sub.height = 0;
        return sub;
    }

    sub.width = min(BLOCK_SIZE, mat.width - idx * BLOCK_SIZE);
    sub.height = min(BLOCK_SIZE, mat.height - idy * BLOCK_SIZE);
    // sub.width = BLOCK_SIZE;
    // sub.height = BLOCK_SIZE;
    sub.stride = mat.stride;
    sub.elements = &mat.elements[idy * BLOCK_SIZE * mat.stride
                            + idx * BLOCK_SIZE];
    return sub;
}

__global__ void MatMulKernel(Matrix A, Matrix B, Matrix C)
{
    int idn = blockIdx.x;
    int idm = blockIdx.y;

    Matrix subC = GetSubMatrix(C, idn, idm);

    float sum = 0;
    int kloop = (A.width + BLOCK_SIZE - 1) / BLOCK_SIZE;
    for(int idk = 0; idk < kloop; idk++) {
        __shared__ float sharedA[BLOCK_SIZE][BLOCK_SIZE];
        __shared__ float sharedB[BLOCK_SIZE][BLOCK_SIZE];

        Matrix subA = GetSubMatrix(A, idk, idm);
        Matrix subB = GetSubMatrix(B, idn, idk);

        sharedA[threadIdx.y][threadIdx.x] = GetElement(subA, threadIdx.y, threadIdx.x);
        sharedB[threadIdx.y][threadIdx.x] = GetElement(subB, threadIdx.y, threadIdx.x);
        // SetElement(subA, threadIdx.y, threadIdx.x, )
        __syncthreads();
        for(int k = 0; k < BLOCK_SIZE; k++) {
            sum += sharedA[threadIdx.y][k] * sharedB[k][threadIdx.x];
        }
        __syncthreads();

    }
    SetElement(subC, threadIdx.y, threadIdx.x, sum);
}

void MatMul(const Matrix &A, const Matrix &B, Matrix &C)
{
    Matrix d_A;
    d_A.width = A.width;
    d_A.height = A.height;
    d_A.stride = A.stride;
    int sizeA = d_A.stride * d_A.height * sizeof(float);
    cudaMalloc(&d_A.elements, sizeA);
    cudaMemcpy(d_A.elements, A.elements, sizeA, cudaMemcpyHostToDevice);

    Matrix d_B;
    d_B.width = B.width;
    d_B.height = B.height;
    d_B.stride = B.stride;
    int sizeB = d_B.stride * d_B.height * sizeof(float);
    cudaMalloc(&d_B.elements, sizeB);
    cudaMemcpy(d_B.elements, B.elements, sizeB, cudaMemcpyHostToDevice);

    Matrix d_C;
    d_C.width = C.width;
    d_C.height = C.height;
    d_C.stride = C.stride;
    int sizeC = d_C.stride * d_C.height * sizeof(float);
    cudaMalloc(&d_C.elements, sizeC);

    dim3 block(BLOCK_SIZE, BLOCK_SIZE);
    dim3 grid((B.width + BLOCK_SIZE - 1) / BLOCK_SIZE,
        (A.height + BLOCK_SIZE - 1) / BLOCK_SIZE
    );
    MatMulKernel<<<grid, block>>>(d_A, d_B, d_C);

    cudaMemcpy(C.elements, d_C.elements, sizeC, cudaMemcpyDeviceToHost);

    cudaDeviceSynchronize();
    cudaFree(d_A.elements);
    cudaFree(d_B.elements);
    cudaFree(d_C.elements);
}

int main()
{
    int M = BLOCK_SIZE * 2 + 1;
    int K = BLOCK_SIZE * 3 + 1;
    int N = BLOCK_SIZE * 4 + 1;

    Matrix A;
    A.width = K;
    A.stride = K;
    A.height = M;
    A.elements = (float*)malloc(M * K * sizeof(float));

    Matrix B;
    B.width = N;
    B.stride = N;
    B.height = K;
    B.elements = (float*)malloc(K * N * sizeof(float));

    Matrix C;
    C.width = N;
    C.stride = N;
    C.height = M;
    C.elements = (float*)malloc(M * N * sizeof(float));

    Matrix golden;
    golden.width = N;
    golden.stride = N;
    golden.height = M;
    golden.elements = (float*)malloc(M * N * sizeof(float));

    for(int i = 0; i < M * K; i ++) {
        A.elements[i] = 1;
    }
    for(int i = 0; i < N * K; i ++) {
        B.elements[i] = 1;
    }

    MatMul(A, B, C);

    for(int m = 0; m < M; m++) {
        for(int n = 0; n < N; n++) {
            for(int k = 0; k < K; k++) {
                golden.elements[m * C.stride + n] +=
                    A.elements[m * A.stride + k] *
                        B.elements[k * B.stride + n];
            }
        }
    }

    for(int m = 0; m < M; m++) {
        for(int n = 0; n < N; n++) {
            if(golden.elements[m * C.stride + n] != C.elements[m * C.stride + n]) {
                std::cout << "[" << m << ", " << n << "]: "
                        << "golden: " << golden.elements[m * C.stride + n] << ", "
                        << "c: " << C.elements[m * C.stride + n]
                        << std::endl;
            }
        }
    }
    std::cout << "end" << std::endl;

    return 0;
}