function [] = createSummaries(MultiCS_Data, name_CS, zline_images,...
    zline_path, cond, settings)

%%%%%%%%%%%%%%%%%%%%%%% Initialize Variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Summary name
summary_name = strcat(settings.SUMMARY_name,'.mat'); 
%Save the data after making sure it is uniquely named (no overwritting)
[ new_filename ] = appendFilename( settings.SUMMARY_path,...
    summary_name{1});

%Save multiple coverslip data
if settings.num_cs > 1
    save(fullfile(settings.SUMMARY_path, new_filename),...
        'MultiCS_Data','name_CS','zline_images','zline_path',...
        'cond','settings'); 
end 


%%%%%%%%%%%%%%%%%%%%%% Create excel summary %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%If there is more than one coverslip and the user did any kind of analysis,
%create a summary excel file 
if settings.num_cs > 1 && settings.analysis
    
    %Get all of the scalar value coverslip numbers and number of 
    %orientation vectors 
    MultiCS_CSN = concatCells( MultiCS_Data.MultiCS_CSID, true );
    MultiCS_anglecount = concatCells( MultiCS_Data.MultiCS_anglecount, ...
        true ); 
    
    %>>> Continuous z-line analysis 
    if settings.exploration || settings.tf_CZL
        MultiCS_medians = ...
            concatCells( MultiCS_Data.MultiCS_medians, true );
        MultiCS_sums = concatCells( MultiCS_Data.MultiCS_sums, true );
    else
        %Set to NaN if does not exist 
        MultiCS_medians = NaN*zeros(size(MultiCS_CSN));
        MultiCS_sums = NaN*zeros(size(MultiCS_CSN));
    end 
    
    
    %>>> OOP
    if settings.exploration || settings.tf_OOP
        MultiCS_OOP = concatCells( MultiCS_Data.MultiCS_OOP, true );
        MultiCS_directors = concatCells( MultiCS_Data.MultiCS_directors,...
            true ); 
    else
        %Set to NaN if does not exist 
        MultiCS_OOP = NaN*zeros(size(MultiCS_CSN));
        MultiCS_directors = NaN*zeros(size(MultiCS_CSN));
    end 
    
    %>>> ACTIN FILTERING 
    if settings.actin_filt
        %Store actin filtering analysis 
        MultiCS_nonzlinefrac = ...
            concatCells( MultiCS_Data.MultiCS_nonzlinefrac, true );
        MultiCS_zlinefrac = ...
            concatCells( MultiCS_Data.MultiCS_zlinefrac, true );
        MultiCS_grid_sizes = ...
            concatCells( MultiCS_Data.MultiCS_grid_sizes, true );
        MultiCS_actin_threshs = ...
            concatCells( MultiCS_Data.MultiCS_actin_threshs, true );
        MultiCS_ACTINOOP = ...
            concatCells( MultiCS_Data.MultiCS_ACTINOOP, true );
        MultiCS_ACTINanglecount = ...
            concatCells( MultiCS_Data.MultiCS_ACTINanglecount, true );
        MultiCS_ACTINdirectors = ...
            concatCells( MultiCS_Data.MultiCS_ACTINdirectors, true );
    else
        %Set to NaN if does not exist 
        MultiCS_nonzlinefrac = NaN*zeros(size(MultiCS_CSN));
        MultiCS_zlinefrac = NaN*zeros(size(MultiCS_CSN));
        MultiCS_grid_sizes = NaN*zeros(size(MultiCS_CSN));
        MultiCS_actin_threshs = NaN*zeros(size(MultiCS_CSN));
        MultiCS_ACTINOOP = NaN*zeros(size(MultiCS_CSN));
        MultiCS_ACTINanglecount = NaN*zeros(size(MultiCS_CSN));
        MultiCS_ACTINdirectors = NaN*zeros(size(MultiCS_CSN));
    end 
    
    %If comparing conditions, store the conditions
    if settings.multi_cond
        MultiCS_Cond = concatCells( MultiCS_Data.MultiCS_CONDID, true );
    else 
        %Set to NaN if does not exist 
        MultiCS_Cond = NaN*zeros(size(MultiCS_CSN));
    end 
    
    %Save in Excel Friendly Names 
    ConditionValue = MultiCS_Cond'; 
    CoverslipID = MultiCS_CSN'; 
    GridSize = MultiCS_grid_sizes';  
    ActinThreshold = MultiCS_actin_threshs';  
    MedianCZL = MultiCS_medians';   
    TotalCZL = MultiCS_sums';  
    NonZlineFraction = MultiCS_nonzlinefrac';  
    ZlineFraction = MultiCS_zlinefrac';  
    OOPzline = MultiCS_OOP';  
    OOPactin = MultiCS_ACTINOOP'; 
    DirectorZline = MultiCS_directors'; 
    DirectorActin = MultiCS_ACTINdirectors'; 
    TotalZline = MultiCS_anglecount'; 
    TotalActin = MultiCS_ACTINanglecount';     
    
    %Get today's date
    date_format = 'yyyymmdd';
    today_date = datestr(now,date_format);
    
    %Initialize Matrices for looped variables 
    ConditionName = cell(size(CoverslipID)); 
    DateAnalyzed_YYYYMMDD = cell(size(CoverslipID)); 
    CoverslipName = cell(size(CoverslipID)); 
    CoverslipPath = cell(size(CoverslipID)); 
    
    %Loop through and save variables 
    for k=1:length(CoverslipID) 
        %Save condition name (if applicable 
        if settings.multi_cond
            ConditionName{k,1} = settings.cond_names{MultiCS_Cond(1,k),1}; 
        else
            ConditionName{k,1} = NaN; 
        end
        %Save CS path 
        temp = zline_path{CoverslipID(k,1),1}; 
        CoverslipPath{k,1} = temp{1}; 
        %Save today's date
        DateAnalyzed_YYYYMMDD{k,1} =today_date; 
        %Save CS name 
        CoverslipName{k,1} = MultiCS_Data.name_CS{CoverslipID(k,1),1}; 
        
    end 
    
    %Save in a table 
    T = table(ConditionValue,ConditionName,CoverslipName,...
        DateAnalyzed_YYYYMMDD,OOPzline,OOPactin,...
        DirectorZline, DirectorActin,... 
        ZlineFraction,NonZlineFraction,TotalZline, ...
        TotalActin, MedianCZL,...
        TotalCZL,GridSize,ActinThreshold,CoverslipPath); 

    %Write the sheet to memory 
    filename = strcat(settings.SUMMARY_name{1}, '.xlsx'); 
    writetable(T,fullfile(settings.SUMMARY_path,filename),...
        'Sheet',1,'Range','A1'); 

end 

    
%%%%%%%%%%%%%%%%%%%%% Summarize & Plot Data for MultiCond %%%%%%%%%%%%%%%%%

if settings.num_cs > 1 && settings.analysis && settings.multi_cond

    %Create a new struct to store multicondition data 
    MultiCond = struct(); 

    %Create folder to store all of the summary plots 
    temp = strcat(settings.SUMMARY_name{1}, '_RESULTS'); 
    [ new_subfolder_name ] = ...
        addDirectory( settings.SUMMARY_path, temp, true ); 

    %Save path for plots 
    plot_names.path = fullfile(settings.SUMMARY_path,new_subfolder_name); 

    %%%%%%%%%%%%%%%%%%%%%%%%% ACTIN FILTER PLOTS %%%%%%%%%%%%%%%%%%%%%%%%%%

    %Plot the non-zline fraction for the conditions if user actin filtered 
    %and has more than one condition 
    if settings.actin_filt
        %>> NON Z-LINE FRACTION:  Plot the mean, standard deviation, 
        %   and data points 
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
        
        %>> Z-LINE FRACTION:  Plot the mean, standard deviation, 
        %   and data points
        plot_names.type = 'Zline Fraction';
        if ~settings.actinthresh_explore
            plot_names.x = 'Conditions'; 
        else 
            plot_names.x = 'Actin Filtering Threshold'; 
        end 
        plot_names.y = 'Zline Fraction';
        plot_names.title = 'Zline Fraction';
        plot_names.savename = 'MultiCond_ZlineSummary'; 
        [ MultiCond.CondValues_Zline, ...
            MultiCond.CondValues_MeanZline,...
            MultiCond.CondValues_StdevZline, MultiCond.IDs ] =...
            plotConditions(MultiCS_zlinefrac, MultiCS_Cond, ...
            settings.cond_names,...
            MultiCS_grid_sizes, MultiCS_actin_threshs, plot_names);


        %>> ACTIN OOP:  Plot the mean, standard deviation, 
        %   and data points
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
        
        %Update the summary file  
        save(fullfile(settings.SUMMARY_path, ...
            strcat(settings.SUMMARY_name{1},'.mat')),...
            'MultiCS_Data','MultiCond','-append');  
        close all;

    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% OOP PLOTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if settings.tf_OOP || settings.exploration
        %>> ZLINE OOP:  Plot the mean, standard deviation, 
        %   and data points
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
        
        %Update the summary file  
        save(fullfile(settings.SUMMARY_path, ...
            strcat(settings.SUMMARY_name{1},'.mat')),...
            'MultiCS_Data','MultiCond','-append');  
        close all;
        
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CZL PLOTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if settings.tf_CZL || settings.exploration
    
        %%>> CZL MEDIAN:  Plot the mean, standard deviation, 
        %   and data points
        
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

        %%>> CZL TOTAL:  Plot the mean, standard deviation, 
        %   and data points
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


        %%>> CZL CS LENGTHS:  Plot length distributions  
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
        
        %%>> CZL CS LENGTHS:  Plot additional medians 
        [ MultiCS_Data.additionalMedianCond, ...
            MultiCS_Data.additionalMedianCondMean, ...
            MultiCS_Data.additionalMedianCondStdev, ~] =...
            plotConditions(MultiCS_medians, MultiCS_Cond, ...
            settings.cond_names, MultiCS_grid_sizes, ...
            MultiCS_actin_threshs, plot_names, ...
            MultiCS_Data.additionalMedians); 
        
        %Update the summary file  
        save(fullfile(settings.SUMMARY_path, ...
            strcat(settings.SUMMARY_name{1},'.mat')),...
            'MultiCS_Data','MultiCond','-append');  
        close all;

    end


    %%%%%%%%%%%%%%%%%%%%%%%%%% EXCEL STATISTICS %%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Add statistics to excel file 
    ConditionValue = MultiCond.IDs(:,1);
    ConditionName = cell(size(ConditionValue)); 
    NumberCoverSlips = zeros(size(ConditionValue)); 
    for k = 1:length(ConditionName) 
        ConditionName{k,1} = settings.cond_names{ConditionValue(k,1),1}; 
        NumberCoverSlips(k,1) = size(MultiCond.CondValues_NonZline{k,1},1); 
    end 
    
    %>>> Continuous z-line length 
    if settings.exploration || settings.tf_CZL
        MedianCZL_mean = MultiCond.CondValues_MeanMedians;
        MedianCZL_stdev = MultiCond.CondValues_StdevMedians;
        TotalCZL_mean = MultiCond.CondValues_MeanSum; 
        TotalCZL_stdev = MultiCond.CondValues_StdevSum; 
    else
        %Set to NaN if does not exist 
        MedianCZL_mean = NaN*zeros(size(ConditionName)); 
        MedianCZL_stdev = NaN*zeros(size(ConditionName)); 
        TotalCZL_mean = NaN*zeros(size(ConditionName));  
        TotalCZL_stdev = NaN*zeros(size(ConditionName)); 
    end 
    
    %>>> OOP
    if settings.exploration || settings.tf_OOP
        OOPzline_mean = MultiCond.CondValues_MeanOOP; 
        OOPzline_stdev = MultiCond.CondValues_StdevOOP; 
        OOPactin_mean = MultiCond.CondValues_ACTINMeanOOP;
        OOPactin_stdev = MultiCond.CondValues_ACTINStdevOOP;
    else
        %Set to NaN if does not exist 
        OOPzline_mean = NaN*zeros(size(ConditionName)); 
        OOPzline_stdev = NaN*zeros(size(ConditionName)); 
        OOPactin_mean = NaN*zeros(size(ConditionName)); 
        OOPactin_stdev = NaN*zeros(size(ConditionName)); 
    end 
    
    %>>> ACTIN FILTERING 
    if settings.actin_filt
        ZlineFraction_mean = MultiCond.CondValues_MeanZline; 
        ZlineFraction_stdev = MultiCond.CondValues_StdevZline; 
        NonZlineFraction_mean = MultiCond.CondValues_MeanNonZline; 
        NonZlineFraction_stdev = MultiCond.CondValues_StdevNonZline;
    else 
        %Set to NaN if does not exist 
        ZlineFraction_mean = NaN*zeros(size(ConditionName)); 
        ZlineFraction_stdev = NaN*zeros(size(ConditionName)); 
        NonZlineFraction_mean = NaN*zeros(size(ConditionName)); 
        NonZlineFraction_stdev = NaN*zeros(size(ConditionName)); 
    end 
   

    %Save in table 
    T = table(ConditionValue,ConditionName,NumberCoverSlips,...
        OOPzline_mean,OOPzline_stdev,OOPactin_mean,...
        OOPactin_stdev,ZlineFraction_mean,ZlineFraction_stdev, ...
        NonZlineFraction_mean, NonZlineFraction_stdev,...
        MedianCZL_mean,MedianCZL_stdev,TotalCZL_mean,TotalCZL_stdev); 

    %Write the sheet
    filename = strcat(settings.SUMMARY_name{1}, '.xlsx'); 
    writetable(T,fullfile(settings.SUMMARY_path,filename),...
        'Sheet',2,'Range','A1'); 


end 

end

