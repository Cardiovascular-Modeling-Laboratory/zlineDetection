% ANALYZEIMAGE - Main function to create binary skeleton and compute
% orientation vectors of an image. It will load an image and convert it 
% to grayscale and then perform (1) coherence-enhancing anisotropic  
% diffusion filtering (2) top hat filetering (3) convert to binary using
% adaptive thresholding (3) skeletonize (4) prune automatically (5) prune
% manually. 
%
% Usage:
%  [ im_struct ] = storeImageInfo( filename );
%
% Arguments:
%       filename    - A string containing the path, filename, and extension
%                       of the image 
%       settings    - A structure array that contains the following
%                       information (from the GUI) 
% 
% Returns:
%       im_struct   - A structura array containing the following
%                       information
% 
% Tessa Morris
% Advisor: Anna Grosberg
% Cardiovascular Modeling Laboratory 
% University of California, Irvine 


function [ im_struct ] = analyzeImage( filename, settings )
%This function will be the "main" analyzing script for a series of
%functions 

%%%%%%%%%%%%%%%%%%%%%%%% Initalize Image Info %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Save the Options struct from settings 
Options = settings.Options;

% Store the image information
[ im_struct ] = storeImageInfo( filename );

%Create a grayscale version of the image (if it was not already in
%grayscale) 
[ im_struct.gray ] = makeGray( im_struct.img ); 

% Create a new folder in the image directory with the same name as the 
% image file 
mkdir(im_struct.im_path,im_struct.im_name); 

% Save the name of the new path 
save_path = strcat(im_struct.im_path, '/', im_struct.im_name); 

%%%%%%%%%%%%%%%%%%%%%%%% Run Coherence Filter %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Coherence-Enhancing Anisotropic Diffusion Filtering, which enhances
% contrast and calculates the orientation vectors for later usage. 
% The parameters (supplied by the GUI) are (1) Orientation Smoothing and
% (2) Diffusion Time 

% Start a wait bar 
hwait = waitbar(0,'Diffusion Filter...');

% Inputs are the grayscale image and the Options struct from settings. 
% The output is the diffusion filtered image and eigenvectors - Not sure
% why this is important, but... 
[ im_struct.CEDgray, im_struct.v1x, im_struct.v1y ] = ...
    CoherenceFilter( im_struct.gray, settings.Options );

% Convert the matrix to be an intensity image 
im_struct.CEDgray = mat2gray( im_struct.CEDgray );

% If the user would like to display the filtered image, display it
if settings.disp_df
    % Open a figure and display the image
    figure; imshow( im_struct.CEDgray );
    
    % Save the figure. 
    imwrite( im_struct.CEDgray, fullfile(save_path, ...
        strcat( im_struct.im_name, '_DiffusionFiltered.tif' ) ),...
        'Compression','none');

end

%%%%%%%%%%%%%%%%%%%%%%%%% Run Top Hat Filter %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Update waitbar 
waitbar(0.5,hwait,'Top Hat Filter...');

%Compute the top hat filter using the disk structuring element with the
%threshold defined by the user input tophat filter. It then adjusts the
%image so that 1% of data is saturated at low and high intensities of the
%image 
im_struct.CEDtophat = ...
    imadjust( imtophat( im_struct.CEDgray, ...
    strel( 'disk', settings.tophat_size ) ) );

% If the user would like to display the filtered image, display it
if settings.disp_tophat
    % Open a figure and display the image
    figure; imshow( im_struct.CEDtophat ); 
    
    % Save the figure. 
    imwrite( im_struct.CEDtophat, fullfile(save_path, ...
        strcat( im_struct.im_name, '_TopHatFiltered.tif' ) ),...
        'Compression','none');
    
end

%%%%%%%%%%%%%%%%%%%%%%%%% Threshold and Clean %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
% Update waitbar 
waitbar(0.7,hwait,'Threshold and Clean...');

% Use adaptive thresholding to convert to black and white.  
[ im_struct.CEDbw, im_struct.surface_thresh ] = ...
    segmentImage( im_struct.CEDtophat ); 

