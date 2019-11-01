% zlineCZL - Call and produce plots of the continuous z-line length. It
% will format the output from continuous z-line detection in a maner that
% can be analzed by continuous_zline_detection 

function [ distances_um ] = zlineCZL(im_struct, settings, savename)

% Continuous Z-line Detection requires the orientation vectors, an input
% image, and the dot product threshold. Extract this information from
% z-line detection results matrices 

% Check to see if this is a parameter exploration for actin filtering
if ~settings.actinthresh_explore && ~settings.grid_explore
    %Load orientation angles from the image structure
    angles = im_struct.orientim; 

    %Create a .mat filename 
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

% Append the savename with today's date and the background removal (this is
% only for a very specific case). 
if nargin == 3
    [save_path, f, ~] = fileparts(savename);  
    output_filename = strcat(output_filename, f(end-16:end)); 
end 

% Run continuous z-line detection 
[ CZL_results, ~ ] = continuous_zline_detection( angles, ...
    mat2gray(im_struct.im), settings.dp_threshold ); 

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

% Store the information from the continuous z-line results that should
% also be saved for z-line detection 
zline_clusters = CZL_results.zline_clusters; 
cluster_tracker = CZL_results.cluster_tracker; 
distances_no_nan = CZL_results.distances_no_nan; 
rmCount = CZL_results.rmCount; 

%Convert the distances from pixels to microns 
distances_um = distances_no_nan/settings.pix2um;

% If this is an explorat
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

    %Append summary file with CZL
    if nargin == 3
        save(savename, 'CZL_struct', '-append');
    else
        save(fullfile(im_struct.save_path, strcat(im_struct.im_name,...
           '_OrientationAnalysis.mat')), 'CZL_struct', '-append');
    end 
end   

end

