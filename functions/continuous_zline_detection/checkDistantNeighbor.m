function [neigh2_struct] = ...
    checkDistantNeighbor(dp_thresh, temp_cluster, ...
    atTop, angles, cluster1, cluster2)

% Check if there are one or two clusters 
if nargin < 6
    %Ignore the second cluster
    oneCluster = true; 
    cluster2 = NaN; 
else
    oneCluster = false; 
end 

% Create a struct to store all of the neighbor information 
neigh2_struct = struct(); 

% Get the size of the current cluster and the temp_cluster
[ temp_num, ~ ] = size(temp_cluster); 

% Initialize shouldIgnore
shouldIgnore = false; 

% If there is only one cluster and there are no values in the temporary
% cluster, ignore this case
if oneCluster && temp_num == 0
    shouldIgnore = true; 
end 

% Get the size of the current cluter 
[ c1_num, ~] = size(cluster1); 

% If there is only one value in the cluster something is wrong 
if c1_num < 2 
    shouldIgnore = true; 
end 

% If there is only one value in the cluster something is wrong 
if ~oneCluster
    [~, c2_num ] = size(cluster2);
    if c2_num < 2 
        shouldIgnore = true; 
    end 
end 

% If there is only one cluster and there is no reason to ignore the
% temporary cluster, find the positions of the neighbors 
if  oneCluster && ~shouldIgnore 
    % Store the number of positions in the temporary cluster
    neigh2_struct.temp_num = temp_num; 
    
    if ~atTop 
        % Find the positions of the closest and one away positions 
        close_temp = 1; 
        away1_temp = 2; 
        close_cluster1 = c1_num-1; 
        away1_cluster1 = c1_num; 
    else
        % Find the positions of the closest and one away positions 
        close_temp = temp_num; 
        away1_temp = temp_num - 1; 
        close_cluster1 = 1; 
        away1_cluster1 = 2; 
    end
    
    % Get the angles 
    theta_ct = angles(temp_cluster(close_temp,1), ...
        temp_cluster(close_temp,2)); 
    theta_a1c1 = angles(cluster1(away1_cluster1,1), ...
        cluster1(away1_cluster1,2));
    
    % Calculate the dot product 
    neigh2_struct.tc_z1a =sqrt(cos(theta_ct-theta_a1c1)^2);  
    
    % If there is more than one vector in teh temporary array, compute the
    % dot products 
    if temp_num > 1
        % Look up the oreientation vectors
        theta_a1t = angles(temp_cluster(away1_temp,1), ...
            temp_cluster(away1_temp,2)); 
        theta_cc1 = angles(cluster1(close_cluster1,1), ...
                cluster1(close_cluster1,2));
                 
        % Compute the dot product. 
        neigh2_struct.ta_z1c  = sqrt(cos(theta_a1t-theta_cc1)^2); 
        
        % Compare the close temp theta value with the far temp theta value
        neigh2_struct.tc_ta = sqrt(cos(theta_ct-theta_a1t)^2);
        
        % Compare the close temp theta value with the close cluster 1 
        % theta value
        neigh2_struct.tc_z1c = sqrt(cos(theta_ct-theta_cc1)^2); 
        
        % Save the position of the closest cluster
        neigh2_struct.close_temp = close_temp; 
    end 
end 

% There should only be one value in the temporary array. 
if ~oneCluster && temp_num > 1
    shouldIgnore = true; 
    disp('Something went wrong. There should only be one value in the temporary array.'); 
end 
    
% If there are two cluster and there is no reason to ignore the
% temporary cluster, find the positions of the neighbors 
if  ~oneCluster && ~shouldIgnore 
    
    % Initialize a logical to join all as expected
    neigh2_struct.joinAll = true; 
    % Initalize logials for which neighbor to join and don't join to false
    neigh2_struct.dontJoin = false; 
    neigh2_struct.joinTop = false; 
    neigh2_struct.joinBottom = false; 
    
    % Get the angle values for the two clusters
    theta_z1c = angles(cluster1(c1_num,1), cluster1(c1_num,2));
    theta_z1a = angles(cluster1(c1_num-1,1), cluster1(c1_num-1,2));
    theta_z2c = angles(cluster2(1,1), cluster2(1,2));
    theta_z2a = angles(cluster2(2,1),cluster2(2,2));
    
    % If there are no values in the temporary matrix compare:
    % (1) close cluster 1 and its second neighbor in cluster 2 
    % (2) close cluster 2 and its second neighbor in cluster 1 
    % if either are false, don't join 
    if temp_num == 0 
        if sqrt(cos(theta_z1c-theta_z2a)^2) < dp_thresh || ...
                sqrt(cos(theta_z1a-theta_z2c)^2) < dp_thresh
            % Set join all to false and don't join to true. 
            neigh2_struct.joinAll = false; 
            neigh2_struct.dontJoin = true; 
        end 
    else
        % Get the first value in the temporary cluster
        theta_t = angles(temp_cluster(1,1), temp_cluster(1,2));
        
        % Compare top temp with secondary neighbor in cluster 1
        dpt_z1a = sqrt(cos(theta_t-theta_z1a)^2); 
        % Compare top temp with secondary neighbor in cluster 2
        dpt_z2a = sqrt(cos(theta_t-theta_z2a)^2);     
        
        % Compare top with cluster 1 
        if dpt_z1a >= dp_thresh
            neigh2_struct.joinTop = true; 
        end
        % Compare top with cluster 2
        if dpt_z2a >= dp_thresh
            neigh2_struct.joinBottom = true;
        end 
        % If both join top and join bottom are false, don't join either
        if ~neigh2_struct.joinTop && ~neigh2_struct.joinBottom
            neigh2_struct.joinAll = false; 
            neigh2_struct.dontJoin = true; 
        end
        % Set join all to true if both join top and join bottom are
        % true 
        neigh2_struct.joinAll = neigh2_struct.joinTop && ...
            neigh2_struct.joinBottom;
    end 
    
    
end 

% Set the neighbor2 struct to zero 
if shouldIgnore 
    neigh2_struct.shouldIgnore = true; 
else
    neigh2_struct.shouldIgnore = false; 
end 
        
end 

