function output = mymedfilt(I,median_length,H,holes)
    med1 = floor(median_length(1)/2);
    med2 = floor(median_length(2)/2);
    outputPixelValue = I;
    [m,n]= size(I);
    if nargin == 2
        for i = 1+med1 : m-med1
            for j = 1+med2 : n-med2
                window = I(i-med1:i+med1,j-med2:j+med2);
                outputPixelValue(i,j) = median(window,'all');
            end
        end
        output = outputPixelValue;
    elseif nargin == 3
        tol = med1*med2/2;
        for i = 1+med1 : m-med1
            for j = 1+med2 : n-med2
                if sum(H(i-med1:i+med1,j-med2:j+med2) ~= 0,'all') < tol
                    window = I(i-med1:i+med1,j-med2:j+med2);
                    outputPixelValue(i,j) = median(window,'all');
                 end
            end
        end
        output = outputPixelValue;
    elseif nargin == 4     
         [row,col] = find(I<5); % 5 s good value
         for k = 1:length(row)
             i = row(k);
             j = col(k);
             if i>med1 && i<m-med1 && j>med2 && j<n-med2
             window = I(i-med1:i+med1,j-med2:j+med2);
             outputPixelValue(i,j) = median(window,'all');
             end
         end
         output = outputPixelValue;
    end
end