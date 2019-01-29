function [ actin_explore ] = ...
    exploreFilterWithActin( im_struct, settings, actin_explore)

% Create a new directory to store all data
new_subfolder = 'ActinFilteringExploration';

% If it does not exist, create it (or append and then create). 
create = true; 
new_subfolder = ...
    addDirectory( im_struct.save_path, new_subfolder, create ); 

% Save the name of the new path 
actin_explore.save_path = fullfile(im_struct.save_path, new_subfolder); 

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

%Create a matrix to store all of the sums 
actin_explore.sums = zeros(length(actin_explore.min_thresh:...
    actin_explore.thresh_step:...
    actin_explore.max_thresh), 1); 

%Create a matrix to store all of the non-sarc percentages 
actin_explore.non_sarcs = zeros(length(actin_explore.min_thresh:...
    actin_explore.thresh_step:...
    actin_explore.max_thresh), 1); 

%Create a matrix to store all of the threshold values
actin_explore.actin_thresh = zeros(length(actin_explore.min_thresh:...
    actin_explore.thresh_step:...
    actin_explore.max_thresh), 1); 

% Start a counter 
actin_explore.n = 0; 

% Save the pre-filtered skeleton for calculation of the non-sarc
% percentages
pre_filt = im_struct.skel_final; 
pre_filt = pre_filt(:); 
pre_filt(pre_filt == 0) = []; 

for thresh = actin_explore.min_thresh:actin_explore.thresh_step:...
        actin_explore.max_thresh
    
    %Increase counter 
    actin_explore.n = actin_explore.n + 1; 
    
    %Create a temporary save name 
    save_name = strcat(im_struct.im_name, '_ACTINthresh', ...
        num2str(actin_explore.n));
    
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
    
    %Save the threshold value 
    actin_explore.actin_thresh(actin_explore.n,1) = thresh;
    
    % Store the actin_explore struct inside of the im_struct
    im_struct.actin_explore = actin_explore; 
    
    %Close all figures
    close all; 
    
    % Calculate the continuous z-line lengths 
    [ actin_explore.lengths{actin_explore.n,1} ] = ...
        continuous_zline_detection(im_struct, settings);
    
    %Clear the command line 
    clc 
    %Close all figures
    close all; 
    
    %Find the median continuous z-line length
    actin_explore.medians(actin_explore.n,1) = ...
        median(actin_explore.lengths{actin_explore.n,1});
    %Find the sum continuous z-line length
    actin_explore.sums(actin_explore.n,1) = ...
        sum(actin_explore.lengths{actin_explore.n,1});
end 

% Create a name to save the file 
summary_name = strcat(im_struct.im_name, '_ActinExploration.mat');

% If the filename exists, add a number until it doesn't 
summary_name = appendFilename( im_struct.save_path, summary_name ); 

% Save the data (append on each iteration)
save(fullfile(im_struct.save_path, summary_name), ...
    'im_struct', 'settings', 'actin_explore');


%Plot the resulting data 
figure; 
hold on; 

%Plot the threshold vs. the median
subplot(3,2,1); 
plot(actin_explore.actin_thresh, actin_explore.medians, 'o', 'color', 'k', ...
    'MarkerFaceColor', 'k'); 
set(gca,'fontsize',12)
title( strcat('Median (\mu m) vs Actin Threshold'),...
    'FontSize',12,'FontWeight','bold');
ylabel('Median CZL (\mu m)','FontSize',12,...
    'FontWeight','bold');
xlabel('Actin Threshold (dot product)','FontSize',12,'FontWeight','bold');

%Plot the threshold vs. the sum
subplot(3,2,2); 
plot(actin_explore.actin_thresh, actin_explore.sums, 'o', 'color', 'k', ...
    'MarkerFaceColor', 'k'); 
set(gca,'fontsize',12)
title( strcat('Sum (\mu m) vs Actin Threshold'),...
    'FontSize',12,'FontWeight','bold');
ylabel('Total CZL (\mu m)','FontSize',12,...
    'FontWeight','bold');
xlabel('Actin Threshold (dot product)','FontSize',12,'FontWeight','bold');

%Plot the non-zline fraction vs. actin trheshold 
subplot(3,2,3); 
plot(actin_explore.actin_thresh, actin_explore.non_sarcs, 'o', 'color', 'k', ...
    'MarkerFaceColor', 'k'); 
set(gca,'fontsize',12)
title( strcat('Non Z-line Fraction vs Actin Threshold'),...
    'FontSize',12,'FontWeight','bold');
ylabel('Non Z-line Fraction','FontSize',12,...
    'FontWeight','bold');
xlabel('Actin Threshold (dot product)','FontSize',12,'FontWeight','bold');

%Plot the median vs non zline 
subplot(3,2,4); 
plot(actin_explore.non_sarcs, actin_explore.medians, 'o', 'color', 'k', ...
    'MarkerFaceColor', 'k'); 
set(gca,'fontsize',12)
title( strcat('Median (\mu m) vs Non Z-line Fraction'),...
    'FontSize',12,'FontWeight','bold');
ylabel('Median CZL (\mu m)','FontSize',12,...
    'FontWeight','bold');
xlabel('Non Z-line Fraction','FontSize',12,'FontWeight','bold');

%Plot the sum vs non zline 
subplot(3,2,5); 
plot(actin_explore.non_sarcs, actin_explore.sums, 'o', 'color', 'k', ...
    'MarkerFaceColor', 'k'); 
set(gca,'fontsize',12)
title( strcat('Sum (\mu m) vs Non Z-line Fraction'),...
    'FontSize',12,'FontWeight','bold');
ylabel('Total CZL (\mu m)','FontSize',12,...
    'FontWeight','bold');
xlabel('Non Z-line Fraction','FontSize',12,'FontWeight','bold');

%Save pdf
saveas(gcf, fullfile(im_struct.save_path, ...
    strcat(im_struct.im_name, '_ActinExploration')), 'pdf');

close;
end

