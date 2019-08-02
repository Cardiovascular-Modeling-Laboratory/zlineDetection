function [ cluster_tracker, zline_clusters, clusterCount,...
    ignored_cases ] = add_to_cluster( temp_cluster, cluster_tracker, ...
    zline_clusters, ignored_cases, cluster_info, dp_thresh, angles, ...
    clusterCount)
%This function will add unassigned cluster (temp_cluster) to the existing
%cluster (zline_clusters) at position unique_nz

%This is done for
%CASE 2: 
% CASE 2-1: a 0 0 
% CASE 2-2: 0 0 a 
%CASE 3: 
% CASE 3-1: a a 0
% CASE 3-2: 0 a a 

% Store all of the important cluster infomration from cluster_info 
cluster_value_nan = cluster_info.cluster_value_nan;
unique_nz = cluster_info.unique_nz;
bin_clusters = cluster_info.bin_clusters;
class_set = cluster_info.class_set; 

%Store the values of the old cluster
old_cluster = zline_clusters{unique_nz, 1};

% Initialize the position of the assigned neighbor 
cp = NaN; 

% CASE 2-1: a 0 0 
% CASE 3-1: a a 0
if isnan( bin_clusters(1) ) && ~isnan(cluster_value_nan(1))
    % Set the secondary case value equal to 1 
    secondary_case = 1; 
    % Set the position of the closest neighbor 
    cp = 1; 
    
    % Determine the primary case 
	if isnan( bin_clusters(2) )
        % Set the primary case value equal to 3
        primary_case = 3; 
        % Change the position of the closest neighbor 
        cp = 2; 
    else
        primary_case = 2; 
	end 
    
end
% CASE 2-2: 0 0 a 
% CASE 3-2: 0 a a 
if isnan( bin_clusters(3) ) &&  ~isnan(cluster_value_nan(3))
    % Set the secondary case value equal to 2 
    secondary_case = 2; 
    % Set the position of the closest neighbor 
    cp = 1; 
    
    % Determine the primary case 
	if isnan( bin_clusters(2) )
        % Set the primary case value equal to 3
        primary_case = 3; 
        % Change the position of the closest neighbor
        cp = 1; 
    else
        primary_case = 2; 
	end     
end 

% If it is none of the cases, do not add the temp_cluster to the current
% cluster. 
if ~isnan(cp)
    
    ignoreCase = false; 
    
    % Determine the position of the closest assigner. 
    % Get the assigner neighbor that is closest to the temp_cluster
    closest_assigner = class_set(cp,:);
    
    % Find where the closest class set is in the old cluster
    mp = coordinatePosition(closest_assigner(1,1), ...
        closest_assigner(1,2), old_cluster(:,1), old_cluster(:,2));
    
    % Initialize onTop boolean statement 
    atTop = NaN; 
    % Determine the location of the nearest neighbor 
    if mp == 1
        atTop = true; 
    elseif mp == size(old_cluster,1)
        atTop = false; 
    end 
    
    if isnan(atTop)
        atTop = false; 
        ignoreCase = true; 
    end
    
    
    % Initialize flipping logical statement 
    needsFlip = false; 
    
    % If the case is 2-2 and the closest neighbor is at the end (~atTop)
    % set flip equal to true 
    if primary_case == 2 && secondary_case == 2 && ~atTop 
        needsFlip = true; 
    end 
    % If the case is 2-1 and the closest neighbor is at the top (atTop)
    % set flip equal to true 
    if primary_case == 2 && secondary_case == 1 && atTop 
        needsFlip = true; 
    end 
    
    % If the temporary cluster needs to be flipped (i.e. dir2 dir0 dir1) do
    % so 
    if needsFlip 
        temp_cluster = flipud(temp_cluster); 
    end 
    
    % Compare the temp_cluster to the existing cluster 
    if ~ignoreCase
        neigh2_struct = checkDistantNeighbor(dp_thresh, temp_cluster, ...
            atTop, angles, zline_clusters{unique_nz, 1});
        
        % Set ignore case equal to true if the neigh2 struct is set to nan 
        if neigh2_struct.shouldIgnore
            ignoreCase = true;
        end 
    
    end 
    
    % Create a logical that states whether a new cluster for the current
    % temporary array should be added 
    addCluster = false; 
    
    if ~ignoreCase 
        % The first value in the matrix dps is the closest value in the
        % temporary cluster to the current cluster, compared to its second
        % neighbor in the current cluster. If these two points are
        % perpendicular, ignore the case. 
        if neigh2_struct.tc_z1a < dp_thresh
            ignoreCase = true; 
        else
            %If there is only one value in the temporary cluster, add it 
            %to the other cluster, otherwise keep comparing the other 
            %values in the cluster
            if neigh2_struct.temp_num > 1 
                % Compare the closest value in the current cluster to its
                % second neighbor in the temporary cluster. If it is
                % perpendicular, add to the cluster normally 
                if neigh2_struct.ta_z1c < dp_thresh
                    % If the two values in the temporary cluster are more
                    % parrallel to eachother than the closest value in the
                    % temporary cluster is to the closest value in the
                    % current cluser, add a cluster with just the temporary
                    % cluster, otherwise, only add the closest temporary
                    % value
                    if neigh2_struct.tc_ta >=neigh2_struct.tc_z1c
                        addCluster = true; 
                    else
                        placeholder_temp = temp_cluster; 
                        clear temp_cluster; 
                        temp_cluster = ...
                            placeholder_temp(neigh2_struct.close_temp, :); 
                    end 
                end 
            end 
        end 
    end 
   
    % Place the newest cluster
    if atTop && ~ignoreCase && ~addCluster
        %Put the temporary cluster before the previously assigned cluster                      
        zline_clusters{unique_nz, 1} = ...
            [temp_cluster; zline_clusters{unique_nz, 1}];
        %Update the cluster tracker 
        cluster_tracker = update_tracker( zline_clusters, ...
            cluster_tracker, unique_nz );  
        
    end
    
    if ~atTop && ~ignoreCase && ~addCluster
        %Put the temporary cluster after the previously assigned cluster  
        zline_clusters{unique_nz, 1} = ...
            [zline_clusters{unique_nz, 1}; temp_cluster];

        %Update the cluster tracker 
        cluster_tracker = update_tracker( zline_clusters, ...
            cluster_tracker, unique_nz );       
        
    end 
    
    % If requested, create a new cluster of just the current temporary
    % cluster
    if ~ignoreCase && addCluster
        clusterCount = clusterCount + 1; 
        zline_clusters{clusterCount, 1} = temp_cluster; 
        
        % Update the cluster tracker
        [ cluster_tracker ] = update_tracker( zline_clusters, ...
            cluster_tracker, clusterCount ); 
    end 
    
    % Update the number of ignoredCases
    if ignoreCase
        ignored_cases = ignored_cases + 1; 
    end 
    
else
    % Update ignored cases 
    ignored_cases = ignored_cases + 1; 
end 

end

