#include "reconstruction.h"

//device functions definations

__device__ void StSPk_Operation(float *d_Vector, float *d_x, int *pattern);
__device__ void additionScalar(float *d_Vector, float *d_first, float *d_second, float scalar);
__device__ void multiplyA(float *d_Vector, float *device_x, float *d_x, int *pattern, float *convResult, int dataH, int dataW, float *temp);
__device__ void dotProduct(float *cache, float *temp);
__device__ void convolve(float *data, float *temp, float *convResult, int dataH, int dataW);
__device__ void dotProductSecond(float *cache, float *temp);

#define MASK_W 7
#define MASK_H 7
#define TILE_W 16 //It has to be same size as block
#define TILE_H 16 //It has to be same size as block
#define MASK_R (MASK_W / 2)

#define w (TILE_W + MASK_W -1)
#define clamp(x) (min(max((x), 0.0), 1.0))
#define ThreadPerBlock TILE_H*TILE_W


__constant__ float MASK[MASK_W * MASK_H];

__device__ __constant__ int Pix[TILE_H * TILE_W];

__global__ void reconstructionKernel(float *data, float *result, int *pattern, int dataH, int dataW, float *device_x, float *device_p)
{
    __shared__ float temp[w*w];
    __shared__ float convResult[ThreadPerBlock];
    __shared__ float d_Vector[ThreadPerBlock];
    __shared__ float d_current_x[ThreadPerBlock];
    __shared__ float d_current_r[ThreadPerBlock];
    __shared__ float d_current_p[ThreadPerBlock];
    __shared__ float d_next_x[ThreadPerBlock];
    __shared__ float d_next_r[ThreadPerBlock];
    __shared__ float d_next_p[ThreadPerBlock];
    __shared__ float cache_crnt_r[ThreadPerBlock]; //for dot product only
    __shared__ float cache_crnt_p[ThreadPerBlock]; //for dot product only
    __shared__ float cache_next_r[ThreadPerBlock]; //for dot product only
    __shared__ float cache[ThreadPerBlock];
    __shared__ int pixels[ThreadPerBlock];

    __shared__ float dot_Num;
    __shared__ float dot_Denom;
    __shared__ float dot_alpha;
    __shared__ float dot_beta;


    __shared__ float flag;
    __shared__ int counter;



    int tx = threadIdx.x + blockIdx.x * blockDim.x;
    int ty = threadIdx.y + blockIdx.y * blockDim.y;
    int localIndex = threadIdx.x + threadIdx.y * TILE_W;
    int index = tx + ty * dataW;
    int bid = blockIdx.x + blockIdx.y * gridDim.x;

    if((tx>=dataW) && (ty>=dataH))
        return;

    //Testing --------------------------------------------------------------------------------------------------
/*
    cache_crnt_p[localIndex] = index;
    cache_crnt_r[localIndex] = 1.0f;
    cache[localIndex] = cache_crnt_p[localIndex] * cache_crnt_r[localIndex];
    __syncthreads();
    result[blockIdx.x + blockIdx.y * gridDim.x] = dotProduct(cache);
*/
     //Testing --------------------------------------------------------------------------------------------------Ends
    if(localIndex == 0)
    {
        counter = 0;
        flag = 9.0f;
    }
    __syncthreads();


//    device_x[index] = 0.0f;
    d_current_x[localIndex] = device_x[index];//data[index];
    cache[localIndex] = data[index];
    pixels[localIndex] = pattern[index];
    __syncthreads();

//float *d_Vector, float *device_x, float *d_x, int* pattern, float *convResult, int dataH, int dataW, float *temp
    multiplyA(d_Vector, device_x, d_current_x, pixels, convResult, dataH, dataW, temp);
    __syncthreads();
    additionScalar(d_current_r, cache, d_Vector, -1); //cache = d_b; r = b - Ax
    __syncthreads();
    d_current_p[localIndex] = d_current_r[localIndex];
    __syncthreads();
    device_p[index] = d_current_p[localIndex];
    __syncthreads();

    // (fabs(flag - 0.00) > 1e-6) && (counter < 3) && (counter < 50)


        while ((counter < 30))
            {

                //Dot product goes here and the answer will be stored in dot_result_num
                cache_crnt_r[localIndex] = d_current_r[localIndex]*d_current_r[localIndex];
                __syncthreads();

                dotProduct(cache_crnt_r, &dot_Num);
                __syncthreads();


                multiplyA(d_Vector, device_p, d_current_p, pixels,convResult,dataH, dataW, temp);
                __syncthreads();

                cache_crnt_p[localIndex] = d_current_p[localIndex] * d_Vector[localIndex];
                __syncthreads();
        //        dot_result_denom = dotProduct(cache_crnt_p);


                dotProduct(cache_crnt_p, &dot_Denom);
                __syncthreads();

                if(localIndex == 0)
                {
                    dot_alpha = dot_Num / dot_Denom;
    //                printf("[%d] [alpha: %f] = %f/%f\n", bid, dot_alpha,dot_Num, dot_Denom);

                }
                __syncthreads();

                additionScalar(d_next_x, d_current_x, d_current_p, dot_alpha);
                __syncthreads();

                additionScalar(d_next_r, d_current_r,d_Vector, (-1)* dot_alpha);
                __syncthreads();


                __syncthreads();

                cache_next_r[localIndex] = d_next_r[localIndex] * d_next_r[localIndex];
                __syncthreads();
                dotProduct(cache_next_r, &dot_Denom); //beta = next_r/current_r
                __syncthreads();
                if(localIndex == 0)
                {
                    flag = sqrtf(dot_Denom);

                }
     //           flag = sqrtf(dot_Denom);
                __syncthreads();

                if(localIndex == 0)
                {
      //              printf("[%d]: %f\n", bid, dot_Denom);
                    dot_beta = dot_Denom / dot_Num;
                }
                 __syncthreads();

                additionScalar(d_next_p, d_next_r,d_current_p, dot_beta);
                 __syncthreads();


                d_current_r[localIndex] = d_next_r[localIndex];
                d_current_p[localIndex] = d_next_p[localIndex];
                d_current_x[localIndex] = d_next_x[localIndex];
                __syncthreads();
                device_p[index] = d_current_p[localIndex];
                __syncthreads();
                device_x[index] = d_current_x[localIndex];
                __syncthreads();
                if(localIndex == 0)
                {
                    counter = counter + 1;
                }
//                __syncthreads();
//                __threadfence();
                __threadfence_block();

            }
//        __syncthreads();
        __threadfence();
        __threadfence_block();

        result[index] = d_next_x[localIndex];
//             result[index] = cache[localIndex];

}
//  multiplyA(d_Vector, device_x, d_current_x, convResult, dataH, dataW, temp);
__device__ void multiplyA(float *d_Vector, float *device_x, float *d_x, int *pattern, float *convResult, int dataH, int dataW, float *temp)
{
    convolve(device_x, temp, convResult, dataH, dataW); //result will be also written on shared memory convResult;
    __syncthreads();
    StSPk_Operation(d_Vector, d_x, pattern); //result will be also stored on temp shared memory
    __syncthreads();
    additionScalar(d_Vector,d_Vector,convResult,1); //result will be stored in result
    __syncthreads();
//    prfloatf("%f\n", result[localIndex]);

}

