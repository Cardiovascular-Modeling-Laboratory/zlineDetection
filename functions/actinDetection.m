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


function [ orientim, reliability ] = actinDetection( filenames, settings )

% Store the image information
[ im_struct ] = storeImageInfo( filenames.actin );

% Create a new folder in the image directory with the same name as the 
% image file if it does not exist. If it does exist, add numbers until it
% no longer exists and then create it 
create = true; 
new_subfolder = ...
    addDirectory( im_struct.im_path, im_struct.im_name, create ); 

% Save the name of the new path 
im_struct.save_path = fullfile(im_struct.im_path, new_subfolder); 

% Compute the actin orientation and reliability
[ grayIM, ~, ~, orientim, reliability ] = ...
    orientInfo( im_struct.img, im_struct.im_name, ...
    im_struct.save_path, settings);

% Only keep orientation values with a reliability greater than 0.5
reliability_binary = reliability > settings.reliability_thresh;

% Get the size of the image
[d1, d2] = size(grayIM); 

% Size of border to remove
br = 10; 

% Remove 10 pixel wide border (br) where orientation values are not accurate
reliability_binary(:,1:1:br) = 0;
reliability_binary(1:1:br,:) = 0;
reliability_binary(:,d2-br:1:d2) = 0;
reliability_binary(d1-br:1:d1,:) = 0;

% Multiply orientation angles by the binary mask image to remove
% data where there are no cells
orientim = orientim.*reliability_binary;
    
end

