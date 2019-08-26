function [ dp_rows, dp_cols] = compare_angles( dot_product_error,...
    angles, nonzero_rows, nonzero_cols, corrected_rows, corrected_cols)
%Compute the dot product between the nonzero orientation angle and their
%candidate rows and columns 

%Get the number of orientation angles.
anglesCount = size(nonzero_rows,1); 

%Create an anonymous function to calculate the dot product. 
fun_dot = @(theta_1, theta_2) sqrt( (cos(theta_1 - theta_2)).^2 ); 

%Get the values of the original orientation angles
original_angles  = get_values( nonzero_rows, nonzero_cols, ...
    angles);

%Get the values of the candidate neighbors in each direction 
%Initalize 
dir1_neighbors = zeros(size(nonzero_rows,1),3);  
dir2_neighbors = zeros(size(nonzero_rows,1),3);  

for k = 1:3
    dir1_neighbors(:,k) = ...
        get_values(corrected_rows(:,k), corrected_cols(:,k), angles);

    dir2_neighbors(:,k) = ...
        get_values(corrected_rows(:,k+3), corrected_cols(:,k+3), angles);
end 

%Set all zeros equal to NaN because they mess up the calculation for the
%dot product.
dir1_neighbors(dir1_neighbors == 0) = NaN; 
dir2_neighbors(dir2_neighbors == 0) = NaN; 

%Calculate the dot product with zeros set to NaN
dir1_dot_product = zeros(size(dir1_neighbors)); 
dir2_dot_product = zeros(size(dir2_neighbors)); 

for k = 1:3
    dir1_dot_product(:,k) = bsxfun(fun_dot, original_angles,...
         dir1_neighbors(:,k));
    dir2_dot_product(:,k) = bsxfun(fun_dot, original_angles,...
         dir2_neighbors(:,k));
end 

%Set the dot product values that are less than the dot product error equal
%to NaN
dir1_dot_product(dir1_dot_product < dot_product_error) = NaN; 
dir2_dot_product(dir2_dot_product < dot_product_error) = NaN; 

%Set the positions that are less than the dot product error equal to NaN
%   Direction 1: 
candidate_dp_rows_dir1 = corrected_rows(:,1:3); 
candidate_dp_cols_dir1 = corrected_cols(:,1:3); 
candidate_dp_rows_dir1( isnan(dir1_dot_product) ) = NaN; 
candidate_dp_cols_dir1( isnan(dir1_dot_product) ) = NaN; 

%   Direction 2: 
candidate_dp_rows_dir2 = corrected_rows(:,4:6); 
candidate_dp_cols_dir2 = corrected_cols(:,4:6); 
candidate_dp_rows_dir2( isnan(dir2_dot_product) ) = NaN; 
candidate_dp_cols_dir2( isnan(dir2_dot_product) ) = NaN; 


%Find the maxima and their column positions for each row in teh dot product
%matrix 
[ max_dir1_cols , ~ ] = all_max( dir1_dot_product ); 
[ max_dir2_cols , ~ ] = all_max( dir2_dot_product ); 

%Initalize dot product rows
dp_rows = zeros(anglesCount, 3);
dp_cols = zeros(anglesCount, 3);

%Set the center row of the dp matrices equal to the nonzero orientation
%vectors 
dp_rows(:,2) = nonzero_rows;
dp_cols(:,2) = nonzero_cols;

%Loop through all of the maxima values. If there is only one maximum
%position, set that value equal to the accepted neighbor. Otherwise, chose
%the nearest neighbor and then chose randomly between them 
for h = 1:anglesCount
    
    %Check Direction 1:
    if length(max_dir1_cols{h}) == 1 
        if isnan(max_dir1_cols{h}) 
            dp_rows( h, 1 ) = NaN; 
            dp_cols( h, 1 ) = NaN; 
        else 
            dp_rows( h, 1 ) =  ...
                candidate_dp_rows_dir1( h, max_dir1_cols{h} );  
            dp_cols( h, 1 ) =  ...
                candidate_dp_cols_dir1( h, max_dir1_cols{h} ); 
        end 
    else
        %Store the columns in this row 
        temp_cols = max_dir1_cols{h};
        %Determine if the nearest neighbor is an option. If so set the
        %value of the dp_rows/cols equal to this value.
        p = find(temp_cols == 2); 
        if ~isempty(p)
            dp_rows( h, 1 ) =  candidate_dp_rows_dir1( h, 2); 
            dp_cols( h, 1 ) =  candidate_dp_cols_dir1( h, 2);
        else
            %Flip a coin that will either be 1 or 3 
            p = round( rand(1) ); 
            p(p == 0) = 3; 
            
            %Set the flipped coin position 
            dp_rows( h, 1 ) =  candidate_dp_rows_dir1( h, temp_cols(p) );  
            dp_cols( h, 1 ) =  candidate_dp_cols_dir1( h, temp_cols(p) ); 
            
        end
        clear temp_cols 
    end
    
    %Check Direction 2: 
    if length(max_dir2_cols{h}) == 1
        if isnan(max_dir2_cols{h}) 
            dp_rows( h, 3 ) = NaN; 
            dp_cols( h, 3 ) = NaN; 
        else 
            dp_rows( h, 3 ) =  ...
                candidate_dp_rows_dir2( h, max_dir2_cols{h} );  
            dp_cols( h, 3 ) =  ...
                candidate_dp_cols_dir2( h, max_dir2_cols{h} ); 
        end 
    else
        %Store the columns in this row 
        temp_cols = max_dir2_cols{h};
        %Determine if the nearest neighbor is an option. If so set the
        %value of the dp_rows/cols equal to this value.
        p = find(temp_cols == 2); 
        if ~isempty(p)
            dp_rows( h, 3 ) =  candidate_dp_rows_dir2( h, 2); 
            dp_cols( h, 3 ) =  candidate_dp_cols_dir2( h, 2);
        else
            %Flip a coin that will either be 1 or 3 
            p = round( rand(1) ); 
            p(p == 0) = 3; 
            
            %Set the flipped coin position 
            dp_rows( h, 3 ) =  candidate_dp_rows_dir2( h, temp_cols(p) );  
            dp_cols( h, 3 ) =  candidate_dp_cols_dir2( h, temp_cols(p) ); 
            
        end
        
    end
    
    %If the row/ column positions are NaN, set the value of the orientation
    %vector equal to NaN 
    dir1nan = isnan( dp_rows(h,1) ) || isnan( dp_cols(h,1) ); 
    dir2nan = isnan( dp_rows(h,3) ) || isnan( dp_cols(h,3) );
    
    if dir1nan && dir2nan
        dp_rows(h,2) = NaN;
        dp_cols(h,2) = NaN;
    end 
    
    clear dir1nan dir2nan
end 

end

