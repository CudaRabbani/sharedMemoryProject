#include "generatepattern.h"


void GeneratePattern(int *d_pixel, int width, int height, float percentage)
{
    FILE *fp, *x_fp, *y_fp;
    fp = fopen("/home/reza/sharedMemoryProject/textFiles/Pattern.txt", "wb");

    if(fp == NULL)
    {
        printf("No such file\n");
    }

    printf("\nGerating Pattern");
    int **pixels;
    int *pix_1D = (int *)malloc(sizeof(int)*height*width);
    int G1, G2;
    int inc;
    int  x, y, N;
    int *x_temp, *y_temp;
    float total_pixel_num;
//  0, 1, 1, 1, 2, 3, 4, 6, 9, 13, 19, 28, 41, 60, 88, 129, 189, 277, 406, 595, 872, 1278, 1873, 2745, 4023, 5896
    G1 = 28; //it has to be bigger
    G2 = 19;
    x = 0, y=0, N = 0;
    int c =0;
    inc = abs(G1-G2);
    total_pixel_num = width * height * percentage;

    x_temp = (int *)malloc(sizeof(int)*height*width);
    y_temp = (int *)malloc(sizeof(int)*height*width);

    pixels = (int **)malloc(sizeof(int *)*height);
    for(int i=0; i<height;i++)
    {
        pixels[i] = (int *)malloc(sizeof(int)*width);
    }

    int count = width*height;
    for(int i=0; i<width; i++)
    {
        for(int j=0; j<height; j++)
        {
            pixels[i][j] = 0;
        }

    }
    while(N<total_pixel_num)
    {
        if((x<width)&&(y<height))
        {
            pixels[x][y] = 1;
            x_temp[c] = x;
            y_temp[c] = y;
            c++;
            N++;

        }
        x = (x + inc)%G2;
        y = (y + inc)%G1;
        //fprfloatf(fp, "%d\n", pixels[N]);

    }
    int temp;
    for(int i=0; i<width; i++)
    {
        for(int j=0; j<height; j++)
        {
            temp = i+width*j;
            pix_1D[temp] = pixels[i][j];

        }

    }
//    prfloatf(".");
    printf("\ntotal_pixel_num: %f \n Total number of pixels using %d\n", total_pixel_num, c);
    for(int i=0; i<count; i++)
    {
        fprintf(fp, "%d\n", pix_1D[i]);
//        printf("%f\n", pix_1D[i]);

    }
     if(cudaMemcpy(d_pixel, pix_1D, sizeof(float)*width*height,cudaMemcpyHostToDevice)!=cudaSuccess)
     {
         printf("\nPattern Generation Copy Error\n");
     }
     fclose(fp);
     printf(".\nGenarating Pattern Complete, Using percentage: %f\n", percentage);

}
