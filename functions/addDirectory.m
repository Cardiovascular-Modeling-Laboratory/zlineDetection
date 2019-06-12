% addDirectory - This function will check if a directory exists. If
% it does exist, it will keep adding numbers until it no longer exists and
% then create that directory if the user would like, otherwise it will just
% output the name of the non existing directory
%
% Usage:
%   new_subfolder_name = ...
%       addDirectory(subfolder_path, subfolder_name, create); 
%
% Arguments:
%   subfolder_path      - path where the new directory should be added
%                           Class Support: STRING
%   subfolder_name      - name of new directory 
%                           Class Support: STRING
%   create              - boolean on whether the user would like to create 
%                           the directory as soon as it no longer exists
%                           Class Support: LOGICAL  
%
% Returns:
%   new_subfolder_name  - name of a directory that does not exist 
%                           Class Support: STRING
%
% Dependencies: 
%   MATLAB Version >= 9.5 
%
% Tessa Morris
% Advisor: Anna Grosberg, Department of Biomedical Engineering 
% Cardiovascular Modeling Laboratory 
% University of California, Irvine 

function [ new_subfolder_name ] = ...
    addDirectory( subfolder_path, subfolder_name, create )

%Start the while loop 
keepAdding = true;  
append_num = 0; 

%Create a new variable to store the subfolder name 
new_subfolder_name = subfolder_name; 

while keepAdding 
    % Store the path and the subfolder name as a new variable
    new_path = fullfile(subfolder_path, new_subfolder_name); 

    % Make sure the path does not exist
    if ~exist(new_path,'dir')
        % If the user would like to create a new path, create the path
        
        if create
            mkdir(new_path);
        end 
        
        % End the loop 
        keepAdding = false; 
    
    else
        % Increate the append number 
        append_num = append_num + 1 ;
        
        % Change the subfolder name 
        new_subfolder_name = strcat(subfolder_name, '_', ...
               num2str(append_num)); 
       
    end 

end 

end
