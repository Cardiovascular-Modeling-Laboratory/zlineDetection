% postAnalysisSummary - Asks the user whether they would like to (1) Load
% settings & image paths (2) Load settings & select images 

%% Add paths with relevant functions 
addpath('plottingFunctions'); 

%% LOAD OLD DATA

% Logical whether user wants to load old image paths 
combineMultipleRuns = true;

% Ask the user if they'd like to load the images or just the settings
runType = questdlg('Would you like to combine coverslips from different zlineDetection runs?', ...
        'Post Analysis Summary','Combine Different Runs','One Run',...
        'Combine Different Runs');
    
% Check response to user input 
if strcmp('One Run',runType)
    combineMultipleRuns = false;
end

% Can summarize
canSummarize = true; 
    

previous_path = pwd; 
pathname = {previous_path}; 
% Check what the user wants to only load settings 
if ~combineMultipleRuns
%     % Set the display message
%     dispmsg = 'Select .mat file that contains settings...';
% else
    % Set the display message
    dispmsg = 'Select .mat file that contains settings and image paths...';
    
    % Have the user select a file that has settings that they would like to
    [ filename, pathname, ~ ] = load_files( ...
        {'*Initialization*.mat;*OrientationAnalysis*.mat'},...
        dispmsg, previous_path, 'off' );

    % Load the previous data
    previous_data = load(fullfile(pathname{1}, filename{1})); 



    % Check to make sure settings is a field 
    if isfield(previous_data, 'settings')
        % Store the settings 
        settings = previous_data.settings;
    else
        disp('Settings not provided in .mat file.');
        canSummarize = false; 
    end  

end 



% Get the data paths from the struct according to settings, if the 
% fields exist 
if ~combineMultipleRuns && canSummarize
    
    % Store the z-line image names if it exist as a field.
    if isfield(previous_data, 'zline_images')
        zline_images = previous_data.zline_images; 
    else
        combineMultipleRuns = false; 
        disp('Cannot select data, zline_images not provided'); 
    end 

    % Store the z-line image paths if it exist as a field.
    if isfield(previous_data, 'zline_path') && ~combineMultipleRuns
        zline_path = previous_data.zline_path; 
    else
        combineMultipleRuns = true; 
        disp('Cannot select data, zline_path not provided'); 
    end 

    % Store the coverslip name if it exist as a field.
    if isfield(previous_data, 'name_CS') && ~combineMultipleRuns
        name_CS = previous_data.name_CS; 
    else
        combineMultipleRuns = true; 
        disp('Cannot select data, name_CS not provided'); 
    end 

    % Check if the user did actin filtering if it exist as a field.
    if settings.actin_filt && ~combineMultipleRuns
        % Store the z-line image names if it exist as a field.
        if isfield(previous_data, 'actin_images')
            actin_images = previous_data.actin_images; 
        else
            combineMultipleRuns = true; 
            disp('Cannot select data, actin_images not provided'); 

        end 

        % Store the z-line image paths if it exist as a field.
        if isfield(previous_data, 'actin_path') && ~combineMultipleRuns
            actin_path = previous_data.actin_path; 
        else
            combineMultipleRuns = true; 
            disp('Cannot select data, actin_path not provided'); 

        end 
    else
        % Set actin images and path to empty if not doing actin filtering 
        actin_images = []; 
        actin_path = []; 
    end 

    % Check if the user selected conditions if it exist as a field.
    if settings.multi_cond && ~combineMultipleRuns
        % Store the z-line conditiosn if it exist as a field.
        if isfield(previous_data, 'cond')
            cond = previous_data.cond; 
        else
            combineMultipleRuns = true; 
            disp('Cannot select data, cond not provided'); 

        end    
    else
        % Set cond to empty if not setting conditions 
        cond = []; 
    end    
    
    numcs = settings.num_cs; 
end

%% Select Coverslip Summaries

if combineMultipleRuns && canSummarize
    settings = struct(); 
    %Prompt Questions
    numcs_prompt = {'Number of Coverslips to Summarize'};
    %Title of prompt 
    numcs_title = 'Post Analysis Coverslip Summary';
    %Dimensions 
    numcs_dims = [1,45];
    %Save answers
    numcs_answer = inputdlg(numcs_prompt,numcs_title,...
    numcs_dims);

    numcs = str2double(numcs_answer{1});
    % Save the number of coverslips 
    settings.num_cs = numcs; 
    
    previous_path = pathname{1}; 
    zline_images = cell(numcs,1);
    zline_path = cell(numcs,1);
    actin_images = cell(numcs,1);
    actin_path = cell(numcs,1);
    cond = zeros(numcs,1); 
    name_CS = cell(numcs,1);
    
    % Set multiple condtions to be true 
    settings.multi_cond = true; 
    % Settings defaults 
    settings.diffusion_explore = false; 
    settings.grid_explore = false; 
    settings.actinthresh_explore = false; 
    settings.analysis = true; 
    settings = additionalUserInput(settings); 
end 

% Initialize CS path and names
CS_path = cell(numcs,1); 
CS_name = cell(numcs,1);

