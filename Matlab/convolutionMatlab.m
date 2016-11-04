data = 0:255;

data = reshape(data, [16 16]);

data = data';
imshow(data);

kernel = [-1.0, 0.0, 1.0; -2.0, 0.0, 2.0; -1.0, 0.0, 1.0];

result = conv2(data, kernel, 'valid');
figure;
imshow(result);