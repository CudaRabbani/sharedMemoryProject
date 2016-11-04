#ifndef RECONSTRUCTION_H
#define RECONSTRUCTION_H


#include<stdio.h>
#include<stdlib.h>
#include<cuda.h>
#include<cuda_runtime.h>
#include "helper_cuda.h"
#include "helper_functions.h"

                         //(dim3 grid, dim3 block, float *data, float *kernel, float *pattern, float *d_result, int maskH, int maskW, int dataH, int dataW, float *device_x, float *device_p)

void reconstructionFunction(dim3 grid, dim3 block, float *data, int *pattern, float *kernel,float *d_result, int maskH, int maskW, int dataH, int dataW, float *device_x, float *device_p);
//void initializePixelShuffle(float *d_pixels);
void VectorDotProduct(dim3 gridSize, dim3 blockSize, float *data_a, float *data_b, float *d_result, int length, int width);



__global__ void reconstructionKernel(float *data, float *pattern, int *result, int dataH, int dataW, float *device_x, float *device_p);





#endif // RECONSTRUCTION_H
