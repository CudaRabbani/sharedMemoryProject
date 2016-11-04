#ifndef GENERATEPATTERN_H
#define GENERATEPATTERN_H

#include<stdio.h>
#include<stdlib.h>
#include<cuda.h>
#include<cuda_runtime.h>
#include<helper_cuda.h>
#include<helper_functions.h>


void GeneratePattern(int *d_pixel, int width, int height, float percentage);



#endif // GENERATEPATTERN_H
