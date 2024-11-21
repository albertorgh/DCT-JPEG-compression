I = imread('prato.jpg');
I = rgb2gray(I);
I = im2double(I);
T = dctmtx(8);
dct = @(block_struct) T * block_struct.data * T';
B = blockproc(I,[8 8],dct);
mask = [1   1   1   1   0   0   0   0
        1   1   1   0   0   0   0   0
        1   1   0   0   0   0   0   0
        1   0   0   0   0   0   0   0
        0   0   0   0   0   0   0   0
        0   0   0   0   0   0   0   0
        0   0   0   0   0   0   0   0
        0   0   0   0   0   0   0   0];
B2 = blockproc(B,[8 8],@(block_struct) mask .* block_struct.data);
invdct = @(block_struct) T' * block_struct.data * T;
I2 = blockproc(B2,[8 8],invdct);
imshow(I)
figure
imshow(I2)

%%
I = imread('prato.jpg');
[rows, cols, ~] = size(I);
rows = floor(rows / 8) * 8;
cols = floor(cols / 8) * 8;
I = I(1:rows, 1:cols, :);
I = im2double(I);
R = I(:,:,1);
G = I(:,:,2);
B = I(:,:,3);
T = dctmtx(8);
dct = @(block_struct) T * block_struct.data * T';
Rb = blockproc(R,[8 8],dct);
Gb = blockproc(G,[8 8],dct);
Bb = blockproc(B,[8 8],dct);
mask = [1   1   1   1   0   0   0   0
        1   1   1   0   0   0   0   0
        1   1   0   0   0   0   0   0
        1   0   0   0   0   0   0   0
        0   0   0   0   0   0   0   0
        0   0   0   0   0   0   0   0
        0   0   0   0   0   0   0   0
        0   0   0   0   0   0   0   0];
Rb2 = blockproc(Rb,[8 8],@(block_struct) mask .* block_struct.data);
Gb2 = blockproc(Gb,[8 8],@(block_struct) mask .* block_struct.data);
Bb2 = blockproc(Bb,[8 8],@(block_struct) mask .* block_struct.data);
invdct = @(block_struct) T' * block_struct.data * T;
IR = blockproc(Rb2,[8 8],invdct);
IG = blockproc(Gb2,[8 8],invdct);
IB = blockproc(Bb2,[8 8],invdct);
I2 = cat(3,IR,IG,IB);

imshow(I)
figure
imshow(I2)

% Metriche per la valutazione: MSE e Compression Ratio

mse_R = mean((R(:) - IR(:)).^2);
mse_G = mean((G(:) - IG(:)).^2);
mse_B = mean((B(:) - IB(:)).^2);
MSE = (mse_R+mse_B+mse_G)/3;
fprintf('MSE totale: %.4f\n',MSE);

total_coeffs = numel(mask) * (rows / 8) * (cols / 8); 
kept_coeffs = sum(mask(:) ~= 0) * (rows / 8) * (cols / 8); 
compression_ratio = kept_coeffs / total_coeffs * 100;
fprintf('Compression Ratio: %.4f\n', compression_ratio)