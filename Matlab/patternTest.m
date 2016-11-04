img = fopen('/home/reza/sharedMemoryProject/textFiles/Pattern.txt','r');
img = fscanf(img , '%f');
img = reshape(img, [16, 16]);
imshow(img);