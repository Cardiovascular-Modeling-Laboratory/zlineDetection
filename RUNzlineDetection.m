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

function [] = RUNzlineDetection()
% Ask if the user has already initialized input 
runType = questdlg('Select previously initialized input?', ...
        'Load Input','Open GUI','Load Settings','Load Data','Load Data');

% If the user wants to open the GUI do so, otherwise ask them to load their
% data 
if strcmp('Open GUI',runType)
    % Open the GUI 
    zlineDetection; 
else
    % Create logicla statment for whether the user would like to select
    % data or load both the settings and data paths from a .mat file  
    selectData = false; 
    
    % Set the display message 
    dispmsg = 'Select .mat file that contains settings and data paths...';
    
    % Check what the user wants to do 
    if strcmp('Load Settings',runType)
        % Change the settings equal to true 
        selectData = true; 
        % Change the display message 
        dispmsg = 'Select .mat file that contains settings...';
    end 
    
    
    % Have the user select a file that has settings that they would like to
    % use 
    
    [ filename, pathname, ~ ] = load_files( ...
        {'initialization*.mat;*OrientationAnalysis.mat'},...
        'Select .mat file that contains settings...', pwd, 'off' );
    
    % Load the previous data
    previous_data = load(fullfile(pathname{1}, filename{1})); 

    % Store the settings 
    settings = previous_data.settings; 
    
    % Get the data paths from the struct according to settings, if the 
    % fields exist 
    if ~selectData
        
        % Store the z-line image names if it exist as a field.
        if isfield(previous_data, 'zline_images')
            zline_images = previous_data.zline_images; 
        else
            selectData = true; 
            disp('Cannot select data, zline_images not provided'); 
        end 
        
        % Store the z-line image paths if it exist as a field.
        if isfield(previous_data, 'zline_path') && ~selectData
            zline_path = previous_data.zline_path; 
        else
            selectData = true; 
            disp('Cannot select data, zline_path not provided'); 
        end 
       
        % Store the coverslip name if it exist as a field.
        if isfield(previous_data, 'name_CS') && ~selectData
            name_CS = previous_data.name_CS; 
        else
            selectData = true; 
            disp('Cannot select data, name_CS not provided'); 
        end 
        
        % Check if the user did actin filtering if it exist as a field.
        if settings.actin_filt && ~selectData
            % Store the z-line image names if it exist as a field.
            if isfield(previous_data, 'actin_images')
                actin_images = previous_data.actin_images; 
            else
                selectData = true; 
                disp('Cannot select data, actin_images not provided'); 

            end 

            % Store the z-line image paths if it exist as a field.
            if isfield(previous_data, 'actin_path') && ~selectData
                actin_path = previous_data.actin_path; 
            else
                selectData = true; 
                disp('Cannot select data, actin_path not provided'); 

            end 
        
        end 
        
        % Check if the user selected conditions if it exist as a field.
        if settings.multi_cond && ~selectData
            % Store the z-line conditiosn if it exist as a field.
            if isfield(previous_data, 'cond')
                cond = previous_data.cond; 
            else
                selectData = true; 
                disp('Cannot select data, cond not provided'); 

            end         
        end 
        
    end 
    
    % Select data if needed
    if selectData
        
        [outputArg1,outputArg2] = initializeZlineDetectionInput(settings); 
    end
    
    % Run the multiple coverslips
    runMultipleCoverSlips(settings); 
end

end






