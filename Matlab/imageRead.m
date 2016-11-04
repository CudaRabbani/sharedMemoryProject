img = imread('/home/reza/sharedMemoryProject/Data/lena_256.jpg');
[r c p] = size(img);
 
% reImg = imresize(img, 0.5);
% [r c p] = size(reImg);
% r
% c
% imshow(reImg);
% title('Resized Image');
% figure;

fileInfo = fopen('/home/reza/sharedMemoryProject/textFiles/image_256.txt', 'wt');;
grayImage = double(rgb2gray(img));
grayImage = grayImage./255;
fprintf(fileInfo, '%f\n', grayImage);
fclose('all');
imshow(grayImage, []);
