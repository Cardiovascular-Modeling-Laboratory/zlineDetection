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
% Update user 
disp('Filtering and computing orientation information...');

% Fitler the image using coherence-enhancing anisotropic diffusion 
% filtering and top hat filtering, then compute the orientation vectors 
[ im_struct.im_gray, im_struct.im_anisodiffuse, im_struct.im_tophat, ...
    im_struct.orientim, im_struct.reliability ] = ...
    orientInfo( im_struct.im, settings.Options, settings.tophat_size); 

% If the user would like to display the diffusion filtered image, display 
% it
if settings.disp_df
    % Open a figure and display the image
    figure; imshow( im_struct.im_anisodiffuse );
    
    % Save the figure. 
    imwrite( im_struct.im_anisodiffuse, fullfile(im_struct.save_path, ...
        strcat( im_struct.im_name, '_DiffusionFiltered.tif' ) ),...
        'Compression','none');

end

% If the user would like to display the top hat filtered image, display it
if settings.disp_tophat
    % Open a figure and display the image
    figure; imshow( im_struct.im_tophat ); 
    
    % Save the figure. 
    imwrite( im_struct.im_tophat, fullfile(im_struct.save_path, ...
        strcat( im_struct.im_name, '_TopHatFiltered.tif' ) ),...
        'Compression','none');
    
end

%%%%%%%%%%%%%%%%%%%%%%%%% Threshold and Clean %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
% Update user
disp('Threshold and Clean...');

% Use adaptive thresholding to convert to binary image
[ im_struct.im_binary, im_struct.surface_thresh ] = ...
    segmentImage( im_struct.im_tophat ); 

% Remove regions that are not reliable (less than 0.5)
im_struct.im_binary( im_struct.reliability < settings.reliability_thresh) = 0; 

% If the user would like to display the binarized image, display it
if settings.disp_bw
    % Open a figure and display the image 
    figure; imshow( im_struct.im_binary )
    
    % Save the figure. 
    imwrite( im_struct.im_binary, fullfile(im_struct.save_path, ...
        strcat( im_struct.im_name, '_Binariazed.tif' ) ),...
        'Compression','none');
    
end

% Remove small objects from binary image.
im_struct.im_binaryclean = bwareaopen( im_struct.im_binary, settings.noise_area );

% If the user would like to display the noise removed binary image, display it
if settings.disp_nonoise
    % Open a figure and display the image 
    figure; imshow(im_struct.im_binaryclean)
    
    % Save the figure. 
    imwrite( im_struct.im_binaryclean, fullfile(im_struct.save_path, ...
        strcat( im_struct.im_name, '_BinariazedClean.tif' ) ),...
        'Compression','none');
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Skeletonize %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Update user 
disp('Skeletonization...');

% Use Matlab skeletonization morphological function, convert to a skeleton,
% fill inside spaces and then conver to a skeleton again.
im_struct.skel_initial = bwmorph( im_struct.im_binaryclean, 'skel', Inf );
im_struct.skel_initial = bwmorph( im_struct.skel, 'fill' );
im_struct.skel_initial = bwmorph( im_struct.skel, 'skel', Inf );

%Binarize the filtered image and remove positions that are not positive in
%the skeleton. 
mask = imbinarize(im_struct.im_gray);
im_struct.skel = im_strct.skel_initial; 
im_struct.skel(~mask) = 0; 


if settings.disp_skel
    % Open a figure and display the image 
    figure; imshow( im_struct.skel ); 
    
    % Save the figure. 
    imwrite( im_struct.skel, fullfile(im_struct.save_path, ...
        strcat( im_struct.im_name, '_SkeletonInitial.tif' ) ),...
        'Compression','none');
    
end

%%%%%%%%%%%%%%%%%%%%%% Remove false z-lines %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% If the image should not be filtered with actin, set the final mask equal
% to the trimmed skeleton and save 


if ~settings.actin_filt
    % Save the mask 
    im_struct.mask = mask; 
    
    % Clean up the skeleton 
    im_struct.skel_trim = cleanSkel( im_struct.skel, settings.branch_size );

    % Set the final skeleton equal to the trimmed skeleton
    im_struct.skel_final = im_struct.skel_trim; 
    

    
else
    % Remove false z-lines by looking at the actin directors
    [ im_struct.mask, im_struct.actin_struct, im_struct.dp ] = ...
    filterWithActin( im_struct, filenames, settings); 

    % Multiply the mask by the trimmed skeleton to get the final skeleton
    im_struct.skel_trim = im_struct.mask.*im_struct.skel;
    im_struct.skel_final = cleanSkel( im_struct.skel_trim, ...
        settings.branch_size );
    im_struct.skel_trim = im_struct.skel_final; 
end 


% Save the mask. 
imwrite( im_struct.mask, fullfile(im_struct.save_path, ...
    strcat( im_struct.im_name, '_Mask.tif' ) ),...
    'Compression','none');

% Save the final skeleton. 
imwrite( im_struct.skel_final, fullfile(im_struct.save_path, ...
    strcat( im_struct.im_name, '_SkeletonMasked.tif' ) ),...
    'Compression','none');

%%%%%%%%%%%%%%%%% Report Final Orentation Vectors %%%%%%%%%%%%%%%%%%%%%%%%%

% Save the unfiltered orienation angles 
im_struct.noskel_orientim = im_struct.orientim; 
im_struct.noactinfilt_orientim = im_struct.noskel_orientim; 
im_struct.noactinfilt_orientim(~im_struct.skel_trim) = NaN; 

% Remove regions that were not part of the binary skeleton
im_struct.orientim(~im_struct.skel_final) = NaN; 

% Post filtering skeleton 
post_filt = im_struct.skel_final;
post_filt = post_filt(:);
post_filt(post_filt == 0) = []; 
% Pre filtering skeleton 
pre_filt = im_struct.skel_trim; 
pre_filt = pre_filt(:); 
pre_filt(pre_filt == 0) = []; 
% Calculate the non-sarcomeric alpha actinin 
% number of pixles eliminated / # total # of pixles positive for alpha
% actinin 
im_struct.nonzlinefrac = (length(pre_filt) - length(post_filt))/ length(pre_filt);
im_struct.zlinefrac = 1 - im_struct.nonzlinefrac; 

% Display that you're saving the data
disp('Saving Data...'); 

% Save the data 
save(fullfile(im_struct.save_path, strcat(im_struct.im_name,...
    '_OrientationAnalysis.mat')), 'im_struct', 'settings');

% Clear command line 
clc; 
end
