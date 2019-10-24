% labelSkeleton - function to add color onto grayscale image at places that
% are positive (1) on a binary image (skeleton)
%
% Arguments:
%   im          - grayscale image 
%                   Class Support: 2D image matrix 
%   skel        - binary skeleton 
%                   Class Support: 2D logical same size as im 
% 
% Returns:    
%   labeled_im  - image labeled in yellow with binary skelton
%                   Class Support: 3D matrix 
% 
% Dependencies: 
%   MATLAB Version >= 9.5 
%   Image Processing Toolbox Version 10.3
%
% Tessa Morris
% Advisor: Anna Grosberg, Department of Biomedical Engineering 
% Cardiovascular Modeling Laboratory 
% University of California, Irvine 

function [ labeled_im ] = labelSkeleton( im, skel )

%Make sure image is mat2gray 
im = mat2gray(im); 

%Save the image as individual RGB channels
RChannel = im;
GChannel = im;
BChannel = im;

%Yellow triplet is [1 1 0]. Set channels where the skeleton is positive
RChannel(skel == 1) = 1; 
GChannel(skel == 1) = 1; 
BChannel(skel == 1) = 0; 

%Concatinate into a labeled image
labeled_im(:,:,1) = RChannel;
labeled_im(:,:,2) = GChannel;
labeled_im(:,:,3) = BChannel;

end

