% continuous_zline_detection - detect the continuous lines in an image of 
% alpha - actinin stained z-lines in images of striated muscle tissues. 
%
% Usage:   
%   [ distances_um ] = continuous_zline_detection(angles, BW, ...
%       dot_product_error, pix2um)
%
% Arguments:
%   angles       - orientation angles in radians with no NaN values
%                           Class Support: numeric 
%   BW          - image 
%   dot_product_error
% vpix2um
% Returns:
%   OOP                 - orientational order parameters
%                           Class Support: double 
%	directionAngle      - principle direction angle in degrees 
%                           Class Support: double 
%   direction_error     - difference between principle direction (in 
%                               degrees) average direction (in degrees)
%                           Class Support: double 
%   director            - principle direction vector
%                           Class Support: 2x1 double 
%
% Dependencies: 
%   MATLAB Version >= 9.5 
%
%
% Written by: Tessa Morris
%   Advisor: Anna (Anya) Grosberg, Department of Biomedical Engineering 
%   Cardiovascular Modeling Laboratory 
%   University of California, Irvine 

function [ CZL_results, CZL_info ] = continuous_zline_detection( angles, BW, ...
    dot_product_error, save_info )

% If there are only three inputs, the user does not want to save
if nargin < 4
    % Set save results to false
    saveResults = false;
else
    % Set save results to true and store the image info  
    saveResults = true;
    
    % Make sure the user provided a save name and save path 
    if ~isfield(save_info,'save_path')
        disp('You must proide a path to save the results.'); 
        disp('save_info.save_path = ?'); 
        saveResults = false; 
    end 
    if ~isfield(save_info,'save_name') && ~saveResults
        save_info.save_name = 'contZlineResults'; 
    end 
    % If the user did not provide an argument for saving as a figure, set
    % it to false
    if ~isfield(save_info,'saveFig') && ~saveResults
        save_info.saveFig = false; 
    end 
end 

%If there are any NaN values in the angles matrix, set them to 0.
angles(isnan(angles)) = 0; 

%Find the nonzero positions of this matrix and get their values. 
[ nonzero_rows, nonzero_cols] = find(angles);

% Get the value of the orientation angles at all of the non-zero positions 
all_angles = get_values(nonzero_rows, nonzero_cols, ...
    angles);

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

% Remove any orientation vectors in which the neighbors are perpendicular 
[  dp2_rows, dp2_cols ] = ...
    check_perpendicular( dp_rows, dp_cols, angles, dp_thresh); 

%Cluster the values in order.  
[ zline_clusters, cluster_tracker ] = ...
    cluster_neighbors( dot_product_error, angles, dp2_rows, dp2_cols);

%Calculate legnths and plot
disp('Plotting and calculating the lengths of continuous z-lines...'); 
[ distance_storage, rmCount, zline_clusters ] = ...
    calculate_lengths( BW, zline_clusters);

% If the results should be saved 
if saveResults
    % Add a title to the plot if the field exists 
    if isfield(save_info,'plot_title')
        title(save_info.plot_title,'FontSize',14,'FontWeight','bold');
    end 
    % Save the figure 
    if save_info.saveFig
        %Save as a .fig file (Matlab Figure)
        new_filename = appendFilename( save_info.save_path, ...
            strcat(save_info.save_name, '.fig' ));
        savefig(fullfile(save_info.save_path, new_filename));
    end
    
    % Save as an image if the file type was provided
    if isfield(save_info,'save_type')
        new_filename = appendFilename( save_info.save_path, ...
            strcat(save_info.save_name,save_info.save_type) ); 
        saveas(gcf, fullfile(save_info.save_path, new_filename),...
            save_info.save_type);
    end 
end 

%Remove any nan from distances 
distances_no_nan = distance_storage; 
distances_no_nan(isnan(distances_no_nan)) = []; 

% Store the results of the continuous z-line detection   
CZL_results = struct(); 
CZL_results.zline_clusters = zline_clusters;
CZL_results.cluster_tracker = cluster_tracker;
CZL_results.distance_storage = distance_storage;
CZL_results.distances_no_nan = distances_no_nan;
CZL_results.rmCount = rmCount;

% Store all of the intermediate steps. This is primarily used for
% demonstrative/ debugging purposes 
CZL_info = struct(); 
CZL_info.angles = angles;
CZL_info.dot_product_error = dot_product_error;
CZL_info.candidate_rows = candidate_rows;
CZL_info.candidate_cols = candidate_cols;
CZL_info.corrected_rows = corrected_rows;
CZL_info.corrected_cols = corrected_cols;
CZL_info.dp_rows = dp_rows;
CZL_info.dp_cols = dp_cols;
CZL_info.dp2_rows = dp2_rows;
CZL_info.dp2_cols = dp2_cols;

% Save .mat file if requested
if saveResults
    new_filename = appendFilename( save_info.save_path, ...
        strcat(save_info.save_name,'.mat') ); 
    
    save(fullfile(save_info.save_path, new_filename), ...
        'CZL_info', 'CZL_results');
end 

end 