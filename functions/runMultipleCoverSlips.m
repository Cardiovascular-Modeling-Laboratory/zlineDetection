function [] = runMultipleCoverSlips(settings)
%This function will be used to run multiple coverslips and obtain a summary
%file

%Possible stains/wells that could included in filenames and should be
%excluded in concatination of filenames
string1 = {'w1','w2','w3','w4','w5'};
string2 = {'Cy7','mCherry','GFP','DAPI'};
txt_exclude = combineStrings(string1,string2);

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
%>>> IDs for the different coverslips and conditions 
MultiCS_CSID = cell(1,settings.num_cs); 
MultiCS_CONDID = cell(1,settings.num_cs); 
%>>> Actin Filtering analysis 
MultiCS_nonzlinefrac = cell(1,settings.num_cs);
MultiCS_zlinefrac = cell(1,settings.num_cs);
%>>> Continuous Z-line Analysis
MultiCS_medians = cell(1,settings.num_cs); 
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


%Save the orientation angles of actin and zlines for each CS 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Select Files %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all; 

%Start counting variable
k = 1; 
while k < settings.num_cs + 1 

    %Boolean statement to keep going unless there is an issue
    keepGoing = true; 
% %Have the user select the different directories for the coverslips
% for k = 1:settings.num_cs 
    
    %Display message telling the user which coverslip they're on 
    disp_message = strcat('Selecting Coverslip',{' '}, num2str(k),...
        {' '}, 'of', {' '}, num2str(settings.num_cs)); 
    disp(disp_message); 
    
    % Prompt the user to select the images they would like to analyze. 
    [ zline_images{k,1}, zline_path{k,1}, zn(k,1) ] = ...
        load_files( {'*w1mCherry*.TIF;*w1mCherry*.tif;*w4Cy7*.tif;*w1Cy7*.tif;*Sarc*.tif;*w3mCherry*.TIF'}, ...
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
        if an(k,1) ~= zn(k,1)
            %Display message telling the user that they did not select the
            %same number of files 
            disp(['The number of z-line files does not equal',...
                'the number of actin files.']); 
            disp(strcat('Actin Images: ',{' '}, num2str(an), ...
                'Z-line Images: ',{' '}, num2str(zn))); 
            %Set keepGoing equal to false so they keep selecting. 
            keepGoing = false; 
        else
            %Sort the z-line and actin file names to make sure that they're
            %matching
            [zline_images{k,1}, actin_images{k,1}, ~, together_vis] = ...
                sortFilenames(zline_images{k,1}, actin_images{k,1}, ...
                txt_exclude);
            %Display results for visualization together. 
            disp(together_vis); 
            disp('Please take a moment to make sure your files are properly sorted.'); 
            disp('Press any key to continue.'); 
            pause; 
            sortedProperly = questdlg('Are your filenames sorted properly?', ...
                    'File Sorting','Yes','No','Yes');
            %Re select this coverslip
            if strcmp('No',sortedProperly)
                %Set keepGoing equal to false so they keep selecting. 
                keepGoing = false; 
            end
            
        end
        

     
    else
        %Set the actin image to NaN 
        actin_images{k,1} = NaN; 
        actin_path{k,1} = NaN; 
        an(k,1) = NaN; 
    end  
    
    %Display path the user selected 
    disp(zline_path{k,1});
    
    if settings.multi_cond && keepGoing
        %Declare conditions for the selected coverslip 
        cond(k,1) = ...
            declareCondition(settings.cond_names, k, settings.num_cs); 
        
        %Display the condition the user selected 
        disp_message = strcat('For Coverslip:',{' '},name_CS{k,1},...
            ', Condition Selected:',{' '}, ...
            settings.cond_names{cond(k,1),1}); 
        disp(disp_message{1}); 
    end 
    
    % Only increase the counter if there were no issues with the data
    % selection
    if keepGoing 
        k = k + 1; 
    else
        disp('Fix any errors and reselect coverslip.'); 
    end
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%% Analyze all CS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Loop through and run each coverslip 
clear k 
for k = 1:settings.num_cs 
    
    % Analyze each coverslip 
    [ CS_results ] = ...
        runDirectory( settings, zline_path{k,1}, zline_images{k,1},...
        actin_path{k,1}, actin_images{k,1}, name_CS{k,1} ); 
    
    %Store the results from each coverslip if these are not single cells 
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
        MultiCS_anglecount{1,k} = CS_results.angle_count; 
        MultiCS_orientim{1,k} = CS_results.CS_angles; 
        MultiCS_directors{1,k} = CS_results.CS_directors; 
        %Save coverslip number 
        MultiCS_CSID{1,k} = k*ones(size(CS_results.CS_OOPs));
        
    end
    
    %Store the actin OOP for each coverslip and the number of orientation
    %vectors 
    if settings.cardio_type == 1 && settings.actin_filt 
        MultiCS_ACTINOOP{1,k} = CS_results.ACTINCS_OOPs; 
        MultiCS_ACTINanglecount{1,k} = CS_results.ACTINangle_count;
        MultiCS_ACTINorientim{1,k} = CS_results.ACTINCS_angles; 
        MultiCS_ACTINdirectors{1,k} = CS_results.ACTINCS_directors; 
    end 
    
    %Store the condition ID 
    if settings.cardio_type == 1 && settings.multi_cond && settings.analysis
        %Save the condition ID 
        MultiCS_CONDID{1,k} = ...
            cond(k,1)*ones(size(CS_results.CS_gridsizes));
    end
    
end 

%%%%%%%%%%%%%%%%%%%%%%%% Summarize Coverslips %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Store all of the Multi CS data in a struct if these are not single cells
% and there is more than one CS 
if settings.cardio_type == 1 && settings.num_cs > 1
    
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

