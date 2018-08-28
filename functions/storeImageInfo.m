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
%(3) path + filename 
im_struct.imNamePath = strcat(path, file); 


%Load the image
[ img, map ] = imread( filename );

%Store the indexed image (img) 
im_struct.img = img; 

%Store the indexed image's associated colormap (c_map) 
im_struct.c_map = map;

end 