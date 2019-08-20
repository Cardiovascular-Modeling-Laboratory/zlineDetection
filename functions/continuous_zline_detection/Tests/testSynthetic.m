% Prompt the user to load the synthetic test cases
[ syn_file, syn_path, ~ ] = ...
    load_files( {'*czl_testcases*.mat'}, ...
    'Select test cases .mat file ...', pwd,'off');

%% Clear command line
clc; 

% Load the data
synthetic_data = load(fullfile(syn_path{1}, syn_file{1})); 

% Store variable names 
true_distances = synthetic_data.true_distances;
syn_positions = synthetic_data.syn_positions;
syn_angles = synthetic_data.syn_angles;
description_txt = synthetic_data.description_txt;

% Set the dot product error 
dot_product_error = 0.90; 
% Get the number of synthetic cases, 
num_cases = size(true_distances,1); 

% Initialize cells to hold all of the results 
all_correct = cell(num_cases,1); 
all_zlines = cell(num_cases,1); 
all_dps = cell(num_cases,2); 
all_order = cell(num_cases,1); 

% Start timer
tic; 

% Loop through all of the 
for c = 1:num_cases
    % Store positions, orientation vectors
    positions = syn_positions{c,1}; 
    BW = positions; 
    orientim = syn_angles{c,1}; 
    angles = orientim;
    
    [ CZL_results, CZL_info ] = continuous_zline_detection( angles, BW, ...
    dot_product_error ); 
    
    close all; 
    
    % Store the positiosn 
    dp_rows = CZL_info.recip_rows; 
    dp_cols = CZL_info.recip_cols; 
    
    % Get the number of non-zero pixles 
    num_nz = size(dp_rows,1); 
    
    % Create every possible ordering of the dp values 
    poss_comb = factorial(num_nz);
    v = 1:num_nz;
    all_perms = perms(v); 

    % Initialize storage matrices
    all_zs = cell(poss_comb,1); 
    correctgroup = zeros(poss_comb,1); 
   
    % Store the true distances
    true_dist = true_distances(c,1); 
    descript_case = description_txt{c,1}; 
    %  Create the dot product row and columns based on the current permutation 
    for k = 1:poss_comb
        % Create the new dp pairngs
        perm_dprows = zeros(size(dp_rows)); 
        perm_dpcols = zeros(size(dp_cols));

        % Loop through and order the dot prodcuts 
        for o = 1:num_nz
            perm_dprows(o,:) = dp_rows(all_perms(k,o),:); 
            perm_dpcols(o,:) = dp_cols(all_perms(k,o),:); 
        end 
    
        %Cluster the values in order.  
        [ zline_clusters, cluster_tracker ] = ...
            cluster_neighbors( dot_product_error, angles, ...
            perm_dprows, perm_dpcols);
        
        [ distance_storage, rmCount, all_zs{k,1} ] = ...
            calculate_lengths( BW, zline_clusters);
        
        close all; 
        distance_storage_nonan = distance_storage; 
        distance_storage_nonan(isnan(distance_storage_nonan)) = []; 
        % If the distance storage has more than one value it's wrong 
        if length(distance_storage_nonan) > 1
            correctgroup(k,1) = 0; 
        else
            if distance_storage_nonan == true_dist
                correctgroup(k,1) = 1;
            else
                correctgroup(k,1) = 0;
            end 
        end 

    end 

    disp(toc); 
    % Display results 
    cas_disp = strcat('Case ',{' '}, num2str(c), ':', {' '},descript_case); 
    disp(cas_disp{1}); 
    acc_val = (sum(correctgroup)/length(correctgroup))*100; 
    disp(strcat('Accuracy:  ', num2str(acc_val), '%')); 

    % Store the clusters, the correct group positions, and the clusters
    all_correct{c,1} = correctgroup; 
    all_zlines{c,1} = all_zs; 
    all_order{c,1} = all_perms; 
end
