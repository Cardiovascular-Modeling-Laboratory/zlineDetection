%% Renaming Merlin files with appropriate extensions
% Author: Mary Tran 
% MATLAB R2023b (requires at earliest R2017) 
% Works for the following folder structure 
% Base directory > Image Folders > Image files 

% DOES NOT Work for 
% Base directory > Sub folders > Image folders > Image files 

clear; clc; 
%Select base directory 
base_dir = uigetdir(); 
newFolderPath = fullfile(base_dir, 'RenamedTiffs'); 
mkdir(newFolderPath)

%Get all image subfolders with the .tif.frames extension 
image_folders = dir(fullfile(base_dir, '*.tif.frames')); 

% Loop through each image folder 
for i = 1:length(image_folders)
    % Get the full path of the current image folder
    image_folder_path = fullfile(base_dir, image_folders(i).name);
    
    % Get all files in the current image folder
    image_files = dir(fullfile(image_folder_path, '*.tif'));

    % Loop through each file in the current image folder 
    for j = 1:length(image_files)
        %Check if file exists (and not a directory) 
        if ~image_files(j).isdir 
            % Get old file name and extensions 
            old_file_name = image_files(j).name; 
            [~, name, ext] = fileparts(old_file_name); 

            % DAPI image
            if contains(name, 'C001')
                new_name = extractBefore(name, 'C001'); % File name without channel numbers \
                new_file_name = [new_name, 'DAPI', ext]; % Full new name 
                    
                % Rename the file and move to RenamedTiffs
                 movefile(fullfile(image_folder_path, old_file_name), ...
                     fullfile(newFolderPath, new_file_name)); 
            end 

            % Actin image
            if contains(name, 'C002')
                new_name = extractBefore(name, 'C002'); % File name without channel numbers \
                new_file_name = [new_name, 'GFP', ext]; % Full new name 
                    
                % Rename the file and move to RenamedTiffs
                 movefile(fullfile(image_folder_path, old_file_name), ...
                     fullfile(newFolderPath, new_file_name)); 
            end 

            % Zline image 
            if contains(name, 'C003')
                new_name = extractBefore(name, 'C003'); % File name without channel numbers \
                new_file_name = [new_name, 'mCherry', ext]; % Full new name 
                    
                % Rename the file and move to RenamedTiffs
                 movefile(fullfile(image_folder_path, old_file_name), ...
                     fullfile(newFolderPath, new_file_name)); 
            end 

            % FN image 
            if contains(name, 'C004')
                new_name = extractBefore(name, 'C004'); % File name without channel numbers \
                new_file_name = [new_name, 'Fibronectin', ext]; % Full new name 
                    
                % Rename the file and move to RenamedTiffs
                 movefile(fullfile(image_folder_path, old_file_name), ...
                     fullfile(newFolderPath, new_file_name)); 
            end

        end 
    end 

end 