% If the user would like to display the filtered image, display it
if settings.disp_bw
    % Open a figure and display the image 
    figure; imshow( im_struct.CEDbw )
    
    % Save the figure. 
    imwrite( im_struct.CEDbw, fullfile(save_path, ...
        strcat( im_struct.im_name, '_Binariazed.tif' ) ),...
        'Compression','none');
    
end

% Remove small objects from binary image.
im_struct.CEDclean = bwareaopen( im_struct.CEDbw, settings.noise_area );

% If the user would like to display the filtered image, display it
if settings.disp_nonoise
    % Open a figure and display the image 
    figure; imshow(im_struct.CEDclean)
    
    % Save the figure. 
    imwrite( im_struct.CEDclean, fullfile(save_path, ...
        strcat( im_struct.im_name, '_BinariazedClean.tif' ) ),...
        'Compression','none');
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Skeletonize %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Update waitbar 
waitbar(0.8,hwait,'Skeletonization...');

% Use Matlab skeletonization morphological function 
im_struct.skel = bwmorph( im_struct.CEDclean, 'skel', Inf );

% Clean up the skeleton 
im_struct.skelTrim = cleanSkel( im_struct.skel, settings.branch_size );


if settings.disp_skel
    % Open a figure and display the image 
    figure; imshow( im_struct.skel ); 
    
    % Save the figure. 
    imwrite( im_struct.skel, fullfile(save_path, ...
        strcat( im_struct.im_name, '_Skeleton.tif' ) ),...
        'Compression','none');
    
    % Open a figure and display the trimmed image 
    figure; imshow(im_struct.skelTrim)

    % Save the figure. 
    imwrite( im_struct.skelTrim, fullfile(save_path, ...
        strcat( im_struct.im_name, '_SkeletonTrimmed.tif' ) ),...
        'Compression','none');
    
end

% Comment out mask creation phase for now - just want to test parameter
% choices
im_struct.skel_final = im_struct.skelTrim; 

% %%%%%%%%%%%%%%%%%%%%%% Remove false z-lines %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create a mask to remove false z-lines 
% This function will be used to seelct regions of the image that should be
% included in analysis 
% If include is true then the mask will only include the selected regions 
% If include is false, the mask will exclude the selected regions 
im_struct.mask  = select_ROI( mat2gray(im_struct.img) , im_struct.skelTrim, 0 );
% im_struct.mask = select_ROI( im_struct.skelTrim, 0 ); 

% Save the mask. 
imwrite( im_struct.mask, fullfile(save_path, ...
    strcat( im_struct.im_name, '_Mask.tif' ) ),...
    'Compression','none');
    
% Create final skeleton 
im_struct.skel_final = im_struct.mask .* im_struct.skelTrim; 

% Save the final skeleton. 
imwrite( im_struct.skel_final, fullfile(save_path, ...
    strcat( im_struct.im_name, '_SkeletonMasked.tif' ) ),...
    'Compression','none');

%%%%%%%%%%%%%%%%%%%%%%% Generate Angles Map %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Update waitbar 
waitbar(0.9,hwait,'Recovering Orientations...');

% Change the
Options.T = 1;

% Compute the orientation vectors at each position  
[~, im_struct.v1xn, im_struct.v1yn] = ...
    CoherenceFilter(im_struct.skel_final,Options);

% Generate Angle Map by getting new angles from CED
im_struct.AngMap = atand(im_struct.v1xn./-im_struct.v1yn);

% Remove angles that are 0 in the binary skeleton
im_struct.AngMap(~im_struct.skel_final) = NaN;
im_struct.AngMap(im_struct.AngMap<0) = ... 
    im_struct.AngMap(im_struct.AngMap<0)+180;


% Close the wait bar
close(hwait)

% Display that you're saving the data
disp('Saving Data...'); 

% Convert the orientation vectors from degrees to radians. 

% Save the data 
save(fullfile(save_path, strcat(im_struct.im_name,...
    '_OrientationAnalysis.mat')), 'im_struct', 'settings');

end

