function [ row_neighbors, col_neighbors, neighbor_values] = ...
    connectivity_8_neighbors( original_matrix, row_values, col_values)
%This function will find the position and value of each row, column value's
%eight connected neighbors.

%Convert row vector to column vectors if necessary
if isrow(row_values)
    row_values = row_values';
end
if isrow(col_values)
    col_values = col_values';
end 

%Find the minimum and maximum row and column size. 
[max_row, max_col] = size(original_matrix); 

%Determine the number positions that you would like to determine the
%neighbors of. 
n_interest = length(row_values); 
n_neighbors = 8;

%For the row values and col values of interest, find the eight connected
%neighbors.
row_order = [0, 1, 1, 1, 0, -1, -1, -1];
col_order = [1, 1, 0, -1, -1, -1, 0, 1];

%Repeat the row and column addition values 
row_additions = repmat(row_order, [n_interest,1] ); 
col_additions = repmat(col_order, [n_interest,1] );

%Repeat the row and column values 
repeat_row_values = repmat(row_values, [1, n_neighbors]); 
repeat_col_values = repmat(col_values, [1, n_neighbors]); 

%Add the row and column values to the addition values 
row_neighbors = bsxfun(@plus, repeat_row_values,  row_additions); 
col_neighbors = bsxfun(@plus, repeat_col_values, col_additions); 

%Correct for the boundaries by setting any values that are greater than the
%max or less than the min equal to NaN 
row_neighbors(row_neighbors < 1) = NaN; 
row_neighbors(row_neighbors > max_row) = NaN; 
col_neighbors(col_neighbors < 1) = NaN; 
col_neighbors(col_neighbors > max_col) = NaN; 

%Find value of the neighbors
neighbor_values = zeros( n_interest, n_neighbors ); 
for r = 1:n_interest
    for c = 1:n_neighbors
        if isnan(row_neighbors(r,c)) || isnan(col_neighbors(r,c))
            neighbor_values(r,c) = NaN; 
        else 
            neighbor_values(r,c) = original_matrix(row_neighbors(r,c), ...
                col_neighbors(r,c)); 
        end 
    end 
end 

end
