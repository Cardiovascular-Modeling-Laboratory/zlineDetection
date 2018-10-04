function [ distances_um ] = continuous_zline_detection(angles, ...
    pix2um, image_path, image_file, dot_product_error, test_set)
% This method aims to detect the continuous lines in an image of alpha 
% actinin stained sarcomeres. 


%Proccess the image. This involves converting to a black and white image
%For visualization purposes. There is also an option to adjust the contrast
%and sharpness of the image. 
if test_set == 1 
    %Store the image filename and the path name. 
    image_filename = [image_path image_file];

    %Get the filename of the image_file (if applicable) 
    [~,name,~] = fileparts(image_file);

    %If there are any NaN values in the angles matrix, set them to 0.
    angles(isnan(angles)) = 0; 
    
    %For plotting purposes save the BW image as angles 
    BW = angles; 
elseif test_set == 2
    BW = image_file;
    name = input('Please Input a File Name: ', 's'); 
else
    %Store the image filename and the path name. 
    image_filename = [image_path image_file];

    %Get the filename of the image_file (if applicable) 
    [~,name,~] = fileparts(image_file);
    [ BW, ~ ] = image_processing( image_filename ); 
    
end 

%Find the nonzero positions of this matrix and get their values. 
[ nonzero_rows, nonzero_cols] = find(angles);
    
[ all_angles ] = get_values(nonzero_rows, nonzero_cols, ...
    angles);

%Calculate the nearest neighbor in the positive and negative direction of 
%the orientation angle. The output will be two n x 3 matrices with the row
%and column positions of: neighbor -, nonzero angle , neighbor +
%It will also output the neighborhood connectivity of hte nearest neighbor 
% abs_max_range = 1; 
% [ nn_angled_rows, nn_angled_cols ] = ...
%     find_angle_neighbors( abs_max_range, all_angles, ...
%     nonzero_rows, nonzero_cols); 
% [ nn_angled_rows, nn_angled_cols, n_connect] = ...
%     find_angle_neighbors( all_angles, nonzero_rows, nonzero_cols);

%Find the boundaries of the edges
[m,n] = size(angles);

%Get the neighbors on either side of the nearest neighbor orientation
%vector by adding and sutracting 30 degrees (pi/6)
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

%Cluster the values in order.  
[ zline_clusters, cluster_tracker ] = cluster_neighbors( dp_rows, ...
    dp_cols, m, n);

%Calculate legnths and plot
disp('Plotting and calculating the lengths of continuous z-lines...'); 
[ distance_storage, rmCount, zline_clusters ] = ...
    calculate_lengths( BW, zline_clusters);

%Save figure as both a TIF and FIG 
if test_set == 1
    %Title the figures
    fig_name = strcat('Continuous Z-lines: ', image_file(11:end-4));
    fig_name = strrep(fig_name,'_',' ');
    title(fig_name,'FontSize',12,'FontWeight','bold');
    %Save as a tiff file 
    zline_figure_name = strcat('z_lines_', name);
    saveas(gcf, fullfile(image_path, zline_figure_name), 'tiffn');
else 
    %Save as a .fig file (Matlab Figure)
    zline_figure_name_fig = strcat('z_lines_', name, '.fig');
    savefig(fullfile(image_path, zline_figure_name_fig));
    %Save as a .tif file
    zline_figure_name = strcat('z_lines_', name);
    saveas(gcf, fullfile(image_path, zline_figure_name), 'tiffn');
end 

%Remove any nan from distances 
distances_no_nan = distance_storage; 
distances_no_nan(isnan(distances_no_nan)) = []; 

%Convert the distances from pixels to microns 
distances_um = distances_no_nan/pix2um;

% %Generate statistical information in a table. 
% [ stat_summary ] = get_statistics( distances_um );

%Save information
disp('Saving data...'); 

%Save the original input data, the count matrix, and the histogram 
%matrix. 
output_filename = strcat('z_lines_', name, '.mat');
% save(fullfile(image_path, output_filename), 'zline_clusters', ...
%     'cluster_tracker','distances_no_nan', ...
%     'distances_um', 'stat_summary', 'rmCount');
save(fullfile(image_path, output_filename), 'zline_clusters', ...
    'cluster_tracker','distances_no_nan', ...
    'distances_um', 'rmCount');
end 