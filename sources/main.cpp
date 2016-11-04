#include "header.h"
#include "reconstruction.h"
#include "generatepattern.h"

int kernelH = 7;
int kernelW = 7;

int bolckX;
int blockY;

float *h_mask, *host_b;


void loadData(float *data, int dataH, int dataW)
{
    FILE *fp = fopen("/home/reza/cuda-workspace/testCmake/textFiles/StY.txt","r");
    for(int i = 0; i< dataH*dataW; i++)
    {
        fscanf(fp, "%f", &data[i]);
    }
}

int* loadPattern(int *h_pixel, int dataH, int dataW)
{

	printf("Loading pattern for the size of %d by %d\n", dataH, dataW);
	FILE *fp;
	fp = fopen("/home/reza/cuda-workspace/testCmake/textFiles/Pattern.txt", "r");


	if(fp == NULL)
	{
		printf("No such file\n");
	}
	for(int i = 0; i< dataH*dataW; i++)
	{
		fscanf(fp, "%d", &h_pixel[i]);
	}

	return h_pixel;

}

void loadKenrel(float *kernel, float lambda, int length)
{
/*    FILE *fp = fopen("/home/reza/sharedMemoryProject/textFiles/kernel.txt", "r");
    for(int i = 0; i<length; i++)
    {
        fscanf(fp, "%f", &kernel[i]);
    }
    */
    kernel[0] = 0.0001;
    kernel[1] = 0.0099;
    kernel[2] = -0.0793;
    kernel[3] = -0.0280;
    kernel[4] = -0.0793;
    kernel[5] = 0.0099;
    kernel[6] = 0.0001;
    kernel[7] = 0.0099;
    kernel[8] = -0.1692;
    kernel[9] = 0.6540;
    kernel[10] = 1.0106;
    kernel[11] = 0.6540;
    kernel[12] = -0.1692;
    kernel[13] = 0.0099;
    kernel[14] = -0.0793;
    kernel[15] = 0.6540;
    kernel[16] = 0.1814;
    kernel[17] = -8.0122;
    kernel[18] = 0.1814;
    kernel[19] = 0.6540;
    kernel[20] = -0.0793;
    kernel[21] = -0.0280;
    kernel[22] = 1.0106;
    kernel[23] = -8.0122;
    kernel[24] = 23.3926;
    kernel[25] = -8.0122;
    kernel[26] = 1.0106;
    kernel[27] = -0.0280;
    kernel[28] = -0.0793;
    kernel[29] = 0.6540;
    kernel[30] = 0.1814;
    kernel[31] = -8.0122;
    kernel[32] = 0.1814;
    kernel[33] = 0.6540;
    kernel[34] = -0.0793;
    kernel[35] = 0.0099;
    kernel[36] = -0.1692;
    kernel[37] = 0.6540;
    kernel[38] = 1.0106;
    kernel[39] = 0.6540;
    kernel[40] = -0.1692;
    kernel[41] = 0.0099;
    kernel[42] = 0.0001;
    kernel[43] = 0.0099;
    kernel[44] = -0.0793;
    kernel[45] = -0.0280;
    kernel[46] = -0.0793;
    kernel[47] = 0.0099;
    kernel[48] = 0.0001;
//    kernel[49] = 0.0001;

    for(int i=0;i<length; i++)
    {
        kernel[i] = kernel[i]* lambda;
    }

}

void writeData(float *data, int dataH, int dataW)
{
    FILE *fp = fopen("/home/reza/cuda-workspace/testCmake/textFiles/solverOutput.txt","w");
    for(int i = 0; i< dataH*dataW; i++)
    {
        fprintf(fp, "%f\n", data[i]);
//        printf("%f\n", data[i]);
    }
    fclose(fp);
    printf("Writing data to Text file is complete\n");

}

void generateData(float *data, int dataH, int dataW)
{
    for(int i=0; i<dataH*dataW; i++)
    {
        data[i] = (float)i;
    }
}


void checkResult(float *data)
{
    for(int i = 0; i<10; i++)
    {
        printf("%.2f\n", data[i]);
    }
}




