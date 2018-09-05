% LOAD_FILES - function to select a series of files and save their names /
% directories in a cell.  
%
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
% 
% Tessa Morris
% Advisor: Anna Grosberg
% Cardiovascular Modeling Laboratory 
% University of California, Irvine 

function [ files, path, n ] = load_files( filetype,...
    disp_message, directory, mult_select )

%Get the number of inputs 
num_inputs =  nargin; 

%Go through and set any inputs that were not set by the user 
if num_inputs == 0 
    filetype = '*'; 
    disp_message = 'Select files...'; 
    directory = ''; 
    mult_select = 'on'; 
elseif num_inputs == 1
    disp_message = 'Select files...'; 
    directory = ''; 
    mult_select = 'on'; 
elseif num_inputs == 2
    directory = ''; 
    mult_select = 'on'; 
elseif num_inputs == 3
    mult_select = 'on'; 
end 

%Display message
disp(disp_message);

%Select files 
[ files,path ]= uigetfile(fullfile(directory, filetype), ...
    disp_message,'MultiSelect', mult_select);

%Convert to string 
files = cellstr(files); 
path = cellstr(path); 

%Determine the number of files 
n = length(files); 

end