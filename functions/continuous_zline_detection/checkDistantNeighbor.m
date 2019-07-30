function [temp_cluster, cluster1, cluster2, shouldIgnore] = ...
    checkDistantNeighbor(temp_cluster, ...
    atTop, dp_thresh, angles, cluster1, cluster2)

% Get the size of the current cluster and the temp_cluster
[~, temp_num ] = size(temp_cluster); 

% Possibilities 
% temp_num = 2 ( d0 and d1/d2)
% temp_num = 1 ( d0/d1/d2 )
% temp_num = 0 ( combining two clusters ) 

% Check if there are one or two clusters 
if nargin < 6
    %Ignore the second cluster
    oneCluster = true; 
    cluster2 = NaN; 
end 

% Initialize shouldIgnore
shouldIgnore = false; 

% If there is only one cluster and there are no values in the temporary
% cluster, ignore this case
if oneCluster && temp_num == 0
    shouldIgnore = true; 
end 

% Get the size of the current cluter 
[~, c1_num ] = size(cluster1); 

% If there is only one value in the cluster something is wrong 
if c1_num < 2 
    shouldIgnore = true; 
end 

% Check to see if there are more than one neighbors in the temp cluster 
if temp_num == 1
    oneTemp = true; 
else
    oneTemp = false; 
end 

% This function will be used to look at the neighbors one over 
if  oneCluster && ~shouldIgnore 
    if atTop 
        % Find the positions of the closest and one away positions 
        close_temp = temp_num; 
        away1_temp = temp_num - 1; 
        close_cluster1 = 1; 
        away1_cluster1 = 2; 

    else

    end
    
    % Get the orientation angles associated with the first positions to
    % compare
    theta_ct = angles(temp_cluster(1,close_temp), ...
        temp_cluster(1,close_temp)); 
    theta_a1c1 = angles(cluster1(1,away1_cluster1), ...
        cluster1(1,away1_cluster1)); 
    
    % Compare the angles. If they're perpendicular, do not add to cluster
    if sqrt(cos(theta_ct-theta_a1c1)^2) > dp_thresh 
        % If there is only one value in the temp cluster add to the cluster
        % as is. If not, compare the next  
        if temp_num > 1
            theta_a1t = angles(temp_cluster(1,away1_temp), ...
                temp_cluster(1,away1_temp)); 
            theta_cc1 = angles(cluster1(1,close_cluster1), ...
                cluster1(1,close_cluster1)); 
            
            % If they're perpendicular, decide what to do with the
            % temporary cluster based which values are closer 
            if sqrt(cos(theta_a1t-theta_cc1)^2) <= dp_thresh 
                
                % Determine which orinetation angle the closest temp is
                % more parallel to 
                if sqrt(cos(theta_ct-theta_a1t)^2) >= ...
                        sqrt(cos(theta_ct-theta_cc1)^2)
                    shouldIgnore = true; 
                else
                    % Change the temporary cluster to only be the closest
                    % dp
                    place_temp = temp_cluster; 
                    clear temp_cluster 
                    temp_cluster = place_temp(:,theta_ct); 
                end 
            end 
            
        end 
    else
        % Do not add anything to closer 
        shouldIgnore = true; 
        
    end 
    
end 

end

