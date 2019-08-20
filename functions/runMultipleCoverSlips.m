% runMultipleCoverSlips - Analyzes multiple coverlsips
%
% Usage:
%  [zline_images, zline_path, name_CS,...
%         actin_images, actin_path, cond] ...
%         = getZlineDetectionImages(settings); 
% 
% Arguments:
%   settings        - Contains settings for z-line detection 
%                       Class Support: STRUCT 
%   zline_images    - Cell to hold z-line image name(s)
%                       Class Support: Cell 
%   zline_path      - Cell to hold z-line path name(s)
%                       Class Support: Cell 
%   name_CS         - Cell to hold the coverslip name(s) 
%                       Class Support: Cell 
%   actin_images    - Cell to hold actin image name(s)
%                       Class Support: Cell 
%   actin_path      - Cell to hold actin path name(s)
%                       Class Support: Cell 
%   cond            - Condition numbers
%                       Class Support: settings.num_cs x 1 vector  
%
% 
% Dependencies: 
%   MATLAB Version >= 9.5 
%
%
% Tessa Morris
% Advisor: Anna Grosberg
% Cardiovascular Modeling Laboratory 
% University of California, Irvine 

function [] = runMultipleCoverSlips(settings, zline_images, zline_path, ...
    name_CS, actin_images, actin_path, cond)

%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Initialize matrices to hold analysis information for each coverslip
%>>> IDs for the different coverslips and conditions 
MultiCS_CSID = cell(1,settings.num_cs); 
MultiCS_CONDID = cell(1,settings.num_cs); 
%>>> Actin Filtering analysis 
MultiCS_nonzlinefrac = cell(1,settings.num_cs);
MultiCS_zlinefrac = cell(1,settings.num_cs);
%>>> Continuous Z-line Analysis
MultiCS_medians = cell(1,settings.num_cs); 
MultiCS_means = cell(1,settings.num_cs);
MultiCS_skewness = cell(1,settings.num_cs);
MultiCS_kurtosis = cell(1,settings.num_cs);
MultiCS_sums = cell(1,settings.num_cs); 
MultiCS_lengths = cell(1,settings.num_cs);
%>>> Z-line Angle analysis
MultiCS_orientim = cell(1,settings.num_cs); 
MultiCS_OOP = cell(1,settings.num_cs);
MultiCS_anglecount = cell(1,settings.num_cs); 
MultiCS_directors = cell(1,settings.num_cs); 
%>>> EXPLORATION Parameters
MultiCS_grid_sizes = cell(1,settings.num_cs);
MultiCS_actin_threshs = cell(1,settings.num_cs);
%>>> Actin angle analysis
MultiCS_ACTINorientim = cell(1,settings.num_cs); 
MultiCS_ACTINOOP = cell(1,settings.num_cs);
MultiCS_ACTINanglecount = cell(1,settings.num_cs); 
MultiCS_ACTINdirectors = cell(1,settings.num_cs); 

