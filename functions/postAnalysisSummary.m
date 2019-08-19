% Set the number of coverslips 
settings.num_cs = 37; 
settings.SUMMARY_path = 'D:\NRVM_Tissues_20190807'; 
%%%%%%%%%%%%%%%%%%%%%%%%%% Initialize Matrices %%%%%%%%%%%%%%%%%%%%%%%%%%%

CS_path = cell(settings.num_cs,1); 
CS_name = cell(settings.num_cs,1); 
name_CS = cell(settings.num_cs,1); 

%Set previous path equal to the current location if only one coverslip is
%selected. Otherwise set it to the location where the CS summary should be
%saved 
if settings.num_cs > 1 
    previous_path = settings.SUMMARY_path; 
else 
    previous_path = pwd; 
end 

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Select Files %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all; 

%Start counting variable
for k = 1:settings.num_cs
    %Display message telling the user which coverslip they're on 
    disp_message = strcat('Selecting Coverslip',{' '}, num2str(k),...
        {' '}, 'of', {' '}, num2str(settings.num_cs)); 
    disp(disp_message); 


    % Prompt the user to select the images they would like to analyze. 
    [ CS_name{k,1}, CS_path{k,1},~ ] = ...
        load_files( {'*20190809.mat'}, ...
        'Select CS summary file...', previous_path);
    
    %Temporarily store the path 
    temp_path = CS_path{k,1}; 

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
    
    % Store the name of the coverslip
    potential_end = size(pathparts,2); 
    while isempty(pathparts{1,potential_end})
        potential_end = potential_end -1; 
    end 
    %Save the name of the directory 
    name_CS{k,1} = pathparts{1,potential_end}; 
    
    % Display update
    disp_message = strcat('Selected Coverslip:',{' '},name_CS{k,1}); 
    disp(disp_message{1});
        
end

clear k
%%
% Load z-line images and paths 
zline_images = cell(settings.num_cs,1);
zline_path = cell(settings.num_cs,1);

for k = 1:settings.num_cs 
   
    % Store the names to use as strings 
    temp_path = CS_path{k,1}; 
    temp_name = CS_name{k,1};
    % Load each coverslip
    data = load(fullfile(temp_path{1}, temp_name{1})); 
    CS_results = data.CS_results; 
    
    % If this is the first iteration use settings
    if k == 1
        settings = data.settings; 
    end 
    
    % Store the z-line images and path 
    zline_images{k,1} = CS_results.zline_images; 
    zline_path{k,1} = CS_results.zline_path; 
    
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


%% Get the condition 
cond = zeros(settings.num_cs,1); 
for k = 1:settings.num_cs 
   
    % Store the names to use as strings 
    temp_path = CS_path{k,1}; 
    disp(temp_path{1}); 
    % If this is the first iteration use settings
    cond(k,1) = ...
            declareCondition(settings.cond_names, k, settings.num_cs); 
        
    %Display the condition the user selected 
    disp_message = strcat('For Coverslip:',{' '},name_CS{k,1},...
        ', Condition Selected:',{' '}, ...
        settings.cond_names{cond(k,1),1}); 
    disp(disp_message{1}); 
end 

%% Fix name cs
for k = 1:settings.num_cs
        %Temporarily store the path 
    temp_path = CS_path{k,1}; 

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
    
    % Store the name of the coverslip
    potential_end = size(pathparts,2); 
    while isempty(pathparts{1,potential_end})
        potential_end = potential_end -1; 
    end 
    %Save the name of the directory 
    name_CS{k,1} = pathparts{1,potential_end}; 
    
end 

%% Save the condition ID
for k = 1:settings.num_cs
    %Save the condition ID 
    MultiCS_CONDID{1,k} = ...
        cond(k,1)*ones(size(CS_results.CS_gridsizes));    
end 

%%

 
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
disp('Finished summarizing.'); 