function [ gray_im ] = makeGray( im )
%Convert a color image from rgb to grayscle 

%Get the size of the image 
d3 = size(im,3); 

%If the image is an rgb image, save a grayscale version of it.
if d3 > 2
    gray_im = rgb2gray(im);
else
    gray_im = im;
end

end

