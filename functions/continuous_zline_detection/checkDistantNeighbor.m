function [id_dp, dps] = ...
    checkDistantNeighbor(temp_cluster, ...
    atTop, dp_thresh, angles, cluster1, cluster2)

% Check if there are one or two clusters 
if nargin < 6
    %Ignore the second cluster
    oneCluster = true; 
    cluster2 = NaN; 
end 

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
    
    % The identifying information will be a 2xnc vector that contains the
    % (1) identifying cluster 0-temp 1-cluster1, 2-cluster2 and (2) the
    % position in that cluster (3) identifying cluster (4) the position in
    % that cluster 
    id_dp = zeros(4,nc); 
    dps = zeros(1,nc); 
    
    
    theta_ct = angles(temp_cluster(1,close_temp), ...
        temp_cluster(1,close_temp)); 
    theta_a1c1 = angles(cluster1(1,away1_cluster1), ...
        cluster1(1,away1_cluster1)); 
    
    % Identify the cluster and corresponding positions in the id matrix 
    id_dp(1,1) = 0; 
    id_dp(3,1) = 1; 
    id_dp(2,1) = close_temp; 
    id_dp(4,1) = away1_cluster1; 
    
    % Calculate the dot product 
    dps(1,1) =sqrt(cos(theta_ct-theta_a1c1)^2);  
    
    % If there is more than one vector in teh temporary array, compute the
    % dot products 
    if temp_num > 1
        % Look up the oreientation vectors
        theta_a1t = angles(temp_cluster(1,away1_temp), ...
            temp_cluster(1,away1_temp)); 
        theta_cc1 = angles(cluster1(1,close_cluster1), ...
                cluster1(1,close_cluster1));
            
        % Identify the cluster
        id_dp(1,2) = 0; 
        id_dp(3,2) = 1; 
        % Corresponding positions in the id matrix 
        id_dp(2,2) = away1_temp; 
        id_dp(4,2) = close_cluster1;       
        % Compute the dot product. 
        dps(1,2) = sqrt(cos(theta_a1t-theta_cc1)^2); 
        
        % Identify the cluster
        id_dp(1,3) = 0; 
        id_dp(3,3) = 0; 
        % Corresponding positions in the id matrix 
        id_dp(2,3) = close_temp; 
        id_dp(4,3) = away1_temp; 
        % Compare the close temp theta value with the far temp theta value
        dps(1,3) = sqrt(cos(theta_ct-theta_a1t)^2);
        
        % Identify the cluster
        id_dp(1,4) = 0; 
        id_dp(3,4) = 1; 
        % Corresponding positions in the id matrix 
        id_dp(2,4) = close_temp; 
        id_dp(4,4) = away1_cluster1; 
        % Compare the close temp theta value with the close cluster 1 
        % theta value
        dps(1,4) = sqrt(cos(theta_ct-theta_cc1)^2); 
                    
    end 
end 
        
end 

