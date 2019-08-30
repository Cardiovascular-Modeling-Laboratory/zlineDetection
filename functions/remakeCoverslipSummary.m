
% Select the coverslip summary file
[ CS_name, CS_path,~ ] = load_files( {'*CS_Summary*.mat'}, ...
    'Select CS summary file for coverslip you want to remake...', pwd);

% Load the current coverslip
CS_data = load(fullfile(CS_path{1},CS_name{1,1})); 

% Get z-line image names 
all_zlineimages = CS_data.CS_results.zline_images; 
zline_images = CS_data.CS_results.zline_images; 

%%
% Logical statement for selecting field of view (images) to eliminate 
stillEliminating = true; 
while stillEliminating
    
    % Display message 
    disp('Select all z-line image fields of view you want to eliminate.'); 
    
    imagelist = zline_images;
    [indx,tf] = listdlg('ListString',imagelist,...
        'ListSize',[300 300],'SelectionMode','multiple',...
        'Name','Images to eliminate');
    
    clc; 
    
    if ~tf
        msg = 'You did not make a selection, a new summary file will not be created.'; 
    else
        % Get teh number eliminated
        numelim = length(indx);
        % Check to make sure the user didn't select all 
        if numelim == length(zline_images)
            msg = 'You selected all of the images, a new summary file will not be created.'; 
            tf = false; 
        else
            % Display all z-lines 
            if numelim == 1
                msg = strcat('You eliminated',{' '},num2str(numelim), {' '}, 'image.');
                msg0 = strcat('The',{' '},num2str(numelim), {' '}, 'z-line image you eliminated:');
            else
                msg = strcat('You eliminated',{' '},num2str(numelim), {' '}, 'images.');
                msg0 = strcat('The',{' '},num2str(numelim), {' '}, 'z-line images you eliminated:');
            end 
            disp(msg0{1})
            % Display eliminated FOV
            for k = 1:numelim
                disp(zline_images{1,indx(k)}); 
            end 
        end 
    end
    
    quest = strcat(msg, {' '}, 'Would like like to accept your selection?'); 
    % Ask the user if they'd like to load the images or just the settings
    acceptSelection = questdlg(quest{1}, ...
            'Accept Elimination','Yes','No',...
            'Yes');

    % Check response to user input 
    if strcmp('Yes',acceptSelection)
        
        if tf             
            % Get today's data
            date_format = 'yyyymmdd';
            today_date = datestr(now,date_format);
            % Replace the old date with the new date 
            % Get coverslip parts
            [~,old_name,ext] = fileparts(CS_name{1}); 
            new_name = strrep(old_name,old_name(end-7:end), today_date); 
            % Append the filename 
            new_name = appendFilename( CS_path{1}, new_name ); 

            
            %Prompt Questions
            sumname_prompt = strcat('Your new coverslip summary file will be located: ',...
                {' '},CS_path{1}, {' '}, ...
                'Accept or rename the new coverslip summary file name (no extension):'); 
            %Title of prompt
            sumname_title = 'New Coverslip Summary File Name (no extension)';
            %Dimensions
            sumname_dims = [1 80];
            %Default inputs
            sumname_definput = {new_name};
            %Save answers
            new_name = inputdlg(sumname_prompt,sumname_title,...
                sumname_dims,sumname_definput);
            new_name = strcat(new_name, ext); 
        
        end 
        
        stillEliminating = false;
        
    end
    
end

