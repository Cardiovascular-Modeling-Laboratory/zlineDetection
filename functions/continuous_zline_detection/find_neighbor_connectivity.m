function [ candidate_neighbors ] = find_neighbor_connectivity( all_angles )
%This function will find the connectivity position of the nearest neighbors
%of each orietnation angle. 
%Determine where each nearest neighbor is located relative to the 8 
%connectivity around the orientation vector of interest.
% 6 7 8 
% 5 v 1
% 4 3 2
% row_order = [0, 1, 1, 1, 0, -1, -1, -1];
% col_order = [1, 1, 0, -1, -1, -1, 0, 1];

% %Find the sin and cosine of the orientation angle, and the orientation
% %angle plus and minus pi/3. In order to get the coordinates of the nearest
% %neighbor and two other alternatives. 
% 
% %Make sure that the all_angles matrix is a column vector 
% %Convert row vector to column vectors if necessary
% if isrow(all_angles)
%     all_angles = all_angles';
% end
% 
% %Repeat the angles values, plus and minus pi/6 (30 degrees). This is the 
% %amount needed to round from one regime to the next   
% pm = [pi/6, 0, -pi/6]; 
% repeated_angles = repmat(all_angles, [1, 3]); 
% repeated_pm = repmat(pm, [size(all_angles,1), 1]); 



% %Store the bounds of each neighbor regime 
% bounds = [(5*pi)/6, (2*pi)/3, pi/3, pi/6, 0]; 
% fwd_n = [5, 4, 3, 2, 1]; 
% bwd_n = [1, 8, 7, 6, 5]; 
% 
% %Create empty vector to store the fwd and reverse nearest neighbors 
% n_connect = zeros(size(all_angles,1), 2); 
% 
% %Loop through all of the lower bounds of the neighbor regimes 
% for k = 1:size(bounds,2)
%     %Find where all of the places that the orientation angle is greater
%     %than or equal to the lower bound of each regime
%     [temp_pos, ~ ] = find(all_angles >= bounds(k));  
%     
%     %Set the poisitions of the forward and reverse neighbors
%     n_connect(temp_pos, 1) = fwd_n(k); 
%     n_connect(temp_pos, 2) = bwd_n(k); 
%     
%     %Set all of the temp positions equal to NaN so that they will not be
%     %included in futher analysis. 
%     all_angles(all_angles >= bounds(k)) = NaN; 
%     
%     %Clear temp positions 
%     clear temp_pos 
% end 
% 
% %Find the connecitivity postions in the adjacent directions 
% %For example: n8<-n1->n2, n1<-n2->n3, ..., n6<-n7-> n8, n7<-n8-> n1
% 
% %Find the candidate neighbors. The order of the candidate neighbors: 
% %fwdnn-1, fwdnn, fwdnn+1, bwdnn-1, bwdnn, bwdnn+1
% n_candidates = 6; 
% candidate_neighbors = zeros(size(all_angles,1), n_candidates); 
% 
% %Repeat the values to add to the candidate matrix values 
% pm_values = [-1, 0, 1]; 
% pm_values = repmat(pm_values, [1,2]); 
% pm_values = repmat(pm_values, [size(all_angles,1), 1]); 
% 
% %Copy the forward and reverse connectivity matrix into the candidate matrix
% for g = 1:3
%     candidate_neighbors(:, g) = n_connect(:, 1); 
%     candidate_neighbors(:, 3+g) = n_connect(:, 2); 
% end 
% 
% %Add the plus / minus values to the candidate neighbors
% candidate_neighbors = bsxfun(@plus, candidate_neighbors, pm_values); 
% 
% %Correct edge cases (n8<-n1->n2 and n7<-n8-> n1)
% candidate_neighbors(candidate_neighbors == 0) = 8; 
% candidate_neighbors(candidate_neighbors == 9) = 1; 
candidate_neighbors =[]; 
end

