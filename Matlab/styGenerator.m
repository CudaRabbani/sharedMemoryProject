img = imread('/home/reza/sharedMemoryProject/Data/lena_256.jpg');
[r, c, p]=size(img);

styFile = fopen('/home/reza/sharedMemoryProject/textFiles/StY_256.txt', 'wt');
rawImg = fopen('/home/reza/sharedMemoryProject/textFiles/image_256.txt', 'r');
mask=fopen('/home/reza/sharedMemoryProject/textFiles/Pattern.txt', 'r');

mask_value=fscanf(mask, '%d');
mask = reshape(mask_value, [16, 16]);
pix_value=fscanf(rawImg, '%f');
pixImg = reshape(pix_value, [r, c]);

dataH = r;
dataW = c;
blockW = 16;
blockH = 16;
blockXdim = dataW/blockW;
blockYdim = dataH/blockH;

noBlocks = blockXdim * blockYdim

startR = 1;
finishR = 16;

count = 1;
maskCount = 1;
blockCount = 1;

maskY = 1;

for i = 1:dataH
    for j = 1:dataW
        if(and(j<=16,i<=16))
            pixImg(i,j) = pixImg(i,j) * mask(i,j);
        else
            pixImg(i,j) = pixImg(i,j) * mask(mod(i,16)+1,mod(j,16)+1);
        end
    end
end
fprintf(styFile, '%f\n',pixImg);
%result = reshape(sty,[r c]);
imshow(pixImg, []);
fclose('all');