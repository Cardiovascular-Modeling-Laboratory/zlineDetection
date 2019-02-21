function [] = createSummaries()
%This function will take the multiple condition summary file, plot the
%results and create an excel file 

%%%%%%%%%%%%%%%%%%%%%%%% Open a summary file %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[ summary_file, summary_path] = ...
        load_files( {'*.mat'}, 'Select summary file...', pwd);

%Load the data 
data = load(fullfile(summary_path{1}, summary_file{1})); 

%Store releavnt data structures
settings = data.settings; 
name_CS = data.name_CS; 
zline_images = data.zline_images;
zline_path = data.zline_path; 
cond = data.cond; 
MultiCS_Data = data.MultiCS_Data; 

%%%%%%%%%%%%%%%%%%%%% Create excel summary %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Get all of the scalar valued IDs and values (everything but lengths &
%angles)
MultiCS_medians = concatCells( MultiCS_Data.MultiCS_medians, true );
MultiCS_sums = concatCells( MultiCS_Data.MultiCS_sums, true );
MultiCS_nonzlinefrac = concatCells( MultiCS_Data.MultiCS_nonzlinefrac, true );
MultiCS_zlinefrac = concatCells( MultiCS_Data.MultiCS_zlinefrac, true );
MultiCS_grid_sizes = concatCells( MultiCS_Data.MultiCS_grid_sizes, true );
MultiCS_actin_threshs = concatCells( MultiCS_Data.MultiCS_actin_threshs, true );
MultiCS_OOP = concatCells( MultiCS_Data.MultiCS_OOP, true );
MultiCS_CSN = concatCells( MultiCS_Data.MultiCS_CSID, true );
MultiCS_Cond = concatCells( MultiCS_Data.MultiCS_CONDID, true );
MultiCS_ACTINOOP = concatCells( MultiCS_Data.MultiCS_ACTINOOP, true );

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
OOPzline = MultiCS_OOP';  
OOPactin = MultiCS_ACTINOOP'; 
TotalZline = MultiCS_anglecount'; 
TotalActin = MultiCS_ACTINanglecount'; 

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
T = table(ConditionValue,ConditionName,CoverslipName,...
    DateAnalyzed_YYYYMMDD,OOPzline,OOPactin,...
    ZlineFraction,NonZlineFraction,TotalZline, ...
    TotalActin, MedianCZL,...
    TotalCZL,GridSize,ActinThreshold); 

%Write the sheet
filename = strcat(settings.SUMMARY_name{1}, '.xlsx'); 
writetable(T,fullfile(settings.SUMMARY_path,filename),...
    'Sheet',1,'Range','A1'); 
    
%%%%%%%%%%%%%%%%%%%%%%%%%%% Plot & Save Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Save a new struct
MultiCond = struct(); 

%Create folder to store all of the summary plots 
temp = strcat(settings.SUMMARY_name{1}, '_RESULTS'); 
[ new_subfolder_name ] = ...
    addDirectory( settings.SUMMARY_path, temp, true ); 
    
%Save path for plots 
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


    %Plot the actin OOP 
    plot_names.type = 'OOP';
    if ~settings.actinthresh_explore
        plot_names.x = 'Conditions'; 
    else 
        plot_names.x = 'Actin Filtering Threshold'; 
    end 
    plot_names.y = 'Actin OOP';
    plot_names.title = 'Actin OOP';
    plot_names.savename = 'MultiCond_ACTINOOPSummary'; 
    [ MultiCond.CondValues_ACTINOOP, ...
        MultiCond.CondValues_ACTINMeanOOP,...
        MultiCond.CondValues_ACTINStdevOOP, MultiCond.IDs  ] =...
        plotConditions(MultiCS_ACTINOOP, MultiCS_Cond, settings.cond_names,...
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
    plot_names.y = 'Z-line OOP';
    plot_names.title = 'Z-line OOP';
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
        plot_names.type = 'Lengths';
        if ~settings.actinthresh_explore
            plot_names.x = 'Coverslips'; 
        else 
            plot_names.x = 'Actin Filtering Threshold'; 
        end 
        plot_names.y = 'Median Continuous Z-line Lengths (\mu m)';
        plot_names.title = 'Median Continuous Z-line Lengths (\mu m)';
        plot_names.savename = 'MultiCS_LengthShape'; 

        [MultiCS_Data.additionalMedians] = ...
            plotCSresults(MultiCS_Data.MultiCS_lengths, ...
            MultiCS_Data.MultiCS_CSID, MultiCS_Data.name_CS,...
            MultiCS_Data.MultiCS_grid_sizes, ...
            MultiCS_Data.MultiCS_actin_threshs, plot_names,cond);

        plot_names.type = 'Medians';
        plot_names.y = ...
            'Median Continuous Z-line Lengths (\mu m)';
        plot_names.title = 'True Medians and \pm 50% Medians';
        plot_names.savename = 'MultiCSMultiMedianSummary'; 

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

%Update the CS 
save(fullfile(settings.SUMMARY_path, new_filename),...
    'MultiCS_Data','-append');  

close all;

end

