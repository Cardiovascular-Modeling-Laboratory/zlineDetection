function [ value_matrix ] = get_values(row_positions, col_positions, ...
    data_image)
%Create a matrix with the data value at each of the row and col
%positions 

%Initialize a value matrix
[size_rows, size_cols] = size(row_positions); 
value_matrix = zeros(size(row_positions)); 

%Find and copy value matrix into the initialized matrices. 
for row_iterations = 1:size_rows
    for col_iterations = 1:size_cols
        
        %If the row or column position is outside of the boundaries then
        %the value_matrix should be NaN at that position. 
        if isnan(row_positions(row_iterations, col_iterations)) || ...
                isnan(col_positions(row_iterations, col_iterations))
            
            value_matrix(row_iterations, col_iterations) = NaN; 
            
        else
            
        value_matrix(row_iterations, col_iterations) = ...
            data_image(row_positions(row_iterations, col_iterations), ...
            col_positions(row_iterations, col_iterations));
        end 
    end
end 

end
