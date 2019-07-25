function [ cluster_tracker, zline_clusters, ignored_cases ] = ...
    add_to_cluster( bin_clusters, cluster_value_nan,...
    unique_nz, temp_cluster, cluster_tracker, zline_clusters, ...
    ignored_cases, class_set)
%This function will add unassigned cluster (temp_cluster) to the existing
%cluster (zline_clusters) at position unique_nz

%This is done for
%CASE 2: 
% CASE 2-1: a 0 0 
% CASE 2-2: 0 0 a 
%CASE 3: 
% CASE 3-1: a a 0
% CASE 3-2: 0 a a 


%Check which direction has been assigned.
%Check to make sure that the distance between the old & new clusters is 0. 

%Store the values of the old cluster
old_cluster = zline_clusters{unique_nz, 1};

%Get the size of the old cluster, classifying cluster, and the temporary
%cluster
cc_max = size(class_set,1);
oc_max = size(old_cluster,1);
temp_max = size(temp_cluster,1); 
% %Store the x and y values 
% %[start, end]
% new_dim1 = [ new_cluster(1,1), new_cluster(nc_max, 1)]; 
% new_dim2 = [ new_cluster(1,2), new_cluster(nc_max, 2)]; 
% 
% old_dim1 = [ old_cluster(1,1), old_cluster(oc_max, 1)]; 
% old_dim2 = [ old_cluster(1,2), old_cluster(oc_max, 2)]; 

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
    
    % Determine the position of the closest assigner. 
    % Get the assigner neighbor that is closest to the temp_cluster
    closest_assigner = class_set(cp,:);
    
    % Find where the closest class set is in the old cluster
    row_match = zeros(1,size(old_cluster,1)); 
    row_match(old_cluster(:,1) == closest_assigner(1,1)) = 1; 
    col_match = zeros(1,size(old_cluster,1));
    col_match(old_cluster(:,2) == closest_assigner(1,2)) = 1; 
    coord_match = row_match.*col_match; 
    
    % Get the position of the closest assginer 
    mp = find(coord_match == 1); 
    
    % Initialize onTop boolean statement 
    atTop = NaN; 
    
    % Determine the location of the nearest neighbor 
    if mp == 1
        atTop = true; 
    elseif mp == size(old_cluster,1)
        atTop = false; 
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
   
   
    % Place the newest cluster
    if atTop
        %Put the temporary cluster before the previously assigned cluster                      
        zline_clusters{unique_nz, 1} = ...
            [temp_cluster; zline_clusters{unique_nz, 1}];
        %Update the cluster tracker 
        cluster_tracker = update_tracker( zline_clusters, ...
            cluster_tracker, unique_nz );  
        
    elseif ~atTop
        %Put the temporary cluster after the previously assigned cluster  
        zline_clusters{unique_nz, 1} = ...
            [zline_clusters{unique_nz, 1}; temp_cluster];

        %Update the cluster tracker 
        cluster_tracker = update_tracker( zline_clusters, ...
            cluster_tracker, unique_nz );        
    end 
    
    
else
    % Update ignored cases 
    ignored_cases = ignored_cases + 1; 
end 


% % CASE 2-1: a 0 0 
% % CASE 3-1: a a 0
% if isnan( bin_clusters(1) ) && ~isnan(cluster_value_nan(1))
%     
%     %Calculate distance between old and new dimensions
%     x_values = [ old_cluster(oc_max, 1), class_set(1,1) ];
%     y_values = [ old_cluster(oc_max, 2), class_set(1,2) ];
%     
%     %Caclulate the distance.
%     dist = coordinate_distances( x_values, y_values);
%     
%     %Check to make sure that this new neighbor is not perpendicular to a
%     %point already in the cluster 
%     if oc_max > 1 && temp_max >= 1 
%         %Check to see if the new neighbor is perpendicular to its neighbors
%         %neighbor
%         isPerp = check_perpendicular( ...
%             [old_cluster(oc_max-1, 1),old_cluster(oc_max-1, 2)], ...
%             [temp_cluster(1,1),temp_cluster(1,2)]  ); 
%     else 
%         isPerp = false; 
%     end 
%     
%     if dist(1,2) == 0 && ~isPerp
%         %If dir1 was previously assigned, put the temporary
%         %cluster after the previously assigned cluster  
%         zline_clusters{unique_nz, 1} = ...
%             [zline_clusters{unique_nz, 1}; temp_cluster];
% 
%         %Update the cluster tracker 
%         cluster_tracker = update_tracker( zline_clusters, ...
%             cluster_tracker, unique_nz );                     
%     else
%         ignored_cases = ignored_cases + 1;
%     end 
% 
% % CASE 2-2: 0 0 a 
% % CASE 3-2: 0 a a 
% elseif  isnan( bin_clusters(3) ) &&  ~isnan(cluster_value_nan(3))
%     
%     %Calculate distance between old and new dimensions
%     x_values = [ old_cluster(1, 1), class_set(cc_max,1) ];
%     y_values = [ old_cluster(1, 2), class_set(cc_max,2) ];
%     
%     %Caclulate the distance.
%     dist = coordinate_distances( x_values, y_values);
%     
%     %Check to make sure that this new neighbor is not perpendicular to a
%     %point already in the cluster 
%     if oc_max >= 2 && temp_max >= 1 
%         %Check to see if the new neighbor is perpendicular to its neighbors
%         %neighbor
%         isPerp = check_perpendicular( ...
%             [old_cluster(2, 1),old_cluster(2, 2)], ...
%             [temp_cluster(temp_max,1),temp_cluster(temp_max,2)] ); 
%     else 
%         isPerp = false; 
%     end 
%     
%     if dist(1,2) == 0 && ~isPerp
%         %If dir2 was previously assigned, put the temporary
%         %cluster before the previously assigned cluster                      
%         zline_clusters{unique_nz, 1} = ...
%             [temp_cluster; zline_clusters{unique_nz, 1}];
% 
%         %Update the cluster tracker 
%         cluster_tracker = update_tracker( zline_clusters, ...
%             cluster_tracker, unique_nz );                     
%     else
%         ignored_cases = ignored_cases + 1;
%     end                                    
% 
% end

end

