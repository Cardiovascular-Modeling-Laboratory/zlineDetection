function [ mask, final_skel, actin_filtering ] = ...
    filterWithActin( directors, dims, orientim, thresh)

%Total number of grids
n = size(directors,1); 

%Create mask 
mask = ones(size(orientim)); 

%Create a direcor matrix
dir_mat = ones(size(orientim)); 
dir_mat(dir_mat == 1) = NaN;  

%Loop through each grid and place the director of each grid as the value in
%the grid
for k = 1:n
    %Set the value each grid equal to its director
    dir_mat(dims(k,1):dims(k,2),dims(k,3):dims(k,4)) = directors(n,1);     
end 


%Take the dot product sqrt(cos(th1 - th2)^2);
dp = sqrt(cos(orientim - dir_mat)^2); 

%If dot product is closer to 1, the angles are more parallel and should be
%removed
mask(dp >= thresh) = 0; 
%If dot product is closer to 0, the angles are more perpendicular and
%should be kept
mask(dp < thresh) = 1; 

%The NaN postitions should be set equal to 1 (meaning no director for
%actin)
mask(isnan(mask)) = 1; 

%Create a skeleton by setting every positive pixel in the orientation
%matrix equal to 1
final_skel = orientim; 
final_skel(~isnan(orientim)) = 1; 
final_skel(isnan(orientim)) = 0;

%Multiply the final skeleton by the mask (removing points below the
%threshold
final_skel = final_skel.*mask; 

% Save all of the actin filtering data in a structural array 
actin_filtering = struct(); 
actin_filtering.directors = directors; 
actin_filtering.dims = dims; 
actin_filtering.threshold = thresh; 

end

