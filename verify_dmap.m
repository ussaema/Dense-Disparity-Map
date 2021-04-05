function p = verify_dmap(D,G)

disp_map = double(D);
g_truth = double(G);
[m,n] = size(disp_map);

if min(disp_map(:))==0 && max(disp_map(:))==255
else
    % Normiere Disparity-Map zwischen 0 und 255
    disp_map=255*(disp_map(:)-min(disp_map(:)))./(max(disp_map(:))-min(disp_map(:)));
    disp_map=reshape(disp_map,[m,n]);
end

if min(g_truth(:))==0 && max(g_truth(:))==255
else
    % Normiere Ground-Truth zwischen 0 und 255
    g_truth=255*(g_truth(:)-min(g_truth(:)))./(max(g_truth(:))-min(g_truth(:)));
    g_truth=reshape(g_truth,[m,n]);
end

error = disp_map-g_truth;
%mean Square Error
mse = sum(sum(error.^2)) / (m*n);
%Peak Signal to Noise Ratio in dB
p = 10*log10(255*255/mse);

end

%https://de.mathworks.com/help/vision/ref/psnr.html