int main(int argc, char *argv[])
{
    cudaEvent_t start, stop;
    float time;

    int dataH = 256;
    int dataW = 256;

    dim3 blockSize(16,16);
    dim3 gridSize(dataW/blockSize.x, dataH/blockSize.y);

    printf("No of Blocks: %d\n", gridSize.x * gridSize.y);

    float  *data;
    float *d_data;

    float *kernel;
    float *d_result, *result;
    int *d_pixel, *h_pixel;
    float *device_x, *device_p;
    float percentage;
    float lambda = 0.001;


    float *a,*b, *dotRes, *matDot;
    float *d_a, *d_b, *d_dot;
    float *temp;


    percentage = 0.8f;


    data = (float *)malloc (sizeof(float) * dataH * dataW);
    kernel = (float *)malloc(sizeof(float) * kernelH * kernelW);
    result = (float *)malloc(sizeof(float) * dataH * dataW);
    h_pixel = (int *)malloc(sizeof(int) * dataH * dataW);
    temp = (float *)malloc(sizeof(float) * dataH * dataW);

    cudaMalloc(&d_data,sizeof(float)*dataH*dataW );
    cudaMalloc(&d_result,sizeof(float)*dataH * dataW );
    cudaMalloc(&d_pixel, sizeof(int) * dataH * dataW);
    cudaMalloc(&device_x,sizeof(float)*dataH * dataW );
    cudaMalloc(&device_p,sizeof(float)*dataH * dataW );


//    GeneratePattern(d_pixel, dataW, dataH, percentage);
    loadData(data, dataH, dataW);
    loadKenrel(kernel, lambda, kernelH*kernelW);
    printf("Loading Pattern\n");
    h_pixel = loadPattern(h_pixel, dataH, dataW);
    for(int i = 0; i<dataH*dataW; i++)
    {
    	temp[i] = 0.0;
    }
//    checkResult((float)h_pixel);
/*
    cudaError_t err = cudaMemcpy(d_pixel, h_pixel, sizeof(int) * dataH * dataW, cudaMemcpyHostToDevice);
    if(err != 0)
    {
    	printf("Pattern error\n");
    }
    else printf("Pattern copy successful\n");
*/
    if(cudaMemcpy(device_x, temp, sizeof(float) * dataH * dataW, cudaMemcpyHostToDevice) != cudaSuccess)
    {
    	printf("device_x unsuccessful\n");
    }
    if(cudaMemcpy(device_p, temp, sizeof(float) * dataH * dataW, cudaMemcpyHostToDevice) != cudaSuccess)
    {
      	printf("device_x unsuccessful\n");
    }
    if(cudaMemcpy(d_pixel, h_pixel, sizeof(int) * dataH * dataW, cudaMemcpyHostToDevice) == cudaSuccess)
    {
    	printf("pattern copy is successful\n");
    }
    else printf("pattern copy error\n");

//    GeneratePattern(d_pixel, blockSize.x, blockSize.y, percentage);

//    initializePixelShuffle(d_pixel);
//    cudaMemset(device_x, 255, dataH*dataW*sizeof(float));

    cudaMemcpy(d_data, data, sizeof(float)*dataH*dataW,cudaMemcpyHostToDevice);

    //dot product only
    cudaMemcpy(d_a, a, sizeof(float)*dataH*dataW, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, b, sizeof(float)*dataH*dataW, cudaMemcpyHostToDevice);

    cudaEventCreate(&start);
    cudaEventRecord(start,0);
    printf("Calling Reconstruction\n");

    reconstructionFunction(gridSize, blockSize, d_data, d_pixel, kernel, d_result, kernelH, kernelW, dataH, dataW, device_x, device_p);
//        reconstructionFunction(gridSize, blockSize, d_a, kernel, d_dot, kernelH, kernelW, dataH, dataW, device_x, device_p); //Dot Product only
    cudaEventCreate(&stop);
    cudaEventRecord(stop,0);
    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&time, start,stop);
    cudaMemcpy(result, d_result, sizeof(float) * dataH * dataW, cudaMemcpyDeviceToHost);
//    cudaMemcpy(dotRes, d_dot, sizeof(float) * gridSize.x*gridSize.y, cudaMemcpyDeviceToHost); //Dot Product only


    int falseCounter = 0;
    writeData(result, dataH, dataW);

    printf("Time: %f\n", time);


    cudaFree(device_p);
    cudaFree(device_x);
    cudaFree(d_data);
//

}




/*
   for(int i=0; i<dataH*dataW; i++)
   {
       if((result[i]>=dataH*dataW))
       {
           printf("index %d has an error\n", result[i]);
           falseCounter++;
       }
   }
   if(falseCounter>0)
   {
       printf("Error in bid\n");
   }
   else printf("No error in bid\n");
   */









/*
    float sum = 0;
    for(int i=0;i<gridSize.x*gridSize.y;i++)
    {
        sum += dotRes[i];
        if(i<10)
        {
            printf("%f ", dotRes[i]);
        }
//        printf("%f ", dotRes[i]);
    }
    printf("\nRes: %f", sum);
*/


    //Dot Product Test
/*
    cudaMemcpy(dotRes, d_dot, sizeof(float) * gridSize.x * gridSize.y, cudaMemcpyDeviceToHost);
    VectorDotProduct(gridSize, blockSize, d_a, d_b, d_dot,dataH,dataW);
    cudaMemcpy(dotRes,d_dot, sizeof(float)* gridSize.x*gridSize.y, cudaMemcpyDeviceToHost);
    float mat = 0;
    int missCount = 0;
    FILE *res = fopen("/home/reza/sharedMemoryProject/textFiles/dotOutImage.txt","r");
    for(int i=0;i<gridSize.x*gridSize.y;i++)
    {
        fscanf(res, "%f", &matDot[i]);
        mat +=matDot[i];
        if(i<10)
        {
            printf("%f\t%f\n", dotRes[i], matDot[i]);
        }

        if(abs(matDot[i] - dotRes[i])>0.0f)
        {
            missCount++;
            printf("[M]: %f\t[C]: %f\n", matDot[i], dotRes[i]);
        }
    }

    float s = 0;
    for(int i = 0; i<gridSize.x*gridSize.y; i++)
    {
        s +=dotRes[i];
    }
    printf("cuda: %f Matlab: %f\n", s, mat);
    printf("Number of Miss matched block is %d\n", missCount);
*/
