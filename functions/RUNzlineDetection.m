% RUNzlineDetection - Asks the user whether they would like to (1) Declare
% settings, select data, and then perform analysis (2) Load settings and
% from .mat file and then select data paths and perform analysis 
% (3) Load settings and data paths from .mat file and then perform analysis
% Written for usage with zlineDetection 
%
% Usage:
%  [ files, path, n ] = load_files( filetype, disp_message, directory, 
%               mult_select )
%
% Arguments:
%       filetype        - A cell with the type of files you would like to 
%                           find in string format
%                           Example: {'*.TIF';'*.tif';'*.*'}
%                           Example: '*.mat'
%       disp_message    - A string containing the message to display to 
%                           users selecting files 
%       directory       - A string of directory to serach 
%       mult_select     - Option to select more than one file. Default is
%                           set to 'on'. Set to either 'on' or 'off'     
% 
% Returns:
%       files           - Cell containing the files 
%       path            - Cell containing the cell path  
%       n               - Number of files  
% 
% Dependencies: 
%   MATLAB Version >= 9.5 
%
%
% Tessa Morris
% Advisor: Anna Grosberg
% Cardiovascular Modeling Laboratory 
% University of California, Irvine 

function [] = RUNzlineDetection(handles)

% Logical whether user wants to load old image paths 
loadImagePaths = get(handles.loadImagePaths, 'Value'); 
% Logical whether user wants to load old settings
loadSettings = get(handles.loadSettings, 'Value'); 

previous_path = pwd; 
% Check what the user wants to only load settings 
if loadSettings
    % Set the display message
    dispmsg = 'Select .mat file that contains settings...';
    % Have the user select a file that has settings that they would like to
    [ settings_filename, settings_pathname, ~ ] = load_files( ...
        {'*Initialization.mat;*OrientationAnalysis.mat'},...
        dispmsg, previous_path, 'off' );
    % Set the previous path just in case the user wants to load images too 
    previous_path = settings_pathname{1};

end 

% Check what the user wants to only load image paths  
if loadImagePaths
    % Set the display message
    dispmsg = 'Select .mat file that contains image paths...';
    % Have the user select a file that has settings that they would like to
    [ images_filename, images_pathname, ~ ] = load_files( ...
        {'*Initialization.mat;*OrientationAnalysis.mat'},...
        dispmsg, previous_path, 'off' );
end 

dontContinue = false; 

% If requested load the settings from the provided  
if loadSettings
    % Load the previous data
    previous_settings = ...
        load(fullfile(settings_pathname{1}, settings_filename{1})); 

    if isfield(previous_settings, 'settings')
        % Store the settings 
        settings = previous_settings.settings; 
        % Get the name and location of summary file if there is more than 
        % one coverslip and the user wants to do any kind of analysis.
        if settings.num_cs > 1 && settings.analysis
            %Display message to select path 
            disp('Select a location to save summary analysis for all Coverslips'); 
            %Ask the user for the location of the summary file 
            settings.SUMMARY_path = ...
                uigetdir(previous_path,'Save Location for Summary Files'); 

            %Get the parts of the summary path 
            pathparts = strsplit(settings.SUMMARY_path,filesep); 

            %Find the location of the current folder 
            potential_end = size(pathparts,2); 
            while isempty(pathparts{1,potential_end})
                potential_end = potential_end -1; 
            end 

            %Get the name of folder 
            base_name = pathparts{1,potential_end}; 

            %Get today's date
            date_format = 'yyyymmdd';
            today_date = datestr(now,date_format);

            %Suggested suggested name for files  
            suggested_name = strcat(base_name, '_MultiCondSummary_',today_date);

            %Ask the user for the summary name 
            %Prompt Questions
            sumname_prompt = ...
                {'Name of Summary File for Multiple Coverslips (no extension):'};
            %Title of prompt
            sumname_title = 'Summary File Name';
            %Dimensions
            sumname_dims = [1 80];
            %Default inputs
            sumname_definput = {suggested_name};
            %Save answers
            settings.SUMMARY_name = inputdlg(sumname_prompt,sumname_title,...
                sumname_dims,sumname_definput);
        end 
    
    else
        disp('Cannot select data, settings not provided in .mat file.');
        disp('Input parameter settings in GUI and start again.');
        % Set don't continue to true
        dontContinue = true; 
    end  
    
