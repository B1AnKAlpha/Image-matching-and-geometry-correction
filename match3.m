function NCC = match_ncc(input,reference)
    a_equal = mean(input,"all");
    NCC = zeros(size(reference,1)-size(input,1),size(reference,2)-size(input,2));
    for addi = 0:size(reference,1)-size(input,1)
        for addj = 0:size(reference,2)-size(input,2)
            b_equal = mean(reference(1+addi:addi+size(input,1),1+addj:addj+size(input,2)),"all");
            up_array = (reference(1+addi:size(input,1)+addi,1+addj:size(input,2)+addj) - b_equal).*(input(1:size(input,1),1:size(input,2)) - a_equal);
            up = sum(up_array,"all");
            down1_array = (input(1:size(input,1),1:size(input,2)) - a_equal).^2;
            down1 = sum(down1_array,"all");
            down2_array = (reference(1+addi:size(input,1)+addi,1+addj:size(input,2)+addj) - b_equal).^2;
            down2 = sum(down2_array,"all");
            down = sqrt(double(down1*down2));
            
            NCC(addi+1,addj+1) = up/down;
        end
    end

end


clc;
clear;

all_image = [];
ncc_result = [];
reference = double(imread("template.tif"));
img = double(imread("img.tif"));

ncc = match_ncc(reference, img);
[M, idx] = max(ncc(:)); 
[row, col] = ind2sub(size(ncc), idx);

matched_patch = img(row:row+ size(reference,1)-1, col:col + size(reference,2)-1);
b = reference(:,:,1);
ncc_result = [row ; col];
all_image = [matched_patch reference(:,:,1)];


figure(1);
imshow(uint8(all_image));
title('origin      result');

figure(2);
imshow(uint8(img(:,:,1)))
hold on 
rectangle('Position',[row,col,size(reference,1)-1,size(reference,1)-1],'LineWidth',2,'EdgeColor','r');
title('rectrangle');