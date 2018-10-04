function [ candidate_rows, candidate_cols ] = ...
    neighbor_positions( all_angles , nonzero_rows, nonzero_cols)

%Find the sin and cosine of the orientation angle, and the orientation
%angle plus and minus pi/3. In order to get the coordinates of the nearest
%neighbor and two other alternatives. 

%Make sure that the all_angles matrix is a column vector 
%Convert row vector to column vectors if necessary
if isrow(all_angles)
    all_angles = all_angles';
end

%Get rounded cosine and sine of each orientation angle 
c_round = round( cos(all_angles) ); 
s_round = round( sin(all_angles) ); 

%Initialze row and column additions 
row_additions = zeros(size(nonzero_rows,1),3); 
col_additions = zeros(size(nonzero_cols,1),3); 

%Set the row and column additions center column equal to the nearest
%orientation vector 
row_additions(:,2) = s_round;
col_additions(:,2) = c_round; 

%Create a n x 4 matrix and then add / subtract 0, 1, or -1
repeat_s = repmat(s_round, [1,4]);
repeat_c = repmat(c_round, [1,4]);

%Repeat the additions 
pms = repmat([0, 1, 0, -1], [size(repeat_s,1), 1]); 
pmc = repmat([1, 0, -1, 0], [size(repeat_c,1), 1]); 

%Sum up the 
summed_s = bsxfun(@plus, repeat_s, pms); 
summed_c = bsxfun(@plus, repeat_c, pmc); 

%Coordinates cannot both be equal to 0, that would just be equal to the
%orientation vector

sumsum = abs( summed_s ) + abs( summed_c ); 
%Will have a step later to also set sum_c values equal to NaN
summed_s(sumsum == 0) = NaN; 

%Neither cooridinate can be +/- 2 
summed_s( abs(summed_s) == 2) = NaN; 
summed_c( abs(summed_c) == 2) = NaN; 

%If they are NaN in either the rows or columns, set the compliment equal to
%NaN
summed_c(isnan(summed_s)) = NaN; 
summed_s(isnan(summed_c)) = NaN; 

%Loop through and only collect the non NaN values 
for h = 1:size(nonzero_rows,1)
    row_nonan = summed_s(h,:); 
    row_nonan(isnan(row_nonan)) = []; 
    row_additions(h,1) = row_nonan(1);
    row_additions(h,3) = row_nonan(2);
    
    col_nonan = summed_c(h,:); 
    col_nonan(isnan(col_nonan)) = []; 
    col_additions(h,1) = col_nonan(1);
    col_additions(h,3) = col_nonan(2);
    
    if length(row_nonan) > 2 || length(col_nonan) > 2
        disp('Something went wrong, more than 2 additions'); 
    end 
end 


%Repeat the nonzero rows and columns 
repeated_rows = repmat(nonzero_rows, [1, 3]);
repeated_cols = repmat(nonzero_cols, [1, 3]);

%Get the candidate neighbors by adding/subtracting the repeated rows/cols
%and the repeated rows/cols
candidate_rows = [ bsxfun(@plus, row_additions, repeated_rows), ...
    bsxfun(@plus, -row_additions, repeated_rows) ]; 
candidate_cols = [ bsxfun(@plus, col_additions, repeated_cols), ...
     bsxfun(@plus, -col_additions, repeated_cols) ];

end

