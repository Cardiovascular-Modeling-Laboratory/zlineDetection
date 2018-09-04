% MAKEGRAY - Creates grayscale version of image. 
%
% This function checks if an image is in color or not. If it is in color,
% it will output a grayscale version. 
%
% Usage:
%  [ gray_im ] = makeGray( im );
%
% Arguments:
%       im          - Image that is a d1 x d2 x d3 matrix 
% 
% Returns:
%       gray_im     - Grayscale version of supplied image (d1 x d2 x 1)
% 
% Suggested parameters: None
% 
% See also: ANALYZEIMAGE

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

