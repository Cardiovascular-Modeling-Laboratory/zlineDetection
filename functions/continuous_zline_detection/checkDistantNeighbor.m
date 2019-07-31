function [neigh2_struct] = ...
    checkDistantNeighbor(dp_thresh, temp_cluster, ...
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
    theta_z1c = angles(cluster1(1,c1_num), cluster1(1,c1_num));
    theta_z1a = angles(cluster1(1,c1_num-1), cluster1(1,c1_num-1));
    theta_z2c = angles(cluster2(1,1), cluster2(1,1));
    theta_z2a = angles(cluster2(1,2),cluster2(1,2));
    
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
        theta_ttop = angles(temp_cluster(1,1), temp_cluster(1,1));
        
        % Compare top temp with secondary neighbor in cluster 1
        dp_ttop_z1a = sqrt(cos(theta_ttop-theta_z1a)^2); 
        % Compare top temp with secondary neighbor in cluster 2
        dp_ttop_z2a = sqrt(cos(theta_ttop-theta_z2a)^2);     
        
        % If there is only one value in the temporary array, compare it to
        % the close value on either side 
        if temp_num == 1
            % Compare top with cluster 1 
            if dp_ttop_z1a >= dp_thresh
                neigh2_struct.joinTop = true; 
            end
            % Compare top with cluster 2
            if dp_ttop_z2a >= dp_thresh
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
        elseif temp_num == 2
            %(1) Compare theta_ttop with theta_z1away
            %(2) Compare theta_ttop with theta_z2close
            dp_ttop_z2c = sqrt(cos(theta_ttop-theta_z2c)^2);   
            %(3) Compare theta_tbot with theta_z1close 
            theta_tbot = angles(temp_cluster(1,2), temp_cluster(1,2));
            dp_tbot_z1c = sqrt(cos(theta_tbot-theta_z1c)^2);    
            %(4) Compare theta_tbot with theta_z2away
            dp_tbot_z2a = sqrt(cos(theta_tbot-theta_z2a)^2);
            
            % Create logical statements 
            topJoinA = dp_ttop_z1a >= dp_thresh; 
            topJoinB = dp_ttop_z2c >= dp_thresh; 
            bottomJoinA = dp_tbot_z1c >= dp_thresh; 
            bottomJoinB = dp_tbot_z2a >= dp_thresh; 
            
            % Set all of the logical statements equal to false 
            neigh2_struct.joinAll = false; 
            neigh2_struct.dontJoin = false; 
            neigh2_struct.splitTemp = false;
            neigh2_struct.removeTop = false;
            neigh2_struct.removeBottom = false;
            neigh2_struct.joinTop = false; 
            neigh2_struct.joinBottom = false; 
            
            % Join all is only true if all are true
            if topJoinA && topJoinB && bottomJoinA && bottomJoinB
                neigh2_struct.joinAll = true; 
            else
                % Any case in which both topJoinA and bottomJoinB are 
                % false, it should not be joined
                if ~topJoinA && ~bottomJoinB
                	neigh2_struct.dontJoin = true;
                else
                    % The only case in which the the bottom and top temp 
                    % split is if top only joins A and bottom only joins B
                    if topJoinA && ~topJoinB && ~bottomJoinA && bottomJoinB 
                        neigh2_struct.splitTemp = true;
                    else
                        % Remove the top temp if it doesn't join any
                        % cluster. Set join bottom equal to true 
                        if ~topJoinA && ~topJoinB
                            neigh2_struct.removeTop = true; 
                            neigh2_struct.joinBottom = true;
                        end 
                        % Remove the bottom temp if it doesn't join any
                        % cluster. Set Join top to true 
                        if ~bottomJoinA && ~bottomJoinB
                            neigh2_struct.removeBottom = true;
                            neigh2_struct.joinTop = true; 
                        end
                        
                        % If both the top and bottom join A, then join top
                        % is true 
                        if topJoinA && bottomJoinA
                            neigh2_struct.joinTop = true; 
                        end 
                        
                        % If both the top and bottom join B, then join
                        % bottom is true
                        if topJoinB && bottomJoinB
                            neigh2_struct.joinBottom = true; 
                        end 
                    end 
                end 
            end 
            
            % If all of the conditions are false, set should Ignore equal
            % to true
            if ~neigh2_struct.joinAll && ~neigh2_struct.dontJoin && ... 
                ~neigh2_struct.splitTemp && ~neigh2_struct.removeTop && ... 
                ~neigh2_struct.removeBottom && ~neigh2_struct.joinTop && ...
                ~neigh2_struct.joinBottom
                
                shouldIgnore = true; 
                disp('Missing Case'); 
            end
            
        end 
        
    end 
    
    
end 

% Set the neighbor2 struct to zero 
if shouldIgnore 
    neigh2_struct.shouldIgnore = true; 
else
    neigh2_struct.shouldIgnore = false; 
end 
        
end 