%Start counting variable
for k = 1:numcs
    %Display message telling the user which coverslip they're on 
    disp_message = strcat('Selecting Coverslip',{' '}, num2str(k),...
        {' '}, 'of', {' '}, num2str(numcs)); 
    disp(disp_message); 
    
    if ~combineMultipleRuns
        % Prompt the user to select the images they would like to analyze. 
        [ CS_name{k,1}, CS_path{k,1},~ ] = ...
            load_files( {'*CS_Summary*.mat'}, ...
            'Select CS summary file...', zline_path{k});
    else
        % Prompt the user to select the images they would like to analyze. 
        [ CS_name{k,1}, CS_path{k,1},~ ] = ...
            load_files( {'*CS_Summary*.mat'}, ...
            'Select CS summary file...', settings.SUMMARY_path);
        
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
        if((pathparts{1,potential_end} == 'RenamedTifsForZlineDetect') | (pathparts{1,potential_end} == 'RenamedTifs'))
            name_CS{k,1} = pathparts{1,potential_end-1};
        else
            name_CS{k,1} = pathparts{1,potential_end};
        end

        % Store the names to use as strings 
        temp_path = CS_path{k,1}; 
        disp(temp_path{1});

        % If this is the first iteration use settings
        cond(k,1) = ...
                declareCondition(settings.cond_names, k, settings.num_cs); 
    end     
        
    %Display the condition the user selected 
    disp_message = strcat('For Coverslip:',{' '},name_CS{k,1},...
        ', Condition Selected:',{' '}, ...
        settings.cond_names{cond(k,1),1}); 
    disp(disp_message{1}); 
        
end


%% Initialize Matrices to store all data 
clc

%Initialize matrices to hold analysis information for each coverslip
%>>> IDs for the different coverslips and conditions 
MultiCS_CSID = cell(1,numcs); 
MultiCS_CONDID = cell(1,numcs); 
%>>> Actin Filtering analysis 
MultiCS_nonzlinefrac = cell(1,numcs);
MultiCS_zlinefrac = cell(1,numcs);
%>>> Continuous Z-line Analysis
MultiCS_medians = cell(1,numcs); 
MultiCS_means = cell(1,numcs);
MultiCS_skewness = cell(1,numcs);
MultiCS_kurtosis = cell(1,numcs);
MultiCS_sums = cell(1,numcs); 
MultiCS_lengths = cell(1,numcs);
%>>> Z-line Angle analysis
MultiCS_orientim = cell(1,numcs); 
MultiCS_OOP = cell(1,numcs);
MultiCS_anglecount = cell(1,numcs); 
MultiCS_directors = cell(1,numcs); 
%>>> EXPLORATION Parameters
MultiCS_grid_sizes = cell(1,numcs);
MultiCS_actin_threshs = cell(1,numcs);
%>>> Actin angle analysis
MultiCS_ACTINorientim = cell(1,numcs); 
MultiCS_ACTINOOP = cell(1,numcs);
MultiCS_ACTINanglecount = cell(1,numcs); 
MultiCS_ACTINdirectors = cell(1,numcs); 

%%%%%%%%%%%%%%%%%%%%%%% Load Previous Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~combineMultipleRuns
    % Load z-line images and paths 
    zline_images = cell(numcs,1);
    zline_path = cell(numcs,1);
end 

for k = 1:numcs 
   
    % Store the names to use as strings 
    temp_path = CS_path{k,1}; 
    temp_name = CS_name{k,1};
    % Load each coverslip
    data = load(fullfile(temp_path{1}, temp_name{1})); 
    CS_results = data.CS_results; 
    
    % If this is the first iteration use settings
    if k == 1
        if ~combineMultipleRuns
            settings = data.settings;
            settings.num_cs = numcs; 
        else
            temp_settings = settings; 
            settings = data.settings; 
            settings.num_cs = temp_settings.num_cs; 
            settings.multi_cond = temp_settings.multi_cond; 
            settings.num_cond = temp_settings.num_cond; 
            settings.cond_names = temp_settings.cond_names; 
            settings.SUMMARY_path = temp_settings.SUMMARY_path; 
            settings.SUMMARY_name = temp_settings.SUMMARY_name; 
            
        end 
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
 
%%%%%%%%%%%%%%%%%%%%%%%% Summarize Coverslips %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Get the name and location of summary file if there is more than one
%coverslip and the user wants to do any kind of analysis 
if settings.num_cs > 1 && settings.analysis && ~combineMultipleRuns
    %Display message to select path 
    disp('Select a location to save summary analysis for all Coverslips'); 
    %Ask the user for the location of the summary file 
    settings.SUMMARY_path = ...
        uigetdir(settings.SUMMARY_path,'Save Location for Summary Files'); 
    
    %Get the parts of the summary path 
    pathparts = strsplit(settings.SUMMARY_path,filesep); 
    
    %Find the location of the current folder 
    potential_end = size(pathparts,2); 
    while isempty(pathparts{1,potential_end})
        potential_end = potential_end -1; 
    end 
    
    %Get the name of folder 
    base_name = pathparts{1,potential_end}; 
    
    %Get today's date
    date_format = 'yyyymmdd';
    today_date = datestr(now,date_format);
    
    %Suggested suggested name for files  
    suggested_name = strcat(base_name, '_MultiCondSummary_',today_date);
    
    %Ask the user for the summary name 
    %Prompt Questions
    sumname_prompt = ...
        {'Name of Summary File for Multiple Coverslips (no extension):'};
    %Title of prompt
    sumname_title = 'Summary File Name';
    %Dimensions
    sumname_dims = [1 80];
    %Default inputs
    sumname_definput = {suggested_name};
    %Save answers
    settings.SUMMARY_name = inputdlg(sumname_prompt,sumname_title,...
        sumname_dims,sumname_definput);
end 


% Store all of the Multi CS data in a struct if these are not single cells
% and there is more than one CS 
if settings.cardio_type == 1 && numcs > 1 ...
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