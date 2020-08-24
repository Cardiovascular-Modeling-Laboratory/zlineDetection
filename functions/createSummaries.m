% convertParameters - For usage with zlineDetection.m ONLY. Create summary
% plots, excel sheets, and .mat files 
% 
% Usage: 
%  createSummaries(MultiCS_Data, name_CS, zline_images,...
%    zline_path, cond, settings)
%
% Arguments:
%   MultiCS_Data
%   name_CS
%   zline_images
%   zline_path
%   cond
%   settings 
% 
% Returns:
%
%
% Dependencies: 
%   MATLAB Version >= 9.5 
%   Statistics and Machine Learning Toolbox Version 11.4
%   Functions: 
%       addDirectory.m
%       appendFilename.m
%       concatCells.m
%       plotCSresults.m
%       plotConditions.m
%
% Tessa Morris
% Advisor: Anna Grosberg, Department of Biomedical Engineering 
% Cardiovascular Modeling Laboratory 
% University of California, Irvine 

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
        MultiCS_means = concatCells( MultiCS_Data.MultiCS_means, true );
        MultiCS_skewness = ...
            concatCells( MultiCS_Data.MultiCS_skewness, true );
        MultiCS_kurtosis = ...
            concatCells( MultiCS_Data.MultiCS_kurtosis, true );
    else
        %Set to NaN if does not exist 
        MultiCS_medians = NaN*zeros(size(MultiCS_CSN));
        MultiCS_sums = NaN*zeros(size(MultiCS_CSN));
        MultiCS_means = NaN*zeros(size(MultiCS_CSN));
        MultiCS_skewness = NaN*zeros(size(MultiCS_CSN));
        MultiCS_kurtosis = NaN*zeros(size(MultiCS_CSN));
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
    MeanCZL = MultiCS_means'; 
    SkewnessCZL = MultiCS_skewness'; 
    KurtosisCZL = MultiCS_kurtosis'; 
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
        ZlineFraction,NonZlineFraction, TotalZline, ...
        TotalActin, MedianCZL, MeanCZL, ...
        TotalCZL, SkewnessCZL, KurtosisCZL, ...
        GridSize, ActinThreshold, CoverslipPath); 
    
    %Write the sheet to memory 
    filename = strcat(settings.SUMMARY_name{1}, '.xlsx'); 
    writetable(T,fullfile(settings.SUMMARY_path,filename),...
        'Sheet',1,'Range','A1'); 

end 

    
%%%%%%%%%%%%%%%%%%%%% Summarize & Plot Data for MultiCond %%%%%%%%%%%%%%%%%

if settings.num_cs > 1 && settings.analysis && settings.multi_cond
    
    % Only create summary plots if the user did not do an exploration 
    if ~settings.exploration
        
        %Create a new struct to store multicondition data 
        MultiCond = struct(); 

        %Create folder to store all of the summary plots 
        temp = strcat(settings.SUMMARY_name{1}, '_RESULTS'); 
        [ new_subfolder_name ] = ...
            addDirectory( settings.SUMMARY_path, temp, true ); 

        %Save path for plots 
        plot_names.path = fullfile(settings.SUMMARY_path,new_subfolder_name); 
        
