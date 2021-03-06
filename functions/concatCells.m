% concatCells - Combine the matrices contained in a cell array. 
%
% Usage: 
%   concated_matrix = concatCells( cell_matrix, same_sze, ...
%       start_pos, stop_pos)
%
% Arguments:
%   cell_matrix - zlineDetection parameters 
%               Class Support: STRUCT
%   same_sze            - logical statement about whether the two matrices
%                           should be the same size
%                           Class Support: LOGICAL 
%   start_pos           - [optional] start index combination positions 
%                           Class Support: positive integer > 1
%   stop_pos            - [optional] end index combination positions 
%                           Class Support: positive integer > 1
% Returns:
%   concated_matrix     - Matrix the size of the combined cell matrix
%                           Class Support: STRUCT
%
% Dependencies: 
%   MATLAB Version >= 9.5 
%
% Tessa Morris
% Advisor: Anna Grosberg, Department of Biomedical Engineering 
% Cardiovascular Modeling Laboratory 
% University of California, Irvine 

function [ concated_matrix ] = concatCells( cell_matrix, same_sze, ...
    start_pos, stop_pos)

%Get the size of the cell matrix
[d1, d2] = size(cell_matrix); 
if d2 > d1
    cell_matrix = cell_matrix';
end 

%If the user did not supply start and end positions, combine the entire
%matrix 
if nargin == 2
    start_pos = 1; 
    stop_pos = length(cell_matrix); 
end 

if ~same_sze 
    %Create an empty matrix
    concated_matrix = []; 
    
    %Loop through all of the positions
    for k=start_pos:stop_pos
        %Temporarily store the values
        temp = cell_matrix{k,1};
        
        if ~isempty(temp)
            %Add the temporary matrix to the concatenated matrix
            concated_matrix = [concated_matrix;temp(:)]; 

            %Clear the temporary matrix 
            clear temp; 
        end 
    end 
else
    if ~isempty(cell_matrix{1,1})
        %Get size of the first entry of the matrix 
        [m,n] = size(cell_matrix{1,1}); 

        %Initialize a matrix that is m x n x number_of_files
        concated_matrix = zeros(m,n,stop_pos-start_pos + 1); 

        %Loop through all of the cell rows and store 
        for k=start_pos:stop_pos
            %Save the current value
            concated_matrix(:,:,k) = cell_matrix{k,1}; 
        end 

        %Resize the matrix to be a 1 x (n*m*number_of_files) matrix
        concated_matrix = reshape(concated_matrix, ...
            [1 m*n*(stop_pos-start_pos+1)]);
    else 
        concated_matrix = []; 
    end 
end 


end

