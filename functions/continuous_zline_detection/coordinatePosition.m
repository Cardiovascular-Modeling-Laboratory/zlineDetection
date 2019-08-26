function [indx_match] = coordinatePosition(rval,cval,all_rows,all_cols)
% Find the position of a coordinate in a list of coordinates 

% Create a logical to store whether there is an issue with the row or
% column formatting 
noIssue = true; 

% Check rows
if size(all_rows,1) ~= 1 && size(all_rows,2) ~=1 
    noIssue = false; 
    disp('Row values must be in a vector that is 1 x N or N x 1');   
end 

% Check columns 
if size(all_cols,1) ~= 1 && size(all_cols,2) ~=1 
    noIssue = false; 
    disp('Col values must be in a vector that is 1 x N or N x 1');   
end 

% Check rows and columns have the same number of values 
if size(all_cols,1) ~= size(all_rows,1) ||...
        size(all_cols,2) ~= size(all_rows,2) 
    noIssue = false; 
    disp('Vectors storing row and column values must be the same size.');   
end 

if ~noIssue 
    indx_match = NaN; 
else 

    % Initialize matrices to store the column and row matches
    row_match = zeros(size(all_rows)); 
    col_match = zeros(size(all_cols));
    
    % Find where the rows and columns match 
    row_match(all_rows == rval) = 1; 
    col_match(all_cols == cval) = 1; 
    coord_match = row_match.*col_match; 
    
    % Get the position of the closest assginer 
    indx_match = find(coord_match == 1);
    
end 

end

