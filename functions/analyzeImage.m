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


function [ im_struct ] = analyzeImage( filenames, settings )
%This function will be the "main" analyzing script for a series of
%functions 

%%%%%%%%%%%%%%%%%%%%%%%% Initalize Image Info %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Save the Options struct from settings 
Options = settings.Options;

% Store the image information
[ im_struct ] = storeImageInfo( filenames.zline );

% Create a new folder in the image directory with the same name as the 
% image file if it does not exist. If it does exist, add numbers until it
% no longer exists and then create it 
create = true; 
new_subfolder = ...
    addDirectory( im_struct.im_path, im_struct.im_name, create ); 

% Save the name of the new path 
im_struct.save_path = fullfile(im_struct.im_path, new_subfolder); 

%%%%%%%%%%%%%%%%% Compute Orientation Information %%%%%%%%%%%%%%%%%%%%%%%%%
% Update waitbar 
disp('Filtering and computing orientation information...');

% Fitler the image using coherence-enhancing anisotropic diffusion 
% filtering and top hat filtering, then compute the orientation vectors 
[ im_struct.gray, im_struct.CEDgray, im_struct.CEDtophat, ...
    im_struct.orientim, im_struct.reliability ] = ...
    orientInfo( im_struct.img, settings.Options, settings.tophat_size); 

% If the user would like to display the diffusion filtered image, display 
% it
if settings.disp_df
    % Open a figure and display the image
    figure; imshow( im_struct.CEDgray );
    
    % Save the figure. 
    imwrite( im_struct.CEDgray, fullfile(save_path, ...
        strcat( im_struct.im_name, '_DiffusionFiltered.tif' ) ),...
        'Compression','none');

end

% If the user would like to display the top hat filtered image, display it
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
disp('Threshold and Clean...');

% Use adaptive thresholding to convert to black and white.  
[ im_struct.CEDbw, im_struct.surface_thresh ] = ...
    segmentImage( im_struct.CEDtophat ); 

% Remove regions that are not reliable (less than 0.5)
im_struct.CEDbw( im_struct.reliability < settings.reliability_thresh) = 0; 

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
disp('Skeletonization...');

% Use Matlab skeletonization morphological function, convert to a skeleton,
% fill inside spaces and then conver to a skeleton again.
im_struct.skel = bwmorph( im_struct.CEDclean, 'skel', Inf );
im_struct.skel = bwmorph( im_struct.skel, 'fill' );
im_struct.skel = bwmorph( im_struct.skel, 'skel', Inf );

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

%%%%%%%%%%%%%%%%%%%%%% Remove false z-lines %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% If the image should not be filtered with actin, set the final mask equal
% to the trimmed skeleton and save 

if ~settings.actin_filt
    % Set the final skeleton equal to the trimmed skeleton
    im_struct.skel_final = im_struct.skelTrim; 
    
    % Create a mask of all ones for now.
    im_struct.mask = ones(size(im_struct.skelTrim)); 
    
else
    disp('Actin Filtering...'); 
    [ im_struct.mask, im_struct.actin_struct ] = ...
    filterWithActin( im_struct, filenames, settings, save_path); 

%     % Compute the orientation vectors for actin
%     [ im_struct.actin_orientim, im_struct.actin_reliability, ...
%         im_struct.actin_im ] = ...
%         actinDetection( filenames.actin, settings, save_path ); 
%     
    
    % % Save the actin analysis image name 
    % actinAnalysis_imagename = ...
    %     strrep(im_struct.im_name, '_w1mCherry', '_zlineActinDirector.mat'); 
    % 
    % % Load the actin analysis file 
    % actin_analysis = ...
    %     load(fullfile(im_struct.im_path,actinAnalysis_imagename)); 
    % 
    % % Create a threshold 
    % thresh = 0.5; 
    % 
    % % Filter with actin and save final skeleton 
    % [ im_struct.mask, im_struct.skel_final, actin_filtering] = ...
    %     filterWithActin( actin_analysis.director, ...
    %     actin_analysis.dims, im_struct.orientim, thresh); 
    % 
    % % Remove regions that were not part of the binary skeleton
    % im_struct.orientim(~im_struct.skel_final) = NaN; 
    % 
    % % Save the actin analysis struct 
    % im_struct.actin_filtering = actin_filtering; 

end 

% Save the mask. 
imwrite( im_struct.mask, fullfile(save_path, ...
    strcat( im_struct.im_name, '_Mask.tif' ) ),...
    'Compression','none');

% Save the final skeleton. 
imwrite( im_struct.skel_final, fullfile(save_path, ...
    strcat( im_struct.im_name, '_SkeletonMasked.tif' ) ),...
    'Compression','none');

%%%%%%%%%%%%%%%%% Report Final Orentation Vectors %%%%%%%%%%%%%%%%%%%%%%%%%

% Remove regions that were not part of the binary skeleton
im_struct.orientim(~im_struct.skel_final) = NaN; 

% Display that you're saving the data
disp('Saving Data...'); 

% Save the data 
save(fullfile(save_path, strcat(im_struct.im_name,...
    '_OrientationAnalysis.mat')), 'im_struct', 'settings');

% Clear command line 
clc; 
end

