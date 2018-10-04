function [ angled_rows, angled_cols ] = ...
    boundary_correction( angled_rows, angled_cols, m, n )
%Correct for boundaries where m is the max row and n is the max column
%value. This function will replace a coordinate that exceeds the boundary
%with NaN. 

%Correct for the boundaries
[exclude_row_mins_rows, exclude_row_mins_cols] = find(angled_rows < 1); 
[exclude_col_mins_rows, exclude_col_mins_cols] = find(angled_cols < 1); 

[exclude_row_maxs_rows, exclude_row_maxs_cols] = find(angled_rows > m); 
[exclude_col_maxs_rows, exclude_col_maxs_cols] = find(angled_cols > n); 

exclude_global_row_positions = [exclude_row_mins_rows', ...
    exclude_col_mins_rows', exclude_row_maxs_rows', exclude_col_maxs_rows'];
exclude_global_col_positions = [exclude_row_mins_cols', ...
    exclude_col_mins_cols', exclude_row_maxs_cols', exclude_col_maxs_cols'];

for k = 1:length(exclude_global_row_positions)
    angled_rows(exclude_global_row_positions(k),...
        exclude_global_col_positions(k)) = NaN; 
    angled_cols(exclude_global_row_positions(k),...
        exclude_global_col_positions(k)) = NaN; 
end 

end

