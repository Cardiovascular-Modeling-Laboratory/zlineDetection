% makeGray - Creates grayscale version of image. It will check if an image 
% is in color or grayscale. If it is in color, it will output a grayscale 
% version. 
%
% Usage:
%  [ gray_im ] = makeGray( im );
%
% Arguments:
% 	im          - image that is a d1 x d2 x d3 matrix 
% 
% Returns:
%   gray_im     - grayscale version of supplied image (d1 x d2 x 1)
% 
% Dependencies: 
%   MATLAB Version >= 9.5 
%
%
% Tessa Morris
% Advisor: Anna Grosberg, Department of Biomedical Engineering 
% Cardiovascular Modeling Laboratory 
% University of California, Irvine 

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

