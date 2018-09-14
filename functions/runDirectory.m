% RUNDIRECTORY - A function to select images and then call functions to
% analyze them 
%
%
% Usage:
%  runDirectory( settings );
%
% Arguments:
%          settings         - structural array containing settings for 
%                               analysis 
% 
% Tessa Morris
% Advisor: Anna Grosberg
% Cardiovascular Modeling Laboratory 
% University of California, Irvine 

function [  ] = runDirectory( settings )
%This function will take file names as an input and then loop through them,
%calling the analyze function

% Prompt the user to select the images they would like to analyze. 
[ image_files, image_path, n ] = ...
    load_files( {'*.TIF';'*.tif';'*.*'} ); 

% Stop if the user hit the cancel button
if isequal(image_path, 0); return; end

% Loop through all of the image files 
for k = 1:n 
    % Store the current filename 
    filename = strcat(image_path{1}, image_files{1,k});
    
    % Perform the analysis including saving the image 
    [~] = analyzeImage( filename, settings ); 
    
    % If the user wants to calculate continuous z-line length 
    if settings.tf_CZL && k == 1
        disp('NOT YET IMPLEMENTED: Continuous Z-line Length'); 
        %settings.dp_threshold
    end 

    % If the user wants to calculate OOP
    if settings.tf_OOP && k == 1
        disp('NOT YET IMPLEMENTED: OOP'); 
        %settings.cardio_type
    end 
    
    % Close all figures
    close all; 
    
    % Clear the file name 
    clear filename
   
end 

end