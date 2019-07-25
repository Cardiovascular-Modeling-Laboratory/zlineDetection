function [ zline_clusters , cluster_tracker, ignored_cases ] = ...
    cluster_neighbors( dp_rows, dp_cols, m, n, tphase)
%This function will cluster the orientation vectors into "continuous
%z-lines" based on their position and their orientation angle. 

%Description of different cases. 

%CASE 1: No assigned clusters 
% 0 0 0 

%CASE 2: One assigned cluster
% CASE 2-1: a 0 0 - Add to cluster 
% CASE 2-2: 0 0 a - Add to cluster  
% CASE 2-3: 0 a 0 - Ignore case 

%CASE 3: Two assigned same clusters
% CASE 3-1: a a 0 - Add to cluster 
% CASE 3-2: 0 a a - Add to cluster
% CASE 3-3: a 0 a - Ignore 

%CASE 4: Two assigned different clusters
% CASE 4-1: a b 0 - Ignore 
% CASE 4-2: 0 a b - Ignore 
% CASE 4-3: a 0 b - Combine all into new cluster

%CASE 5: All three assigned 
% CASE 5-1: a b b / a a b - Combine all into new cluster
% CASE 5-2: b a b - Not sure how to handle this / Ignore
% CASE 5-3: a b c - Ignore 
% CASE 5-4: a a a - Ignore

% Add testing phase and set the default to be false
if nargin < 5
    tphase = false; 
end 

%Storage matrix to update whether a position has been assigned to a cluster
cluster_tracker = zeros(m,n); 
            
%Intialize a cell array that will store all of the clusters
zline_clusters = {}; 

%Counter count 
clusterCount = 0; 

%Counter for ignored cases
ignored_cases = 0; 

%Loop through all of the nonzero orientation angles and assign them to a
%cluster. 
for k = 1:size(dp_rows, 1)
    
    %Determine the number and position of the nan values 
    %Row positions:
    [~, r_nan] = find( isnan( dp_rows(k,:) ) ); 
    %Col positions:
    [~, c_nan] = find( isnan( dp_cols(k,:) ) ); 
    
    %Find where all of the NaN values are. 
    all_nan_pos = unique( [r_nan; c_nan] ); 
    
    %Set all of the NaN positions equal to zero in a storage matrix 
    nan_positions = zeros( 1, size(dp_rows,2) ); 
    
    for nn = 1:length(all_nan_pos) 
        nan_positions( 1, all_nan_pos( nn ) ) = NaN; 
    end 
    
    %Move onto the next set (ni1, vi, ni2) if any of the following are
    %true:
    %(1) The orientation vector vi is NaN 
    %(2) Both of the neighbors are NaN    
    
    %Check value of orientation vector 
    if isnan( nan_positions(1,2) )
        nextVi = true; 
    
    %Check value of the nearest neighbors
    elseif isnan( nan_positions(1,1) ) && isnan( nan_positions(1,3) )
        nextVi = true; 
    
    else
        nextVi = false; 
            
    end  
    
    
    %Continue with analysis only if we should not move onto the next
    %orientation vector based on the positions of the NaN values. 
    if ~nextVi
         
        %Determine cluster classification information. See function for
        %more details 
        [ cluster_value_nan, bin_clusters, cluster_value, ...
            unique_nz, case_num, second_case] = ...
            determine_case( nan_positions, dp_rows(k,:), dp_cols(k,:), ...
            cluster_tracker ); 
        
        %Get the positions of the set that are assigned to a cluster
        class_set = get_assigner( dp_rows(k,:), dp_cols(k,:), ...
            cluster_value_nan);
        
%CASE 1:     No assigned clusters. Add all non-NaN values to a new cluster        
        if case_num == 1
            %Increase cluster count 
            clusterCount = clusterCount + 1; 

            %Add all of the non NaN values to a new row in cluster tracker
            zline_clusters{clusterCount, 1} = ...
                create_cluster( dp_rows(k,:), dp_cols(k,:)); 

            %Update the cluster tracker
            [ cluster_tracker ] = update_tracker( zline_clusters, ...
                cluster_tracker, clusterCount );  

%CASES 2 - 4: Create a temporary cluster from the unassigned values         
        elseif case_num > 1 && case_num < 5
            %Determine the values that are not assigned to a cluster
            not_assigned_row = bsxfun(@times, dp_rows(k,:),...
                bin_clusters);
            not_assigned_cols = bsxfun(@times, dp_cols(k,:),...
                bin_clusters);
            
            %Create a temporary cell with all of the unassigned
            %values 
            temp_cluster = create_cluster( not_assigned_row, ...
                not_assigned_cols );

