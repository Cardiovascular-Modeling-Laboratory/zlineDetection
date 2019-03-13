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


function [ orientim, reliability, grayIM ] = ...
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
[ grayIM ] = makeGray( im ); 

% Run Diffusion Filter:
% Coherence-Enhancing Anisotropic Diffusion Filtering, which enhances
% contrast and calculates the orientation vectors for later usage. 
% The parameters (supplied by the GUI) are (1) Orientation Smoothing and
% (2) Diffusion Time 
Options = settings.Options; 
% Inputs are the grayscale image and the Options struct from settings. 
% The output is the diffusion filtered image and eigenvectors - Not sure
% why this is important, but... 
[ CEDgray, ~, ~ ] = CoherenceFilter( grayIM, Options );


% 
% % Compute the actin orientation and reliability
% [ grayIM, CEDgray, CEDtophat, orientim, reliability ] = ...
%     orientInfo( im, settings.Options, settings.tophat_size);

% Only keep orientation values with a reliability greater than 0.5
reliability_binary = reliability > settings.reliability_thresh;

% Get the size of the image
[height, width] = size(grayIM); 

% Size of border to remove
br = 10; 

% Remove 10 pixel wide border (br) where orientation values are not accurate
reliability_binary(:,1:1:br) = 0;
reliability_binary(1:1:br,:) = 0;
reliability_binary(:,width-br:1:width) = 0;
reliability_binary(height-br:1:height,:) = 0;

% Multiply orientation angles by the binary mask image to remove
% data where there are no cells
orientim = orientim.*reliability_binary;

if disp_actin
    % Save the diffusion filtered actin image
    imwrite( CEDgray, fullfile(save_path, ...
        strcat( actin_name, '_ActinDiffusionFiltered.tif' ) ),...
        'Compression','none');

    % Save the top hat filtered image 
    imwrite( CEDtophat, fullfile(save_path, ...
        strcat( actin_name, '_ActinTopHatFiltered.tif' ) ),...
        'Compression','none');
end 
    
end

