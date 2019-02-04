function [CS_results] = combineFOV( settings, CS_results )
% This function will combine the FOV for a single coverslip

%%%%%%%%%%%%%%%%%%%% Convert Cells to Matrices %%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Properly ordered FOV values
FOV_Grouped = struct; 

%>>> ACTIN FILTERING: Non Sarc Fractions (NO EXPLORATION) 
FOV_Grouped.FOV_nonsarc = concatCells( CS_results.FOV_nonsarc, true ); 

%>>> ACTIN FILTERING: Continuous z-line length (NO EXPLORATION) 
FOV_Grouped.FOV_medians = concatCells( CS_results.FOV_medians, true ); 
FOV_Grouped.FOV_sums = concatCells( CS_results.FOV_sums, true ); 

%>>> ACTIN FILTERING: OOP (NO EXPLORATION) 
FOV_Grouped.FOV_OOPs = concatCells( CS_results.FOV_OOPs, true );  

%>>> EXPLORATION
FOV_Grouped.FOV_thresholds = ...
    concatCells( CS_results.FOV_thresholds, true );  
FOV_Grouped.FOV_grid_sizes = ...
    concatCells( CS_results.FOV_grid_sizes, true );  

%Get unique threshold values 
unique_thresh = unique(FOV_Grouped.FOV_thresholds); 
attot = length(unique_thresh); 
%Get unique grid sizes
unique_grids = unique(FOV_Grouped.FOV_grid_sizes); 
gtot = length(unique_grids); 

%Get the number of FOV 
zn = length(CS_results.zline_images); 

%Get the total number of conditions 
tot = attot*gtot; 

