% This script is for testing purposes. 
% It contains code to run all of the added experimental test cases a few
% times 

%Temporarily store the path of continuous z-line detection  
temp_path = pwd; 

%Get the parts of the path 
pathparts = strsplit(temp_path,filesep);

%Set previous path 
previous_path = pathparts{1,1}; 

%Go back one folder 
for p =2:size(pathparts,2)-1
    if ~isempty(pathparts{1,p+1})
        previous_path = fullfile(previous_path, pathparts{1,p}); 
    end 
end 

%Add a backslash to the beginning of the path in order to use if this
%is a mac, otherwise do not
if ~ispc
    previous_path = strcat(filesep,previous_path);
end 
    
% Add the previous path to use functions
addpath(previous_path); 

% Prompt the user to load the synthetic test cases
expcases = load(fullfile(pwd,'czl_exptestcases.mat')); 

% Save the angles, images, and skeletons 
all_angles = expcases.angles; 
all_images = expcases.images; 
all_skel = expcases.skeletons; 

% Number of permutations to run for each case 
numperm = 5; 

% Get the number of cases
numcases = size(all_angles,1); 

% Start timer
tic; 

% Set dot product error
 dot_product_error = 0.90; 
 
 % Permutations and dp
 perm_vals = cell(numcases,1); 
 dpvals = cell(numcases,2); 
 
 
% Loop through all of the 
for c = 1:numcases
    % Store positions, orientation vectors
    positions = all_skel{c,1}; 
    BW = all_images{c,1}; 
    orientim = all_angles{c,1}; 
    angles = orientim;
    
    
    % Run continuous z-line detection 
    [ CZL_results, CZL_info ] = continuous_zline_detection( angles, BW, ...
    dot_product_error ); 
    temp_dist = CZL_results.distances_no_nan; 
    k = 0;
    title(strcat('Case ',num2str(k)), 'FontSize',16, 'FontWeight','bold' );
    disp_msg = strcat('Case', {' '}, num2str(k), {' '}, 'has', {' '},...
        num2str(length(temp_dist)), {' '},' CZL.');
    disp_msg2 = strcat('Mean:', {' '}, ...
        num2str(round(mean(temp_dist),2)), ...
        {' '}, 'St.Dev.:', {' '}, num2str(round(std(temp_dist),2)));
    disp(disp_msg{1}); 
    disp(disp_msg2{1}); 
    % Store the positiosn 
    dp_rows = CZL_info.recip_rows; 
    dp_cols = CZL_info.recip_cols; 
    
    % Get the number of non-zero pixles 
    num_nz = size(dp_rows,1); 
    v = 1:num_nz; 
    
    % Initialize a matrix to store the random permutations 
    some_perms = zeros(numperm, num_nz); 
   
    % Initialize storage matrices
    all_zs = cell(numperm,1); 
    
    %  Create the dot product row and columns based on the current permutation 
    for k = 1:numperm
        
        % Create a random permutation 
        some_perms(k,:) = v(randperm(length(v)));
        
        % Create the new dp pairngs
        perm_dprows = zeros(size(dp_rows)); 
        perm_dpcols = zeros(size(dp_cols));

        % Loop through and order the dot prodcuts 
        for o = 1:num_nz
            perm_dprows(o,:) = dp_rows(some_perms(k,o),:); 
            perm_dpcols(o,:) = dp_cols(some_perms(k,o),:); 
        end 
    
        %Cluster the values in order.  
        [ zline_clusters, cluster_tracker ] = ...
            cluster_neighbors( dot_product_error, angles, ...
            perm_dprows, perm_dpcols);
        
        [ distance_storage, rmCount, all_zs{k,1} ] = ...
            calculate_lengths( BW, zline_clusters);
        title(strcat('Case ',num2str(k)), 'FontSize',16, 'FontWeight','bold' );
        
        
        distance_storage_nonan = distance_storage; 
        distance_storage_nonan(isnan(distance_storage_nonan)) = []; 
            
        disp_msg = strcat('Case', {' '}, num2str(k), {' '}, 'has', {' '},...
            num2str(length(distance_storage_nonan)), {' '},' CZL.');
        disp_msg2 = strcat('Mean:', {' '}, ...
            num2str(round(mean(distance_storage_nonan),2)), ...
            {' '}, 'St.Dev.:', {' '}, num2str(round(std(distance_storage_nonan),2)));
        disp(disp_msg{1}); 
        disp(disp_msg2{1}); 
    
    end 

     % Permutations and dp
     perm_vals{c,1} = some_perms; 
     dpvals{k,1} = dp_rows; 
     dpvals{k,2} = dp_cols; 
 
 
end

