clc
clear
%% 读取数据
I = imread('待配准.tif');
J = imread('参考影像.tif');
[m,n] = size(J);
[o,p] = size(I);
convert = zeros(1000,1000);

fixedPoints = readtable('ncc_result1.xlsx');
X = table2array(fixedPoints(1,:));
Y = table2array(fixedPoints(2,:));
x = table2array(fixedPoints(3,:));
y = table2array(fixedPoints(4,:));
X = X';
Y = Y';
x = x';
y = y';

one = ones(size(x));
A = [one X Y];


%% 多项式的遥感图像纠正
Lx = x';
Ly = y';

% 计算多项式系数
delta_a = (A'*A)\A'*Lx';
delta_b = (A'*A)\A'*Ly';

Vx = A*delta_a-Lx';
Vy = A*delta_b-Ly';

% 精度评定
epsilon_x = sqrt(sum(Vx'.*Vx,"all")/61);
epsilon_y = sqrt(sum(Vy'.*Vy,"all")/61);

disp(['X精度为',num2str(epsilon_x),'，Y精度为',num2str(epsilon_y)])

%% 遥感图像纠正变换
conner_x = delta_a(1)+delta_a(2)*[1;m;m;1]+delta_a(3)*[1;1;n;n];
conner_y = delta_b(1)+delta_b(2)*[1;m;m;1]+delta_b(3)*[1;1;n;n];


X1 = min(conner_x,[],'all');
X2 = max(conner_x,[],'all');
Y1 = min(conner_y,[],'all');
Y2 = max(conner_y,[],'all');
M = (Y2-Y1)+1;
N = (X2-X1)+1;

for i = 1:o
    for j = 1:p
        convert_x = delta_a(1)+delta_a(2).*i+delta_a(3).*j;
        convert_y = delta_b(1)+delta_b(2).*i+delta_b(3).*j;
        %原图像灰边
        convert(floor(convert_x+45),floor(convert_y+45)) = I(i,j);
        
    end
end

convert_img = uint8(convert(47:floor(45+X2),47:floor(45+Y2)-2));
figure(1);
imshow(convert_img);
title('convert');

figure(2);
imshow(uint8(I));
title('origin');

%% 插值
[a,b] = size(convert_img);
[zero_y, zero_x] = find(convert_img == 0);

% 筛除边界的 0 值
valid_idx = (zero_x > 1) & (zero_x < b) & (zero_y > 1) & (zero_y < a);
afterzero_x = zero_x(valid_idx);
afterzero_y = zero_y(valid_idx);

% 邻近像素索引
left_x = afterzero_x - 1;
right_x = afterzero_x + 1;
up_y = afterzero_y - 1;
down_y = afterzero_y + 1;

% 插值计算
convert_img(sub2ind([a, b], afterzero_y, afterzero_x)) = ...
    0.25 * convert_img(sub2ind([a, b], up_y, afterzero_x)) + ...
    0.25 * convert_img(sub2ind([a, b], down_y, afterzero_x)) + ...
    0.25 * convert_img(sub2ind([a, b], afterzero_y, left_x)) + ...
    0.25 * convert_img(sub2ind([a, b], afterzero_y, right_x));

figure(3);
imshow(uint8(convert_img));
title('chazhi');