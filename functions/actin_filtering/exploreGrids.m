function [ actin_explore ] = ...
    exploreGrids(im_struct, settings, actin_explore)
%This function will create a range of grids
%Check to see if this is a actin threshold exploration as well
if settings.actin_thresh > 1
    disp('Actin Threshold Explore Too'); 
end 

%Total number of grids
tot = length(actin.grid_min:actin_explore.grid_step:actin_explore.grid_max);
%Start counter 
n = 0;
%Loop trhough all of the grids 
for grids = round(actin.grid_min:actin_explore.grid_step:actin_explore.grid_max)

end 

end

