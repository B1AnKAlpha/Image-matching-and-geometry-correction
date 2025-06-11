function NCC = match_ncc(input,reference)
    a_equal = mean(input,"all");
   % b_equal = mean(reference,"all");
    NCC = zeros(size(reference,1)-size(input,1),size(reference,2)-size(input,2));
    for addi = 0:3:size(reference,1)-size(input,1)
        for addj = 0:3:size(reference,2)-size(input,2)
            b_equal = mean(reference(1+addi:addi+size(input,1),1+addj:addj+size(input,2)),"all");
            %up = 0;
            %for i = 1:size(input,1)
            %    for j = 1:size(input,2)
            %        up=up+(input(i,j)-a_equal)*(reference(i+addi,j+addj)-b_equal);
            %        up
            %    end
            %end
            up_array = (reference(1+addi:size(input,1)+addi,1+addj:size(input,2)+addj) - b_equal).*(input(1:size(input,1),1:size(input,2)) - a_equal);
            up = sum(up_array,"all");
           % down1=0;
           %for i = 1:size(input,1)
           %   for j = 1:size(input,2)
           %      down1=down1+(input(i,j)-a_equal)^2;
           %     down1
           % end
            %end
            %down2=0;
            down1_array = (input(1:size(input,1),1:size(input,2)) - a_equal).^2;
            down1 = sum(down1_array,"all");

            down2_array = (reference(1+addi:size(input,1)+addi,1+addj:size(input,2)+addj) - b_equal).^2;
            down2 = sum(down2_array,"all");

            %for i = 1:size(input,1)
            %    for j = 1:size(input,2)
            %        down2=down2+(reference(i+addi,j+addj)-b_equal)^2;
            %        down2
            %    end
            %end
            down = sqrt(double(down1*down2));
            
            NCC(addi+1,addj+1) = up/down;
        end
    end

end


clc;
clear;

reference = double(imread("参考影像.tif"));
img = double(imread("待配准.tif"));
n = 10;

x = linspace(1, size(img,1), n+1);
x(end) = [];
y = linspace(1, size(img,2), n+1);
y(end) = [];

index = 1;
ncc_result = [];
all_image = [];

% 子块尺寸
sub_h = floor(size(img,1)/((n+1)*1.5));
sub_w = floor(size(img,2)/((n+1)*1.5));

for xloc = 2:9
    for yloc = 2:9
        % 起始点
        x_minloc = round(x(xloc));
        y_minloc = round(y(yloc));

        % 结束点，确保不越界
        x_maxloc = min(x_minloc + sub_h - 1, size(img,1));
        y_maxloc = min(y_minloc + sub_w - 1, size(img,2));


        batch = img(x_minloc:x_maxloc, y_minloc:y_maxloc);

        % 匹配
        ncc = match_ncc(batch, reference);
        [M, idx] = max(ncc(:)); 
        [row, col] = ind2sub(size(ncc), idx);

        ncc_result = [ncc_result, [x_minloc ; y_minloc ; row ; col]];

        % 取匹配参考图块
        ref_x_end = min(row + sub_h - 1, size(reference,1));
        ref_y_end = min(col + sub_w - 1, size(reference,2));


        matched_patch = reference(row:ref_x_end, col:ref_y_end);
        all_image = [all_image; [matched_patch batch]];

        disp(['已完成第', num2str(index), '个点的匹配，该点NCC：',num2str(M)]);
        index = index + 1;
    end
end

figure(1);
imshow(uint8(all_image));
title('origin ncc_result');

writematrix(ncc_result,"ncc_result1.xlsx")
