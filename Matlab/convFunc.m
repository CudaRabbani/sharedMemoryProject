MaskFile = fopen('/home/reza/sharedMemoryProject/textFiles/kernel.txt', 'r');
%mask = fscanf(MaskFile, '%f');
mask = [0.0001,0.0099,-0.0793,-0.0280,-0.0793,0.0099,0.0001,0.0099,-0.1692,0.6540,1.0106,0.6540,-0.1692,0.0099,-0.0793,0.6540,0.1814,-8.0122,0.1814,0.6540,-0.0793,-0.0280,1.0106,-8.0122,23.3926,-8.0122,1.0106,-0.0280,-0.0793,0.6540,0.1814,-8.0122,0.1814,0.6540,-0.0793,0.0099,-0.1692,0.6540,1.0106,0.6540,-0.1692,0.0099,0.0001,0.0099,-0.0793,-0.0280,-0.0793,0.0099,0.0001];
mask = reshape(mask, [7 7]);
mask = mask .* 0.01;


imgMat = fopen('/home/reza/sharedMemoryProject/textFiles/StY.txt', 'r');
img = fscanf(imgMat, '%f');

img = reshape(img, [512 512]);

%ans = conv2(img,mask, 'same');
ans = imfilter(img, mask);
imshow(ans, []);
title('Matlab output');
figure;
cudaFile = fopen('/home/reza/sharedMemoryProject/textFiles/solverOutput.txt', 'r');
cuda = fscanf(cudaFile, '%f');
cuda = reshape(cuda, [512 512]);
imshow(cuda, []);
title('CUDA output');
figure;
diff= (ans - cuda);
imshow(reshape(diff, [512 512]));
title('Difference');
diff_1 = sum(sum(diff))
sdiff = diff_1 .^2;
finalDiff = sum(sdiff);
format long
finalDiff = sum(finalDiff)