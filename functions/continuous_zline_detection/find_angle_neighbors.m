function [ angled_rows, angled_cols] = ...
    find_angle_neighbors( all_angles, nonzero_rows, nonzero_cols)
%Calculate the nearest neighbors in the direction of the point of interest
%over the max range

%Double check that the angle number, row number, and column number are all
%the same
row_col_same = length(nonzero_rows) - length(nonzero_cols) == 0; 
angles_col_same = length(all_angles) - length(nonzero_cols) == 0; 
row_angles_same = length(nonzero_rows) - length(all_angles) == 0; 

if row_col_same == 0 || angles_col_same == 0 ||  row_angles_same == 0 
    disp('Warning dimesnions of nonzeros and the angles are not the same.');
end 

%Determine a range to draw a line over. 
range = 1:-1:-1;

%Repeat the columns and rows length of the range times. 
repeated_rows = bsxfun(@times, nonzero_rows, ...
    ones(length(nonzero_rows), length(range)));
repeated_cols = bsxfun(@times, nonzero_cols, ...
    ones(length(nonzero_cols), length(range)));

%Repeat range
repeated_range = bsxfun(@times, range, ...
    ones(length(all_angles), length(range)));

%Repeat thetas
repeated_thetas = bsxfun(@times, all_angles, ...
    ones(length(all_angles), length(range)));

%Take the cosine and sine of the angles
c = cos(repeated_thetas);
s = sin(repeated_thetas);

%Multiply the cosine and sine of the angles by the repeated ranges. 
c_range = bsxfun(@times, repeated_range, c);
s_range = bsxfun(@times, repeated_range, s);

%Find all rows and columns in the range and then round. 
angled_rows = round(repeated_rows + s_range);
angled_cols = round(repeated_cols + c_range);

end