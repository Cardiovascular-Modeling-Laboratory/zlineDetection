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
%Save the non-zline fraction for each coverslip 
MultiCS_nonzlinefrac = cell(1,settings.num_cs);
MultiCS_zlinefrac = cell(1,settings.num_cs);

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
close all; 
%Have the user select the different directories for the coverslips
for k = 1:settings.num_cs 
    
    %Display message telling the user which coverslip they're on 
    disp_message = strcat('Selecting Coverslip',{' '}, num2str(k),...
        {' '}, 'of', {' '}, num2str(settings.num_cs)); 
    disp(disp_message); 
    
    % Prompt the user to select the images they would like to analyze. 
    [ zline_images{k,1}, zline_path{k,1}, zn(k,1) ] = ...
        load_files( {'*w1mCherry*.TIF;*w1mCherry*.tif;*w4Cy7*.tif;*w1Cy7*.tif;*Sarc*.tif'}, ...
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
    
    %Add a backslash to the beginning of the path in order to use if this
    %is a mac, otherwise do not
    if ~ispc
        previous_path = strcat(filesep,previous_path);
    end 
    
    potential_end = size(pathparts,2); 
    while isempty(pathparts{1,potential_end})
        potential_end = potential_end -1; 
    end 
    %Save the name of the directory 
    name_CS{k,1} = pathparts{1,potential_end}; 
    
    %If the user is actin filtering, have them select the files 
    if settings.actin_filt
        [ actin_images{k,1}, actin_path{k,1}, an(k,1) ] = ...
            load_files( {'*GFP*.TIF;*GFP*.tif;*Actin*.tif'}, ...
            'Select images stained for actin...',temp_path{1});

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
        %Set the actin image to NaN 
        actin_images{k,1} = NaN; 
        actin_path{k,1} = NaN; 
        an(k,1) = NaN; 
    end  
    
    %Display path the user selected 
    disp(zline_path{k,1});
    
    if settings.multi_cond
        %Declare conditions for the selected coverslip 
        cond(k,1) = ...
            declareCondition(settings.cond_names, k, settings.num_cs); 
        
        %Display the condition the user selected 
        disp_message = strcat('Condition:',{' '}, num2str(cond(k,1))); 
        disp(disp_message{1}); 
    end 
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%% Analyze all CS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Loop through and run each coverslip 
clear k 
for k = 1:settings.num_cs 
    
    % Analyze the Coverslip 
    [ CS_results ] = ...
        runDirectory( settings, zline_path{k,1}, zline_images{k,1},...
        actin_path{k,1}, actin_images{k,1}, name_CS{k,1} ); 
    
    if settings.cardio_type == 1 && settings.analysis
        %Store the results from analyzing each coverslip 
        MultiCS_lengths{1,k} = CS_results.CS_lengths;
        MultiCS_medians{1,k} =CS_results.CS_medians;
        MultiCS_sums{1,k} = CS_results.CS_sums;
        MultiCS_nonzlinefrac{1,k} = CS_results.CS_nonzlinefrac;
        MultiCS_zlinefrac{1,k} = CS_results.CS_zlinefrac;
        MultiCS_grid_sizes{1,k} = CS_results.CS_gridsizes;
        MultiCS_actin_threshs{1,k} = CS_results.CS_thresholds;
        MultiCS_OOP{1,k} = CS_results.CS_OOPs;    

        %Save coverslip number 
        MultiCS_CSID{1,k} = k*ones(size(CS_results.CS_OOPs)); 
    end
    
    if settings.multi_cond && settings.cardio_type == 1 && settings.analysis
        %Save the condition ID 
        MultiCS_CONDID{1,k} = ...
            cond(k,1)*ones(size(CS_results.CS_gridsizes));
    end
    
end 

if settings.cardio_type == 1 && settings.analysis
    %Store in struct
    MultiCS_Data = struct(); 
    MultiCS_Data.MultiCS_lengths=MultiCS_lengths;
    MultiCS_Data.MultiCS_medians=MultiCS_medians;
    MultiCS_Data.MultiCS_sums=MultiCS_sums;
    MultiCS_Data.MultiCS_nonzlinefrac=MultiCS_nonzlinefrac;
    MultiCS_Data.MultiCS_zlinefrac=MultiCS_zlinefrac; 
    MultiCS_Data.MultiCS_grid_sizes=MultiCS_grid_sizes;
    MultiCS_Data.MultiCS_actin_threshs=MultiCS_actin_threshs;
    MultiCS_Data.MultiCS_OOP=MultiCS_OOP;
    MultiCS_Data.MultiCS_CSID=MultiCS_CSID;
    MultiCS_Data.MultiCS_CONDID=MultiCS_CONDID;    
    MultiCS_Data.name_CS = name_CS;
    
    %Summary name
    summary_name = strcat(settings.SUMMARY_name,'.mat'); 
    %Save the data after making sure it is uniquely named (no overwritting)
    [ new_filename ] = appendFilename( settings.SUMMARY_path,...
        summary_name{1});
    save(fullfile(settings.SUMMARY_path, new_filename),...
        'MultiCS_Data','name_CS','zline_images','zline_path',...
        'cond','settings'); 

    %%%%%%%%%%%%%%%%%%%%%%%%%%% Plot & Save Data %%%%%%%%%%%%%%%%%%%%%%%%%%

    %Get all of the scalar valued IDs and values (everything but lengths
    MultiCS_medians = concatCells( MultiCS_Data.MultiCS_medians, true );
    MultiCS_sums = concatCells( MultiCS_Data.MultiCS_sums, true );
    MultiCS_nonzlinefrac = concatCells( MultiCS_Data.MultiCS_nonzlinefrac, true );
    MultiCS_zlinefrac = concatCells( MultiCS_Data.MultiCS_zlinefrac, true );
    MultiCS_grid_sizes = concatCells( MultiCS_Data.MultiCS_grid_sizes, true );
    MultiCS_actin_threshs = concatCells( MultiCS_Data.MultiCS_actin_threshs, true );
    MultiCS_OOP = concatCells( MultiCS_Data.MultiCS_OOP, true );
    MultiCS_CSN = concatCells( MultiCS_Data.MultiCS_CSID, true );
    MultiCS_Cond = concatCells( MultiCS_Data.MultiCS_CONDID, true );

    %Save a new struct
    MultiCond = struct(); 
   
    %Create folder to store all of the summary plots 
    temp = strcat(settings.SUMMARY_name, '_RESULTS'); 
    [ new_subfolder_name ] = ...
        addDirectory( settings.SUMMARY_path, temp, true ); 
    
    %Save path 
    plot_names.path = fullfile(settings.SUMMARY_path,new_subfolder_name); 

    
    %Plot the non-zline fraction for the conditions if user actin filtered 
    %and has more than one condition 
    if settings.actin_filt && settings.multi_cond
        %>>BY CONDITION Plot the mean, standard deviation, and data points 
        %for non_zline fraction 
        plot_names.type = 'Non-Zline Fraction';
        if ~settings.actinthresh_explore
            plot_names.x = 'Conditions'; 
        else 
            plot_names.x = 'Actin Filtering Threshold'; 
        end 
        plot_names.y = 'Non-Zline Fraction';
        plot_names.title = 'Non-Zline Fraction';
        plot_names.savename = 'MultiCond_NonZlineSummary'; 
        [ MultiCond.CondValues_NonZline, ...
            MultiCond.CondValues_MeanNonZline,...
            MultiCond.CondValues_StdevNonZline, MultiCond.IDs ] =...
            plotConditions(MultiCS_nonzlinefrac, MultiCS_Cond, ...
            settings.cond_names,...
            MultiCS_grid_sizes, MultiCS_actin_threshs, plot_names);
        
        plot_names.type = 'Zline Fraction';
        if ~settings.actinthresh_explore
            plot_names.x = 'Conditions'; 
        else 
            plot_names.x = 'Actin Filtering Threshold'; 
        end 
        plot_names.y = 'Zline Fraction';
        plot_names.title = 'Zline Fraction';
        plot_names.savename = 'MultiCond_ZlineSummary'; 
        [ MultiCond.CondValues_NonZline, ...
            MultiCond.CondValues_MeanNonZline,...
            MultiCond.CondValues_StdevNonZline, MultiCond.IDs ] =...
            plotConditions(MultiCS_zlinefrac, MultiCS_Cond, ...
            settings.cond_names,...
            MultiCS_grid_sizes, MultiCS_actin_threshs, plot_names);
        
    end

    %Plot the OOP for the conditions if user actin filtered and
    %has more than one condition 
    if (settings.tf_OOP || settings.exploration) && settings.multi_cond
        %>>BY CONDITION Plot the mean, standard deviation, and data points 
        %for non_zline fraction 
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
            MultiCond.CondValues_StdevOOP, MultiCond.IDs  ] =...
            plotConditions(MultiCS_OOP, MultiCS_Cond, settings.cond_names,...
            MultiCS_grid_sizes, MultiCS_actin_threshs, plot_names);
    end

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
            MultiCond.CondValues_StdevMedians, MultiCond.IDs  ] =...
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
            MultiCond.CondValues_StdevSum, MultiCond.IDs ] =...
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
            plot_names.y = 'Median Continuous Z-line Lengths (\mu m)';
            plot_names.title = 'Median Continuous Z-line Lengths';
            plot_names.savename = 'MultiCS_MedianSummary'; 

            [MultiCS_Data.additionalMedians] = ...
                plotCSresults(MultiCS_Data.MultiCS_lengths, ...
                MultiCS_Data.MultiCS_CSID, MultiCS_Data.name_CS,...
                MultiCS_Data.MultiCS_grid_sizes, ...
                MultiCS_Data.MultiCS_actin_threshs, plot_names);
            
            
            plot_names.y = 'Difference in Median Cont. Z-line Lengths (\mu m)';
            plot_names.title = 'Distance Between True Medians and \pm 50% Medians';
            plot_names.savename = 'MultiCSandCOND_MedianSummary'; 
            
            %Plot the differences for each condition 
            [ MultiCS_Data.additionalMedianCond, ...
                MultiCS_Data.additionalMedianCondMean, ...
                MultiCS_Data.additionalMedianCondStdev, ~] =...
                plotConditions(MultiCS_medians, MultiCS_Cond, ...
                settings.cond_names, MultiCS_grid_sizes, ...
                MultiCS_actin_threshs, plot_names, ...
                MultiCS_Data.additionalMedians); 


        end

    end

    %Save the data 
    save(fullfile(settings.SUMMARY_path, new_filename),...
        'MultiCond', '-append'); 
    
    %Create summary excel file  
    %Store the number and name of the condition
    ConditionValue = MultiCS_Cond'; 
    ConditionName = cell(size(MultiCS_Cond,2),size(MultiCS_Cond,1)); 
    for k = 1:length(ConditionName) 
        ConditionName{k,1} = settings.cond_names{MultiCS_Cond(1,k),1}; 
    end 
    GridSize = MultiCS_grid_sizes';  
    ActinThreshold = MultiCS_actin_threshs';  
    MedianCZL = MultiCS_medians';   
    TotalCZL = MultiCS_sums';  
    NonZlineFraction = MultiCS_nonzlinefrac';  
    ZlineFraction = MultiCS_zlinefrac';  
    OOP = MultiCS_OOP';  
    %Get the name of each coverslip
    CoverslipID = MultiCS_CSN'; 
    CoverslipName = cell(size(CoverslipID)); 
    for k = 1:length(CoverslipID)
        CoverslipName{k,1} = MultiCS_Data.name_CS{CoverslipID(k,1),1}; 
    end

    %Save the data analyzed
    DateAnalyzed_YYYYMMDD = cell(size(CoverslipID)); 
    %Get today's date
    date_format = 'yyyymmdd';
    today_date = datestr(now,date_format);
    for k = 1:length(CoverslipID)
        DateAnalyzed_YYYYMMDD{k,1} =today_date; 
    end 

    % CoverslipName = MultiCS_Data.name_CS;  
    T = table(ConditionValue,ConditionName,GridSize,ActinThreshold,...
        MedianCZL,TotalCZL,NonZlineFraction,ZlineFraction,OOP,...
        CoverslipName,DateAnalyzed_YYYYMMDD); 
    
    %Update the CS 
    save(fullfile(settings.SUMMARY_path, new_filename),...
        'MultiCS_Data','-append'); 
    
    %Write the sheet
    filename = strcat(settings.SUMMARY_name{1}, '.xlsx'); 
    writetable(T,fullfile(settings.SUMMARY_path,filename),...
        'Sheet',1,'Range','A1'); 
end 

close all;

end

