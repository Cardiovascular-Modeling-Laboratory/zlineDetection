function [ clustered_values ] = create_cluster( dp_rows, dp_cols)
%This function will add all of the row and column positions to a cell that
%can then be concatenated to a previous matrix if necessary 

%Create a matrix 
clustered_values = []; 

%Loop through all the directions (dir1, dir0, dir2) and make sure to only 
%add directions that are not NaN
for nd = 1:size(dp_rows, 2)
    
    %Check if both the row and the column positions are not NaN, add them
    %to the cluster.
    if isnan(dp_rows(1,nd)) == false && isnan(dp_cols(1,nd)) == false 
       
        %Add directions to the cell cluster 
        clustered_values = [clustered_values; ...
             dp_rows(1,nd), dp_cols(1,nd)];
    end 

end

end

