% This script is for testing purposes. 
% It contains code to analyze a specific section of a previously analyzed 
% image (requiring orientation vectors and binary skeletons). 
% It also contains synthetic data to test the code. 

%% OPTION 1: TEST REGION OF A SPECIFIC ANALYZED IMAGE 
% Load an im_struct for an image you'd like to test and display it 
figure; imshow(im_struct.skel_final_trimmed); 

% Select a section using the following command 
r = round(getrect()); 

% Get only the orientation vectors in the selected section. 
sec_orientim = im_struct.orientim(r(2):r(2)+r(4), r(1):r(1)+r(3)); 
orientim = sec_orientim; 
orientim(isnan(orientim)) = 0;
angles = orientim; 

% Get the binary skeleton in the region 
sec_skel_final = im_struct.skel_final_trimmed(r(2):r(2)+r(4), r(1):r(1)+r(3));
positions = sec_skel_final; 

% Get the image in that region 
BW0 = mat2gray(im_struct.im); 
BW = BW0(r(2):r(2)+r(4), r(1):r(1)+r(3));



% %% 
% % Get the orientation vectors and skeleton in that region and get in the
% % correct format
% load('D:\NRVM_SingleCells_20190724\AR1_SD20150807_W10_w1mCherry\AR1_SD20150807_W10_w1mCherry_OrientationAnalysis.mat')
% 
% r = [72,183,31,8]; 
% sec_orientim = im_struct.orientim(r(2):r(2)+r(4), r(1):r(1)+r(3)); 
% orientim = sec_orientim; 
% orientim(isnan(orientim)) = 0;
% angles = orientim; 
% 
% sec_skel_final = getRectSection(im_struct.skel_final_trimmed, r, false);
% positions = sec_skel_final; 
% 
% %%
% orientim = im_struct.orientim; 
% orientim(isnan(orientim)) = 0; 
% angles = orientim; 
% 
% positions = mat2gray(im_struct.im);
% BW = positions; 

%%
r2 = [2,5,5,3]; 
r2 = round(r2);
sec_orientim2 = sec_orientim(r2(2):r2(2)+r2(4), r2(1):r2(1)+r2(3)); 
orientim = sec_orientim2;
orientim(isnan(orientim)) = 0;
angles = orientim; 

sec_skel_final2 = getRectSection(sec_skel_final, r2, false);
positions = sec_skel_final2; 



%% Compute neighbors and the dot product values 

%Find the nonzero positions of this matrix and get their values. 
dot_product_error = 0.90; 
% angles = orientim; 

[ nonzero_rows, nonzero_cols] = find(angles);
    
[ all_angles ] = get_values(nonzero_rows, nonzero_cols, ...
    angles);

%Find the boundaries of the edges
[m,n] = size(angles);

%Get the neighbors on either side of the nearest neighbor orientation
%vector. The order of the candidate neighbors: 
%fwdnn-1, fwdnn, fwdnn+1, bwdnn-1, bwdnn, bwdnn+1
% [ candidate_neighbors ] = find_neighbor_connectivity( all_angles );

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

%% Visualize candidate neighbors and the accepted neighbors based on the 
% dot product threshold 

%Color options 
col=['g', 'm', 'b', 'r'];
col = repmat( col, [1 , ceil( size(corrected_cols, 1) / size(col, 2))] ); 

figure;
subplot(1,2,1); 
magnification = 1000; 
imshow(positions, 'InitialMagnification', magnification); 
hold on; 
for h = 1:size(corrected_cols, 1)
    %Get coordinates temporarily
    x = corrected_cols(h,:)'; 
    y = corrected_rows(h,:)'; 
    plot(x,y,'o', 'color', col(h)); 
    k = boundary(x,y);
    plot(x(k),y(k), '-', 'color', col(h));
    
    clear x y k 
end 

title('Corrected Neighbors', 'FontSize',16, 'FontWeight','bold' );

subplot(1,2,2); 
magnification = 1000; 
imshow(positions, 'InitialMagnification', magnification); 
hold on; 
for h = 1:size(dp_rows, 1)
    %Get coordinates temporarily
    x = dp_cols(h,:)'; 
    y = dp_rows(h,:)'; 
    %Remove NaN values
    x(isnan(x)) = []; 
    y(isnan(y)) = []; 
    plot(x,y,'o', 'color', col(h)); 
    plot(x,y, '-', 'color', col(h));
    
    clear x y 
end 

title('Accepted Neighbors', 'FontSize',16, 'FontWeight','bold' );

%% Randomize the order of the dot product neighbors to test clustering 

% Get the number of nonzero positions 
num_nz = sum(positions(:)); 
% Make sure that the size of the dp_rows matches that 
if size(dp_cols,1) ~= num_nz
    disp('Sizes do not match.'); 
end 
BW = positions;
sc = 4; 

if sc == 3
    true_dist = (num_nz-1)*sqrt(2); 
elseif sc == 4
    true_dist =sqrt(2) + 3; 
else 
% Calculate the true distance of the z-lines
true_dist = sqrt( (nonzero_cols(1)-nonzero_cols(end))^2 + ...
    (nonzero_rows(1)-nonzero_rows(end))^2 ); 
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
% display results 
acc_val = (sum(correctgroup)/length(correctgroup))*100; 
disp(strcat('Accuracy:  ', num2str(acc_val), '%')); 

%% Cluster testing
%Cluster the values in order.  
[ zline_clusters, cluster_tracker ] = cluster_neighbors( dp_rows, ...
    dp_cols, m, n, true);

%% Check specific cluster
k = 115; 
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
    perm_dpcols, m, n, true);

%% Plot actual clusters
BW = positions; 

%Cluster the values in order.  
[ zline_clusters, cluster_tracker ] = cluster_neighbors( dp_rows, ...
    dp_cols, m, n);

figure; 
tot_cluster = max(max(cluster_tracker)); 
imagesc(cluster_tracker);
hold on;
plot(nonzero_cols, nonzero_rows, 's', 'MarkerSize', 10, 'color', 'black')
for k = 1:tot_cluster
    hold on;
    temp_plot = zline_clusters{k};
    if isnan(temp_plot)
        disp(['Cluster ', num2str(k), ' is NaN.']); 
    else 
    plot(temp_plot(:,2), temp_plot(:,1), '-.','color', 'red')
    end
    clear temp_plot
end 

title('Plotted Clustering', 'FontSize',16, 'FontWeight','bold' );





%%
%Cluster the values in order.  
[ zline_clusters, cluster_tracker ] = cluster_neighbors( dp_rows, ...
    dp_cols, m, n, false);
%Calculate legnths and plot
disp('Plotting and calculating the lengths of continuous z-lines...'); 
[ distance_storage, rmCount, zline_clusters ] = ...
    calculate_lengths( BW, zline_clusters);



