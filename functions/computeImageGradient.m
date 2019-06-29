% computeImageGradient - Written for usage with hog.m It computes the image 
% gradient magnitude and orientation at each pixel. It does this by first 
% applying a Gaussian filter for a set sigma value, and then computes the 
% horizontal and vertical derivatives. 
%
%
% Usage: 
%   [ mag, ori ] = computeImageGradient( I, sigma ); 
%
% Arguments:
%   I                   - grayscale image of dimension HxW
%                           Class Support: GRAYSCALE IMAGE
%   simga               - simga of Gaussian filter  
%                           Class Support: positive number > 1 
%
% Returns:
%   mag                 - magnitude is the sqrt of gradient in the x and y
%                           directions 
%                           Class Support: DOUBLE HxW
%   ori                 - orientation is the inverse tangent of dy over dx
%                           Class Support: DOUBLE HxW
%
% Dependencies: 
%   MATLAB Version >= 9.5 
%   Image Processing Toolbox Version 10.3
%
% Written for CS 216: Image Understanding at University of California, 
% Irvine in Spring 2018 taught by Professor Charless Fowlkes
% Tessa Morris 
% Advisor: Anna Grosberg, Department of Biomedical Engineering 
% Cardiovascular Modeling Laboratory 
% University of California, Irvine 

function [ mag, ori ] = computeImageGradient( I, sigma )
%Gaussian filter the iamge  
gauss_image = imgaussfilt( I, sigma );
    
%Compute the gradient in the x and y directions 
[dx, dy] = gradient( gauss_image );

%The magnitude is the sqrt of gradient in the x and y directions 
mag = sqrt( dx.^2 + dy.^2 ); 

%The orientation is the inverse tangent of dy over dx  
ori = atan2(dy, dx);

end 