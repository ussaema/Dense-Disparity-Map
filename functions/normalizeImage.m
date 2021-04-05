function outputImage = normalizeImage(inputImage)
        inputImage = rgb_to_gray(inputImage);
        W = double(inputImage);
        % Compute Mean
        mu = mean(W,'all');
        Wsub = W-mu;
        % Compute Standartdeviation
        sigma = std(W,0,'all')+1e-11;
        % Normalize
        W = Wsub/sigma;
        outputImage = W;
       % outputImage = uint8(outputImage*(255/max(outputImage,[],'all')));
end

