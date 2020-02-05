% postAnalysisConfocal 

%% Add paths with relevant functions 
addpath('plottingFunctions'); 

%% Load initialization functions

% Logical whether user wants to load multiple runs
combineMultipleRuns = true;

% Ask the user if they'd like to load the images or just the settings
runType = ...
    questdlg('Would you like to combine results from multiple ZlineDetection runs?', ...
        'Post Analysis Confocal Data','Combine Multiple Runs','One Run',...
        'Combine Multiple Runs');
    
% Check response to user input 
if strcmp('One Run',runType)
    combineMultipleRuns = false;
end

% Can summarize
canSummarize = true; 
    
% Initialize path 
previous_path = pwd; 
pathname = {previous_path};

% Check what the user wants to only load settings 
if ~combineMultipleRuns
    % Set the display message
    dispmsg = 'Select the multi condition summary initialization file...';
    
    % Have the user select a file that has settings that they would like to
    [ filename, pathname, ~ ] = load_files( ...
        {'*Initialization*.mat'},...
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
        name_CS{k,1} = pathparts{1,potential_end}; 

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

%% Confocal Table

% Get the total number of slices per FOV
nslice = length(zline_images{1});

% Store total number of FOV
total_confocalFOV = settings.num_cs;

% Store total number of Coverslips
if isempty(cond)
    total_confocalCS = 1;
else
    total_confocalCS = length(unique(cond));
end

% Total number of images
nim = nslice*total_confocalFOV;

% Image name and path 
ImageSliceName = cell(nim,1);
ImageSlicePath = cell(nim,1);
% Coverslip and FOV name
CoverslipName = cell(nim,1);
FieldofViewName = cell(nim,1);
CoverslipNumber = zeros(nim,1);
% Initialize Slice Number
SliceNumber = zeros(nim,1);

% Iteration counter
it = 1;
% Loop through the FOVs
for k = 1:total_confocalFOV
    for s = 1:nslice
        % Increase iteration
        it = it +1;
    end
end 