%%
% If the user selected enough images 
if tf
    % Start logical 
    dontCreate = false; 
    % Store the settings 
    settings = CS_data.settings; 
    % Create structs to hold the CS_results and FOV_results 
    CS_results = struct(); 
    FOV_results = struct();
    % Store the eliminated info in a struct 
    eliminated_results = struct(); 
    eliminated_results.all_zlineimages = all_zlineimages; 
    eliminated_results.old_CSname = old_name;
    eliminated_results.numelim = numelim; 
    eliminated_results.elim_index = indx; 
    
    % Loop through and recreate the CS_results and FOV_results 
    num_keep = 1:length(all_zlineimages); 
    for k = 1:numelim
        num_keep(num_keep == indx(k)) = NaN; 
    end 
    % Remove all of the elimated values 
    num_keep(isnan(num_keep)) = []; 
    % Check to make sur ethe numbers match 
    if length(num_keep) ~= length(all_zlineimages)
        disp('Issue eliminating z-lines'); 
        dontCreate = true; 
    end 
    
    if ~dontCreate
        % Get the number of z-line images to keep 
        zn = length(num_keep); 
        
        % Initialize matrices
        %>>> Actin Filtering analysis 
        FOV_nonzlinefrac = cell(1,zn);
        FOV_zlinefrac = cell(1,zn);
        FOV_prefiltered = cell(1,zn); 
        FOV_postfiltered = cell(1,zn); 
        %>>> Continuous Z-line Analysis
        FOV_lengths = cell(1,zn); 
        FOV_medians = cell(1,zn); 
        FOV_means = cell(1,zn); 
        FOV_sums = cell(1,zn);  
        %>>> Z-line Angle analysis
        FOV_angles = cell(1,zn);  
        FOV_OOPs = cell(1,zn); 
        FOV_directors = cell(1,zn); 
        FOV_anglecount = cell(1,zn); 
        %>>> EXPLORATION Parameters
        FOV_thresholds = cell(1,zn); 
        FOV_grid_sizes = cell(1,zn); 
        %>>> Actin angle analysis
        ACTINFOV_angles = cell(1,zn);  
        ACTINFOV_OOPs = cell(1,zn); 
        ACTINFOV_directors = cell(1,zn); 
        ACTINFOV_anglecount = cell(1,zn); 
       
        % Initialize zline images 
        zline_images = cell(1,zn); 
        % Store the z-line path 
        zline_path = CS_results.zline_path; 
        
        % Loop through and get all of the data 
        for k = 1:length(num_keep)
            
            % Store the z-line images 
             zline_images{1,k} = all_zlineimages{1,num_keep(k)};

            if isfield(CS_data.FOV_results,'FOV_prefiltered')	 
                FOV_prefiltered{1,k} = FOV_results.FOV_prefiltered{1,num_keep(k)};	
            else
                FOV_prefiltered{1,k} = [];	
            end
            
            if isfield(CS_data.FOV_results,'FOV_postfiltered')	 
                FOV_postfiltered{1,k} = FOV_results.FOV_postfiltered{1,num_keep(k)};	
            else
                FOV_postfiltered{1,k} = [];	
            end
            
            if isfield(CS_data.FOV_results,' FOV_lengths')	 
                FOV_lengths{1,k} = CS_data.FOV_results.FOV_lengths{1,num_keep(k)};	
            else
                FOV_lengths{1,k} = [];
            end 

            if isfield(CS_data.FOV_results,' FOV_angles')	 
                FOV_angles{1,k} = CS_data.FOV_results.FOV_angles{1,num_keep(k)};	
            else
                FOV_angles{1,k} = [];
            end 
            
            if isfield(CS_data.FOV_results,' ACTINFOV_angles')	 
                ACTINFOV_angles{1,k} = CS_data.FOV_results.ACTINFOV_angles{1,num_keep(k)};	
            else
                ACTINFOV_angles{1,k} = [];
            end 

            if isfield(CS_data.FOV_results,' FOV_thresholds')	 
                FOV_thresholds{1,k} = CS_data.FOV_results.FOV_thresholds{1,num_keep(k)};	
            else
                FOV_thresholds{1,k} = [];
            end 
            
            if isfield(CS_data.FOV_results,' FOV_grid_sizes')	 
                FOV_grid_sizes{1,k} = FOV_results.FOV_grid_sizes{1,num_keep(k)};	
            else
                FOV_grid_sizes{1,k} = [];
            end 

        end
        %Create a struct for the coverslip data  
        CS_results = struct(); 
        %>>> Files 
        CS_results.zline_path = zline_path;
        CS_results.zline_images = zline_images; 
        %>>> Actin Filtering analysis 
        CS_results.FOV_prefiltered = FOV_prefiltered;
        CS_results.FOV_postfiltered = FOV_postfiltered;
        %>>> Continuous Z-line Analysis 
        CS_results.FOV_lengths = FOV_lengths;
        %>>> Z-line Angle analysis  
        CS_results.FOV_angles = FOV_angles; 
        %>>> Actin angle analysis 
        CS_results.ACTINFOV_angles = ACTINFOV_angles; 
        %>>> EXPLORATION Parmaeters 
        CS_results.FOV_thresholds = FOV_thresholds; 
        CS_results.FOV_grid_sizes = FOV_grid_sizes; 

        %Combine the FOV 
        CS_results = combineFOV( settings, CS_results ); 

        %Create new struct to hold FOV data 
        FOV_results = struct();
        %>>> Files 
        FOV_results.zline_path = zline_path;
        FOV_results.zline_images = zline_images;
        %>>> Actin Filtering analysis 
        FOV_results.FOV_nonzlinefrac = FOV_nonzlinefrac;
        FOV_results.FOV_zlinefrac = FOV_zlinefrac;
        FOV_results.FOV_prefiltered = FOV_prefiltered;
        FOV_results.FOV_postfiltered = FOV_postfiltered;
        %>>> Continuous Z-line Analysis 
        FOV_results.FOV_lengths = FOV_lengths;
        FOV_results.FOV_medians = FOV_medians;
        FOV_results.FOV_sums = FOV_sums;
        %>>> Z-line Angle analysis  
        FOV_results.FOV_angles = FOV_angles;
        FOV_results.FOV_OOPs = FOV_OOPs; 
        FOV_results.FOV_directors = FOV_directors;
        FOV_results.FOV_anglecount = FOV_anglecount;
        %>>> Actin angle analysis 
        FOV_results.ACTINFOV_angles = ACTINFOV_angles;
        FOV_results.ACTINFOV_OOPs = ACTINFOV_OOPs; 
        FOV_results.ACTINFOV_directors = ACTINFOV_directors; 
        FOV_results.ACTINFOV_anglecount = ACTINFOV_anglecount; 
        %>>> EXPLORATION Parameters 
        FOV_results.FOV_thresholds = FOV_thresholds;
        FOV_results.FOV_grid_sizes = FOV_grid_sizes;

        %Remove the appropriate data fields from the CS_results struct 
        CS_results = rmfield(CS_results, 'FOV_prefiltered');
        CS_results = rmfield(CS_results, 'FOV_postfiltered');
        CS_results = rmfield(CS_results, 'FOV_lengths');
        CS_results = rmfield(CS_results, 'FOV_angles');
        CS_results = rmfield(CS_results, 'FOV_thresholds');
        CS_results = rmfield(CS_results, 'FOV_grid_sizes');
        CS_results = rmfield(CS_results, 'ACTINFOV_angles');
    
    
    end 
    
    save(fullfile(CS_path{1},new_name{1}), 'settings','CS_results',...
        'FOV_results'); 
    
end 
