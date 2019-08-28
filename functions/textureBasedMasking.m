% textureBasedMasking - Determines regions (blk_sze x blk_sze) in an image
% that contains an edge and texture in that region
%
% Usage: 
%   [bw_final,background, per_rem] = ...
%       textureBasedMasking(I,sigma,blk_size,noise_size,...
%       displayResults)
%
% Arguments:
%   I                   - grayscale image of dimension HxW
%                           Class Support: GRAYSCALE IMAGE
%   simga               - simga of Gaussian filter  
%                           Class Support: positive number > 1 
%   blk_size            - block size (DEFAULT 8)
%                           Class Support: positive integer > 1
%   noise_size          - amount of pixels to remove as noise
%                           Class Support: positive integer > 1
% Returns:
%   bw_final            - binary image where 0 is considered background
%                           based on texture 
%                           Class Support: HxW LOGICAL
%  background           - the background of the image 
%                           Class Support: HxW image 
%   per_rem             - percent of the image remaining (1 in bw_final)
%                           Class Support: DOUBLE 
%
% Dependencies: 
%   MATLAB Version >= 9.5 
%   Image Processing Toolbox Version 10.3
%   Functions:
%       computeImageGradient.m
%       hog.m
%
% Tessa Morris 
% Advisor: Anna Grosberg, Department of Biomedical Engineering 
% Cardiovascular Modeling Laboratory 
% University of California, Irvine 

function [bw_final,background, per_rem, thresh_per] = ...
    textureBasedMasking(I,sigma,blk_size,noise_size,...
    displayResults)

% If the user did not specify whether or not they'll display results, set
% it to false 
if nargin < 5 
    displayResults = false; 
end 

thresh_per = 0; 
% Convert intensity to be between 0 and 1
Igray = mat2gray(I); 

% Compute the gradient magnitude and orientation at each pixel.
[ mag, ori ] = computeImageGradient( Igray, sigma ); 

%Determine the size of the input image 
[h,w] = size(I); 

%Determine the size of the output. It will be the (rounded up) size of the
%image divided by the block size ( 8 x 8 )
h2 = ceil(h/blk_size); 
w2 = ceil(w/blk_size);

% Sum up the magnitude values over blk_sizexblk_size pixel blocks
magchblock = im2col(mag,[blk_size blk_size],'distinct');  

% Reshape summed magnitude to be size of compressed image                                    
magblock = reshape( sum(magchblock,1), [h2 w2] ); 

% Divide by the maximum magnitude 
magblocknorm = magblock/max(magblock(:)); 

% Entropy filter the normalized max magnitude
magentropy = entropyfilt(magblocknorm);

% Normalize the entropy filter
magentropynorm = magentropy/max(magentropy(:)); 

% Binarize the entropy filter 
bw_magentropy = imbinarize(magentropynorm); 

% Display the entropy results if requested. 
if displayResults
    figure; 
    imagesc(magentropynorm)
end 
% % Compute histogram of oriented graidents. 
% % sigma = 0.5; 
% % blk_size = 15; 
% [ohist,thresh_per] = hog( J, sigma , blk_size); 
% 
% % Calculate the average in each grid 
% ohist_avg = mean(ohist,3); 
% 
% % Initial binarization 
% bw_ohist = zeros(size(ohist_avg)); 
% bw_ohist(ohist_avg > 0) = 1; 

% Fill holes that are less than the noise size 
bw_fill = ~bwareaopen(~bw_magentropy, noise_size);

% Remove noise 
%noise_size = 1*8;
bw_nonoise = bwareaopen( bw_fill, noise_size );

% Dilate the binary image 
disk_sze = 1; 
se = strel('disk',disk_sze);
bw4 = imdilate(bw_nonoise, se); 


% % Display the figure if requested 
% if displayResults
%     figure; imshow(bw4); 
% end 

% Resize the binary image to be the size of the original image 
bw_final = imresize(bw4, size(I));
% Set all of the values greater than 0 equal to 1 
bw_final(bw_final > 0) = 1; 

% Calculate the percentage of the image that is positive in the binary
% image 
per_rem = sum(bw_final(:))/(size(I,1)*size(I,2)); 
per_rem = per_rem*100; 

% If the percent remaining is equal to 0, then use matlab binarization to
% create mask. 
if per_rem == 0 
    if exist('imbinarize.m','file') == 2 
        bw_final = imbinarize(I);
    else
        bw_final = im2bw(I, graythresh(I));
    end 
    
    % Compute the new percentage remaining 
    per_rem = sum(bw_final(:))/(size(I,1)*size(I,2)); 
    per_rem = per_rem*100; 
    % Set thresh_per equal to NaN, indicating this method was not used
    thresh_per = NaN;     
end 


% Get only the false parts of bw6
background = Igray; 
background(bw_final == 1) = 0; 
foreground = Igray; 
foreground(bw_final == 0) = 0; 
% If the user would like to display the results, display the background and
% the percent remaining in the background 
if displayResults
    % Display background
%     figure; imshow(background); 
%     figure; imshow(foreground); 
    figure; 
    multi = cat(3,foreground,background);
    montage(multi);
    % Display Percent remaining 
    disp_msg = strcat('Percent Image Remaining:', {' '}, ...
        num2str(round(per_rem,2)), '%'); 
    disp(disp_msg{1});
end 

end 