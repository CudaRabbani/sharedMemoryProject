clear;
img = imread('/home/reza/cuda-workspace/testCmake/Data/lena_256.jpg');
[r c p] = size(img);



image=fopen('/home/reza/cuda-workspace/testCmake/textFiles/StY.txt', 'r');

img = fscanf(image,'%f');
img = reshape(img, [r, c]);
%subplot(1,2,1);
%img = fliplr(img);
imshow(img, []);
figure;



%subplot(1,2,1);
%imshow(rgb2gray(img));
% title('original');
% figure;
image=fopen('/home/reza/cuda-workspace/testCmake/textFiles/solverOutput.txt', 'r');

img = fscanf(image,'%f');
img = reshape(img, [r, c]);
%img = img';
%subplot(1,2,2);
imshow(img, [0 1]);
title('CUDA output');
format long
%diff = sum(sum(img))