__device__ void StSPk_Operation(float *d_Vector, float *d_x, int *pattern)
{
    int localIndex = threadIdx.x + threadIdx.y * TILE_W;
    d_Vector[localIndex] = d_x[localIndex] * pattern[localIndex];
//    printf("%f\n", Pix[localIndex]);
}

__device__ void additionScalar(float *d_Vector, float *d_first, float *d_second, float scalar)
{
    int localIndex = threadIdx.x + threadIdx.y * TILE_W;
    d_Vector[localIndex] = d_first[localIndex] + scalar*d_second[localIndex];
//    __syncthreads();
}


__device__ void dotProduct(float *cache, float *temp)
{

    int localIndex = threadIdx.x + threadIdx.y * blockDim.x;

    int i = ThreadPerBlock/2;

    while( (i!= 0) )
    {
        if(localIndex < i)
        {
            cache[localIndex] += cache[localIndex + i];

        }
        __syncthreads();
        i/=2;
    }
    __syncthreads();

    if(localIndex == 0)
    {
        temp[0] = cache[0];

    }


    __syncthreads();
//    return temp;


}



__device__ void dotProductSecond(float *cache, float *temp)
{

    int localIndex = threadIdx.x + threadIdx.y * blockDim.x;

    __shared__ int i;

    if(localIndex == 0)
    {
        i = ThreadPerBlock/2;
    }
    __syncthreads();


    while( (i!= 0) )
    {
        if(localIndex < i)
        {
            cache[localIndex] += cache[localIndex + i];

        }
        __syncthreads();
        if(localIndex == 0)
        {
             i/=2;
        }

        __syncthreads();
    }
    __syncthreads();

    if(localIndex == 0)
    {
        temp[0] = cache[0];
//        printf("dot: %f ", temp[0]);
//        return cache[0];
    }


//    __syncthreads();
//    return temp;


}




void reconstructionFunction(dim3 grid, dim3 block, float *data, int *pattern, float *kernel, float *d_result, int maskH, int maskW, int dataH, int dataW, float *device_x, float *device_p)
{

    if(cudaMemcpyToSymbol(MASK, kernel, maskH * maskW * sizeof(float)) != cudaSuccess)
    {
        printf("Copy to constant memory error\n");
    }
    printf("Launching threads\n");
    reconstructionKernel<<<grid,block>>>(data, d_result, pattern, dataH, dataW, device_x, device_p);


}
/*
void initializePixelShuffle(float *d_pixels)
{
    if(cudaMemcpyToSymbol(Pix, d_pixels, sizeof(int) * 128 * 128) != cudaSuccess)
    {
        printf("Writing of Pixel shuffle to constant memory Failed\n");
    }
    else
    {
        printf("Pixels are copied to constant memory\n");
    }
}
*/



