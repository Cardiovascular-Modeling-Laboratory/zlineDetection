function [recip_rows,recip_cols] = neighborReciprocity(dp_rows, dp_cols)
% Get the maximum dimensions 
temp_d1 = dp_rows(:); 
temp_d1(isnan(temp_d1)) = []; 
temp_d2 = dp_cols(:); 
temp_d2(isnan(temp_d2)) = []; 

% Create a matrix to store the ID number of each orientation vector
IDmatd1 = zeros(max(temp_d1(:)), max(temp_d2(:))); 
IDmatd2 = zeros(max(temp_d1(:)), max(temp_d2(:))); 
IDmat0 = zeros(max(temp_d1(:)), max(temp_d2(:))); 

% Assign each dp poistion an id number 
for k = 1:size(dp_rows,1)
    if ~isnan(dp_rows(k,1)) && ~isnan(dp_cols(k,1))
        if IDmatd1(dp_rows(k,1), dp_cols(k,1)) == 0 
            IDmatd1(dp_rows(k,1), dp_cols(k,1)) = k; 
        else
            IDmatd1(dp_rows(k,1), dp_cols(k,1)) = NaN; 
        end 
    end
    if ~isnan(dp_rows(k,2)) && ~isnan(dp_cols(k,2))
        IDmat0(dp_rows(k,2),dp_cols(k,2)) = k; 
    end 
    if ~isnan(dp_rows(k,3)) && ~isnan(dp_cols(k,3))
        if IDmatd2(dp_rows(k,3), dp_cols(k,3)) == 0
            IDmatd2(dp_rows(k,3), dp_cols(k,3)) = k; 
        else
            IDmatd2(dp_rows(k,3), dp_cols(k,3)) = NaN; 
        end 
    end
end 

recip_rows = dp_rows; 
recip_cols = dp_cols; 

% For each orientation vector, check to make sure it is also selected as a
% neighbor of its neighbor 
for k = 1:size(dp_rows,1)
    disp(k); 
    % Check both neighbor positions 
    for h = [1,3]
        disp(h); 
        % Only check the ID position if the pixel is not NaN 
        if ~isnan(dp_rows(k,h)) && ~isnan(dp_cols(k,h))  
            if ~isnan(IDmatd2(dp_rows(k,h), dp_cols(k,h))) && ...
                    ~isnan(IDmatd1(dp_rows(k,h), dp_cols(k,h)))
                % Check to see if in either neighbor ID matrices the  
                % position is equal to k. If so, set the neighbor to NaN 
                if IDmatd2(dp_rows(k,h), dp_cols(k,h)) ~= k && ...
                        IDmatd1(dp_rows(k,h), dp_cols(k,h)) ~= k
                    recip_rows(k,h) = NaN; 
                    recip_cols(k,h) = NaN; 
                    disp('Not listed.'); 
                end 
            else
                % Get the value in the orientation vector matrix 
                val0 = IDmat0(dp_rows(k,h), dp_cols(k,h)); 
                
                % Get the position of its neighbors 
                if ~isnan(dp_rows(val0,h)) && ~isnan(dp_cols(val0,h))  
                    vald1 = IDmatd2(dp_rows(val0,h), dp_cols(val0,h));
                    vald2 = IDmatd1(dp_rows(val0,h), dp_cols(val0,h));
                    if k ~= vald1 || k ~= vald2
                        recip_rows(k,h) = NaN; 
                        recip_cols(k,h) = NaN; 
                        disp('Not the correct neighbor.');  
                    end 
                else
                    recip_rows(k,h) = NaN; 
                    recip_cols(k,h) = NaN; 
                    disp('Not the correct neighbor, not listed.');  
                end 
            end 
        end 
    end 
end 
end

