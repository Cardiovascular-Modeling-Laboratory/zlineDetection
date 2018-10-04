function [ max_cell , max_values ] = all_max( value_matrix )
%Determine the maximum value occuring in each row of a matrix. This
%function will create a cell array and return the positions of all of the
%maxima in a given row 

%Find the max in each row of the matrix 
max_values = max(value_matrix'); 
max_values = max_values';

%Repeat the max value and subtract it from the values in the original
%matrix 
diffs = value_matrix - repmat( max_values, [1, size(value_matrix,2)] ); 

%Find the positions of all of the zeros (where the matrix is equal to
%the maximum 
[max_r, max_c] = find(diffs == 0); 

%Determine the number of unqiue maxima in each row 
unique_vals = sort( unique(max_r) );

%Initalize the cell array 
max_cell = cell( length(max_values), 1);

%Find positions of all NaN maximum values and set them equal to NaN; 
nan_r = find(isnan(max_values)); 
for k = 1:length(nan_r)
    max_cell{nan_r(k)} = NaN; 
end 

%Add the column positions to their respective rows 
for h = 1:length(max_r) 
    max_cell{max_r(h)} = [max_cell{max_r(h)}, max_c(h)]; 
end 

end