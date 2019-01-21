function [ actin_explore ] = ...
    exploreGrids(im_struct, settings, actin_explore)
%This function will create a range of grids


%Total number of grids
tot = length(actin.grid_min:actin_explore.grid_step:actin_explore.grid_max);
%Start counter 
n = 0;
%Loop trhough all of the grids 
for grids = round(actin.grid_min:actin_explore.grid_step:actin_explore.grid_max)
    
    %Set the grid size to the current grid size 
    settings.grid_size(1) = grids; 
    settings.grid_size(2) = grids;   
    
    % Compute the director for each grid 
    [ actin_struct.dims, actin_struct.oop, actin_struct.director, ...
        actin_struct.grid_info, actin_struct.visualization_matrix, ...
        actin_struct.director_matrix] = ...
        gridDirector( actin_struct.actin_orientim, settings.grid_size );

    % Save the image 
    if settings.disp_actin
        % Visualize the actin director on top of the z-line image by first
        % displaying the z-line image and then plotting the orinetation 
        %vectors. 
        figure;
        spacing = 15; color_spec = 'b'; 
        plotOrientationVectors(actin_struct.visualization_matrix,...
            mat2gray(im_struct.gray),spacing, color_spec) 

        % Save figure 
        saveas(gcf, fullfile(im_struct.save_path, ...
            strcat( im_struct.im_name, '_zlineActinDirector_GRID', ...
            num2str(grids),'.tif')), 'tiffn');
    end 

    %On the first iteration, save pure version of outputs from the previous
    %analysis 
    if n == 0
        %Save pure versions of the orientation matrix 
        orientim = im_struct.orientim; 
        %Final skeleton 
        skel_final = im_struct.skel_final;
        %Old save path 
        old_sp = im_struct.save_path; 
        % Save the pre-filtered skeleton for calculation of the non-sarc
        % percentages
        pre_filt = im_struct.skel_final; 
        pre_filt = pre_filt(:); 
        pre_filt(pre_filt == 0) = []; 
         
    end        
    
    %Take the dot product sqrt(cos(th1 - th2)^2);
    im_struct.dp = ...
        sqrt(cos(orientim - actin_struct.director_matrix).^2); 
    
    %Check to see if this is a actin threshold exploration as well
    if settings.actin_thresh > 1
        %Increase counter
        n = n+1;
        
        if n == 1
            %Create cells to store summary files 
            summary_explore = struct(); 
            
            %Create a cell to store all of the continuous z-line lengths
            summary_explore.non_sarcs = cell(tot, 1); 

            %Create a matrix to store all of the medians 
            summary_explore.medians = cell(tot, 1); 

            %Create a matrix to store all of the sums 
            summary_explore.sums = cell(tot, 1);
            
            %Create a matrix to store all of the threshold values 
            summary_explore.actin_thresh = cell(tot, 1);   
            
            %Create a matrix to store all of the grid sizes
            summary_explore.grid_sizes= zeros(tot, 1);     
        end 
        %Create a new path to store grid size explorations 
        new_subfolder = strcat('Exploration_Size', num2str(grids));

        % If it does not exist, create it (or append and then create). 
        create = true; 
        new_subfolder = ...
            addDirectory( im_struct.save_path, new_subfolder, create ); 
        
        %Save the new path
        actin_explore.grid_savepath = ...
            fullfile(im_struct.save_path, new_subfolder); 

        %Change the save_path to the new directory 
        im_struct.save_path = actin_explore.grid_savepath;  
        
        %Run the explore actin 
        [ actin_explore ] = ...
            exploreFilterWithActin( im_struct, settings, actin_explore); 
        
        %Store the new information 
        summary_explore.non_sarcs{n,1} = actin_explore.non_sarcs; 

        %Create a matrix to store all of the medians 
        summary_explore.medians{n,1} = actin_explore.medians; 

        %Create a matrix to store all of the sums 
        summary_explore.sums{n,1} = actin_explore.sum;
            
        %Create a matrix to store all of the threshold values 
        summary_explore.actin_thresh{n,1} = actin_explore.actin_thresh;   
            
        %Create a matrix to store all of the grid sizes
        summary_explore.grid_sizes(n,1)= actin_explore.grid_sizes;   
            
    else
        %Filter normally 
        
        %Increase the count 
        n = n+1; 
        
        %Initialize saving matrices if the first iteration 
        if n == 1
            
            %Create a cell to store all of the masks
            actin_explore.masks = cell(tot, 1); 

            %Create a cell to store all of the final skeletons
            actin_explore.final_skels = cell(tot, 1); 

            %Create a cell to store all of the orientation matrices
            actin_explore.orientims = cell(tot, 1); 

            %Create a cell to store all of the continuous z-line lengths
            actin_explore.lengths = cell(tot, 1); 

            %Create a matrix to store all of the medians 
            actin_explore.medians = zeros(tot, 1); 

            %Create a matrix to store all of the sums 
            actin_explore.sums = zeros(tot, 1); 

            %Create a matrix to store all of the non-sarc percentages 
            actin_explore.non_sarcs = zeros(tot, 1); 
            
        end 
        
        %On the final iteration, save the information 
        mask = ones(size(orientim)); 
        
        %If dot product is closer to 1, the angles are more parallel and  
        %should be removed
        mask(im_struct.dp >= settings.actin_thresh) = 0; 
        
        %If dot product is closer to 0, the angles are more perpendicular 
        %and should be kept
        mask(im_struct.dp < settings.actin_thresh) = 1; 

        %The NaN postitions should be set equal to 1 (meaning no director 
        %for actin)
        mask(isnan(mask)) = 1; 
        
        %Store the mask in the masks cell
        actin_explore.masks{n,1} = mask; 
    
        %Modify the final skeleton by multiplying by the maks 
        actin_explore.final_skels{n,1} = skel_final.*mask; 
        im_struct.final_skel = skel_final; 
    
        % Remove regions that were not part of the binary skeleton
        im_struct.orientim = orientim; 
        im_struct.orientim(~actin_explore.final_skels{n,1}) = NaN; 
        actin_explore.orientims{n,1} = im_struct.orientim;
        
        % Save the mask. 
        imwrite( mask, fullfile(im_struct.save_path, ...
            strcat( im_struct.im_name, '_Mask_GRID', ...
            num2str(grids),'.tif') ),...
            'Compression','none');

        % Save the final skeleton. 
        imwrite( actin_explore.final_skels{n,1}, ...
            fullfile(im_struct.save_path, ...
            strcat( im_struct.im_name, '_Skeleton_GRID', ...
            num2str(grids),'.tif') ),'Compression','none');
    
        % Isolate the number of pixels in the post filtering skeleton 
        post_filt = actin_explore.final_skels{n,1};
        post_filt = post_filt(:);
        post_filt(post_filt == 0) = []; 
    
        % Calculate the non-sarcomeric alpha actinin 
        % number of pixles eliminated / # total # of pixles positive for alpha
        % actinin 
        actin_explore.non_sarcs(n,1) = ...
            (length(pre_filt) - length(post_filt))/ ...
            length(pre_filt);

        % Calculate the continuous z-line lengths 
        [ actin_explore.lengths{n,1} ] = ...
            continuous_zline_detection(im_struct, settings);
    
        %Close all figures
        close all; 
    
        %Find the median continuous z-line length
        actin_explore.medians(n,1) = ...
            median(actin_explore.lengths{n,1});
        
        %Find the sum continuous z-line length
        actin_explore.sums(n,1) = ...
            sum(actin_explore.lengths{n,1});
        
        %Save the current grid size 
        actin_explore.grid_sizes(n,1) = grids; 
        
    end 

    
    
end 

%Summary and saving data
if settings.actin_thresh > 1
    %Save all of the analysis 
    % Create a name to save the file 
    summary_name = strcat(im_struct.im_name, '_GridActinExploration.mat');

    % If the filename exists, add a number until it doesn't 
    summary_name = appendFilename( old_sp, summary_name ); 

    % Save the data (append on each iteration)
    save(fullfile(old_sp, summary_name), ...
        'im_struct', 'settings', 'actin_explore','summary_explore');
    
else
    
    %Save all of the analysis 
    % Create a name to save the file 
    summary_name = strcat(im_struct.im_name, '_GridActinExploration.mat');

    % If the filename exists, add a number until it doesn't 
    summary_name = appendFilename( im_struct.save_path, summary_name ); 

    % Save the data (append on each iteration)
    save(fullfile(im_struct.save_path, summary_name), ...
        'im_struct', 'settings', 'actin_explore');

end 

end

