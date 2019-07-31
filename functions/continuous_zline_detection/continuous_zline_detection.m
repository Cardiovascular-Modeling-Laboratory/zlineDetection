function [ distances_um ] = continuous_zline_detection(im_struct, settings)
% This method aims to detect the continuous lines in an image of alpha 
% actinin stained sarcomeres. 

%%%%%%%%%%%%%%%%%%%%%%%% LOAD FROM IM_STRUCT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check to see if this is a parameter exploration for actin filtering
if ~settings.actinthresh_explore && ~settings.grid_explore
    %Load orientation angles from the image structure
    angles = im_struct.orientim; 

%     %Create a .mat filename 
%     output_filename = strcat( im_struct.im_name, '_zlines.mat'); 
    output_filename = im_struct.im_name; 
    %Store the location to save all of the files
    save_path = im_struct.save_path; 
else 
    %Save the actin explore struct 
    actin_explore = im_struct.actin_explore; 
    
    %Load orientation angles from the current iteration of the
    %actin_explore struct
    angles = actin_explore.orientims{actin_explore.n,1};
    
    %Create a .mat filename (only save the threshold if this is a threshold
    %exploration 
    if settings.actinthresh_explore
        output_filename = strcat( im_struct.im_name,'_ACTINthresh', ...
            num2str(actin_explore.n)); 
    else
        output_filename = strcat( im_struct.im_name ); 
  
    end 
    
    %Store the location to save all of the files 
    save_path = actin_explore.save_path; 
end 

%If there are any NaN values in the angles matrix, set them to 0.
angles(isnan(angles)) = 0; 

%Save the pixel to micron conversion
pix2um = settings.pix2um; 

%Save the dot prodcut error 
dot_product_error = settings.dp_threshold; 

%Save the image and convert to a matrix 
BW = im_struct.im; 
BW = mat2gray(BW);

%Find the nonzero positions of this matrix and get their values. 
[ nonzero_rows, nonzero_cols] = find(angles);
    
[ all_angles ] = get_values(nonzero_rows, nonzero_cols, ...
    angles);

%%%%%%%%%%%%%%%%%%%%%%%%%% BEGIN CZL METHOD %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Find the boundaries of the edges
[m,n] = size(angles);

%Get the neighbors on either side of the nearest neighbor orientation
%vector by adding and sutracting 30 degrees (pi/6)
[ candidate_rows, candidate_cols ] = ...
    neighbor_positions( all_angles , nonzero_rows, nonzero_cols);

%Correct for boundaries. If any of the neighbors are outside of the
%dimensions, their positions will be set to NaN 
[ corrected_rows, corrected_cols ] = ...
    boundary_correction( candidate_rows, candidate_cols, m, n ); 

%Find the dot product and remove points that are less than the acceptable
%error. First set any neighbors that are nonzero in the orientation
%matrix equal to NaN
[ dp_rows, dp_cols] = compare_angles( dot_product_error,...
    angles, nonzero_rows, nonzero_cols, corrected_rows, corrected_cols);

%Cluster the values in order.  
[ zline_clusters, cluster_tracker ] = ...
    cluster_neighbors( dot_product_error, angles, dp_rows, dp_cols);

%Calculate legnths and plot
disp('Plotting and calculating the lengths of continuous z-lines...'); 
[ distance_storage, rmCount, zline_clusters ] = ...
    calculate_lengths( BW, zline_clusters);

%If this is a actin filtering parameter exploration, add a title
if settings.actinthresh_explore || settings.grid_explore
    im_title = strcat(strrep(im_struct.im_name,'_', '\_'), ...
        '; Actin Threshold: ', {' '}, ...
        num2str(actin_explore.thresholds(actin_explore.n,1)),...
        {' '},'; Grid Size: ',num2str(settings.grid_size(1))); 
    
    %Add title
    title(im_title{1,1},'FontSize',14,'FontWeight','bold');
end

%Save as a .fig file (Matlab Figure)
fig_name = strcat( output_filename, '_zlines.fig' );
savefig(fullfile(save_path, fig_name));
%Save as a .tif file
saveas(gcf, fullfile(save_path, fig_name(1:end-4)), 'tiffn');


settings.pltZact = false; 
% If the actin detect image is available, plot the z-lines on top of it 
if settings.pltZact 
    % Save the actin struct
    actin_struct = im_struct.actin_struct;
    
    %Save the actin image
    actin_im = actin_struct.actin_im;
    
    %Convert to gray matrix
    actin_im = mat2gray(actin_im); 
    
    %Plot z-lines on top of the actin image 
    disp('Plotting continuous z-lines on actin image...'); 
    [ ~, ~, ~ ] = ...
        calculate_lengths( actin_im, zline_clusters);
    
    %Get the file parts of the actin 
    [~, actin_name] = fileparts(actin_struct.filename);
    disp(actin_struct.filename); 
    %If this is a parameter exploration, add the parameter threshold number
    if settings.actinthresh_explore || settings.grid_explore
        
        %Add title
        im_title = strcat(strrep(actin_name,'_', '\_'), ...
            '; Actin Threshold: ', {' '}, ...
            num2str(actin_explore.actin_thresh(actin_explore.n,1)),...
            {' '},'; Grid Size: ',num2str(settings.grid_size(1))); 
        %Add title
        title(im_title{1,1},'FontSize',14,'FontWeight','bold');

        %Save the actin image as a .tif and .fig
        actin_name = strcat(actin_name, '_ACTINthresh', ...
            num2str(actin_explore.n),'_zlines');
    end 
    
    %Add .fig extension to name 
    actin_name = strcat(actin_name, '.fig'); 
    
    %Save the .fig and .tiff 
    savefig(fullfile(save_path, actin_name));
    saveas(gcf, fullfile(save_path, actin_name(1:end-4)),...
        'tiffn');
end 

%Remove any nan from distances 
distances_no_nan = distance_storage; 
distances_no_nan(isnan(distances_no_nan)) = []; 

%Convert the distances from pixels to microns 
distances_um = distances_no_nan/pix2um;

%Save information
disp('Saving data...'); 

if settings.exploration
    % Save the (1) z-line clusters (2) cluster trackers (3) distances in microns
    % (4) distances in microns (5) number removed 
    save(fullfile(save_path, strcat(output_filename,'_zlines.mat')), ...
        'zline_clusters', 'cluster_tracker','distances_no_nan', ...
        'distances_um', 'rmCount');
else 
    %Save a struct
    CZL_struct = struct(); 
    CZL_struct.zline_clusters = zline_clusters; 
    CZL_struct.cluster_tracker = cluster_tracker; 
    CZL_struct.distances_no_nan = distances_no_nan; 
    CZL_struct.distances_um = distances_um; 
    CZL_struct.rmCount = rmCount; 

    %Append summary file with OOP 
    save(fullfile(im_struct.save_path, strcat(im_struct.im_name,...
       '_OrientationAnalysis.mat')), 'CZL_struct', '-append');
end   

end 