function [ BW, processed_image ] = image_processing( filename )
%Read the original image 
I = imread(filename);

%Some time the image will not have been converted to gray properly. The
%image will be a n x m x 3 where the 3 represents the  3 planes
%(red, green, blue). If that is the case then convert it to be actual gray
%scale
[~, ~, dim] = size(I); 

if dim == 1
    %Convert image to be between 0 and 1. 
    BW = mat2gray(I);
else
    %Convert image to grayscale
    grayI = rgb2gray(I); 
    %Convert Image to be between 0 and 1
    BW = mat2gray(grayI); 
end 

%Initially adjust and sharpen the image. 
adjusted_BW = imadjust(BW);
processed_image = imsharpen(adjusted_BW,'Radius',2,'Amount',1);
    

end

