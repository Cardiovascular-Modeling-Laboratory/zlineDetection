function [] = runMultipleCoverSlips(settings)
%This function will be used to run multiple coverslips and obtain a summary
%file

%%%%%%%%%%%%%%%%%%%%%%%%%% Initialize Matrices %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Create a cell to hold the coverslip name 
name_CS = cell(settings.num_cs,1);

%Create a cell for zlines
zline_images = cell(settings.num_cs,1);
zline_path = cell(settings.num_cs,1);
zn = zeros(settings.num_cs,1);

%Create a cell for actin
actin_images = cell(settings.num_cs,1);
actin_path = cell(settings.num_cs,1);
an = zeros(settings.num_cs,1);

%Save conditions 
cond = zeros(settings.num_cs,1);

%Set previous path equal to the current location if only one coverslip is
%selected. Otherwise set it to the location where the CS summary should be
%saved 
if settings.num_cs >1 
    previous_path = settings.SUMMARY_path; 
else 
    previous_path = pwd; 
end 

%Initialize matrices to hold analysis information for each coverslip
%Save the medians for each coverslip 
MultiCS_medians = cell(1,settings.num_cs); 
%Save the totals for each coverslip 
MultiCS_sums = cell(1,settings.num_cs); 
%Save the non-sarc fraction for each coverslip 
MultiCS_nonsarc = cell(1,settings.num_cs);
%Save the medians for each coverslip 
MultiCS_grid_sizes = cell(1,settings.num_cs);
MultiCS_actin_threshs = cell(1,settings.num_cs);
%Save the lengths for each coverslip 
MultiCS_lengths = cell(1,settings.num_cs);
%Save the OOP for each coverslip 
MultiCS_OOP = cell(1,settings.num_cs);

%IDs for the different coverslips and conditions 
MultiCS_CSID = cell(1,settings.num_cs); 
MultiCS_CONDID = cell(1,settings.num_cs); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Select Files %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Have the user select the different directories for the coverslips
for k = 1:settings.num_cs 
    
    %Display message telling the user which coverslip they're on 
    disp_message = strcat('Selecting Coverslip',{' '}, num2str(k),...
        {' '}, 'of', {' '}, num2str(settings.num_cs)); 
    disp(disp_message); 
    
    % Prompt the user to select the images they would like to analyze. 
    [ zline_images{k,1}, zline_path{k,1}, zn(k,1) ] = ...
        load_files( {'*w1mCherry*.TIF;*w1mCherry*.tif;*w1Cy7*.tif'}, ...
        'Select images stained for z-lines...', previous_path);
    
    %Temporarily store the path 
    temp_path = zline_path{k,1}; 

    %Get the parts of the path 
    pathparts = strsplit(temp_path{1},filesep);
    
    %Set previous path 
    previous_path = pathparts{1,1}; 
    
    %Go back one folder 
    for p =2:size(pathparts,2)-1
        if ~isempty(pathparts{1,p+1})
            previous_path = fullfile(previous_path, pathparts{1,p}); 
        end 
    end 
    
    %Add a backslash to the beginning of the path in order to use 
    previous_path = strcat(filesep,previous_path);
    
    potential_end = size(pathparts,2); 
    while isempty(pathparts{1,potential_end})
        potential_end = potential_end -1; 
    end 
    %Save the name of the directory 
    name_CS{k,1} = pathparts{1,potential_end}; 
    
    %If the user is actin filtering, have them select the files 
    if settings.actin_filt
        [ actin_images{k,1}, actin_path{k,1}, an(k,1) ] = ...
            load_files( {'*GFP*.TIF;*GFP*.tif'}, ...
            'Select images stained for actin...',zline_path{k,1});

        % If the number of actin and z-line files are not equal,
        % warn the user
        if an ~= zn
            disp(['The number of z-line files does not equal',...
                'the number of actin files.']); 
            disp(strcat('Actin Images: ',{' '}, num2str(an), ...
                'Z-line Images: ',{' '}, num2str(zn))); 
            disp('Press "Run Folder" to try again.'); 
            return; 
        end
    
        % Sort the z-line and actin files. Ideally this means that 
        % they'll be called in the correct order. 
        zline_images{k,1} = sort(zline_images{k,1}); 
        actin_images{k,1} = sort(actin_images{k,1}); 
    
    else
        actin_images = NaN; 
        actin_path = NaN; 
        an = NaN; 
    end  
    
    if settings.multi_cond
        %Declare conditions for the selected coverslip 
        cond(k,1) = ...
            declareCondition(settings.cond_names, k, settings.num_cs); 
    end 
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%% Analyze all CS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Loop through and run each coverslip 
clear k 
for k = 1:settings.num_cs 
    
    %Set the image and path names equal to NaN if the user is not doing
    %actin filtering. 
    if ~settings.actin_filt
        actin_path{k,1} = NaN; 
        actin_images{k,1} = NaN; 
    end 
    
    % Analyze the Coverslip 
    [ CS_results ] = ...
        runDirectory( settings, zline_path{k,1}, zline_images{k,1},...
        actin_path{k,1}, actin_images{k,1}, name_CS{k,1} ); 
    
    if settings.cardio_type == 1
        %Store the results from analyzing each coverslip 
        MultiCS_lengths{1,k} = CS_results.CS_lengths;
        MultiCS_medians{1,k} =CS_results.CS_medians;
        MultiCS_sums{1,k} = CS_results.CS_sums;
        MultiCS_nonsarc{1,k} = CS_results.CS_nonsarc;
        MultiCS_grid_sizes{1,k} = CS_results.CS_gridsizes;
        MultiCS_actin_threshs{1,k} = CS_results.CS_thresholds;
        MultiCS_OOP{1,k} = CS_results.CS_OOPs;    

        %Save coverslip number 
        MultiCS_CSID{1,k} = k*ones(size(CS_results.CS_OOPs)); 
    end
    
    if settings.multi_cond && settings.cardio_type == 1
        %Save the condition ID 
        MultiCS_CONDID{1,k} = ...
            cond(k,1)*ones(size(CS_results.CS_gridsizes));
    end
    