% CASE 2: One assigned value 
            if case_num == 2             
                
% CASE 2-3: 0 a 0 - Do not add to any cluster                                
                if isnan( bin_clusters(2) )
                    
                    ignored_cases = ignored_cases + 1;   
                
                else
% CASE 2-1: a 0 0 - Add to cluster
% CASE 2-2: 0 0 a - Add to cluster

                    %Add to cluster 
                    [ cluster_tracker, zline_clusters, ...
                        ignored_cases ] = add_to_cluster( bin_clusters,...
                        cluster_value_nan, unique_nz, temp_cluster, ...
                        cluster_tracker, zline_clusters, ignored_cases,...
                        class_set); 
                end 

%CASE 3 or 4 
            else 
%CASE 3: Two assigned same clusters
                if case_num == 3
                    
% CASE 3-3: a 0 a - Do not add to any cluster 
                    if second_case == 3

                        ignored_cases = ignored_cases + 1;

% CASE 3-1: a a 0 - Add to cluster
% CASE 3-2: 0 a a - Add to cluster 
                    elseif second_case == 1

                        %Add to cluster 
                        [ cluster_tracker, zline_clusters, ...
                            ignored_cases ] = ...
                            add_to_cluster( bin_clusters,...
                            cluster_value_nan,unique_nz, temp_cluster, ...
                            cluster_tracker, zline_clusters, ...
                            ignored_cases, class_set);
                    end 
                    
%CASE 4: Two assigned different clusters
                else

% CASE 4-1: a b 0 - Do not add to any cluster 
% CASE 4-2: 0 a b - Do not add to any cluster  
                    if second_case == 1 || second_case == 2
 
                       ignored_cases = ignored_cases + 1;

% CASE 4-3: a 0 b 
                    else
                    
                        %Create a new cluster by combining the clusters by
                        %their directional order. Set previous clusters
                        %equal to NaN 
                        [ cluster_tracker, zline_clusters, ...
                            clusterCount, ignored_cases] = ...
                            combine_clusters( ...
                            cluster_tracker, zline_clusters, ...
                            clusterCount, cluster_value, ...
                            temp_cluster, ignored_cases, ...
                            dp_rows(k,:), dp_cols(k,:) );
                    end
                    
                
                end 
            end 

        else 
%NO CASE
            if case_num ~= 5
                disp('Something went wrong, not identified as any case.');

%CASE 5   
            else 
                
% CASE 5-1: a b b / a a b - Combine all into new cluster
                if second_case == 1
                    %Set the temporary cluster equal to an empty matrix
                    temp_cluster = []; 
                        
                    %Create a new cluster by combining the clusters by
                    %their directional order. Set previous clusters
                    %equal to NaN 
                    [ cluster_tracker, zline_clusters, ...
                        clusterCount, ignored_cases ] = ...
                        combine_clusters( ...
                        cluster_tracker, zline_clusters, ...
                        clusterCount, cluster_value, ...
                        temp_cluster, ignored_cases, ...
                        dp_rows(k,:), dp_cols(k,:) ); 
                    
% CASE 5-2: b a b - Not sure how to handle this / Ignore
% CASE 5-3: a b c - Ignore

                else 
                    ignored_cases = ignored_cases + 1;
                end 
            end 
        end 
        
        if tphase 
            % Open a figure 
            figure; 
            % Visualize the latest cluster and store the case number and
            % display cluster
            tot_cluster = max(max(cluster_tracker)); 
            imagesc(cluster_tracker);
            hold on;
            plot(dp_cols(:,2), dp_rows(:,2), 's', 'MarkerSize', 10,...
                'color', 'black')
            for hh = 1:tot_cluster
                hold on;
                temp_plot = zline_clusters{hh};
                if isnan(temp_plot)
                    disp(['Cluster ', num2str(hh), ' is NaN.']); 
                else 
                plot(temp_plot(:,2), temp_plot(:,1), '-.','color', 'red')
                end
                clear temp_plot
            end 
            % Add title 
            title_message = strcat('Iteration Number: ',{' '}, num2str(k),...
                {' '}, 'Case: ',num2str(case_num), '-', num2str(second_case));
            title(title_message{1},'FontSize',16, 'FontWeight','bold' ); 
        end 
        
    end 
end 

end