/*
This convolve function reads data from global memory. Result is written back to Shared Memory

*/
__device__ void convolve(float *data, float *temp, float *convResult, int dataH, int dataW)
{
    int tx = threadIdx.x;
    int ty = threadIdx.y;
    int bx = blockIdx.x;
    int by = blockIdx.y;
    int localIndex;

    int dest = ty * TILE_W + tx;
    int destY = dest /w;
    int destX = dest % w;
//    printf("DEST: %d destX: %d destY: %d\n", dest, destX, destY);
    int srcY = by * TILE_W + destY - MASK_H/2;
    int srcX = bx * TILE_H + destX - MASK_W/2;
    int src = (srcY * dataW + srcX);
    localIndex = destY * w + destX;
//    printf("SOURCE: %d srcX: %d srcY: %d\n", src, srcX, srcY);
    if (srcY >= 0 && srcY < dataH && srcX >= 0 && srcX < dataW)
        temp[localIndex] = data[src];
//        temp[destY][destX] = data[src];
    else
        temp[localIndex] = 0.0;
//        temp[destY][destX] = 0.0;
    __syncthreads();
    dest = ty * TILE_W + tx + TILE_H * TILE_W;
    destY = dest / w;
    destX = dest % w;
    srcY = by * TILE_W + destY - MASK_R;
    srcX = bx * TILE_H + destX - MASK_R;
    src = srcY * dataW + srcX;
    localIndex = destY * w + destX;
    //    printf("DEST: %d destX: %d destY: %d\n", dest, destX, destY);
    //     printf("SOURCE: %d srcX: %d srcY: %d\n", src, srcX, srcY);
    if (destY < w)
    {
        if(srcY >= 0 && srcY <dataH && srcX >=0 && srcX <  dataW)
            temp[localIndex] = data[src];
//            temp[destY][destX] = data[src];
        else
            temp[localIndex] = 0.0;
//            temp[destY][destX] = 0.0;
    }


    __syncthreads();

    float out = 0.0f;
    int y,x;

    for(y = 0; y<MASK_H; y++)
    {
        for(x = 0; x<MASK_W; x++)
        {
            localIndex = (ty+y) * w + (tx+x);
            out += temp[localIndex] * MASK[y * MASK_W + x];
//            out += temp[ty + y][tx + x] * MASK[y * MASK_W + x];
        }
    }

    y = by * TILE_W + ty;
    x = bx * TILE_H + tx;

     localIndex = threadIdx.x + threadIdx.y * blockDim.x;
//    float tempY =threadIdx.y + blockIdx.y * blockDim.y;

    if(y < dataH && x < dataW)
    {
//        result[y * dataW + x] = out;
        convResult[localIndex] = out; //writing convolution result in shared memory for that block;
    }
//    prfloatf("%d\n", localIndex);
    __syncthreads();

}



//Not using these functions

__device__ float blockDotProduct(float *data_a,float *data_b, int width)
{

    float temp = 0;

    int tidX = blockDim.x * blockIdx.x + threadIdx.x;
    int tidY = blockDim.y * blockIdx.y + threadIdx.y;
    int tid = tidX + tidY * width;
    int blockId = blockIdx.x + blockIdx.y * gridDim.x;

    __shared__ float cache[ThreadPerBlock]; //For Vector Dot Product


    int cachedIndex = threadIdx.x + threadIdx.y * blockDim.x;

    cache[cachedIndex] = data_a[tid]*data_b[tid];
    __syncthreads();
    if(cachedIndex==(ThreadPerBlock-1))
    {
        for(int i=0; i<ThreadPerBlock; i++)
        {
            temp += cache[i];

        }
    }
    return temp;

}
__global__ void  dotProductFunc(float *data_a, float *data_b, float *result, int dataH, int dataW)
{
    __shared__ float cache[ThreadPerBlock];

    float temp = 0;

    int tidX = blockDim.x * blockIdx.x + threadIdx.x;
    int tidY = blockDim.y * blockIdx.y + threadIdx.y;
    int tid = tidX + tidY * dataW;
    int blockId = blockIdx.x + blockIdx.y * gridDim.x;

    int localIndex = threadIdx.x + threadIdx.y * blockDim.x;
    cache[localIndex] = data_a[tid]*data_b[tid];
    __syncthreads();
//    result[blockId] = dotProduct(cache);
 /*
    float i = ThreadPerBlock/2;

    while( (i!= 0) )
    {
        if(localIndex < i)
        {
            cache[localIndex] += cache[localIndex + i];

        }
        __syncthreads();
        i/=2;
    }

    if(localIndex == 0)
    {
        result[blockId] = cache[0];
    }
*/

}
void VectorDotProduct(dim3 gridSize, dim3 blockSize, float *data_a, float *data_b, float *d_result, int length, int width)
{
//    blockDotProduct<<<gridSize,blockSize>>>(data_a, data_b, d_result, result, length, width);
    dotProductFunc<<<gridSize,blockSize>>>(data_a, data_b, d_result, length, width);
//    Vector_Dot_Product<<<blockPerGrid,ThreadPerBlock>>>(data_a, data_b, d_result);
}

