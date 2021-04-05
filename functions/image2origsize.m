function outputImage = image2origsize(inputImage,origSize)
   
oldSize = size(inputImage);                   %# Get the size of your image
newSize = max([origSize(1),origSize(2)],1);  %# Compute the new image size
scale = newSize./oldSize;
%# Compute an upsampled set of indices:


rowIndex = min(round(((1:newSize(1))-0.5)./scale(1)+0.5),oldSize(1));
colIndex = min(round(((1:newSize(2))-0.5)./scale(2)+0.5),oldSize(2));

%# Index old image to get new image:

outputImage = inputImage(rowIndex,colIndex,:);
end