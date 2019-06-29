% CLUSTERIMAGES - function that will filter zline and actin images and
% then use k-means clustering to label the image.
%  
%
% Usage:
%  [ CMcluster, actincluster ] = clusterImages( actin_im, zline_im )
%
% Arguments:
%       actin_im        - grayscale image with actin stain 
%       zline_im        - grayscale image with alpha-actinin stain
%       displayResults  - optional argument to display the results 
   
% 
% Returns:
%       CMcluster       - 3 cluster labels which ideally are CM, nonCM, and
%                           background 
%       actincluster    - 2 cluster labels which ideally are actin and
%                           background 
% 
% Adapted from MATLAB's "Texture Segmentation Using Gabor Filters"
% Documentation 
% 
% Tessa Morris
% Advisor: Anna Grosberg
% Cardiovascular Modeling Laboratory 
% University of California, Irvine 

function [ IMcluster, IMcenters, feature_set ] = ...
    clusterImages( im, nclusters, wavelength, orientation, displayResults)

if nargin < 5 
    displayResults = false; 
end 


% Make sure that this version of matlab contains the k-means clustering
% function 
if exist('imsegkmeans.m','file') == 2 
    
%     % Declare a range of wavelengths and orientations for the gabor filter 
%     % wavelength describes the wavelength of the sinusoidal carrier in the 
%     % range [2, Inf). 
%     % orinetation is the orientation of the filter, normal direction to teh
%     % sinusoidal plane wave in the range [0,360]. 
%     wavelength = 2.^(1:3) * 3; 
%     orientation = 0:45:135;
    % Create the gabor filters 
    g = gabor(wavelength,orientation);
    
    % Gabor filter both the actin and z-line images  
    gabormag_im = imgaborfilt(im,g);
    
    % Display the gabor filter results if requested 
    if displayResults
        figure; 
        montage(gabormag_im,'Size',...
            [length(orientation) length(wavelength)])
    end 
    
    % Smooth each filtered image to remove local variations. Sigma is 
    % defined by 3/2 the wavelength 
    for k = 1:length(g)
        sigma = 0.5*g(k).Wavelength;
        gabormag_im(:,:,k) = imgaussfilt(gabormag_im(:,:,k),3*sigma); 
    end

    disp(size(gabormag_im)); 
    % Display the smoothed images in a montage if requested 
    if displayResults
        figure; 
        montage(gabormag_im,'Size',...
            [length(orientation) length(wavelength)])
    end 
    disp(size(gabormag_im));
    % Create a mesh grid of the image  
    [X,Y] = meshgrid(1:size(im,2),1:size(im,1));
    
    % Concatinate all of the image features (gabor filtered and unmodified
    % intensity)
    feature_set = cat(3,single(im),gabormag_im,X,Y);
    disp(size(single(im)));
    disp(size(X));
    disp(size(Y)); 
    % Convert featureset to be between 0 and 1 with singel precision
    feature_set = single(mat2gray(feature_set)); 
    
    disp(size(feature_set)); 
    % Use k-means to create nclusters from the image and its gabor filtered
    [IMcluster, IMcenters] = ...
        imsegkmeans(feature_set, nclusters,'NormalizeInput',true);    
    
    % Display the clusters if requested 
    if displayResults
        IM_labels = labeloverlay(im, IMcluster);
        figure; imshow(IM_labels)
    end 
    
else
    disp('Your version of Matlab does not contain the functions needeed.'); 
    % Set results to NaN 
    IMcluster = NaN; 
    feature_set = NaN; 
end 

end

