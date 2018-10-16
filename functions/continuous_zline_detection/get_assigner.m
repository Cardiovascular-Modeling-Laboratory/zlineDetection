function [ class_set ] = get_assigner( rows, cols, cluster_value_nan)
% dp_rows(k,:), dp_cols(k,:)
%Get a matrix of the classifying set 

%This is done for
%CASE 2: 
% CASE 2-1: a 0 0 
% CASE 2-2: 0 0 a 
%CASE 3: 
% CASE 3-1: a a 0
% CASE 3-2: 0 a a 

%Get the classifying dimensions
classified_rows = [];
classified_cols = [];
for d = 1:size(cluster_value_nan, 2)
    if ~isnan(cluster_value_nan(d)) && cluster_value_nan(d) ~= 0 
        classified_rows = [classified_rows; rows(d)];
        classified_cols = [classified_cols; cols(d)];     
    end 
end

%Store the classifying rows and columns in a matrix
class_set = [classified_rows, classified_cols]; 

%Make NaN if it is empty 
if isempty(class_set)
    class_set = NaN; 
end 

end

