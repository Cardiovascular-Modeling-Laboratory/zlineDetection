% declareCondition - For usage with zlineDetection.m ONLY. Request the
% condition number for the current coverslip 
% 
% Usage: 
%  createSummaries(MultiCS_Data, name_CS, zline_images,...
%    zline_path, cond, settings)
%
% Arguments:
%   cond_names  - name of all conditions 
%                   Class Support: cell of strings 
%   k           - current cover slip number 
%                   Class Support: postive integer 
%   num_cs      - total number of coverslips 
%                   Class Support: postive integer 
%
% Returns:
%   cond        - condition number declared by user
%                   Class Support: positive integer 
%
% Dependencies: 
%   MATLAB Version >= 9.5 
%
%
% Tessa Morris
% Advisor: Anna Grosberg, Department of Biomedical Engineering 
% Cardiovascular Modeling Laboratory 
% University of California, Irvine 

function [cond] = declareCondition(cond_names, k, num_cs)
%Create a pop up list for user to declare their conditions 

% Loop through and create an array 
list = cell(1,length(cond_names)); 
for h = 1:length(cond_names)
    %Save the name 
    list{1,h} = cond_names{h,1};
end 

% Name of the list 
temp_list = strcat('Condition for CS',{' '}, num2str(k), ' of ',{' '},...
num2str(num_cs)); 
listname = temp_list{1,1};

% Display the list 
[cond,~] = listdlg('ListString',list,'SelectionMode','single', ...
    'ListSize',[300,150], 'Name',listname);

    
end

