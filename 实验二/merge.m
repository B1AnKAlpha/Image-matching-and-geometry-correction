
function his = rgb2his(rgb)
    R = rgb(:, :, 1); G = rgb(:, :, 2); B = rgb(:, :, 3); I = (R + G + B) / 3;
    minRGB = min(min(R, G), B); S = 1 - (3 ./ (R + G + B + eps)) .* minRGB;
    num = 0.5 * ((R - G) + (R - B)); den = sqrt((R - G).^2 + (R - B).*(G - B)) + eps;
    theta = acos(num ./ den); H = theta; H(B > G) = 2 * pi - H(B > G); H = H / (2 * pi);
    his = cat(3, H, I, S);
end

function rgb = his2rgb(his)
    H = his(:, :, 1) * 2 * pi; I = his(:, :, 2); S = his(:, :, 3); R = zeros(size(H));
    G = zeros(size(H)); B = zeros(size(H)); idx1 = (H >= 0) & (H < 2*pi/3);
    idx2 = (H >= 2*pi/3) & (H < 4*pi/3); idx3 = (H >= 4*pi/3) & (H <= 2*pi);
    B(idx1) = I(idx1) .* (1 - S(idx1)); R(idx1) = I(idx1) .* (1 + S(idx1) .* cos(H(idx1)) ./ cos(pi/3 - H(idx1)));
    G(idx1) = 3 * I(idx1) - (R(idx1) + B(idx1)); H2 = H - 2*pi/3; R(idx2) = I(idx2) .* (1 - S(idx2));
    G(idx2) = I(idx2) .* (1 + S(idx2) .* cos(H2(idx2)) ./ cos(pi/3 - H2(idx2))); B(idx2) = 3 * I(idx2) - (R(idx2) + G(idx2));
    H3 = H - 4*pi/3; G(idx3) = I(idx3) .* (1 - S(idx3)); B(idx3) = I(idx3) .* (1 + S(idx3) .* cos(H3(idx3)) ./ cos(pi/3 - H3(idx3)));
    R(idx3) = 3 * I(idx3) - (G(idx3) + B(idx3)); rgb = cat(3, R, G, B); rgb = max(rgb, 0); 
end

function matched_img = manual_histmatch(source_img, ref_img, max_val)
    num_bins = round(max_val) + 1; source_clamped = max(0, min(source_img, max_val));
    ref_clamped = max(0, min(ref_img, max_val)); idx_source = round(source_clamped(:)) + 1;
    idx_ref = round(ref_clamped(:)) + 1; hist_source = accumarray(idx_source, 1, [num_bins, 1]);
    hist_ref = accumarray(idx_ref, 1, [num_bins, 1]); cdf_source = cumsum(hist_source) / numel(source_img);
    cdf_ref = cumsum(hist_ref) / numel(ref_img); lut = zeros(num_bins, 1);
    for i = 1 : num_bins
        idx_match = find(cdf_ref >= cdf_source(i), 1, 'first');
        if isempty(idx_match), lut(i) = max_val; else, lut(i) = idx_match - 1; end
    end
    matched_img = lut(idx_source); matched_img = reshape(matched_img, size(source_img));
end


function scaled_img = stretch_and_scale(img_in)
    img_double = double(img_in);
    all_pixels = img_double(:);
    low_val = prctile(all_pixels, 0.5);
    high_val = prctile(all_pixels, 99.5);
    scaled_img = 255.0 * (img_double - low_val) / (high_val - low_val + eps);
    scaled_img = max(0, min(scaled_img, 255));
end

try
    rgb_raw = imread('多光谱.tif');
    pan_raw = imread('全色.tif');
catch ME
    error('错误信息: %s', ME.message);
end

disp('正在进行预处理...');
TARGET_MAX_VAL = 255.0;

SOURCE_MAX_VAL = 2047.0;
rgb_scaled = (min(double(rgb_raw), SOURCE_MAX_VAL) / SOURCE_MAX_VAL) * TARGET_MAX_VAL;


pan_scaled = stretch_and_scale(pan_raw);


if size(pan_scaled, 1) ~= size(rgb_scaled, 1) || size(pan_scaled, 2) ~= size(rgb_scaled, 2)
    pan_scaled = imresize(pan_scaled, [size(rgb_scaled, 1), size(rgb_scaled, 2)], 'bicubic');
end

his = rgb2his(rgb_scaled);
original_I = his(:, :, 2);

pan_matched = manual_histmatch(pan_scaled, original_I, TARGET_MAX_VAL);
pan_matched = manual_histmatch(original_I, pan_scaled, TARGET_MAX_VAL);
his(:, :, 2) = pan_matched;
fused_rgb = his2rgb(his);

fused_rgb_clipped = min(max(fused_rgb, 0), TARGET_MAX_VAL);
fused_rgb_final = uint8(fused_rgb_clipped);

% --- 图像显示 ---
figure('Name', 'IHS 融合结果 (优化版)', 'NumberTitle', 'off');

subplot(1,3,1); 
imshow(uint8(rgb_scaled)); 
title('原始彩色图像');

subplot(1,3,2); 
imshow(uint8(pan_scaled)); 
title('全色图像 (已拉伸)');

subplot(1,3,3); 
imshow(fused_rgb_final); 
title('融合后图像');