% averageImage - Takes an input image and breaks it into grids and computes
% the average value in that grid 
%
% Usage:
%   [ avgIM ] = averageImage( im, comp )
%
% Arguments:
%   im      - 2D matrix
%               Class Support: 2D numeric or logical matrix 
%   comp    - size of the grids [dim1 dim2] 
%               Class Support: 2x1 array of positive values  
%
% Returns:
%   avgIM   - 2D matrix size 
%               Class Support: 2D numeric matrix 
%
% Dependencies: 
%   MATLAB Version >= 9.5 
%
%
% Tessa Morris
% Advisor: Anna Grosberg, Department of Biomedical Engineering 
% Cardiovascular Modeling Laboratory 
% University of California, Irvine 

function [ avgIM ] = averageImage( im, comp )

% Get the size of the image 
[ dim1, dim2 ] = size(im); 

% Divide the number of components by 
d1C = ceil(dim1/comp(1)); 
d2C = ceil(dim2/comp(2)); 

% Initialize an average image
avgIM = zeros(size(im)); 

% Need to do two for loops 
for k1 = 1:comp(1)
    for k2 = 1:comp(2)
        %Save the start and end points 
        k1Start = 1 + (k1 - 1)*d1C; 
        k2Start = 1 + (k2 - 1)*d2C; 
        k1Stop = k1*d1C; 
        k2Stop = k2*d2C; 
        
        %Correct for boundaries 
        if k1Stop > dim1
            k1Stop = dim1; 
        end 
        if k2Stop > dim2
            k2Stop = dim2; 
        end
        
        %Save the intensity values in the quadrant in a temporary array
        temp_val = im(k1Start:k1Stop, k2Start:k2Stop); 
        
        %Remove NaN values
        temp_val(isnan(temp_val)) = []; 
        
        %Get the average 
        if isempty(temp_val)
            temp_ave = 0; 
        else 
            temp_ave = mean(temp_val); 
        end 
        
        %Set the positions in the average image equal to the temp average
        avgIM(k1Start:k1Stop, k2Start:k2Stop) = temp_ave; 
        
        %Clear variables 
        clear temp_ave temp_val 
    end
end 

end

