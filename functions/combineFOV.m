% function [ output_args ] = combineFOV( settings, zline_images, zline_path )
%This function will combine the FOV for a coverslip. 

%(1) The user did both a grid exploration with an actin threshold 
% exploration 

tic

if settings.actin_thresh > 1 && settings.grid_explore
     
    % Loop through all of the z-line image paths and names 
    for z = 1:length(zline_images)
        
        %Display message
        dispmsg = strcat('Image ', num2str(z), ' of ', ...
            num2str(length(zline_images)));
        disp(dispmsg);
        toc
        
        %Get the parts of the file 
        [ path, file, ext ] = ...
            fileparts( fullfile(zline_path{1}, zline_images{z}) );

        %Path location 
        save_path = fullfile(path, file); 
        
        %Grid name
        grid_name = strcat(file, '_GridActinExploration.mat'); 
        
        %Load the Grid Actin Exploration 
        grid_data = load(fullfile(save_path,grid_name)); 
        
        %Store the grid sizes and actin thresholds 
        summary_explore = grid_data.summary_explore;
        %Grid sizes
        grid_sizes = summary_explore.grid_sizes;
        %Actin thresholds
        actin_thresh = summary_explore.actin_thresh;
        actin_thresh = actin_thresh{1};
        %The pre-filtered image 
        im_struct = grid_data.im_struct; 
        pre_filtered = im_struct.skelTrim;
        pre_filtered = pre_filtered(:); 
        pre_filtered(pre_filtered == 0) = [];  

        %If z = 1, initialize matrices
        if z == 1
            %Start a counter 
            n = 1; 
            
            %Get the total number of rows needed for the cells/arrays.
            tot = length(zline_images)*size(actin_thresh,1)*...
                size(grid_sizes,1);
            
            %>>> ARRAYS
            non_sarcs = zeros(tot,1);
            medians = zeros(tot,1);
            sums = zeros(tot,1);
            
            %Get the pre_filtering (n,1) and post_filtering (n,2) lengths
            nonsarc_data = zeros(tot,2); 
            %Get the grid_sizes (n,1) and the actin_thresholds (n,2) 
            exploration_values = zeros(tot,2);  
            %>>> CELLS
            filenames = cell(tot,1);
            lengths = cell(tot,1); 
            
        end 
        
        %Loop through all of the grid sizes 
        for g = 1:size(grid_sizes,1)
            %Actin save_path
            actin_savepath = fullfile(save_path,...
                strcat('Exploration_Size', num2str(grid_sizes(g)))); 
            %Load the actin exploration path 
            actinexplore_data = load(fullfile(actin_savepath, ...
                strcat(file, '_ActinExploration.mat'))); 
            
            %Save actin_explore
            actin_explore = actinexplore_data.actin_explore; 
            
            
            %Loop through and save all of the actin_thresholds 
            for f = 1: size(actin_thresh,1)
                %Store the current grid size
                exploration_values(n,1) = grid_sizes(g,1); 
                %Store the current actin threshold 
                exploration_values(n,2) = actin_thresh(f,1); 
                %Store the current filename 
                filenames{n,1} = strcat(file, ext); 
                
                %Individually calculated values
                non_sarcs(n,1) = actin_explore.non_sarcs(f,1);
                medians(n,1)= actin_explore.medians(f,1);
                sums(n,1)= actin_explore.sums(f,1);
                
                %Get the pre_filtering (n,1) lengths
                nonsarc_data(n,1) = length(pre_filtered);
            
                %Get the post_filtering (n,1) lengths
                post_filt = actin_explore.final_skels{f,1};
                post_filt = post_filt(:);
                post_filt(post_filt == 0) = [];    
                nonsarc_data(n,2) = length(post_filt);
                
                %Store the lengths
                lengths{n,1} = actin_explore.lengths{f,1};
                
                %Increase the count 
                n = n+1;
                
            end 
            
            
% pre_filt = im_struct.skel_final; 
% pre_filt = pre_filt(:); 
% pre_filt(pre_filt == 0) = [];             
% Isolate the number of pixels in the post filtering skeleton 
%     post_filt = actin_explore.final_skels{actin_explore.n,1};
%     post_filt = post_filt(:);
%     post_filt(post_filt == 0) = []; 
%     
%     % Calculate the non-sarcomeric alpha actinin 
%     % number of pixles eliminated / # total # of pixles positive for alpha
%     % actinin 
%     actin_explore.non_sarcs(actin_explore.n,1) = ...
%         (length(pre_filt) - length(post_filt))/ ...
%         length(pre_filt);
    
        end 
        
    end 
else
    disp('Not yet implemented...'); 
end 

toc

% settings.tf_CZL
%(2) The user only did a actin threshold exploration 

%(3) THe user did not do any exploration 


% end

