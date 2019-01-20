% ACTINDETECTION - automaticly detect actin alignment in cardiomyocytes
% stained with phalloidin by filtering and calculation oreintation vectors
%
% Arguments:
%             Images of phaloidin stained actin captured from the
%               same cover slip under the same exact aquisition conditions,
%               file should TIF format grayscale at least 8-bit depth
%
% Returns:    Binary skeleton images of restored sarcomeres for each image
%
%             Binary skeleton images of restored actin after ROI based
%               removal of non-sarcomeres for each image
%
%             *.actinOrientation.mat file containing actin alignment
% Adapted from:
% Peter Kovesi
% School of Computer Science & Software Engineering
% The University of Western Australia
% pk at csse uwa edu au
% http://www.csse.uwa.edu.au/~pk
% January 2005
%
% and Adam W. Feinberg
% Disease Biophysics Group
% School of Engineering and Applied Sciences
% Havard University, Cambridge, MA 02138

% Last updated Sept 25, 2018 by Tessa Morris
% Last updated May 20, 2014 by Anna Grosberg
% The Edwards Lifesciences Center for Advanced Cardiovascular Technology
% 2418 Engineering Hall
% University of California, Irvine
% Irvine, CA  92697-2700


function [ output_args ] = actinDetection( filenames, settings )

% Save the Options struct from settings 
Options = settings.Options;

% Store the image information
[ im_struct ] = storeImageInfo( filenames.actin );

%Create a grayscale version of the image (if it was not already in
%grayscale) 
[ im_struct.gray ] = makeGray( im_struct.img ); 

% Create a new folder in the image directory with the same name as the 
% image file if it does not exist. If it does exist, add numbers until it
% no longer exists and then create it 
create = true; 
new_subfolder = ...
    addDirectory( im_struct.im_path, im_struct.im_name, create ); 

% Save the name of the new path 
im_struct.save_path = fullfile(im_struct.im_path, new_subfolder); 

%%%%%%%%%%%%%%%%%%%%%%%% Run Coherence Filter %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Coherence-Enhancing Anisotropic Diffusion Filtering, which enhances
% contrast and calculates the orientation vectors for later usage. 
% The parameters (supplied by the GUI) are (1) Orientation Smoothing and
% (2) Diffusion Time 

% Start a wait bar 
disp('Diffusion Filter...');

% Inputs are the grayscale image and the Options struct from settings. 
% The output is the diffusion filtered image and eigenvectors - Not sure
% why this is important, but... 
[ im_struct.CEDgray, im_struct.v1x, im_struct.v1y ] = ...
    CoherenceFilter( im_struct.gray, settings.Options );

% Clear the command line 
clc; 

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
disp('Top Hat Filter...');

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

%%%%%%%%%%%%%%%%%% Calculate Orientation Vectors %%%%%%%%%%%%%%%%%%%%%%%%%%

% Calculate orientation vectors
[im_struct.orientim, im_struct.reliability] = ...
    ridgeorient(im_struct.CEDtophat, ...
    Options.sigma, Options.rho, Options.rho);

%%%%%%%%%%%%%%%%%%%%%%%%% Threshold and Clean %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
% Update waitbar 
disp('Threshold and Clean...');

% Use adaptive thresholding to convert to black and white.  
[ im_struct.CEDbw, im_struct.surface_thresh ] = ...
    segmentImage( im_struct.CEDtophat ); 

% Remove regions that are not reliable (less than 0.5)
im_struct.CEDbw( im_struct.reliability < settings.reliability_thresh) = 0; 

end

