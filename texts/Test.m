file = fopen('Pattern.txt', 'r');
a = fscanf(file, '%d');

X = fopen('X_coords.txt', 'r');
x_coords = fscanf(X,'%d');
Y = fopen('Y_coords.txt', 'r');
y_coords = fscanf(Y,'%d');

img = zeros(512,512);

d = size(x_coords);
for i=1:d
    a = x_coords(i);
    b = y_coords(i);
    img(a+1,b+1) = 1;
end

imshow(img);


% matrix_2D = reshape(a, 512,512);
% imshow(matrix_2D, []);
% fclose(file);
