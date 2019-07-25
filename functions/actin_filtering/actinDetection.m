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


function [ orientim, gray_im, actin_background, actin_anisodiffuse] = ...
    actinDetection( filename, settings, disp_actin, save_path )

%Get the file parts (path, name of the file, and the extension)
[ path, file, ext ] = fileparts( filename );

%Save the image image identifying information 
%(1) filename 
actin_name = file; 
%(2) path
actin_path = path; 

% Load the image
[ im, map ] = imread( filename );

if nargin == 3 
    % Create a new folder in the image directory with the same name as the 
    % image file if it does not exist. If it does exist, add numbers until 
    % it no longer exists and then create it 
    create = true; 
    new_subfolder = ...
        addDirectory( actin_path, actin_name, create ); 

    % Save the name of the new path 
    save_path = fullfile(actin_path, new_subfolder); 
end 

%Create a grayscale version of the image (if it was not already in
%grayscale) 
[ gray_im ] = makeGray( im ); 


% Use texture based masking to remove the background of the image 
[actin_background, actin_im_background, actin_per_rem,...
    actin_back_thresh_per] = ...
    textureBasedMasking( gray_im, settings.back_sigma, ...
    settings.back_blksze, settings.back_noisesze,...
    settings.disp_back ); 

% Run diffusion filtering on actin image  
[ actin_anisodiffuse, ~, ~ ] = ...
    CoherenceFilter( gray_im, settings.Options );

% Clear the command line 
clc; 

% Convert the matrix to be an intensity image 
actin_anisodiffuse = mat2gray( actin_anisodiffuse );


% Calculate orientation vectors
[orientim, ~] = ridgeorient(actin_anisodiffuse, ...
    settings.Options.sigma, settings.Options.rho, settings.Options.rho);

% Set all of the orientation vectors considered background to be zero. 
orientim(actin_background == 0) = 0; 

% Save the diffusion filtered actin image if requested
if disp_actin
    
    imwrite( actin_anisodiffuse, fullfile(save_path, ...
        strcat( actin_name, '_ActinDiffusionFiltered.tif' ) ),...
        'Compression','none');
end 
    
end

