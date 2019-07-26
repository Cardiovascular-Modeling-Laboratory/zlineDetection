function [ cluster_tracker, zline_clusters, clusterCount, ...
    ignored_cases ] = ...
    combine_clusters( cluster_tracker, zline_clusters, clusterCount, ...
    cluster_value, temp_cluster, ignored_cases, dp_rows, dp_cols )
%This function will combine two clusters into one

%Distance anonymous function 
dist = @(x1,x2,y1,y2) sqrt((x1-x2)^2 + (y1-y2)^2);

%Create a matrix to store the start and stop positions of the two
%neighboring clusters 
cn = ones(1,4); 

%Store the first cluster and get the size
d1_cval = cluster_value(1); 
dir1_cluster = zline_clusters{ d1_cval, 1 };
[cn(2), ~] = size(dir1_cluster); 

%Store the second cluster and get the size 
d2_cval = cluster_value(end); 
dir2_cluster = zline_clusters{ d2_cval, 1 };
[cn(4), ~] = size(dir2_cluster); 

%Store sizes of the set neighbors
dp = [1;length(dp_rows)]; 

%Save the size of the temporary cluster
temp_max = size(temp_cluster,1); 

%Initialize a matrix to store the distances between both neighbors and the
%start and stop positions of both neighboring clusters
distances = zeros(2,4);

%Calculating distance, which will be in the following form: 
%   dir1_start dir2_end dir2_start dir2_end
%dp1
%dp2
for d = 1:2
    for c = 1:2
        %Direction 1:
        distances(d,c) = dist( dp_rows(dp(d)), dir1_cluster(cn(c), 1), ...
             dp_cols(dp(d)), dir1_cluster(cn(c),2) );
        %Direction 2:
        distances(d,c+2) = ...
            dist( dp_rows(dp(d)), dir2_cluster(cn(c+2), 1), ...
            dp_cols(dp(d)), dir2_cluster(cn(c+2),2) );
    end
end 


%Check to make sure the middle cluster is not perpendicular on either side
% Direction 1 
if cn(2) > 1 && temp_max >= 1 
    isPerpdir1 = check_perpendicular(...
        [dir1_cluster(cn(2)-1, 1),dir1_cluster(cn(2)-1, 2)], ...
        [temp_cluster(1,1),temp_cluster(1,2)] ); 
else
    isPerpdir1 = false; 
end 

% Direction 2
if cn(4) >= 2 && temp_max >= 1 
    isPerpdir2 = check_perpendicular(...
        [dir2_cluster(2, 1),dir2_cluster(2, 2)], ...
            [temp_cluster(temp_max,1),temp_cluster(temp_max,2)] ); 
else
    isPerpdir2 = false; 
end 


%NOTE: it is possible that some of the clusters should be sorted in
%opposite direction (ex: cluster = cluster(end:1, :)) in order to optimize
%the order. However the reason that the order is flipped is usually because
%the lines are in different directions. 
%For now set it to be a very simple case 


%If the distances between (below) are nonzero don't combine the matrices
%(1.) dir1 cluster (end) & dp_rows(1)dp_cols(1)
%(2.) dir2 cluster (1) & dp_rows(end)dp_cols(end)

% if distances(1,2) == 0 && distances(2,3) == 0
if distances(1,2) <= sqrt(2) && distances(2,3) <= sqrt(2) ...
        && ~isPerpdir1 && ~isPerpdir2

    %Increase clusterCount
    clusterCount = clusterCount + 1; 


    %Create a new row in the cell array zline_clusters 
    %and order the new cluster based on the order of  
    %the cluster values
    zline_clusters{clusterCount, 1} = ...
        [zline_clusters{ cluster_value(1), 1 }; ...
        temp_cluster; ...
        zline_clusters{ cluster_value(end), 1 }]; 


    %Set the previous clusters to NaN 
    zline_clusters{ cluster_value(1), 1 } = NaN; 
    zline_clusters{ cluster_value(end), 1 } = NaN; 

    %Update the tracker 
    cluster_tracker = ...
        update_tracker( zline_clusters, ...
        cluster_tracker, clusterCount ); 
else
    ignored_cases = ignored_cases + 1; 
end 

end