%%%%%%%%%%%%%%%%%%%%%%%%%%% Analyze all CS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Loop through and run each coverslip 
clear k 
for k = 1:settings.num_cs 
    
    % Analyze each coverslip 
    [ CS_results ] = ...
        runDirectory( settings, zline_path{k,1}, zline_images{k,1},...
        actin_path{k,1}, actin_images{k,1}, name_CS{k,1} ); 
    
    %Store the results from each coverslip if these are not single cells 
    if settings.cardio_type == 1 && settings.analysis && ...
            ~settings.diffusion_explore
        %Store the results from analyzing each coverslip 
        MultiCS_lengths{1,k} = CS_results.CS_lengths;
        MultiCS_medians{1,k} =CS_results.CS_medians;
        MultiCS_sums{1,k} = CS_results.CS_sums;
        MultiCS_means{1,k} = CS_results.CS_means; 
        MultiCS_skewness{1,k} = CS_results.CS_skewness;
        MultiCS_kurtosis{1,k} = CS_results.CS_kurtosis; 
        MultiCS_nonzlinefrac{1,k} = CS_results.CS_nonzlinefrac;
        MultiCS_zlinefrac{1,k} = CS_results.CS_zlinefrac;
        MultiCS_grid_sizes{1,k} = CS_results.CS_gridsizes;
        MultiCS_actin_threshs{1,k} = CS_results.CS_thresholds;
        MultiCS_OOP{1,k} = CS_results.CS_OOPs;    
        MultiCS_anglecount{1,k} = CS_results.angle_count; 
        MultiCS_orientim{1,k} = CS_results.CS_angles; 
        MultiCS_directors{1,k} = CS_results.CS_directors; 
        %Save coverslip number 
        MultiCS_CSID{1,k} = k*ones(size(CS_results.CS_OOPs));
        
    end
    
    %Store the actin OOP for each coverslip and the number of orientation
    %vectors 
    if settings.cardio_type == 1 && settings.actin_filt && ...
            ~settings.diffusion_explore
        MultiCS_ACTINOOP{1,k} = CS_results.ACTINCS_OOPs; 
        MultiCS_ACTINanglecount{1,k} = CS_results.ACTINangle_count;
        MultiCS_ACTINorientim{1,k} = CS_results.ACTINCS_angles; 
        MultiCS_ACTINdirectors{1,k} = CS_results.ACTINCS_directors; 
    end 
    
    %Store the condition ID 
    if settings.cardio_type == 1 && settings.multi_cond ...
            && settings.analysis && ~settings.diffusion_explore
        %Save the condition ID 
        MultiCS_CONDID{1,k} = ...
            cond(k,1)*ones(size(CS_results.CS_gridsizes));
    end
    
end 

%%%%%%%%%%%%%%%%%%%%%%%% Summarize Coverslips %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Store all of the Multi CS data in a struct if these are not single cells
% and there is more than one CS 
if settings.cardio_type == 1 && settings.num_cs > 1 ...
        && ~settings.diffusion_explore
    
    %Store results in struct 
    MultiCS_Data = struct(); 
    %>>> IDs for the different coverslips and conditions 
    MultiCS_Data.MultiCS_CSID=MultiCS_CSID;
    MultiCS_Data.MultiCS_CONDID=MultiCS_CONDID;    
    MultiCS_Data.name_CS = name_CS;
    %>>> Actin Filtering analysis
    MultiCS_Data.MultiCS_nonzlinefrac=MultiCS_nonzlinefrac;
    MultiCS_Data.MultiCS_zlinefrac=MultiCS_zlinefrac; 
    %>>> Continuous Z-line Analysis
    MultiCS_Data.MultiCS_lengths=MultiCS_lengths;
    MultiCS_Data.MultiCS_medians=MultiCS_medians;
    MultiCS_Data.MultiCS_sums=MultiCS_sums;
    MultiCS_Data.MultiCS_means=MultiCS_means; 
    MultiCS_Data.MultiCS_skewness=MultiCS_skewness;
    MultiCS_Data.MultiCS_kurtosis=MultiCS_kurtosis; 
        
    %>>> Z-line Angle analysis
    MultiCS_Data.MultiCS_orientim = MultiCS_orientim; 
    MultiCS_Data.MultiCS_OOP=MultiCS_OOP;
    MultiCS_Data.MultiCS_anglecount = MultiCS_anglecount; 
    MultiCS_Data.MultiCS_directors = MultiCS_directors; 
    %>>> Actin angle analysis
    MultiCS_Data.MultiCS_ACTINorientim = MultiCS_ACTINorientim; 
    MultiCS_Data.MultiCS_ACTINOOP = MultiCS_ACTINOOP; 
    MultiCS_Data.MultiCS_ACTINanglecount = MultiCS_ACTINanglecount; 
    MultiCS_Data.MultiCS_ACTINdirectors = MultiCS_ACTINdirectors; 
    %>>> EXPLORATION Parameters 
    MultiCS_Data.MultiCS_grid_sizes=MultiCS_grid_sizes;
    MultiCS_Data.MultiCS_actin_threshs=MultiCS_actin_threshs;

    %Create summary information, including excel sheets and plots (when
    %applicable
    createSummaries(MultiCS_Data, name_CS, zline_images,...
        zline_path, cond, settings);
    
end 

%Clear command line and display finished time 
clc 
disp('zlineDetection Complete.'); 
t = datetime('now'); 
disp(t); 

end