%>>> Specially Group data (more than 1 value that are inconsistently valued
FOV_Grouped.FOV_lengths = cell(zn,tot);
FOV_Grouped.FOV_angles = cell(zn,tot);  
FOV_Grouped.FOV_prefiltered = cell(zn,tot);
FOV_Grouped.FOV_postfiltered = cell(zn,tot);

%%%%%%%%%%%%%%%%%%%%%%%% Initialize Matrices  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%>>> Continuous Z-line Length
CS_results.CS_lengths = cell(1,tot); 
CS_results.CS_medians = zeros(1,tot); 
CS_results.CS_sums = zeros(1,tot);  
% FOV_lengths = cell(1,tot); 
CS_results.FOVstats_medians = zeros(2,tot); %1: mean 2: stdev 
CS_results.FOVstats_sums = zeros(2,tot);  %1: mean 2: stdev 

%>>> Non Sarc Fractions 
CS_results.CS_nonsarc = zeros(1,tot);
CS_results.FOVstats_nonsarc = zeros(2,tot);%1: mean 2: stdev 

%>>> OOP 
CS_results.CS_angles = cell(1,tot); 
CS_results.CS_OOPs = zeros(1,tot);
CS_results.FOVstats_OOPs = zeros(2,tot);%1: mean 2: stdev 

%>>> EXPLORATION
CS_results.CS_thresholds = zeros(1,tot);
CS_results.CS_gridsizes = zeros(1,tot);

%Loop through all of the conditions 
for z = 1:zn 
    %Store the information for the current image 
    current_prefilt = CS_results.FOV_prefiltered{1,z};
    current_postfilt = CS_results.FOV_postfiltered{1,z};
    current_lengths = CS_results.FOV_lengths{1,z};
    current_angles = CS_results.FOV_angles{1,z};
    current_grids = CS_results.FOV_grid_sizes{1,z};
    current_threshs = CS_results.FOV_thresholds{1,z}; 
        
    %Start a counter 
    n = 1;

    for g = 1:gtot
        %Set include grids to be the same size as the current grid
        include_grid = zeros(size(current_grids)); 
        %Set the values that are not equal to unique grid value equal to
        %NaN; 
        include_grid(current_grids ~= unique_grids(g)) = NaN;
        
        
        %First iteration, concat matrices to get statistics 
        if z == 1
            %Get grid values to exclude 
            exlude_grids = zeros(1,tot*zn); 
            exlude_grids(FOV_Grouped.FOV_grid_sizes ~= ...
                unique_grids(g)) = NaN; 
        end
        
        for a = 1:attot
            %Set include thresh to be the same size as the current grid
            include_thresh = zeros(size(current_threshs)); 
            %Set the values that are not equal to unique grid value equal 
            %to NaN; 
            include_thresh(current_threshs ~= unique_thresh(a)) = NaN;
            
            %Add the include values for the grid and thresholds
            include = include_thresh + include_grid; 
            
            %Find the position where include is not NaN 
            p = find(isnan(include)); 
            
            %Store the values at the current grids 
            FOV_Grouped.FOV_lengths{z,n} = current_lengths{1,p};
            FOV_Grouped.FOV_angles{z,n} = current_angles{1,p};
            FOV_Grouped.FOV_prefiltered{z,n} = current_prefilt{1,p};
            FOV_Grouped.FOV_postfiltered{z,n} = current_postfilt{1,p};
            
            %First iteration, concat matrices to get statistics 
            if z == 1 
                %Get threshold values to exclude 
                exlude_thresh = zeros(1,tot*zn); 
                exlude_thresh(FOV_Grouped.FOV_thresholds ~= ...
                    unique_thresh(a)) = NaN; 
            
                %Store the current grid and threshold values 
                CS_results.CS_gridsizes(1,n) = unique_grids(g); 
                CS_results.CS_thresholds(1,n) = unique_thresh(a);
                
                %Store the median, sums, nonsarc and OOPs that are included
                include_medians = FOV_Grouped.FOV_medians ...
                    + exlude_grids + exlude_thresh; 
                include_medians(isnan(include_medians)) = []; 
                include_sums = FOV_Grouped.FOV_sums ...
                    + exlude_grids + exlude_thresh;  
                include_sums(isnan(include_sums)) = []; 
                include_nonsarc = FOV_Grouped.FOV_nonsarc ...
                    + exlude_grids + exlude_thresh; 
                include_nonsarc(isnan(include_nonsarc)) = []; 
                include_OOP = FOV_Grouped.FOV_OOPs ...
                    + exlude_grids + exlude_thresh;  
                include_OOP(isnan(include_OOP)) = []; 
                
                %Get the FOV stats 1: mean 2: stdev 
                CS_results.FOVstats_medians(1,n) = mean(include_medians);
                CS_results.FOVstats_medians(2,n) = std(include_medians);
                CS_results.FOVstats_sums(1,n) = mean(include_sums); 
                CS_results.FOVstats_sums(2,n) = std(include_sums); 
                CS_results.FOVstats_nonsarc(1,n) = mean(include_nonsarc);
                CS_results.FOVstats_nonsarc(2,n) = std(include_nonsarc); 
                CS_results.FOVstats_OOPs(1,n) = mean(include_OOP); 
                CS_results.FOVstats_OOPs(2,n) = std(include_OOP); 
            end              
            %Increase counter 
            n = n+1; 
                
        end 
    end
end 

%Loop through and calculate the values for all of the different combination  
for t = 1:tot
    
    %Continuous Z-line Values 
    CS_results.CS_lengths{1,t} = concatCells( FOV_Grouped.FOV_lengths{:,t}, false );
    CS_results.CS_medians(1,t) = median(CS_results.CS_lengths{1,t}); 
    CS_results.CS_sums(1,t) = sum(CS_results.CS_lengths{1,t});   
    
    %Get the OOPs
    CS_results.CS_angles{1,t} = concatCells( FOV_Grouped.FOV_angles{:,t}, true );
    temp_angles = CS_results.CS_angles{1,t}; 
    temp_angles(isnan(temp_angles)) = 0;
    [CS_results.CS_OOPs(1,t), ~, ~, ~ ] = calculate_OOP( temp_angles ); 
    
    %Get the pre and post filtered values for the non_sarc fraction 
    pre_filt = concatCells( FOV_Grouped.FOV_prefiltered{:,t}, false ); 
    post_filt = concatCells( FOV_Grouped.FOV_postfiltered{:,t}, false );
    
    %Make sure there are no zeros
    post_filt(post_filt == 0) = []; 
    pre_filt(pre_filt == 0) = []; 

    %Calculate the non-sarc fraction 
    CS_results.CS_nonsarc{1,t} = ...
        (length(pre_filt) - length(post_filt))/ length(pre_filt);
        
end 

%Store the FOV_Grouped struct 
CS_results.FOV_Grouped = FOV_Grouped; 

%Plot the CZL median results

%Plot the CZL sum results 

%Plot the non-sarc fraction results 

%Plot the OOP results



% if settings.actin_thresh > 1 && settings.grid_explore
%      
%     % Loop through all of the z-line image paths and names 
%     for z = 1:length(zline_images)
%         
%         %Display message
%         dispmsg = strcat('Image ', {' '},num2str(z), ' of ', {' '}, ...
%             num2str(length(zline_images)));
%         disp(dispmsg);
%         toc
%         
%         %Get the parts of the file 
%         [ path, file, ext ] = ...
%             fileparts( fullfile(zline_path{1}, zline_images{z}) );
% 
%         %Path location 
%         save_path = fullfile(path, file); 
%         
%         %Grid name
%         grid_name = strcat(file, '_GridActinExploration.mat'); 
%         
%         %Load the Grid Actin Exploration 
%         grid_data = load(fullfile(save_path,grid_name)); 
%         
%         %Store the grid sizes and actin thresholds 
%         summary_explore = grid_data.summary_explore;
%         %Grid sizes
%         grid_sizes = summary_explore.grid_sizes;
%         %Actin thresholds
%         actin_thresh = summary_explore.actin_thresh;
%         actin_thresh = actin_thresh{1};
%         %The pre-filtered image 
%         im_struct = grid_data.im_struct; 
%         pre_filtered = im_struct.skelTrim;
%         pre_filtered = pre_filtered(:); 
%         pre_filtered(pre_filtered == 0) = [];  
% 
%         %If z = 1, initialize matrices
%         if z == 1
%             %Start a counter 
%             n = 1; 
%             
%             %Get the total number of rows needed for the cells/arrays.
%             tot = length(zline_images)*size(actin_thresh,1)*...
%                 size(grid_sizes,1);
%             
%             %>>> ARRAYS
%             non_sarcs = zeros(tot,1);
%             medians = zeros(tot,1);
%             sums = zeros(tot,1);
%             
%             %Get the pre_filtering (n,1) and post_filtering (n,2) lengths
%             nonsarc_data = zeros(tot,2); 
%             %Get the grid_sizes (n,1) and the actin_thresholds (n,2) 
%             exploration_values = zeros(tot,2);  
%             %>>> CELLS
%             filenames = cell(tot,1);
%             lengths = cell(tot,1); 
%             
%         end 
%         
%         %Loop through all of the grid sizes 
%         for g = 1:size(grid_sizes,1)
%             %Actin save_path
%             actin_savepath = fullfile(save_path,...
%                 strcat('Exploration_Size', num2str(grid_sizes(g)))); 
%             %Load the actin exploration path 
%             actinexplore_data = load(fullfile(actin_savepath, ...
%                 strcat(file, '_ActinExploration.mat'))); 
%             
%             %Save actin_explore
%             actin_explore = actinexplore_data.actin_explore; 
%             
%             %Loop through and save all of the actin_thresholds 
%             for f = 1:size(actin_thresh,1)
%                 
%                 %Calculate the position 
%                 p = 1 + (z-1) + ...
%                     length(zline_images)*size(grid_sizes,1)*(f-1) + ...
%                     length(zline_images)*(g-1); 
%                 %Store the current grid size
%                 exploration_values(p,1) = grid_sizes(g,1); 
%                 %Store the current actin threshold 
%                 exploration_values(p,2) = actin_thresh(f,1); 
%                 %Store the current filename 
%                 filenames{p,1} = strcat(file, ext); 
%                 
%                 %Individually calculated values
%                 non_sarcs(p,1) = actin_explore.non_sarcs(f,1);
%                 medians(p,1)= actin_explore.medians(f,1);
%                 sums(p,1)= actin_explore.sums(f,1);
%                 
%                 %Get the pre_filtering (n,1) lengths
%                 nonsarc_data(p,1) = length(pre_filtered);
%             
%                 %Get the post_filtering (n,1) lengths
%                 post_filt = actin_explore.final_skels{f,1};
%                 post_filt = post_filt(:);
%                 post_filt(post_filt == 0) = [];    
%                 nonsarc_data(p,2) = length(post_filt);
%                 
%                 %Store the lengths
%                 lengths{p,1} = actin_explore.lengths{f,1};
%                 
%                 %Increase the count 
%                 n = n+1;
%                 
%             end 
%     
%         end 
%         
%     end
%     
%     %Initialize matrices to store the median, sum, nonsarc, grid values
%     CS_median = zeros(size(actin_thresh,1)*size(grid_sizes,1),1); 
%     CS_sum = zeros(size(actin_thresh,1)*size(grid_sizes,1),1); 
%     CS_nonsarc = zeros(size(actin_thresh,1)*size(grid_sizes,1),1); 
%     CS_explorevalues = zeros(size(actin_thresh,1)*size(grid_sizes,1),2); 
%     CS_lengths = cell(size(actin_thresh,1)*size(grid_sizes,1),1);
%     %Summarize values
%     for cond = 1:size(actin_thresh,1)*size(grid_sizes,1)
%         %Number of values for each condition 
%         n = length(zline_images); 
%         %Get the start and end positions
%         pa = 1 + (cond - 1)*n; 
%         po = cond*n;
%         
%         %Get the lengths
%         temp_l = concatCells( lengths, false, pa, po); 
%         %Store all of the lengths
%         CS_lengths{cond,1} = temp_l; 
%         %Calculate the median czl 
%         CS_median(cond,1) = median(temp_l); 
%         %Calculate the sum czl 
%         CS_sum(cond,1) = sum(temp_l); 
%         %Calculate the non sarc fracion 
%         CS_nonsarc(cond,1) = ...
%             (sum(nonsarc_data(pa:po,1)) -sum(nonsarc_data(pa:po,2)))/...
%             sum(nonsarc_data(pa:po,1)); 
%         
%         
%         %Save the exploration values
%         %Grid sizes
%         CS_explorevalues(cond,1) = exploration_values(pa,1); 
%         CS_explorevalues(cond,2) = exploration_values(pa,2); 
%     end 
%     
%     %Get date
%     date_format = 'yyyymmdd';
%     today_date = datestr(now,date_format);
%     new_filename = strcat('CS_Summary',today_date,'.mat'); 
%     
%     %Create a struct to store values of the coverslip
%     CS_actinexplore = struct(); 
%     CS_actinexplore.CS_median = CS_median; 
%     CS_actinexplore.CS_sum = CS_sum; 
%     CS_actinexplore.CS_nonsarc = CS_nonsarc; 
%     CS_actinexplore.CS_explorevalues = CS_explorevalues; 
%     CS_actinexplore.CS_lengths = CS_lengths; 
%     %Create a struct to store values of all FOV in the coverslip
%     FOV_actinexplore = struct(); 
%     FOV_actinexplore.non_sarcs = non_sarcs; 
%     FOV_actinexplore.medians = medians;
%     FOV_actinexplore.sums = sums; 
%     FOV_actinexplore.nonsarc_data = nonsarc_data;
%     FOV_actinexplore.exploration_values = exploration_values;
%     FOV_actinexplore.filenames =filenames; 
%     FOV_actinexplore.lengths = lengths;  
%     
%     %Save the results. Create a new .mat file if it does not exist. Append
%     %it otherwise 
%     if exist(fullfile(path, new_filename),'file') == 2
%         save(fullfile(path, new_filename), 'CS_actinexplore',...
%             'FOV_actinexplore', '-append');
%     else
%         save(fullfile(path, new_filename), 'CS_actinexplore',...
%             'FOV_actinexplore');
%     end 
%     
%     %Plot the median results 
%     names = struct(); 
%     names.x = 'Actin Filtering Threshold'; 
%     names.y = 'Median Continuous Z-line Lengths (\mu m)';
%     names.title = 'Coverslip: Median Continuous Z-line Lengths';
%     names.savename = 'CS_MedianSummary'; 
%     names.path = path; 
%     plotCSresults( CS_explorevalues, medians,CS_median, n, names ); 
%     close; 
%     
%     %Plot the sum results 
%     names.y = 'Total Continuous Z-line Lengths (\mu m)';
%     names.title = 'Coverslip: Mean Total Continuous Z-line Lengths';
%     names.savename = 'CS_AverageTotalSummary'; 
%     plotCSresults( CS_explorevalues, sums, CS_sum, n, names ); 
%     close; 
%     
%     names.title = 'Coverslip: Total Continuous Z-line Lengths';
%     names.savename = 'CS_TotalSummary'; 
%     plotCSresults( CS_explorevalues, [], CS_sum, n, names ); 
%     close; 
%     
%     %Plot the non_sarc fraction results
%     names.y = 'Non-Sarc Fraction';
%     names.title = 'Coverslip: Non Sarc Fraction';
%     names.savename = 'CS_NonSarcSummary'; 
%     plotCSresults( CS_explorevalues, non_sarcs, CS_nonsarc, n, names ); 
%     close; 
%     
%     %Save the names and settings
%     save(fullfile(path, new_filename), 'settings', 'zline_images',...
%         'zline_path', '-append');
%     
% else
%     disp('Not yet implemented...'); 
% end 


end 