else
    settings = getGUIsettings(handles); 
end 


% Get the data paths from the struct according to settings, if the 
% fields exist 
if loadImagePaths && ~dontContinue
    % Load the previous data
    previous_images = ...
        load(fullfile(images_pathname{1}, images_filename{1}));
    
    % Store the z-line image names if it exist as a field.
    if isfield(previous_images, 'zline_images')
        zline_images = previous_images.zline_images; 
    else
        loadImagePaths = false; 
        disp('Cannot select data, zline_images not provided'); 
    end 

    % Store the z-line image paths if it exist as a field.
    if isfield(previous_images, 'zline_path') && loadImagePaths
        zline_path = previous_images.zline_path; 
    else
        loadImagePaths = false; 
        disp('Cannot select data, zline_path not provided'); 
    end 

    % Store the coverslip name if it exist as a field.
    if isfield(previous_images, 'name_CS') && loadImagePaths
        name_CS = previous_images.name_CS; 
    else
        loadImagePaths = false; 
        disp('Cannot select data, name_CS not provided'); 
    end 

    % Check if the user did actin filtering if it exist as a field.
    if settings.actin_filt && loadImagePaths
        % Store the z-line image names if it exist as a field.
        if isfield(previous_images, 'actin_images')
            actin_images = previous_images.actin_images; 
        else
            loadImagePaths = false; 
            disp('Cannot select data, actin_images not provided'); 

        end 

        % Store the z-line image paths if it exist as a field.
        if isfield(previous_images, 'actin_path') && loadImagePaths
            actin_path = previous_images.actin_path; 
        else
            loadImagePaths = false; 
            disp('Cannot select data, actin_path not provided'); 

        end 
    else
        % Set actin images and path to empty if not doing actin filtering 
        actin_images = []; 
        actin_path = []; 
    end 

    % Check if the user selected conditions if it exist as a field.
    if settings.multi_cond && loadImagePaths
        % Store the z-line conditiosn if it exist as a field.
        if isfield(previous_images, 'cond')
            cond = previous_images.cond; 
        else
            loadImagePaths = false; 
            disp('Cannot select data, cond not provided'); 

        end    
    else
        % Set cond to empty if not setting conditions 
        cond = []; 
    end 

end 

% Select data if needed
if ~loadImagePaths && ~dontContinue 
    [zline_images, zline_path, name_CS,...
        actin_images, actin_path, cond] ...
        = getZlineDetectionImages(settings); 
end

%Save multiple coverslip data
if settings.num_cs == 1
    % Get today's date
    date_format = 'yyyymmdd';
    today_date = datestr(now,date_format);
    % Save in the z-line path 
    settings.SUMMARY_path = zline_path{1}; 
    summary_name = strcat(name_CS{1},'_',today_date, '_Initialization.mat'); 
else
    % Save the summary name 
    summary_name = strcat(settings.SUMMARY_name{1}, '_Initialization.mat'); 
end 



%Save the data after making sure it is uniquely named (no overwritting)
[ new_filename ] = appendFilename( settings.SUMMARY_path,...
    summary_name);

save(fullfile(settings.SUMMARY_path, new_filename),...
    'name_CS','zline_images','zline_path',...
    'actin_images','actin_path','cond','settings'); 
    
% Run the multiple coverslips
if ~dontContinue 
    runMultipleCoverSlips(settings, zline_images, zline_path, name_CS, ...
        actin_images, actin_path, cond); 
end 

end






