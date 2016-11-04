clear
dataH = 512;
dataW = 512;
blockW = 16;
blockH = 16;
blockXdim = dataW/blockW
blockYdim = dataH/blockH

image=fopen('/home/reza/sharedMemoryProject/textFiles/StY.txt', 'r');
img = fscanf(image,'%f');
% a = img;
% a = reshape(a, [512 512]);

a = 0:dataH*dataW-1;
a = reshape(a, [dataH dataW]);
b = a'.*a';
startR = 1;
finishR = 16;

count = 1;
for i= 1:blockYdim
    startC = 1;
    finishC = 16;
    for j = 1:blockXdim   
        block(count) = sum(sum(b(startR:finishR,startC:finishC)));
        startC = finishC + 1;
        finishC = startC + 15;
        count = count +1;
    end
    startR= finishR+1;
    finishR = startR +15;
end
count
% block1 = sum(sum(b(1:16,1:16)))
% block2 = sum(sum(b(1:16,17:32)))
% block3 = sum(sum(b(1:16,33:48)))
% block4 = sum(sum(b(1:16,49:64)))
data=fopen('/home/reza/sharedMemoryProject/textFiles/dotOutImage.txt', 'w');
for i =1:count - 1
    block(i);
    fprintf(data,'%f\n', block(i));
    if(i<11)
        fprintf('[%d]: %f\n', i,block(i))
    end
end
fclose(data);

format long
sum(block)