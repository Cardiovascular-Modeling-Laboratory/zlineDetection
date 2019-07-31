function [ actin_explore ] = ...
    exploreFilterWithActin( im_struct, settings, actin_explore)

%%%%%%%%%%%%%%%%%%%%%%% Initialize Grids %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set values for the grid exploration 
gmin = settings.grid_size(1); 
gmax = gmin; 
gstep = 1;

%If requested, Get the range of values for the grid exploration 
if settings.grid_explore
    %Get the min, max, and step size 
    gmin = actin_explore.grid_min; 
    gmax = actin_explore.grid_max; 
    gstep = actin_explore.grid_step; 

end 

%Get the total and unique values for the grids 
unique_grids = round( gmin:gstep:gmax ); 
gtot = length(unique_grids); 

%%%%%%%%%%%%%%%%%%%%%%% Initialize Thresholds %%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set values for the threshold exploration 
atmin = settings.actin_thresh; 
atmax = gmin; 
atstep = 1; 

%If requested, Get the range of values for the actin threshold exploration
if settings.actinthresh_explore
    %Get the min, max, and step size 
    atmin = actin_explore.min_thresh; 
    atmax = actin_explore.max_thresh;
    atstep = actin_explore.thresh_step;
end

%Get the total and unique values for actin threshold
unique_thresh = atmin:atstep:atmax; 
attot = length(unique_thresh); 

        
%%%%%%%%%%%%%%%%%%%%%%%%%% Initialize Matrices %%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Caclulate the total number of data points 
tot = attot*gtot; 

%>> ALL EXPLORE: Create a matrix to store all of the non-sarc fractions 
non_zlinefracs = zeros(tot, 1); 
zlinefracs = zeros(tot, 1); 
%>> ALL EXPLORE: Create a matrix to store all of the medians 
medians = zeros(tot, 1); 
%>> ALL EXPLORE: Create a matrix to store all of the sums 
sums = zeros(tot, 1);
%>> ALL EXPLORE: Create a matrix to store all of the threshold values 
thresholds = zeros(tot, 1);   
%>> ALL EXPLORE: Create a matrix to store all of the grid sizes
grid_sizes= zeros(tot, 1);     
%>> ALL EXPLORE: Create a cell to store all of the masks
masks = cell(tot, 1); 
%>> ALL EXPLORE: Create a cell to store all of the continuous z-line 
% lengths
lengths = cell(tot, 1);
%>> ALL EXPLORE: Create a cell to store all of the final skeletons
final_skels = cell(tot, 1);
%>> ALL EXPLORE: Create a cell to store all of the orientation matrices
orientims = cell(tot, 1);
%>> ALL EXPLORE: Create a matrix to store all of post-filtered values
post_filt = zeros(tot,1); 


%Old save path 
image_savepath = im_struct.save_path;

% Save the prefiltered skeleton 
prefilt_skel = im_struct.skel_trim;

% Save the pre-filtered skeleton for calculation of the non-zlinefrac
% percentages
pre_filt = prefilt_skel(:); 
pre_filt(pre_filt == 0) = []; 
pre_filt = length(pre_filt); 

%%%%%%%%%%%%%%%%%% Loop through all explore options %%%%%%%%%%%%%%%%%%%%%%%

