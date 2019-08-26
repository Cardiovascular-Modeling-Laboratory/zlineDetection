function [  dp2_rows, dp2_cols ] = ...
    check_perpendicular( dp_rows, dp_cols, angles, dp_thresh)
%This function will check if two of its neighbors are perpendicular.

%Create an anonymous function to calculate the dot product. 
fun_dot = @(theta_1, theta_2) sqrt( (cos(theta_1 - theta_2)).^2 ); 

% Get the number of orientation vectors
n = size(dp_rows,1); 

% Get all of the orientation vecotrs in the forward and backwards
% directions 
theta_dir1 = get_values(dp_rows(:,1), dp_cols(:,1), angles);
theta_dir2 = get_values(dp_rows(:,3), dp_cols(:,3), angles);

%Set all zeros equal to NaN because they mess up the calculation for the
%dot product.
theta_dir1(theta_dir1 == 0) = NaN; 
theta_dir2(theta_dir2 == 0) = NaN; 

%Calculate the dot product with zeros set to NaN
dp = bsxfun(fun_dot, theta_dir1, theta_dir2);

% If the dot product is already NaN ignore it 
dp_binary1 = zeros(size(dp)); 
dp_binary1(dp >= dp_thresh) = 1; 
dp_binary2 = zeros(size(dp)); 
dp_binary2(isnan(dp)) = 1; 
dp_binary = dp_binary1 + dp_binary2; 
dp_binary(dp_binary > 1) = 1; 

% Remove all of the positions that do not have parallel neighbors
dp2_rows = dp_rows;
dp2_cols = dp_cols; 
if sum(dp_binary(:)) ~= n
    [d1,~] = find(dp_binary == 0); 
    for k = 1:length(d1)
        dp2_rows(d1(k),:) = NaN; 
        dp2_cols(d1(k),:) = NaN; 
    end 
end


end