%>> SUMMARY PLOT: ACTIN SEGMENTATION 

        %Plot the z-line fraction for the conditions if user actin filtered 
        %and has more than one condition 
        if settings.actin_filt
    %>> Z-LINE FRACTION:  Plot the mean, standard deviation, and data 
    %   points
            
            % Name to save figure
            plot_names.savename = 'MultiCond_ZlineFractionSummary'; 
            % Change the x-label 
            plot_settings.xlabel = 'Tissue Condition';
            % Change the y-label
            plot_settings.ylabel = 'Z-line Fraction';
            % Set the x-tick labels to be the condition names 
            plot_settings.xticklabel = settings.cond_names; 
            
            % Change the y axis lmits
            plot_settings.ymin = 0; 
            plot_settings.ymax = 1; 
            
            % Provide raw data
            data_vals = MultiCS_zlinefrac;
            % Provide the data labels 
            data_labels = MultiCS_Cond;
            
            % Plot and calculate the mean and standard deviation 
            [ cond_num, MultiCond.CondValues_MeanZline,...
                MultiCond.CondValues_StdevZline ] =...
                plotConditions(data_vals, data_labels, ...
                plot_settings, plot_names);

            clear plot_settings data_vals data_labels
            
    %>> ACTIN OOP:  Plot the mean, standard deviation, and data points
    
            % Name to save figure
            plot_names.savename = 'MultiCond_ACTINOOPSummary'; 
            % Change the x-label 
            plot_settings.xlabel = 'Tissue Condition';
            % Change the y-label
            plot_settings.ylabel = 'Actin OOP';
            % Set the x-tick labels to be the condition names 
            plot_settings.xticklabel = settings.cond_names; 
            
            % Change the y axis lmits
            plot_settings.ymin = 0; 
            plot_settings.ymax = 1; 
            
            % Provide raw data
            data_vals = MultiCS_ACTINOOP;
            % Provide the data labels 
            data_labels = MultiCS_Cond;
            
            % Plot and calculate the mean and standard deviation 
            [ cond_num, MultiCond.CondValues_ACTINMeanOOP,...
                MultiCond.CondValues_ACTINStdevOOP ] =...
                plotConditions(data_vals, data_labels, ...
                plot_settings, plot_names);

            clear plot_settings data_vals data_labels

            %Update the summary file  
            save(fullfile(settings.SUMMARY_path, ...
                strcat(settings.SUMMARY_name{1},'.mat')),...
                'MultiCS_Data','MultiCond','-append');              
        end

%>> SUMMARY PLOT: Z-line OOP 
        if settings.tf_OOP

            % Name to save figure
            plot_names.savename = 'MultiCond_ZlineOOPSummary'; 
            % Change the x-label 
            plot_settings.xlabel = 'Tissue Condition';
            % Change the y-label
            plot_settings.ylabel = 'Z-line OOP';
            % Set the x-tick labels to be the condition names 
            plot_settings.xticklabel = settings.cond_names; 
            
            % Change the y axis lmits
            plot_settings.ymin = 0; 
            plot_settings.ymax = 1; 
            
            % Provide raw data
            data_vals = MultiCS_OOP;
            % Provide the data labels 
            data_labels = MultiCS_Cond;
            
            % Plot and calculate the mean and standard deviation 
            [ cond_num, MultiCond.CondValues_MeanOOP,...
                MultiCond.CondValues_StdevOOP ] =...
                plotConditions(data_vals, data_labels, ...
                plot_settings, plot_names);

            clear plot_settings data_vals data_labels

            %Update the summary file  
            save(fullfile(settings.SUMMARY_path, ...
                strcat(settings.SUMMARY_name{1},'.mat')),...
                'MultiCS_Data','MultiCond','-append');  

        end
        
