% Prompt the user to load the synthetic test cases
[ syn_file, syn_path, ~ ] = ...
    load_files( {'*czl_testcases*.mat'}, ...
    'Select test cases .mat file ...', pwd,'off');

% Clear command line
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

% Loop through all of the 
for c = 1:num_cases
    % Store positions, orientation vectors
    positions = syn_positions{c,1}; 
    BW = positions; 
    orientim = syn_angles{c,1}; 
    angles = orientim; 

% >>> Get the neighbors of all of the orientation vectors 

    %Find the nonzero positions of this matrix and get their values. 
    [ nonzero_rows, nonzero_cols] = find(angles);
    [ all_angles ] = get_values(nonzero_rows, nonzero_cols, ...
        angles);

    %Find the boundaries of the edges
    [m,n] = size(angles);

    %Find the positions in the orientation matrix of the candidate neighbors
    [ candidate_rows, candidate_cols ] = ...
        neighbor_positions( all_angles , nonzero_rows, nonzero_cols);

    %Correct for boundaries. If any of the neighbors are outside of the
    %dimensions, their positions will be set to NaN 
    % [ corrected_nn_rows, corrected_nn_cols ] = ...
    %     boundary_correction( nn_angled_rows, nn_angled_cols, m, n ); 
    [ corrected_rows, corrected_cols ] = ...
        boundary_correction( candidate_rows, candidate_cols, m, n ); 

    %Find the dot product and remove points that are less than the acceptable
    %error. First set any neighbors that are nonzero in the orientation
    %matrix equal to NaN
    [ dp_rows, dp_cols] = compare_angles( dot_product_error,...
        angles, nonzero_rows, nonzero_cols, corrected_rows, corrected_cols);

    % Store the dp rows and columns 
    all_dps{c,1} = dp_rows;
    all_dps{c,2} = dp_cols; 
    
% >>> Get all permutations     
    % Store the true distance and text desription 
    true_dist = true_distances(c,1); 
    descript_case = description_txt{c,1}; 
    
    % Get the number of nonzero positions 
    num_nz = sum(positions(:)); 
    % Make sure that the size of the dp_rows matches that 
    if size(dp_cols,1) ~= num_nz
        disp('Sizes do not match.'); 
    end 

    % Create every possible ordering of the dp values 
    poss_comb = factorial(num_nz);
    v = 1:num_nz;
    all_perms = perms(v); 

    % Initialize vector to store correct or incorrect
    correctgroup = zeros(poss_comb,1); 
    tic; 

    all_zs = cell(poss_comb,1); 

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
        [ zline_clusters, cluster_tracker ] = cluster_neighbors( perm_dprows, ...
            perm_dpcols, m, n);
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