end 

if settings.cardio_type == 1
    %Store in struct
    MultiCS_Data = struct(); 
    MultiCS_Data.MultiCS_lengths=MultiCS_lengths;
    MultiCS_Data.MultiCS_medians=MultiCS_medians;
    MultiCS_Data.MultiCS_sums=MultiCS_sums;
    MultiCS_Data.MultiCS_nonsarc=MultiCS_nonsarc;
    MultiCS_Data.MultiCS_grid_sizes=MultiCS_grid_sizes;
    MultiCS_Data.MultiCS_actin_threshs=MultiCS_actin_threshs;
    MultiCS_Data.MultiCS_OOP=MultiCS_OOP;
    MultiCS_Data.MultiCS_CSID=MultiCS_CSID;
    MultiCS_Data.MultiCS_CONDID=MultiCS_CONDID;
    %Summary name
    summary_name = strcat(settings.SUMMARY_name,'.mat'); 
    %Save the data after making sure it is uniquely named (no overwritting)
    [ new_filename ] = appendFilename( settings.SUMMARY_path,...
        summary_name{1});
    save(fullfile(settings.SUMMARY_path, new_filename),...
        'MultiCS_Data','name_CS','zline_images','zline_path',...
        'cond','settings'); 

    %%%%%%%%%%%%%%%%%%%%%%%%%%% Plot & Save Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %Get all of the scalar valued IDs and values (everything but lengths
    MultiCS_medians = concatCells( MultiCS_Data.MultiCS_medians, true );
    MultiCS_sums = concatCells( MultiCS_Data.MultiCS_sums, true );
    MultiCS_nonsarc = concatCells( MultiCS_Data.MultiCS_nonsarc, true );
    MultiCS_grid_sizes = concatCells( MultiCS_Data.MultiCS_grid_sizes, true );
    MultiCS_actin_threshs = concatCells( MultiCS_Data.MultiCS_actin_threshs, true );
    MultiCS_OOP = concatCells( MultiCS_Data.MultiCS_OOP, true );
    MultiCS_CSN = concatCells( MultiCS_Data.MultiCS_CSID, true );
    MultiCS_Cond = concatCells( MultiCS_Data.MultiCS_CONDID, true );

    %Save a new struct
    MultiCond = struct(); 
    %Save path 
    plot_names.path = settings.SUMMARY_path; 

    %Plot the non-sarc fraction for the conditions if user actin filtered and
    %has more than one condition 
    if settings.actin_filt && settings.multi_cond
        %>>BY CONDITION Plot the mean, standard deviation, and data points 
        %for non_sarc fraction 
        plot_names.type = 'Non-Sarc Fraction';
        if ~settings.actinthresh_explore
            plot_names.x = 'Conditions'; 
        else 
            plot_names.x = 'Actin Filtering Threshold'; 
        end 
        plot_names.y = 'Non-Sarc Fraction';
        plot_names.title = 'Non-Sarc Fraction';
        plot_names.savename = 'MultiCond_NonSarcSummary'; 
        [ MultiCond.CondValues_NonSarc, ...
            MultiCond.CondValues_MeanNonSarc,...
            MultiCond.CondValues_StdevNonSarc ] =...
            plotConditions(MultiCS_nonsarc, MultiCS_Cond, ...
            settings.cond_names,...
            MultiCS_grid_sizes, MultiCS_actin_threshs, plot_names);
    end

    % %Plot the non-sarc fraction for the conditions if user actin filtered and
    % %has more than one coverslip 
    % if settings.actin_filt && settings.num_cs > 1
    %     %>>BY CONDITION Plot the mean, standard deviation, and data points 
    %     %for non_sarc fraction 
    %     plot_names.type = 'Non-Sarc Fraction';
    %     if ~settings.actinthresh_explore
    %         plot_names.x = 'Coverslips'; 
    %     else 
    %         plot_names.x = 'Actin Filtering Threshold'; 
    %     end 
    %     plot_names.y = 'Non-Sarc Fraction';
    %     plot_names.title = 'Non-Sarc Fraction';
    %     plot_names.savename = 'MultiCS_NonSarcSummary'; 
    % %     [ ~, ~,~ ] =...
    % %     plotConditions(MultiCS_nonsarc, MultiCS_CSN, settings.cond_names,...
    % %     MultiCS_grid_sizes, MultiCS_actin_threshs, plot_names);
    % end


    %Plot the OOP for the conditions if user actin filtered and
    %has more than one condition 
    if settings.tf_OOP && settings.multi_cond
        %>>BY CONDITION Plot the mean, standard deviation, and data points 
        %for non_sarc fraction 
        plot_names.type = 'OOP';
        if ~settings.actinthresh_explore
            plot_names.x = 'Conditions'; 
        else 
            plot_names.x = 'Actin Filtering Threshold'; 
        end 
        plot_names.y = 'OOP';
        plot_names.title = 'OOP';
        plot_names.savename = 'MultiCond_OOPSummary'; 
        [ MultiCond.CondValues_OOP, ...
            MultiCond.CondValues_MeanOOP,...
            MultiCond.CondValues_StdevOOP ] =...
            plotConditions(MultiCS_OOP, MultiCS_Cond, settings.cond_names,...
            MultiCS_grid_sizes, MultiCS_actin_threshs, plot_names);
    end

    % %Plot the OOP for the conditions if user actin filtered and
    % %has more than one coverslip 
    % if settings.tf_OOP && settings.num_cs > 1
    %     %>>BY CONDITION Plot the mean, standard deviation, and data points 
    %     %for non_sarc fraction 
    %     plot_names.type = 'OOP';
    %     if ~settings.actinthresh_explore
    %         plot_names.x = 'Coverslips'; 
    %     else 
    %         plot_names.x = 'Actin Filtering Threshold'; 
    %     end 
    %     plot_names.y = 'OOP';
    %     plot_names.title = 'OOP';
    %     plot_names.savename = 'MultiCS_OOPSummary'; 
    % %     [ ~, ~,~ ] =...
    % %     plotConditions(MultiCS_OOP, MultiCS_OOP, settings.cond_names,...
    % %     MultiCS_grid_sizes, MultiCS_actin_threshs, plot_names);
    % end

    if settings.tf_CZL || settings.grid_explore || settings.actinthresh_explore

        %Plot the medians and sums for each condition 
        if settings.multi_cond
        %>>BY CONDITION Plot the mean, standard deviation, and data points for 
        %median 
        plot_names.type = 'Medians';
        if ~settings.actinthresh_explore
            plot_names.x = 'Conditions'; 
        else 
            plot_names.x = 'Actin Filtering Threshold'; 
        end 
        plot_names.y = 'Median Continuous Z-line Lengths (\mu m)';
        plot_names.title = 'Median Continuous Z-line Lengths';
        plot_names.savename = 'MultiCond_MedianSummary'; 
        [ MultiCond.CondValues_Medians, ...
            MultiCond.CondValues_MeanMedians,...
            MultiCond.CondValues_StdevMedians ] =...
        plotConditions(MultiCS_medians, MultiCS_Cond, settings.cond_names,...
        MultiCS_grid_sizes, MultiCS_actin_threshs, plot_names); 

        %>>BY CONDITION Plot the mean, standard deviation, and data points 
        %for sums
        plot_names.type = 'Totals';
        if ~settings.actinthresh_explore
            plot_names.x = 'Conditions'; 
        else 
            plot_names.x = 'Actin Filtering Threshold'; 
        end 
        plot_names.y = 'Total Continuous Z-line Lengths (\mu m)';
        plot_names.title = 'Total Continuous Z-line Lengths';
        plot_names.savename = 'MultiCond_TotalSummary'; 
        [ MultiCond.CondValues_Sum, MultiCond.CondValues_MeanSum,...
            MultiCond.CondValues_StdevSum ] =...
        plotConditions(MultiCS_sums, MultiCS_Cond, settings.cond_names,...
        MultiCS_grid_sizes, MultiCS_actin_threshs, plot_names); 

        end

        %Plot the lengths for each coverslips 
        if settings.num_cs > 1
             plot_names.type = 'Medians';
            if ~settings.actinthresh_explore
                plot_names.x = 'Coverslips'; 
            else 
                plot_names.x = 'Actin Filtering Threshold'; 
            end 
            plot_names.y = 'Continuous Z-line Lengths (\mu m)';
            plot_names.title = 'Median Continuous Z-line Lengths';
            plot_names.savename = 'MultiCS_MedianSummary'; 

            plotCSresults(MultiCS_Data.MultiCS_lengths, ...
                MultiCS_Data.MultiCS_CSID,...
                MultiCS_Data.MultiCS_grid_sizes, ...
                MultiCS_Data.MultiCS_actin_threshs, plot_names);

        end

    end

    %Save the data 
    save(fullfile(settings.SUMMARY_path, new_filename),...
        'MultiCond', '-append'); 
end 

% if settings.exploration
%     %>>BY CONDITION Plot the mean, standard deviation, and data points for 
%     %median 
%     plot_names.type = 'Medians';
%     plot_names.x = 'Actin Filtering Threshold'; 
%     plot_names.y = 'Median Continuous Z-line Lengths (\mu m)';
%     plot_names.title = 'Median Continuous Z-line Lengths';
%     plot_names.savename = 'MultiCond_MedianSummary'; 
%     [ MultiCond.CondValues_Medians, ...
%         MultiCond.CondValues_MeanMedians,...
%         MultiCond.CondValues_StdevMedians ] =...
%     plotConditions(MultiCS_medians, MultiCS_Cond, settings.cond_names,...
%     MultiCS_grid_sizes, MultiCS_actin_threshs, plot_names); 
%     
%     %>>BY CONDITION Plot the mean, standard deviation, and data points 
%     %for sums
%     plot_names.type = 'Totals';
%     plot_names.x = 'Actin Filtering Threshold'; 
%     plot_names.y = 'Total Continuous Z-line Lengths (\mu m)';
%     plot_names.title = 'Total Continuous Z-line Lengths';
%     plot_names.savename = 'MultiCond_TotalSummary'; 
%     [ CondValues_Sum, CondValues_MeanSum,CondValues_StdevSum ] =...
%     plotConditions(MultiCS_sums, MultiCS_Cond, settings.cond_names,...
%     MultiCS_grid_sizes, MultiCS_actin_threshs(:,1), plot_names); 
%     
% 
%     %>>BY COVERSLIP MultiCS_lengths
%     plot_names.type = 'Lengths';
%     plot_names.y = 'Continuous Z-line Lengths (\mu m)';
%     plot_names.title = 'Continuous Z-line Lengths By Coverslip';
%     plot_names.savename = 'AllCS_MedianSummary'; 
%     [ ~, ~,~ ] =...
%     plotConditions(MultiCS_lengths, 1:length(name_CS), name_CS,...
%     MultiCS_grid_sizes(:,1), MultiCS_actin_threshs(:,1), plot_names, true);
% 
% 
% end
% 
% 
% 
% 
% 
% 
% 
% %If there is more than one CS calculate summary information and save 
% if settings.num_cs > 1
%     % If the user did an actin exploration, store the values for each
%     % CS. 
%     if settings.exploration 
%         %Store the actin struct
%         CS_actinexplore = outputs.CS_actinexplore; 
% 
%         %Store the medians
%         MultiCS_medians{1,k} = CS_actinexplore.CS_median;
%         %Store the sums 
%         MultiCS_sums{1,k} = CS_actinexplore.CS_sum;
%         %Store the non sarc fraction
%         MultiCS_nonsarc{1,k} = CS_actinexplore.CS_nonsarc;
%         %Store the grid sizes 
%         MultiCS_grid_sizes{1,k} = ...
%             CS_actinexplore.CS_explorevalues(:,1);
%         %Store the actin thresholds 
%         MultiCS_actin_threshs{1,k} = ...
%             CS_actinexplore.CS_explorevalues(:,2);
%         %Store the lengths 
%         MultiCS_lengths{1,k} = CS_actinexplore.CS_lengths;
% 
%     else
%         %Create a struct to store the plot names 
%         plot_names = struct(); 
%         %Save the path 
%         plot_names.path = settings.SUMMARY_path; 
%         
%         %Save the summary filename 
%         plot_names.savename = settings.SUMMARY_name; 
%         
%         %If the user did not do a parameter exploration, but did actin
%         %filter, store the grid sizes and actin thresholds
%         if settings.actin_filt
%             %Store the grid sizes 
%             MultiCS_grid_sizes{1,k} = ...
%                 CS_actinexplore.CS_explorevalues(:,1);
%             %Store the actin thresholds 
%             MultiCS_actin_threshs{1,k} = ...
%                 CS_actinexplore.CS_explorevalues(:,2);
%         end 
%         %If the user calculated the continuous z-line lengths, store
%         %those values 
%         if settings.tf_CZL
%             %Store the medians
%             MultiCS_medians{1,k} = CS_actinexplore.CS_median;
%             %Store the sums 
%             MultiCS_sums{1,k} = CS_actinexplore.CS_sum;
%             %Store the lengths 
%             MultiCS_lengths{1,k} = CS_actinexplore.CS_lengths;
%         end 
% 
%         %If the user calculated the OOP, store those values for each
%         %cover slip
%         if settings.tf_OOP
%             %Store the OOPs 
%             MultiCS_OOP{1,k} = CS_actinexplore.CS_OOP; 
%         end 
%     end 
% 
% end 
% %Get the parts of the last previous path 
% pathparts = strsplit(previous_path,filesep);
% 
% %Set previous path 
% save_path = pathparts{1,1}; 
% 
% %Go back one folder 
% for p =2:size(pathparts,2)-1
%     if ~isempty(pathparts{1,p+1})
%         save_path = fullfile(save_path, pathparts{1,p}); 
%     end 
% end 
% 
%     
% %Create a struct to store the plot names 
% plot_names = struct(); 
% %Save the path 
% plot_names.path = save_path; 
% 
% % Plot results fro 
% 
%         
close all;

end

