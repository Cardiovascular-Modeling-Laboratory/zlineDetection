function [ concated_matrix ] = concatCells( cell_matrix, start_pos, stop_pos)
%This function will combine the matrices contained in a cell array. 

%If the user did not supply start and end positions, combine the entire
%matrix 
if nargin ==1 
    start_pos = 1; 
    stop_pos = length(cell_matrix); 
end 

%Create an empty matrix
concated_matrix = []; 

%Loop through all of the positions
for k=start_pos:stop_pos
    %Temporarily store the values
    temp = cell_matrix{k,1}; 
    
    %Add the temporary matrix to the concatenated matrix 
    concated_matrix = [concated_matrix;temp]; 
    
    %Clear the temporary matrix 
    clear temp; 
end 

end

