% appendFilename - This function will check if a file exists at the given 
% path. If it does then it it will add numbers at the end until it does not
% exist. 
% 
% Usage:
%   new_filename = appendFilename( path, file_name ) 
%
% Arguments:
%   path            - path to check existance of a file 
%                           Class Support: STRING
%   file_name       - name of the file
%                           Class Support: STRING
%
% Returns:
%   new_filename    - name of a unique file name in the given path 
%                           Class Support: STRING
%
% Dependencies: 
%   MATLAB Version >= 9.5 
%
%
% Tessa Morris
% Advisor: Anna Grosberg, Department of Biomedical Engineering 
% Cardiovascular Modeling Laboratory 
% University of California, Irvine 

function [ new_filename ] = appendFilename( path, file_name )

%Start the while loop 
keepAdding = true;  
append_num = 0; 

%Separate the extension and the file 
[~, file, ext] = fileparts( file_name ); 

%Initialize the appeneded file as just the name of the file wihtout the
%extension 
appended_name = file; 

while keepAdding 
    %Add the path and filename together 
    filename = fullfile(path, strcat(appended_name, ext)); 

    %Check to see if the file exists 2 = YES, 0 = NO
    ex = exist(filename, 'file'); 
    
    if ex == 2
        %If it does exist, increate the append number 
        append_num = append_num + 1; 

        %Append the name 
        appended_name = strcat(file, '_', num2str(append_num));
    else 
        keepAdding = false; 
    end 

end 

new_filename = strcat(appended_name, ext); 

end
