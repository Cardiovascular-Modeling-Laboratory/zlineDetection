function [ orientim ] = orientimperp2orientim( orientim_perp )
%This is a function to get the orientation angles from the angles
%perpendicular to the orientation angles. 
[nonzero_rows, nonzero_cols] = find(orientim_perp); 
orientim = zeros(size(orientim_perp)); 

for k = 1:length(nonzero_rows)
    orientim(nonzero_rows(k), nonzero_cols(k)) = ...
        orientim_perp(nonzero_rows(k), nonzero_cols(k)) - (pi*3/2);
end 

end

