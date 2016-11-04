clear;
% //  0, 1, 1, 1, 2, 3, 4, 6, 9, 13, 19, 28, 41, 60, 88, 129, 189, 277, 406, 595, 872, 1278, 1873, 2745, 4023, 5896
img = imread('/home/reza/cuda-workspace/testCmake/Data/lena_256.jpg');
fileID1=fopen('/home/reza/cuda-workspace/testCmake/textFiles/Pattern.txt','wt');
styFile = fopen('/home/reza/cuda-workspace/testCmake/textFiles/StY.txt', 'wt');
[r, c, p]=size(img);
H=r;
W=c;
mask=zeros(H,W);
%mask(1:2:end, 1:2:end) = 1;
G2=277;
G1=406;
inc=abs(G2-G1);
pixel = 0.85;
NUM=H*W*pixel;
x=0;y=0;N=0;

while N<NUM
    if and(x<W, y<H)
        mask(sub2ind(size(mask), y+1, x+1))=1;
        N=N+1;
    end
    x=mod(x+inc, G1);
    y=mod(y+inc, G2);
end



%mask=logical(mask);

%mask=mask';
s = sprintf('Mask using %.2f pixel', pixel * 100);
fprintf(fileID1, '%d\n', mask);
imshow(mask);
title (s);
figure;

grayImage = double(rgb2gray(img));
grayImage = grayImage./255;
maskedImage = grayImage .* mask;
fprintf(styFile, '%f\n', maskedImage);
sf = sprintf('Image using %.2f pixel', pixel * 100);
 imshow(maskedImage, []);
 title (sf);
% title('Original gray image')
% figure;
fclose('all');




