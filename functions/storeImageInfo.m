% STOREIMAGEINFO - Saves image and identifying information into a structure 
% array. 
%
% Function to load and save an image when supplied a filename
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
function [ im_struct ] = storeImageInfo( filename )

%Get the file parts (path, name of the file, and the extension)
[ path, file, ext ] = fileparts( filename );

%Initialize a structure 
im_struct = struct();

%Save the image image identifying information 
%(1) path + filename + extension 
im_struct.im_location = filename; 
%(2) filename 
im_struct.im_name = file; 
%(3) path
im_struct.im_path = path; 

%Load the image
[ img, map ] = imread( filename );

%Store the indexed image (img) 
im_struct.img = img; 

%Store the indexed image's associated colormap (c_map) 
im_struct.c_map = map;

end 