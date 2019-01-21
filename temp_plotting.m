%Load z-line images 
[ zline_images, zline_path, zn ] = ...
    load_files( {'*w1mCherry*.TIF';'*w1mCherry*.tif';'*.*'}, ...
    'Select images stained for z-lines...'); 

%Load actin images 
[ actin_images, actin_path, an ] = ...
    load_files( {'*GFP*.TIF';'*GFP*.tif';'*.*'}, ...
    'Select images stained for actin...');

% Add directories that contain code 
addpath('functions');
addpath('functions/coherencefilter_version5b');
addpath('functions/continuous_zline_detection');
addpath('functions/actin_filtering');

% Sort the z-line and actin files. Ideally this means that they'll be
% called in the correct order. 
zline_images = sort(zline_images); 
actin_images = sort(actin_images); 


if an == zn
    for k = 1:zn 
        %Get the z-line and actinimage name
        [zname, ~ ] = fileparts( zline_images{1,k} );
        [aname, ~ ] = fileparts( actin_images{1,k} ); 
        
        %Get the actin exploration files
        path = fullfile(zline_path{1}, zname);
        o
        
        
    end 
else
    disp('Number of files are not equal'); 
end


% %Get the file parts (path, name of the file, and the extension)
% [ path, file, ext ] = fileparts( filename );
% 
% %Initialize a structure 
% im_struct = struct();
% 
% %Save the image image identifying information 
% %(1) path + filename + extension 
% im_struct.im_location = filename; 
% %(2) filename 
% im_struct.im_name = file; 
% %(3) path
% im_struct.im_path = path; 
% 
% %Load the image
% [ img, map ] = imread( filename );
% 
% %Store the indexed image (img) 
% im_struct.img = img; 
% 
% %Store the indexed image's associated colormap (c_map) 
% im_struct.c_map = map;
