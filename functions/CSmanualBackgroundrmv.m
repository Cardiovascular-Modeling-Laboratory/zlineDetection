% This function will be used to eliminate portions of the background that
% should be eliminated from analysis 

%% Select coverslip summary file
% Select the coverslip summary file
[ CS_name, CS_path,~ ] = load_files( {'*CS_Summary*.mat'}, ...
    'Select CS summary file for coverslip you would like to manually review...', pwd);

% Load the current coverslip
CS_data = load(fullfile(CS_path{1},CS_name{1,1})); 

% Get z-line image names 
zline_images = CS_data.CS_results.zline_images; 

%% Select orientation analysis files 
n = length(zline_images); 
FOV_names = cell(n,1); 
FOV_paths = cell(n,1); 
% Select the orientation analysis files 
for k = 1:n
    clc; 
    [p,f,e] = fileparts(fullfile(CS_path{1},zline_images{n})); 
    likelypath = fullfile(p,f); 
    [ temp_name, temp_path,~ ] = load_files( {'*OrientationAnalysis*.mat'}, ...
        'Select the orientation analysis file...', likelypath);
    FOV_names{k,1} = temp_name{1}; 
    FOV_paths{k,1} = temp_path{1}; 
end

%% Curate FOVs 
% For each FOV display the image and ask if the user would like to
% eliminate part of the background 

% Save modified number and their ID 
modn = 0; 
modbin = zeros(n,1); 

% Select the orientation analysis files 
% for k = 1:n
for k = 1:1
    % Load the labeled image
    currentFOV = load(fullfile(FOV_paths{k,1},FOV_names{k,1}));
    % Load settings
    settings = currentFOV.settings; 
    % Load image struct  
    im_struct = currentFOV.im_struct; 
    % If exists, load the CZL struct and oop struct - maybe ???
    
    % Label the skeleton 
    [ labeled_im ] = ...
        labelSkeleton( mat2gray(im_struct.im), ...
        im_struct.skel_final_trimmed ); 
    imshow(labeled_im); 
    
    % Ask the user if they'd like to remove parts of the background  
    answer = questdlg('Would you like to manually remove parts of the background?', ...
	'Modify Image', ...
	'Yes','No','Yes');

    % Close image 
    close; 
    % Handle response
    switch answer
        case 'Yes'
            mask = modifyROI( mat2gray(im_struct.im), ...
                im_struct.skel_final_trimmed, false ); 
    end
   
end