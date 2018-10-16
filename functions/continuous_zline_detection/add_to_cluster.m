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

% CASE 2-1: a 0 0 
% CASE 3-1: a a 0
if isnan( bin_clusters(1) ) && ~isnan(cluster_value_nan(1))
    
    %Calculate distance between old and new dimensions
    x_values = [ old_cluster(oc_max, 1), class_set(1,1) ];
    y_values = [ old_cluster(oc_max, 2), class_set(1,2) ];
    
    %Caclulate the distance.
    dist = coordinate_distances( x_values, y_values);
    
    %Check to make sure that this new neighbor is not perpendicular to a
    %point already in the cluster 
    if oc_max > 1 && temp_max >= 1 
        %Check to see if the new neighbor is perpendicular to its neighbors
        %neighbor
        isPerp = check_perpendicular( ...
            [old_cluster(oc_max-1, 1),old_cluster(oc_max-1, 2)], ...
            [temp_cluster(1,1),temp_cluster(1,2)]  ); 
    else 
        isPerp = false; 
    end 
    
    if dist(1,2) == 0 && ~isPerp
        %If dir1 was previously assigned, put the temporary
        %cluster after the previously assigned cluster  
        zline_clusters{unique_nz, 1} = ...
            [zline_clusters{unique_nz, 1}; temp_cluster];

        %Update the cluster tracker 
        cluster_tracker = update_tracker( zline_clusters, ...
            cluster_tracker, unique_nz );                     
    else
        ignored_cases = ignored_cases + 1;
    end 

% CASE 2-2: 0 0 a 
% CASE 3-2: 0 a a 
elseif  isnan( bin_clusters(3) ) &&  ~isnan(cluster_value_nan(3))
    
    %Calculate distance between old and new dimensions
    x_values = [ old_cluster(1, 1), class_set(cc_max,1) ];
    y_values = [ old_cluster(1, 2), class_set(cc_max,2) ];
    
    %Caclulate the distance.
    dist = coordinate_distances( x_values, y_values);
    
    %Check to make sure that this new neighbor is not perpendicular to a
    %point already in the cluster 
    if oc_max >= 2 && temp_max >= 1 
        %Check to see if the new neighbor is perpendicular to its neighbors
        %neighbor
        isPerp = check_perpendicular( ...
            [old_cluster(2, 1),old_cluster(2, 2)], ...
            [temp_cluster(temp_max,1),temp_cluster(temp_max,2)] ); 
    else 
        isPerp = false; 
    end 
    
    if dist(1,2) == 0 && ~isPerp
        %If dir2 was previously assigned, put the temporary
        %cluster before the previously assigned cluster                      
        zline_clusters{unique_nz, 1} = ...
            [temp_cluster; zline_clusters{unique_nz, 1}];

        %Update the cluster tracker 
        cluster_tracker = update_tracker( zline_clusters, ...
            cluster_tracker, unique_nz );                     
    else
        ignored_cases = ignored_cases + 1;
    end                                    

end

end

