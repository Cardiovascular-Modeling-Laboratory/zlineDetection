% hog - (Histogram of Gradient Orientations) Compute the gradient 
% orientation histograms over blk_size x blk_size blocks of pixels in an 
% image. The orientations are binned into 9 possible bins. 
%
% Usage: 
%   ohist = hog( I, sigma ); 
%
% Arguments:
%   I                   - grayscale image of dimension HxW
%                           Class Support: GRAYSCALE IMAGE
%   simga               - simga of Gaussian filter  
%                           Class Support: positive number > 1 
%   blk_size            - block size (DEFAULT 8)
%                           Class Support: positive integer > 1
% Returns:
%   ohist               - orientation histograms for each block.
%                           ohist(i,j,k) contains the count of how many 
%                           edges of orientation k fell in block (i,j)
%                           Class Support: DOUBLE (H/blk_size)x(W/blk_size)
%                                           x9 
%
% Dependencies: 
%   MATLAB Version >= 9.5 
%   Image Processing Toolbox Version 10.3
%   Functions: computeImageGradient.m
%
% Written for CS 216: Image Understanding at University of California, 
% Irvine in Spring 2018 taught by Professor Charless Fowlkes
% Tessa Morris 
% Advisor: Anna Grosberg, Department of Biomedical Engineering 
% Cardiovascular Modeling Laboratory 
% University of California, Irvine 


function [ohist,thresh_per] = hog( I, sigma, blk_size )

% OUTPUT 
% ohist : orientation histograms for each block. ohist is of dimension 
% (H/8)x(W/8)x9 ohist(i,j,k) contains the count of how many edges of 
% orientation k fell in block (i,j)

%Determine the size of the input image 
[h,w] = size(I); 

%Declare a block size if not declared by user
if nargin < 3
    blk_size = 8; 
end 

%Determine the size of the output. It will be the (rounded up) size of the
%image divided by the block size ( 8 x 8 )
h2 = ceil(h/blk_size); 
w2 = ceil(w/blk_size);

%Number of orientation bins. 
nori = 9;       

%Use function mygradient to compute the gradient magnitude and orientation
%at each pixel. This is based on how it was done in Homework 3  
[ mag, ori ] = computeImageGradient( I, sigma ); 

%
min_thresh = 0.025; 
max_thresh = 0.1; 
step_thresh = 0.025; 

% Store the ratio of the image foreground/background intensities 
threshes = min_thresh:step_thresh:max_thresh; 
bfratio = zeros(length(threshes),1); 
%Use a threshold to determine if a pixel is an edge.
% Determine the value of the threshold 
for tp = 1:length(threshes)
    % Calculate the threshold value 
    temp_thresh = threshes(tp)*max(mag(:)); 
    
    % Get a binary matrix of the edges 
    temp_edges = mag; 
    temp_edges(mag > temp_thresh) = 1; 
    temp_edges(mag <= temp_thresh) = 0; 
    figure; imshow(temp_edges); title(num2str(tp)); 
    % Compute average intensity of the foreground 
    Ifore = I; 
    Ifore(temp_edges == 0) = NaN; 
    Ifore = Ifore(:); 
    Ifore(isnan(Ifore)) = []; 
    % Compute average intensity of the background 
    Iback = I; 
    Iback(temp_edges == 1) = NaN; 
    Iback = Iback(:); 
    Iback(isnan(Iback)) = []; 
    disp(median(Ifore));
    % Calculate the ratio of the background/foreground 
    bfratio(tp,1) = median(Iback)/median(Ifore); 
end 

% Get the index and the values of the minimum background/foreground 
[~, idx] = min(bfratio); 

% Save the threshold percentage
thresh_per = threshes(idx); 

% Set the threshold
thresh = threshes(idx)*max(mag(:)); 

%Bin orientations into 9 equal sized bins between -pi/2 and pi/2 
bin_size = pi/9; 

%Initialize the orientation histograms for each block
ohist = zeros(h2,w2,nori);

%Separate out pixels into orientation channels
%Suggested: Loop over the orientation bins. Identify the pixels in the
%image whose magnitude is above the threshold and whose orientation falls
%in the given bin. 
%Do this using logical oprations in order to generate an array the same
%size as the image that contains 1s at the locations of every edge pixels
%that falls int he given orientation bin and is above threshold. 
%Can use the function im2col(.., [8 8], 'distinct') to collect pixels in
%each 8 x 8 spatial block. This function will automatically pad out the
%image to a multiple of 8, which is convenient. 
for i = 1:nori
    
    %Find the min and max angle for the current bin
    min_angle = (-pi/2) + (i-1)*bin_size; 
    max_angle = (-pi/2) + i*bin_size; 
        
    %Create a binary image containing 1's for the pixels that are edges at 
    %this orientation. 
    %Initalize the binary image (B) to be all zeros, and then set values
    %that are inbetween the min and max angle and have a magnitude greater
    %than the threshold equal to 1. 
    B = zeros(h,w); 
    B( ori >= min_angle & ori <= max_angle & mag > thresh) = 1;  
    
    %Sum up the values over blk_sizexblk_size pixel blocks.The function 
    %im2col is a useful function for grabbing blocks
    chblock = im2col(B,[blk_size blk_size],'distinct');  
  
    %Sum over each block and store result in ohist                                       
    ohist(:,:,i) = reshape( sum(chblock,1), [h2 w2] ); 
  
end

%Because each block will contain a different number of edges, normalize the
%resulting histogram such that sum(ohist,3) is 1 everywhere
%NOTE: Don't divide by 0! If there are no edges in a block (ie. this counts
%sums to 0 for the block) then just leave all the values 0.

%Calculate the sum of the third dimension of ohist 
sum_dim3 = sum(ohist,3);

%If any of the dimensions sum to 0, set them equal to 1 so that there is no
%dividing by 0
sum_dim3( sum_dim3 == 0 ) = 1; 

%Divide the ohist by the sum of its third dimension. 
ohist = bsxfun(@rdivide, ohist, sum_dim3); 

end 