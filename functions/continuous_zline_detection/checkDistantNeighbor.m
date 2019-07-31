function [neigh2_struct] = ...
    checkDistantNeighbor(temp_cluster, ...
    atTop, angles, cluster1, cluster2)

% Check if there are one or two clusters 
if nargin < 6
    %Ignore the second cluster
    oneCluster = true; 
    cluster2 = NaN; 
end 

% Create a struct to store all of the neighbor information 
neigh2_struct = struct(); 

% Get the size of the current cluster and the temp_cluster
[~, temp_num ] = size(temp_cluster); 

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

% If there is only one cluster and there is no reason to ignore the
% temporary cluster, find the positions of the neighbors 
if  oneCluster && ~shouldIgnore 
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
    
    % Initialize a vector to store the dot products between groups
    % This is dependent on the size of the temporary cluster 
    if temp_num > 1
        nc = 4;
    else
        nc = 1; 
    end 
    
    % Get the angles 
    theta_ct = angles(temp_cluster(1,close_temp), ...
        temp_cluster(1,close_temp)); 
    theta_a1c1 = angles(cluster1(1,away1_cluster1), ...
        cluster1(1,away1_cluster1)); 
    
    % Calculate the dot product 
    neigh2_struct.tc_z1a =sqrt(cos(theta_ct-theta_a1c1)^2);  
    
    % If there is more than one vector in teh temporary array, compute the
    % dot products 
    if temp_num > 1
        % Look up the oreientation vectors
        theta_a1t = angles(temp_cluster(1,away1_temp), ...
            temp_cluster(1,away1_temp)); 
        theta_cc1 = angles(cluster1(1,close_cluster1), ...
                cluster1(1,close_cluster1));
                 
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

% Set the neighbor2 struct to zero 
if shouldIgnore 
    neigh2_struct.shouldIgnore = true; 
else
    neigh2_struct.shouldIgnore = false; 
end 
        
end 

