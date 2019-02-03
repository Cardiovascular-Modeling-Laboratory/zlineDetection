function [CS_results] = combineFOV( settings, CS_results )
% This function will combine the FOV for a single coverslip


%Get unique threshold values 
unique_thresh = unique(CS_results.FOV_thresholds); 
attot = length(unqiue_thresh); 
%Get unique grid sizes
unique_grids = unique(CS_results.FOV_grid_sizes); 
gtot = length(unique_grids); 

%Get the number of FOV 
zn = length(CS_results.zline_images); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CZL  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot continuous z-line lengths and median of all lengths


% % Get the number of different grids. If there was no grid exploration, this
% % value is just equal to 1. 
% if ~grid_explore
%     % Set the number of different grid options equal to 1
%     gn = 1; 
%     % Set the grid sizes equal to the GUI input value 
%     grid_sizes = settings.grid_size(1); 
% end 
% 
% % Get the number of different actin thresholds. If there was no actin
% % exploration this value is equal to 1 
% if ~actinthresh_explore
%     % Set the number of different actin threshold options equal to 1 
%     an = 1; 
%     % Set the actin threshold equal to the GUI input value 
%     thresh_vals = settings.actin_thresh; 
% end 
% 
% 




%NON-SARC 

%CZL 

%OOP







% If the user did an exploration value get the values 


% (1) The user did both a grid exploration with an actin threshold 
% exploration 

tic

if settings.actin_thresh > 1 && settings.grid_explore
     
    % Loop through all of the z-line image paths and names 
    for z = 1:length(zline_images)
        
        %Display message
        dispmsg = strcat('Image ', {' '},num2str(z), ' of ', {' '}, ...
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
            for f = 1:size(actin_thresh,1)
                
                %Calculate the position 
                p = 1 + (z-1) + ...
                    length(zline_images)*size(grid_sizes,1)*(f-1) + ...
                    length(zline_images)*(g-1); 
                %Store the current grid size
                exploration_values(p,1) = grid_sizes(g,1); 
                %Store the current actin threshold 
                exploration_values(p,2) = actin_thresh(f,1); 
                %Store the current filename 
                filenames{p,1} = strcat(file, ext); 
                
                %Individually calculated values
                non_sarcs(p,1) = actin_explore.non_sarcs(f,1);
                medians(p,1)= actin_explore.medians(f,1);
                sums(p,1)= actin_explore.sums(f,1);
                
                %Get the pre_filtering (n,1) lengths
                nonsarc_data(p,1) = length(pre_filtered);
            
                %Get the post_filtering (n,1) lengths
                post_filt = actin_explore.final_skels{f,1};
                post_filt = post_filt(:);
                post_filt(post_filt == 0) = [];    
                nonsarc_data(p,2) = length(post_filt);
                
                %Store the lengths
                lengths{p,1} = actin_explore.lengths{f,1};
                
                %Increase the count 
                n = n+1;
                
            end 
    
        end 
        
    end
    
    %Initialize matrices to store the median, sum, nonsarc, grid values
    CS_median = zeros(size(actin_thresh,1)*size(grid_sizes,1),1); 
    CS_sum = zeros(size(actin_thresh,1)*size(grid_sizes,1),1); 
    CS_nonsarc = zeros(size(actin_thresh,1)*size(grid_sizes,1),1); 
    CS_explorevalues = zeros(size(actin_thresh,1)*size(grid_sizes,1),2); 
    CS_lengths = cell(size(actin_thresh,1)*size(grid_sizes,1),1);
    %Summarize values
    for cond = 1:size(actin_thresh,1)*size(grid_sizes,1)
        %Number of values for each condition 
        n = length(zline_images); 
        %Get the start and end positions
        pa = 1 + (cond - 1)*n; 
        po = cond*n;
        
        %Get the lengths
        temp_l = concatCells( lengths, false, pa, po); 
        %Store all of the lengths
        CS_lengths{cond,1} = temp_l; 
        %Calculate the median czl 
        CS_median(cond,1) = median(temp_l); 
        %Calculate the sum czl 
        CS_sum(cond,1) = sum(temp_l); 
        %Calculate the non sarc fracion 
        CS_nonsarc(cond,1) = ...
            (sum(nonsarc_data(pa:po,1)) -sum(nonsarc_data(pa:po,2)))/...
            sum(nonsarc_data(pa:po,1)); 
        
        
        %Save the exploration values
        %Grid sizes
        CS_explorevalues(cond,1) = exploration_values(pa,1); 
        CS_explorevalues(cond,2) = exploration_values(pa,2); 
    end 
    
    %Get date
    date_format = 'yyyymmdd';
    today_date = datestr(now,date_format);
    new_filename = strcat('CS_Summary',today_date,'.mat'); 
    
    %Create a struct to store values of the coverslip
    CS_actinexplore = struct(); 
    CS_actinexplore.CS_median = CS_median; 
    CS_actinexplore.CS_sum = CS_sum; 
    CS_actinexplore.CS_nonsarc = CS_nonsarc; 
    CS_actinexplore.CS_explorevalues = CS_explorevalues; 
    CS_actinexplore.CS_lengths = CS_lengths; 
    %Create a struct to store values of all FOV in the coverslip
    FOV_actinexplore = struct(); 
    FOV_actinexplore.non_sarcs = non_sarcs; 
    FOV_actinexplore.medians = medians;
    FOV_actinexplore.sums = sums; 
    FOV_actinexplore.nonsarc_data = nonsarc_data;
    FOV_actinexplore.exploration_values = exploration_values;
    FOV_actinexplore.filenames =filenames; 
    FOV_actinexplore.lengths = lengths;  
    
    %Save the results. Create a new .mat file if it does not exist. Append
    %it otherwise 
    if exist(fullfile(path, new_filename),'file') == 2
        save(fullfile(path, new_filename), 'CS_actinexplore',...
            'FOV_actinexplore', '-append');
    else
        save(fullfile(path, new_filename), 'CS_actinexplore',...
            'FOV_actinexplore');
    end 
    
    %Plot the median results 
    names = struct(); 
    names.x = 'Actin Filtering Threshold'; 
    names.y = 'Median Continuous Z-line Lengths (\mu m)';
    names.title = 'Coverslip: Median Continuous Z-line Lengths';
    names.savename = 'CS_MedianSummary'; 
    names.path = path; 
    plotCSresults( CS_explorevalues, medians,CS_median, n, names ); 
    close; 
    
    %Plot the sum results 
    names.y = 'Total Continuous Z-line Lengths (\mu m)';
    names.title = 'Coverslip: Mean Total Continuous Z-line Lengths';
    names.savename = 'CS_AverageTotalSummary'; 
    plotCSresults( CS_explorevalues, sums, CS_sum, n, names ); 
    close; 
    
    names.title = 'Coverslip: Total Continuous Z-line Lengths';
    names.savename = 'CS_TotalSummary'; 
    plotCSresults( CS_explorevalues, [], CS_sum, n, names ); 
    close; 
    
    %Plot the non_sarc fraction results
    names.y = 'Non-Sarc Fraction';
    names.title = 'Coverslip: Non Sarc Fraction';
    names.savename = 'CS_NonSarcSummary'; 
    plotCSresults( CS_explorevalues, non_sarcs, CS_nonsarc, n, names ); 
    close; 
    
    %Save the names and settings
    save(fullfile(path, new_filename), 'settings', 'zline_images',...
        'zline_path', '-append');
    
else
    disp('Not yet implemented...'); 
end 


end 

% settings.tf_CZL
%(2) The user only did a actin threshold exploration 

%(3) THe user did not do any exploration 


% end

