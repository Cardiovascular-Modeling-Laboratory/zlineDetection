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

