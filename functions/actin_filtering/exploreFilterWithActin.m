function [ actin_explore ] = ...
    exploreFilterWithActin( im_struct, settings, actin_explore)

% Create a new directory to store all data
new_subfolder = 'ActinFilteringExploration';

% If it does not exist, create it (or append and then create). 
create = true; 
new_subfolder = ...
    addDirectory( im_struct.save_path, new_subfolder, create ); 

% Save the name of the new path 
actin_explore.save_path = fullfile(im_struct.im_path, new_subfolder); 


%Create a cell to store all of the masks
actin_explore.masks = ...
    cell(length(actin_explore.min_thresh:actin_explore.thresh_step:...
    actin_explore.max_thresh), 1); 

%Create a cell to store all of the final skeletons
actin_explore.final_skels = ...
    cell(length(actin_explore.min_thresh:actin_explore.thresh_step:...
    actin_explore.max_thresh), 1); 

%Create a cell to store all of the orientation matrices
actin_explore.orientims = ...
    cell(length(actin_explore.min_thresh:actin_explore.thresh_step:...
    actin_explore.max_thresh), 1); 

%Create a cell to store all of the continuous z-line lengths
actin_explore.lengths = ...
    cell(length(actin_explore.min_thresh:actin_explore.thresh_step:...
    actin_explore.max_thresh), 1); 

%Create a matrix to store all of the medians 
actin_explore.medians = zeros(length(actin_explore.min_thresh:...
    actin_explore.thresh_step:...
    actin_explore.max_thresh), 1); 

%Create a matrix to store all of the non-sarc percentages 
actin_explore.non_sarcs = zeros(length(actin_explore.min_thresh:...
    actin_explore.thresh_step:...
    actin_explore.max_thresh), 1); 


% Start a counter 
actin_explore.n = 0; 

% Save the pre-filtered skeleton for calculation of the non-sarc
% percentages
pre_filt = im_struct.skel_final; 
pre_filt = pre_filt(:); 
pre_filt(pre_filt == 0) = []; 

% Save the data (append on each iteration)
save(fullfile(actin_explore.save_path, strcat(im_struct.im_name,...
    '_ActinExploration.mat')), 'im_struct', 'settings', 'actin_explore');

for thresh = actin_explore.min_thresh:actin_explore.thresh_step:...
        actin_explore.max_thresh
    
    %Create a temporary save name 
    save_name = strcat(im_struct.im_name, '_ACTINthresh', ...
        num2str(actin_explore.n));
    
    %Increase counter 
    actin_explore.n = actin_explore.n+1; 
    
    %Create a matrix to store the mask 
    mask = ones(size(im_struct.orientim)); 
    
    %If dot product is closer to 1, the angles are more parallel and should be
    %removed
    mask(im_struct.dp >= thresh) = 0; 
    %If dot product is closer to 0, the angles are more perpendicular and
    %should be kept
    mask(im_struct.dp < thresh) = 1; 

    %The NaN postitions should be set equal to 1 (meaning no director for
    %actin)
    mask(isnan(mask)) = 1; 

    %Store the mask in the masks cell
    actin_explore.masks{actin_explore.n,1} = mask; 
    
    %Modify the final skeleton by multiplying by the maks 
    actin_explore.final_skels{actin_explore.n,1} = ...
        im_struct.skel_final.*mask; 
    
    % Remove regions that were not part of the binary skeleton
    temp_orientim = im_struct.orientim; 
    temp_orientim(~actin_explore.final_skels{actin_explore.n,1}) = NaN; 
    actin_explore.orientims{actin_explore.n,1} = temp_orientim; 
    
    
    % Save the mask. 
    imwrite( mask, fullfile(actin_explore.save_path, ...
        strcat( save_name, '_Mask.tif' ) ),...
        'Compression','none');

    % Save the final skeleton. 
    imwrite( actin_explore.final_skels{actin_explore.n,1}, ...
        fullfile(actin_explore.save_path, ...
        strcat( save_name, '_Skeleton.tif' ) ),...
        'Compression','none');
    
    % Isolate the number of pixels in the post filtering skeleton 
    post_filt = actin_explore.final_skels{actin_explore.n,1};
    post_filt = post_filt(:);
    post_filt(post_filt == 0) = []; 
    
    % Calculate the non-sarcomeric alpha actinin 
    % number of pixles eliminated / # total # of pixles positive for alpha
    % actinin 
    actin_explore.non_sarcs(actin_explore.n,1) = ...
        (length(pre_filt) - length(post_filt))/ ...
        length(pre_filt);
    
    % Store the actin_explore struct inside of the im_struct
    im_struct.actin_explore = actin_explore; 
    
    % Calculate the continuous z-line lengths 
    
    %If analyzing continuous z-line length add folder to path 
    if czl
       addpath('/Users/tessamorris/Documents/MATLAB/continous_line_detection/');
       dot_product_error = 0.99;
       pix2um = 6.22; 
       
       %Save the angles and set NaNs equal to 0
       angles = orientim.*final_skel; 
       angles(isnan(angles)) = 0;
       %Calculate the continuous z-line length 
       [ distances_um ] = continuous_zline_detection(angles, ...
            pix2um, current_path, strcat(save_name,'.tif'), ...
            dot_product_error, false); 
        %Add title to image 
        title(strcat('Threshold: ', num2str(thresh)), ...
            'FontSize', 14, 'FontWeight', 'bold'); 
        %Save the zline image
        saveas(gcf, fullfile(save_path, ...
                strcat(save_name,'_ZLINES_thresh',...
                strrep(num2str(thresh),'.',''))), 'tiffn');
        close all; 
        
        %Get statistics
        med_dist = median(distances_um); 
        sum_lengths = sum(distances_um); 
        %Open figure
        figure; 
        
        %Plot histogram 
        histogram(distances_um);
        set(gca,'fontsize',12)
        hist_name = strcat('Median: ', num2str(med_dist),' \mu m', ...
            ' ; Sum: ', num2str(sum_lengths), ' \mu m');
        title(hist_name,'FontSize',14,'FontWeight','bold');
        xlabel('Continuous Z-line Lengths (\mu m)','FontSize',14,...
            'FontWeight','bold');
        ylabel('Frequency','FontSize',14,'FontWeight','bold');
        saveas(gcf, fullfile(save_path, ...
                strcat(save_name,'_ZLINES_hist_thresh',...
                strrep(num2str(thresh),'.',''))), 'pdf');
        close all; 
            
    else 
        figure; imshow(final_skel); 
        title(strcat('Threshold: ', num2str(thresh)), 'FontSize', 14, 'FontWeight', 'bold'); 
        saveas(gcf, fullfile(save_path, ...
                strcat(save_name,'_thresh',...
                strrep(num2str(thresh),'.',''))), 'pdf');
        close all; 
    end 
end 


% Save all of the actin filtering data in a structural array 
actin_filtering = struct(); 
actin_filtering.directors = director; 
actin_filtering.dims = dims; 
actin_filtering.threshold = thresh; 

end

