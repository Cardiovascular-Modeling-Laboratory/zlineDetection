% ANALYZEIMAGE - Main function to create binary skeleton and compute
% orientation vectors of an image 
%
% This function will do the following processes: 
%   - Load an image and convert it to grayscale
%   - Perform coherence-enhancing anisotropic diffusion filtering
%
%
% Usage:
%  [ im_struct ] = storeImageInfo( filename );
%
% Arguments:
%       filename    - A string containing the path, filename, and extension
%                       of the image 
% 
% Returns:
%       im_struct   - A structure array that contains the following
%                       information: 
%                       im_location - path to image file
%                       im_name     - name of the image file
%                       imNamePath  - path of the image file and the name
%                                       of the image file 
%                       img         - indexed image 
%                       c_map       - indexed image's associated colormap
% 
% Suggested parameters: None
% 
% See also: ANALYZEIMAGE

function [ im_struct ] = analyzeImage( filename, settings )
%This function will be the "main" analyzing script for a series of
%functions 

%%%%%%%%%%%%%%%%%%%%%%%% Initalize Image Info %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Save the Options struct from settings 
Options = settings.Options;

% Store the image information
[ im_struct ] = storeImageInfo( filename );

% % Filter the image 
% im_struct = filterImage( im_struct, settings ); 

%Create a grayscale version of the image (if it was not already in
%grayscale) 
[ im_struct.gray ] = makeGray( im_struct.img ); 


%%%%%%%%%%%%%%%%%%%%%%%% Run Coherence Filter %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Coherence-Enhancing Anisotropic Diffusion Filtering, which enhances
% contrast and calculates the orientation vectors for later usage. 
% The parameters (supplied by the GUI) are (1) Orientation Smoothing and
% (2) Diffusion Time 

% Start a wait bar 
hwait = waitbar(0,'Diffusion Filter...');

% Inputs are the grayscale image and the Options struct from settings. 
% The output is the diffusion filtered image and the gradient in each 
% direction (?)  
[ im_struct.CEDgray, im_struct.v1x, im_struct.v1y ] = ...
    CoherenceFilter( im_struct.gray, Options );

% Conver the matrix to be an intensity image 
im_struct.CEDgray = mat2gray( im_struct.CEDgray );

% If the user would like to display the filtered image, display it
if settings.CEDFig
    figure; imshow( im_struct.CEDgray )
end

%%%%%%%%%%%%%%%%%%%%%%%%% Run Top Hat Filter %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Update waitbar 
waitbar(0.5,hwait,'Top Hat Filter...');

%Compute the top hat filter using the disk structuring element with the
%threshold defined by the user input tophat filter 
im_struct.CEDtophat = ...
    imadjust( imtophat( im_struct.CEDgray, ...
    strel( 'disk', settings.thpix ) ) );

% If the user would like to display the filtered image, display it
if settings.topHatFig
    figure; imshow( im_struct.CEDtophat ); 
end

%%%%%%%%%%%%%%%%%%%%%%%%% Threshold and Clean %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
% Update waitbar 
waitbar(0.7,hwait,'Threshold and Clean...');

% Use adaptive thresholding - deleted this function so need to make sure
% that the new version - segmentImage does the same thing. 
im_struct.CEDbw = segmentImage( im_struct.CEDtophat );

% If the user would like to display the filtered image, display it
if settings.threshFig
    figure; imshow( im_struct.CEDbw )
end

% Remove small objects from binary image.
im_struct.CEDclean = bwareaopen( im_struct.CEDbw, settings.noisepix );

% If the user would like to display the filtered image, display it
if settings.noiseRemFig
    figure; imshow(im_struct.CEDclean)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Skeletonize %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Update waitbar 
waitbar(0.8,hwait,'Skeletonization...');

% Use Matlab skeletonization morphological function 
im_struct.skel = bwmorph( im_struct.CEDclean, 'skel', Inf );

if settings.skelFig
    figure; imshow( im_struct.skel ); 
end

%Clean up the skeleton 
im_struct.skelTrim = cleanSkel( im_struct.skel, settings.maxBranchSize );

% If the user would like to display the filtered image, display it
if settings.skelTrimFig
    figure; imshow(im_struct.skelTrim)
end

%%%%%%%%%%%%%%%%%%%%%% Remove false z-lines %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create a mask to remove false z-lines 

% Save the mask under the image struct 

%%%%%%%%%%%%%%%%%%%%%%% Generate Angles Map %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Update waitbar 
waitbar(0.9,hwait,'Recovering Orientations...');

% Change the
Options.T = 1;

% Compute the orientation vectors at each position  
[~, im_struct.v1xn, im_struct.v1yn] = ...
    CoherenceFilter(im_struct.skelTrim,Options);

% Generate Angle Map by getting new angles from CED
im_struct.AngMap = atand(im_struct.v1xn./-im_struct.v1yn);

close(hwait)

% Post process the orientation vectors so that they're in radians and also
% between 0 and pi 

end

