%Tessa Altair Morris ID: 60007036
%CS 216 Spring 2018
%Homework 4, Problem 1

function [ mag, ori ] = computeImageGradient( I, sigma )
% This function is used by hog.m 
% It computes the image gradient magnitude and orientation at each pixel
% It does this by first applying a Gaussian filter for a set sigma value, 
% and then computes the horizontal and vertical derivatives. 

%Gaussian filter the iamge  
gauss_image = imgaussfilt( I, sigma );
    
%Compute the gradient in the x and y directions 
[dx, dy] = gradient( gauss_image );

%The magnitude is the sqrt of gradient in the x and y directions 
mag = sqrt( dx.^2 + dy.^2 ); 

%The orientation is the inverse tangent of dy over dx  
ori = atan2(dy, dx);

end 