%Start a counter 
n = 0; 
%Loop through grids
for g = 1:gtot
    
    %Set the grid size to the current grid size 
    settings.grid_size(1) = unique_grids(g); 
    settings.grid_size(2) = unique_grids(g); 
    
    %Save the actin_struct
    actin_struct = im_struct.actin_struct; 
    
    % Compute the director for each grid 
    [ actin_struct.dims, actin_struct.oop, actin_struct.director, ...
        actin_struct.grid_info, actin_struct.visualization_matrix, ...
        actin_struct.director_matrix] = ...
        gridDirector( actin_struct.actin_orientim, settings.grid_size );
    
    %Resave the actin_struct in the image struct
    im_struct.actin_struct = actin_struct; 
    
    % Save the image of the actin directors on top of the z-lines  
    if settings.disp_actin
        % Visualize the actin director on top of the z-line image by first
        % displaying the z-line image and then plotting the orinetation 
        %vectors. 
        figure;
        spacing = 15; color_spec = 'b'; 
        plotOrientationVectors(actin_struct.visualization_matrix,...
            mat2gray(im_struct.im_gray),spacing, color_spec) 

        % Save figure 
        saveas(gcf, fullfile(image_savepath, ...
            strcat( im_struct.im_name, '_zlineActinDirector_GRID', ...
            num2str(unique_grids(g)),'.tif')), 'tiffn');
    end 
    
    %Take the dot product sqrt(cos(th1 - th2)^2);
    im_struct.dp = ...
        sqrt(cos(im_struct.orientim - actin_struct.director_matrix).^2);
    
    
    % Start a counter for just actin thresholds 
    actin_explore.n = 0; 
    
    %Create a cell to store all of the orientation matrices
    actin_explore.orientims = cell(attot, 1);
    
    %Create a matrix to store all of the threshold values
    actin_explore.thresholds = zeros(attot, 1);    
    
    %Loop through the actin thresholds 
    for a = 1:attot
        %Increase the counter for the total matrix 
        n = n+1; 
        
        %Increase actin threshold counter
        actin_explore.n = actin_explore.n+1; 
        
        %Store the current grid size
        thresholds(n,1) = unique_thresh(a);  

        %Store the current actin threshold
        grid_sizes(n,1) = unique_grids(g);   
        
        %If there is more than one grid size, create a new folder 
        if settings.grid_explore && a == 1 
            %Create a new path to store grid size explorations 
            new_subfolder = strcat('Exploration_Size', ...
                num2str(unique_grids(g)));

            % If it does not exist, create it (or append and then create). 
            create = true; 
            new_subfolder = ...
                addDirectory( image_savepath, new_subfolder, create ); 

            %Save the new path
            actin_explore.grid_savepath = ...
                fullfile(image_savepath, new_subfolder); 

            %Change the save_path to the new directory 
            im_struct.save_path = actin_explore.grid_savepath;
            
            %Set path for the continuous z-line 
            actin_explore.save_path = actin_explore.grid_savepath;             
        end 
        
        %If there is more than one actin threshold, create a new folder  
        if settings.actinthresh_explore && a == 1
            % Create a new directory to store all data
            new_subfolder = 'ActinFilteringExploration';

            % If it does not exist, create it (or append and then create). 
            create = true; 
            new_subfolder = ...
                addDirectory( im_struct.save_path, new_subfolder, create ); 

            % Save the name of the new path 
            actin_explore.save_path = fullfile(im_struct.save_path, ...
                new_subfolder); 
            
            %Create a temporary save_name 
            save_name = strcat(im_struct.im_name, '_ACTINthresh', ...
                num2str(actin_explore.n));

        end 
        
            %Create a matrix to store the mask 
            mask = ones(size(im_struct.orientim)); 

            %If dot product is closer to 1, the angles are more parallel 
            %and should be removed
            mask(im_struct.dp >= thresholds(n,1) ) = 0; 
            %If dot product is closer to 0, the angles are more 
            %perpendicular andshould be kept
            mask(im_struct.dp < thresholds(n,1) ) = 1; 

            %The NaN postitions should be set equal to 1 (meaning no 
            %director for actin)
            mask(isnan(mask)) = 1; 

            %Store the mask in the masks cell
            masks{n,1} = mask; 
    
            %Modify the final skeleton by multiplying by the maks 
            final_skels{n,1} = prefilt_skel.*mask; 
    
            % Remove regions that were not part of the binary skeleton
            temp_orientim = im_struct.orientim; 
            temp_orientim(~final_skels{n,1}) = NaN; 
            
            %Store the orientation matrix in the global matrix 
            orientims{n,1} = temp_orientim; 
    
            % Save the mask. 
            imwrite( mask, fullfile(actin_explore.save_path, ...
                strcat( save_name, '_Mask.tif' ) ),...
                'Compression','none');

            % Save the final skeleton. 
            imwrite(final_skels{n,1}, ...
                fullfile(actin_explore.save_path, ...
                strcat( save_name, '_Skeleton.tif' ) ),...
                'Compression','none');
    
            % Isolate the number of pixels in the post filtering skeleton 
            temp_post = final_skels{n,1};
            temp_post = temp_post(:);
            temp_post(temp_post == 0) = []; 
            post_filt(n,1) = length(temp_post); 
    
            % Calculate the non-sarcomeric alpha actinin 
            % number of pixles eliminated / # total # of pixles positive 
            % for alpha actinin 
            non_zlinefracs(n,1) = (pre_filt - post_filt(n,1))./pre_filt;
            zlinefracs(n,1) = 1 - non_zlinefracs(n,1); 
            
            %Save the threshold value 
            actin_explore.actin_thresh(actin_explore.n,1) = thresholds(n,1);
    
            %Close all figures
            close all; 
            
            %For the continuous z-line lengths store the orientation matrix
            actin_explore.orientims{actin_explore.n,1} = orientims{n,1};
            
            %For the continuous z-line lengths store the threshold values 
            actin_explore.thresholds(actin_explore.n,1) = unique_thresh(a);
            
            %For the continuous z-lien lengths store the actin_explore 
            %struct inside of the im_struct
            im_struct.actin_explore = actin_explore; 
            
            if settings.tf_CZL
                % Calculate the continuous z-line lengths 
                lengths{n,1} = zlineCZL(im_struct, settings);

                %Clear the command line 
                clc 

                %Close all figures
                close all; 

                %Find the median continuous z-line length
                medians(n,1) = median(lengths{n,1});
                %Find the sum continuous z-line length
                sums(n,1) = sum(lengths{n,1});

            else
                lengths{n,1} = NaN; 
                medians(n,1) = NaN; 
                sums(n,1) = NaN; 
            end 
    end
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%% Plot and Save Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Replace the value of the im_struct back to what it was 
im_struct.save_path = image_savepath; 

% Save all of the relevant data in the actin_explore struct 
actin_explore.non_zlinefracs = non_zlinefracs; 
actin_explore.zlinefracs = zlinefracs; 
actin_explore.medians = medians; 
actin_explore.sums = sums;
actin_explore.thresholds = thresholds;   
actin_explore.grid_sizes = grid_sizes;     
actin_explore.masks = masks; 
actin_explore.lengths = lengths;
actin_explore.final_skels = final_skels;
actin_explore.orientims = orientims;
actin_explore.post_filt = post_filt; 
actin_explore.prefilt_skel = prefilt_skel;
actin_explore.pre_filt = pre_filt; 

% Create a name to save the file 
summary_name = strcat(im_struct.im_name, '_ActinExploration.mat');

% If the filename exists, add a number until it doesn't 
summary_name = appendFilename( im_struct.save_path, summary_name ); 

% Save the data (append on each iteration)
save(fullfile(im_struct.save_path, summary_name), ...
    'im_struct', 'settings', 'actin_explore');

% Summarize the analysis 
%actinExplorePlots( im_struct, actin_explore, settings ); 

end