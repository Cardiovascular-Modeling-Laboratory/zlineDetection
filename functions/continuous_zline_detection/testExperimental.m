% This script is for testing purposes. 
% It contains code to analyze a specific section of a previously analyzed 
% image (requiring orientation vectors and binary skeletons). 
% It also contains synthetic data to test the code. 


%% Load an orientation anlsysis file 

% Prompt the user to select the images they would like to analyze. 
[ orient_file, orient_path, ~ ] = ...
    load_files( {'*OrientationAnalysis.mat'}, ...
    'Select Orientation Analysis .mat file ...', pwd,'off');

% Load the orientation data 
orient_data = load(fullfile(orient_path{1}, orient_file{1})); 
im_struct = orient_data.im_struct; 
    
    
%% TEST REGION OF A SPECIFIC ANALYZED IMAGE 
% Display the image 
figure; imshow(mat2gray(im_struct.im)); 

% Select a section using the following command 
r = round(getrect()); 

% Get only the orientation vectors in the selected section. 
sec_orientim = im_struct.orientim(r(2):r(2)+r(4), r(1):r(1)+r(3)); 
orientim = sec_orientim; 
orientim(isnan(orientim)) = 0;
angles = orientim; 

% Get the binary skeleton in the region 
sec_skel_final = ...
    im_struct.skel_final_trimmed(r(2):r(2)+r(4), r(1):r(1)+r(3));
positions = sec_skel_final; 

% Get the image in that region 
BW0 = mat2gray(im_struct.im); 
BW = BW0(r(2):r(2)+r(4), r(1):r(1)+r(3));

%% 