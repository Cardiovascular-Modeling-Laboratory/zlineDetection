function [ cluster_tracker ] = update_tracker( zline_clusters, ...
    cluster_tracker, clusterCount )
%This function will update the cluster tracker

%Get a matrix of the positions in the zline cluster 
cluster_values = zline_clusters{clusterCount, 1}; 

%Loop through all of the cluster values 
for cv = 1:size(cluster_values, 1)
    
    %Update all of the values in the cluster tracker to be the value of the
    %clusterCount
    cluster_tracker( cluster_values(cv,1), ...
        cluster_values(cv,2) ) =  clusterCount; 

end

end

