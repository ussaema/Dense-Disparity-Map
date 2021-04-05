function outputImage = gradientImage(inputImage)
    inputImage = rgb_to_gray(inputImage);
    [fx,fy]=sobel_xy(inputImage);
    outputImage = sqrt(fx.^2+fy.^2);
    outputImage = uint8(outputImage*(255/max(outputImage,[],'all')));
end

