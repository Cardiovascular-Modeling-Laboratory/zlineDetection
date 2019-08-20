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


function [ orientim, gray_im, actin_background, actin_smoothed, ...
    actin_normalized] = ...
    actinDetection( filename, settings, disp_actin, save_path )

% Convert 2 micron sarcomere spacing into pixels
SarcSpacing = 2*settings.pix2um;
% Maximum length of sarcomere spacing
MaxSarcSpacing = round(1.5*SarcSpacing); 

%Get the file parts (path, name of the file, and the extension)
[ path, file, ext ] = fileparts( filename );

%Save the image image identifying information 
%(1) filename 
actin_name = file; 
%(2) path
actin_path = path; 

% Load the image
[ im, ~ ] = imread( filename );

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

% If the user wants to smooth the actin image first before computing the
% image gradients, do so 
if settings.actin_sigma > 0 
    gray_im = mat2gray(gray_im); 
    if settings.actin_kernelsize > 0
        if mod(settings.actin_kernelsize,2) == 0
            settings.actin_kernelsize = settings.actin_kernelsize - 1;
        end 
        actin_smoothed = imgaussfilt(gray_im, settings.actin_sigma, ...
            'FilterSize',settings.actin_kernelsize);
    else
        actin_smoothed = imgaussfilt(gray_im, settings.actin_sigma); 
    end 
else
    actin_smoothed = mat2gray(gray_im); 
end

% Identify ridge-like regions and normalise image
[actin_normalized, mask] = ridgesegment(actin_smoothed, MaxSarcSpacing, ...
    settings.actin_backthresh);

% Calculate orientation vectors
[orientim, reliability] = ridgeorient( actin_normalized, ...
    settings.actin_gradientsigma, settings.actin_blocksigma, ...
    settings.actin_orientsmoothsigma );

% Only keep orientation values with a reliability greater than 0.5
reliability_binary = reliability > settings.actin_reliablethresh;

% Multiply orientation angles by the binary mask image to remove
% data where there are no cells
actin_background = mask.*reliability_binary;

% Remove all orientation vectors in the background 
orientim = orientim.*actin_background;

% Save the diffusion filtered actin image if requested
if disp_actin
    
    imwrite( actin_smoothed, fullfile(save_path, ...
        strcat( actin_name, '_ActinGaussianFiltered.tif' ) ),...
        'Compression','none');
end 
    
end

