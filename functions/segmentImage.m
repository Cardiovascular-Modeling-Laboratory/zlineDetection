% segmentImage - Adaptive thresholding to remove background from image.
% This function will segment the image using the Yanowitz-Bruckstein 
% image segmentation with fiber unentanglement. The gray values of these 
% edge pixels are fixed in the initial threshold surface and the remaining 
% surface is obtained by solving the Laplace equation through successive 
% over-relaxation
%
%
% Usage:
%  [ yb_bw, std_bw, yb_gray ] = segmentImage( im ); 
%
% Arguments:
%   im              - Image to be segmented. For best results, this image
%                       should have been filtered using diffusion & top hat
%                       filtering
%                       Class Support: gray scale image  
%   mask            - Optional argument masking regions that are in the 
%                       background
%                       Class Support: logical same size as image 
%   maxiter         - max the number of iterations (Default 40) 
%                       Class Support: positive integer 
%
% Returns:
%   seg_im          - Segmented image where pixels above the threshold
%                       surface are white, back otherwise
%                       Class Support: logical same size as image 
%   surface_thresh  - Threshold surface 
%                       Class Support: gray scale image of the surface  
%
% Dependencies: 
%   MATLAB Version >= 9.5 
%   Image Processing Toolbox Version 10.3
%   Functions: 
%       makeGray.m
%       segmentImage.m
%
% Written by Nils Persson 2016
% Modified by Tessa Morris 
% Advisor: Anna Grosberg, Department of Biomedical Engineering 
% Cardiovascular Modeling Laboratory 
% University of California, Irvine 

function [ seg_im, surface_thresh ] = segmentImage( im, mask, maxiter )

% Convert the image to be grayscale and conver to double precision 
[ gray_im ] = double( makeGray( im ) );

% Set the mask to be all ones if it was not provided or if the mask is not 
% the same size as the image create a mask the same size as the image 
if nargin == 1  
    mask = ones(size(im)); 
else
    if size(mask,1) ~= size(im,1) || size(mask,2) ~= size(im,2)
        mask = ones(size(im)); 
    end 
end 

% Set the max number of iterations if has not been provided by the user  
if nargin < 3
    maxiter = 40; 
end 

% Apply a Canny edge finder - 1's at the edges, 0's elsewhere and convert
% to double precision 
edges = double ( edge( gray_im,'canny' ) );

% Fill in the grey values of the edge pixels in a new image file                      
% edge_intensities = gray_im.*edges;
initial_thresh = gray_im.*edges;

% Remove the regions of the initial thresh that are masked
initial_thresh( mask == 0 ) = 0; 

% Perform Yanowitz-Bruckstein surface interpolation to create threshold
% surface from edge gray values
surface_thresh = YBiter( initial_thresh, maxiter ); 

% Segment the image. Pixels above threshold surface are white, black
% otherwise
seg_im = gray_im > surface_thresh;

% Make sure that all regions in the background have been removed
seg_im( mask == 0 ) = 0; 

end
