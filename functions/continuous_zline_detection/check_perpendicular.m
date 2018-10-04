function [ isPerp ] = check_perpendicular( neigh_fwd, neigh_bwd )
%This function will check if two of its neighbors are perpendicular.

%Check absolute value between rows 
drow = abs( neigh_fwd(1) - neigh_bwd(1) );

%Check the absolute value between columns 
dcol = abs( neigh_fwd(2) - neigh_bwd(2) ); 

%Check to see if they're both one (perpendicular)
if drow == 1 && dcol == 1
    isPerp = true; 
else 
    isPerp = false;
end 

end

