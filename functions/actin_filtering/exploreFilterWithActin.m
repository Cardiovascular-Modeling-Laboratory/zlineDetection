function [ mask, final_skel, actin_filtering ] = ...
    exploreFilterWithActin( director, dims, orientim, current_path, save_name,...
    czl)

% Create a new directory to store all data
folderName = strcat(save_name,'_Explore');
save_path = fullfile(current_path, folderName); 

% If the path does not exist create it
if ~exist(save_path,'dir')
    mkdir(save_path);
end
    
%Total number of grids
n = size(director,1); 

%Create mask 
mask = ones(size(orientim)); 

%Create a direcor matrix
dir_mat = ones(size(orientim)); 

%Check to make sure the direcor isn't in radians
if max(director) > 10
    director = deg2rad(director); 
end 

%Loop through each grid and place the director of each grid as the value in
%the grid
for k = 1:n
    %Set the value each grid equal to its director
    dir_mat(dims(k,1):dims(k,2),dims(k,3):dims(k,4)) = director(k,1);     
end 

%Take the dot product sqrt(cos(th1 - th2)^2);
dp = sqrt(cos(orientim - dir_mat).^2); 

for thresh = 0:0.05:1
    %If dot product is closer to 1, the angles are more parallel and should be
    %removed
    mask(dp >= thresh) = 0; 
    %If dot product is closer to 0, the angles are more perpendicular and
    %should be kept
    mask(dp < thresh) = 1; 

    %The NaN postitions should be set equal to 1 (meaning no director for
    %actin)
    mask(isnan(mask)) = 1; 

    %Create a skeleton by setting every positive pixel in the orientation
    %matrix equal to 1
    final_skel = orientim; 
    final_skel(~isnan(orientim)) = 1; 
    final_skel(isnan(orientim)) = 0;
    %Multiply the final skeleton by the mask (removing points below the
    %threshold
    final_skel = final_skel.*mask; 
    
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