%>> SUMMARY PLOT: Continuous Z-line Detection 
        if settings.tf_CZL 
    %%>> CZL MEDIAN:  Plot the mean, standard deviation, 
    %   and data points
            % Name to save figure
            plot_names.savename = 'MultiCond_MedianCZLSummary'; 
            % Change the x-label 
            plot_settings.xlabel = 'Tissue Condition';
            % Change the y-label
            plot_settings.ylabel = 'Median Continuous Z-line Length (\mu m)';
            % Set the x-tick labels to be the condition names 
            plot_settings.xticklabel = settings.cond_names; 
            
            % Provide raw data
            data_vals = MultiCS_medians;
            % Provide the data labels 
            data_labels = MultiCS_Cond;
            
            % Plot and calculate the mean and standard deviation 
            [ cond_num, MultiCond.CondValues_MeanMedians,...
                MultiCond.CondValues_StdevMedians ] =...
                plotConditions(data_vals, data_labels, ...
                plot_settings, plot_names);

            clear plot_settings data_vals data_labels
            
	%%>> CZL Total:  Plot the mean, standard deviation, 
    %   and data points  
            % Name to save figure
            plot_names.savename = 'MultiCond_TotalCZLSummary'; 
            % Change the x-label 
            plot_settings.xlabel = 'Tissue Condition';
            % Change the y-label
            plot_settings.ylabel = 'Total Continuous Z-line Length (\mu m)';
            % Set the x-tick labels to be the condition names 
            plot_settings.xticklabel = settings.cond_names; 
            
            % Provide raw data
            data_vals = MultiCS_sums;
            % Provide the data labels 
            data_labels = MultiCS_Cond;
            % Plot and calculate the mean and standard deviation 
            [ cond_num, MultiCond.CondValues_MeanSum,...
                MultiCond.CondValues_StdevSum ] =...
                plotConditions(data_vals, data_labels, ...
                plot_settings, plot_names);
            clear plot_settings data_vals data_labels
            
    %%>> CZL Mean:  Plot the mean, standard deviation, 
    %   and data points
            % Name to save figure
            plot_names.savename = 'MultiCond_MeanCZLSummary'; 
            % Change the x-label 
            plot_settings.xlabel = 'Tissue Condition';
            % Change the y-label
            plot_settings.ylabel = 'Mean Continuous Z-line Length (\mu m)';
            % Set the x-tick labels to be the condition names 
            plot_settings.xticklabel = settings.cond_names; 
            
            % Provide raw data
            data_vals = MultiCS_means;
            % Provide the data labels 
            data_labels = MultiCS_Cond;
            
            % Plot and calculate the mean and standard deviation 
            [ cond_num, MultiCond.CondValues_MeanMeans,...
                MultiCond.CondValues_StdevMeans ] =...
                plotConditions(data_vals, data_labels, ...
                plot_settings, plot_names);

            clear plot_settings data_vals data_labels
            

    %%>> CZL Skewness:  Plot the mean, standard deviation, 
    %   and data points

            % Name to save figure
            plot_names.savename = 'MultiCond_SkewnessCZLSummary'; 
            % Change the x-label 
            plot_settings.xlabel = 'Tissue Condition';
            % Change the y-label
            plot_settings.ylabel = 'Skewness of Continuous Z-line Lengths';
            % Set the x-tick labels to be the condition names 
            plot_settings.xticklabel = settings.cond_names; 
            
            % Provide raw data
            data_vals = MultiCS_skewness;
            % Provide the data labels 
            data_labels = MultiCS_Cond;
            
            % Plot and calculate the mean and standard deviation 
            [ cond_num, MultiCond.CondValues_MeanSkewness,...
                MultiCond.CondValues_StdevSkewness ] =...
                plotConditions(data_vals, data_labels, ...
                plot_settings, plot_names);

            clear plot_settings data_vals data_labels
            
    %%>> CZL Kurtosis:  Plot the mean, standard deviation, 
    %   and data points
    
            % Name to save figure
            plot_names.savename = 'MultiCond_KurtosisCZLSummary'; 
            % Change the x-label 
            plot_settings.xlabel = 'Tissue Condition';
            % Change the y-label
            plot_settings.ylabel = 'Kurtosis Continuous Z-line Lengths';
            % Set the x-tick labels to be the condition names 
            plot_settings.xticklabel = settings.cond_names; 
            
            % Provide raw data
            data_vals = MultiCS_kurtosis;
            % Provide the data labels 
            data_labels = MultiCS_Cond;
            
            % Plot and calculate the mean and standard deviation 
            [ cond_num, MultiCond.CondValues_MeanKurtosis,...
                MultiCond.CondValues_StdevKurtosis ] =...
                plotConditions(data_vals, data_labels, ...
                plot_settings, plot_names);

            clear plot_settings data_vals data_labels
            
    %%>> CZL CS Additional Medians:  Plot additional medians 
            % Loop through all of the coverslips and calculate the
            % 25th and 75th percentile values 
            MultiCS_CZL2575 = zeros(settings.num_cs,3); 
            
            for k = 1:settings.num_cs
                current = MultiCS_Data.MultiCS_lengths{k}; 
                temp_data = current{1}; 
                % Calculate the median and interquartile range
                MultiCS_CZL2575(k,2) = median(temp_data); 
        
                % Get the number of points 
                npts = length(temp_data); 
                
                % Sort the data 
                sorted_data = sort(temp_data); 
                
                %Compute 25th & 75th percentile 
                MultiCS_CZL2575(k,1) = sorted_data( round(npts*0.25) );
                MultiCS_CZL2575(k,3) = sorted_data( round(npts*0.75) );

        
            end 
    
            % Name to save figure
            plot_names.savename = 'MultiCSMultiMedianCZLSummary'; 
            % Change the x-label 
            plot_settings.xlabel = 'Tissue Condition';
            % Change the y-label
            plot_settings.ylabel = 'Median, 25th, and 75th Continuous Z-line Lengths (\mu m)';
            % Set the x-tick labels to be the condition names 
            plot_settings.xticklabel = settings.cond_names; 
            % Provide the data labels 
                data_labels = MultiCS_Cond;
            
            % Loop through all of the medians and plot 
            for k = 1:3
                
                if k == 1
                    doHold = false;
                else
                    doHold = true; 
                end 
                if k == 3
                    dontSave = false;
                else
                    dontSave = true; 
                end 
                % Provide raw data
                data_vals = MultiCS_CZL2575(:,k);
                
            
                % Plot and calculate the mean and standard deviation 
                plotConditions(data_vals, data_labels, ...
                    plot_settings, plot_names, doHold, dontSave);

                clear data_vals 
            
            end 
            clear plot_settings data_vals data_labels
            %Update the summary file  
            save(fullfile(settings.SUMMARY_path, ...
                strcat(settings.SUMMARY_name{1},'.mat')),...
                'MultiCS_Data','MultiCond','-append');  
        end


        %%%%%%%%%%%%%%%%%%%%%%%%%% EXCEL STATISTICS %%%%%%%%%%%%%%%%%%%%%%%%%%%

        % Add statistics to excel file 
        ConditionValue = cond_num;
        ConditionName = cell(size(ConditionValue)); 
        NumberCoverSlips = zeros(size(ConditionValue)); 
        for k = 1:length(ConditionName) 
            ConditionName{k,1} = settings.cond_names{ConditionValue(k,1),1}; 
            % Calculate the number of coverslips for each condition by
            % getting all of the condition labels and then removing all of
            % the conditions that do not match the current condition 
            cond_CS_all = MultiCS_Cond'; 
            cond_CS_all(cond_CS_all ~= ConditionValue(k)) = []; 
            NumberCoverSlips(k,1) = length(cond_CS_all); 
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
        else 
            %Set to NaN if does not exist 
            ZlineFraction_mean = NaN*zeros(size(ConditionName)); 
            ZlineFraction_stdev = NaN*zeros(size(ConditionName)); 
        end 

        %Save in table 
        T = table(ConditionValue,ConditionName,NumberCoverSlips,...
            OOPzline_mean,OOPzline_stdev,OOPactin_mean,...
            OOPactin_stdev,ZlineFraction_mean,ZlineFraction_stdev, ...
            MedianCZL_mean,MedianCZL_stdev,TotalCZL_mean,TotalCZL_stdev); 

        %Write the sheet
        filename = strcat(settings.SUMMARY_name{1}, '.xlsx'); 
        writetable(T,fullfile(settings.SUMMARY_path,filename),...
            'Sheet',2,'Range','A1'); 
    else
        % Display message that actin segmentation parameter exploration
        % summary plots are not available 
        if settings.actin_explore
            disp('Summary plots for actin segmentation parameter exploration is not available at this time.'); 
        end
        % Display message that actin segmentation parameter exploration
        % summary [plot are not available 
        if settings.diffusion_explore
            disp('Summary plots for diffusion filtering parameter exploration is not available at this time.'); 
        end
    end 

end 

end

