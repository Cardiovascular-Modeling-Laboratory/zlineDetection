function [] = runMultipleCoverSlips(settings)
%This function will be used to run multiple coverslips and obtain a summary
%file

%If doing the exploration get additional options

%Get the number of coverslips

%Have the user select the different directories for the coverslips
for k = 1:settings.num_cond 
% Prompt the user to select the images they would like to analyze. 
[ zline_images, zline_path, zn ] = ...
    load_files( {'*w1mCherry*.TIF';'*w1mCherry*.tif';'*.*'}, ...
    'Select images stained for z-lines...'); 

end

