% determine_case - This function will compute essential information to
% group of set of nonzero orientation vectors (vi) and their nearest 
% neighbors (ni1, ni2) into continuous lines. 
%
% An essential step is determining the case of a set (ni1, vi, ni2)
%   CASE 1: No assigned clusters 
%       0 0 0 
%   CASE 2: One assigned cluster
%       CASE 2-1: a 0 0 - Add to cluster 
%       CASE 2-2: 0 0 a - Add to cluster  
%       CASE 2-3: 0 a 0 - Ignore case 
%   CASE 3: Two assigned same clusters
%       CASE 3-1: a a 0 - Add to cluster 
%       CASE 3-2: 0 a a - Add to cluster
%       CASE 3-3: a 0 a - Ignore 
%   CASE 4: Two assigned different clusters
%       CASE 4-1: a b 0 - Ignore 
%       CASE 4-2: 0 a b - Ignore 
%       CASE 4-3: a 0 b - Combine all into new cluster
%   CASE 5: All three assigned 
%       CASE 5-1: a b b / a a b - Combine all into new cluster
%       CASE 5-2: b a b - Ignore
%       CASE 5-3: a b c - Ignore 
%       CASE 5-4: a a a - Ignore
%
% Usage:
%   [ cluster_info] = ...
%       determine_case( nan_positions, rows, cols, cluster_tracker )
%
% Arguments:
%   nan_positions       - positions in the set that 
%                           Class Support: 3x1 logical
%   rows                - the row position of the current set in the
%                           original image 
%                           Class Support: 3 x 1 matrix 
%   cols                - the column position of the current set in the 
%                           original image 
%                           Class Support: 3 x 1 matrix 
%   cluster_tracker     - matrix that tracks the cluster assignment of each
%                           pixel
%                           Class Support: m x n matrix
% Returns:
%   cluster_info        - struct which contains the following fields: 
%                           Class Support: STRUCT
%   cluster_value_nan   - the values of the cluster tracker at the
%                           positions in the set
%                           Class Support: 
%   bin_clusters        - positions that have already been assigned to a
%                           cluster are set to NaN, otherwise, they are 1
%                           Class Support: 
%   cluster_value       - cluster values with no NaN values 
%                           Class Support: 
%   case_num            - primary case number (see above)
%                           Class Support: nonzero integer 
%   second_case         - secondary case number (see above)
%                           Class Support: nonzero integer
%   unique_nz           - unique clusters 
%                           Class Support: 
%
% Dependencies: 
%   MATLAB Version >= 9.5 
%
% Tessa Morris
% Advisor: Anna Grosberg, Department of Biomedical Engineering 
% Cardiovascular Modeling Laboratory 
% University of California, Irvine 
function [ cluster_info] = ...
    determine_case( nan_positions, rows, cols, cluster_tracker )
        
%Find the value of the cluster tracker at each position that is a
%number. If the value of either neighbor is NaN, set the cluster
%tracker value equal to NaN. 
cluster_value_nan = zeros(1,size(rows, 2));
        
for d = 1:size(rows, 2)

    %Determine if the value at the position is NaN or not
    if ~isnan( nan_positions(1,d) ) 
        %Save the cluster tracker value at that position 
        cluster_value_nan(d) = ...
            cluster_tracker(rows(1,d), cols(1,d));
    else 
        %If the cluster value is NaN set the value of the cluster
        %equal to NaN
        cluster_value_nan(d) = NaN;                 
    end

end

%Binary positions - mark positions that have already been added
%to a cluster equal to NaN and otherwise they should be equal
%to 1 
bin_clusters = cluster_value_nan;
bin_clusters(bin_clusters ~= 0) = NaN; 
bin_clusters(~isnan(bin_clusters)) = 1; 

%Remove all NaN positions from the clusters 
cluster_value = cluster_value_nan; 
cluster_value( isnan(cluster_value) ) = [];

%Determine number of assigned cluster values 
assigned_cluster_value = cluster_value; 
assigned_cluster_value(assigned_cluster_value == 0) = []; 
assignedCount = length(assigned_cluster_value);   

%Determine how many unique values have been assigned.
unique_nz = cluster_value; 
unique_nz(unique_nz == 0) = []; 
unique_nz = unique(unique_nz); 
uniqueCount = length(unique_nz); 

%Assign case numbers & secondary case numbers
second_case = NaN; 

if assignedCount <=1 
    case_num = assignedCount + 1;
%CASE 1
    if case_num == 1
        second_case = 0;
    else
%CASE 2: One assigned cluster
% CASE 2-1: a 0 0
        if bin_clusters(1) == 1
            second_case = 1; 
% CASE 2-2: 0 0 a 
        elseif bin_clusters(2) == 1
            second_case = 2; 
% CASE 2-3: 0 a 0 
        elseif bin_clusters(3) == 1
            second_case = 3; 
        end 
    end
    
elseif assignedCount == 2

%CASE 3: Two assigned same clusters 
    if uniqueCount == 1
        case_num = 3; 
        
    else
%CASE 4: Two assigned different clusters
        case_num = 4; 
    end
    
% CASE 3/4-1: x x 0 
    if isnan( bin_clusters(1) ) && isnan( bin_clusters(2) )
        second_case = 1; 
% CASE 3/4-2: 0 x x 
    elseif isnan( bin_clusters(2) ) && isnan( bin_clusters(3) )
        second_case = 2;
% CASE 3/4-3: x 0 x  
    elseif isnan( bin_clusters(1) ) && isnan( bin_clusters(3) )
        second_case = 3; 
    end 
else
%CASE 5: All three assigned 
    case_num = 5; 
    
% CASE 5-4: a b c
    if uniqueCount == 3
        second_case = 3; 
% CASE 5-2: b a b
    elseif cluster_value_nan(1) == cluster_value_nan(3) && ...
            cluster_value_nan(1) ~= cluster_value_nan(2)
        second_case = 2; 
% CASE 5-1: a b b / a a b - Combine all into new cluster
    elseif uniqueCount == 1
        second_case = 4;
% CASE 5-4: a a a - Ignore
    else
        second_case = 1; 
    end 
end 

% Save all information in a struct called cluster info 
cluster_info = struct(); 
cluster_info.cluster_value_nan = cluster_value_nan;
cluster_info.unique_nz = unique_nz;
cluster_info.bin_clusters = bin_clusters;
cluster_info.case_num = case_num;
cluster_info.cluster_value = cluster_value;
cluster_info.second_case = second_case;

end

