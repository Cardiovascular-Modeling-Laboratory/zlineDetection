% createInitialMask - Create binary image from a grayscale image 
%
% Usage:
%   im, bw, mask = createInitialMask( im , disk_size)
%
% Arguments:
%   im          - grayscale 2D image 
%                   Class Support: real, non-sparse, 2-D matrix 
%   disk_size   - size of disk structuring object for dilation 
%                   Class Support: real, positive number 
%
% Returns:
%   im          - same as input im 
%                   Class Support: real, non-sparse, 2-D matrix 
%   bw          - binary version of im 
%                 	Class Support: logical matrix the same size as im 
%   mask        - dilated binary version of bw 
%                   Class Support: logical matrix the same size as im 
%   
%
% Dependencies: 
%   MATLAB Version >= 9.5 
%   Image Processing Toolbox Version 10.3
%
% Tessa Morris
% Advisor: Anna Grosberg, Department of Biomedical Engineering 
% Cardiovascular Modeling Laboratory 
% University of California, Irvine 

function [ im, bw, mask ] = createInitialMask( im , disk_size)
%Convert to binary using both adaptive and normal thresholding
bw1 = imbinarize(im,'adaptive','Sensitivity',1); 
bw2 = imbinarize(im); 

%Create binary matrix where both binarizations are 1 
bw = zeros(size(im)); 
bw( bw1==true & bw2==true ) = 1;

%Dilate binary image with a disk structure 
mask =imdilate( bw, strel( 'disk', disk_size ) );

%Get the number of pixels that are 0,1,and total 
im_mask = zeros(size(im)); 
im_mask(mask ==1) = 1; 
pos_pix = sum(im_mask(:)); 
tot_pix = size(im,1)*size(im,2); 
disp(pos_pix/tot_pix); 
end

