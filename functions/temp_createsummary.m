k = 1; 
previous_path = pwd; 
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
    
[ actin_images{k,1}, actin_path{k,1}, an(k,1) ] = ...
    load_files( {'*GFP*.TIF;*GFP*.tif;*Actin*.tif'}, ...
    'Select images stained for actin...',temp_path{1});


%% 
k = 1;
%%%%%%%%%%%%%%%%%%%%%%%% Initialize Variables  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
zline_path = zline_path{k,1}; 
zline_images = zline_images{k,1}; 
actin_path = actin_path{k,1}; 
actin_images= actin_images{k,1}; 
name_CS = name_CS{k,1}; 
%%
%%%%%%%%%%%%%%%%%%%%%%%% Initialize Matrices  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
zn = length(zline_images); 

%>>> ACTIN FILTERING: Non Zline Fractions (NO EXPLORATION) 
FOV_nonzlinefrac = cell(1,zn);
FOV_zlinefrac = cell(1,zn);

FOV_prefiltered = cell(1,zn); 
FOV_postfiltered = cell(1,zn); 

%>>> ACTIN FILTERING: Continuous z-line length (NO EXPLORATION) 
FOV_lengths = cell(1,zn); 
FOV_medians = cell(1,zn); 
FOV_sums = cell(1,zn);  

%>>> ACTIN FILTERING: OOP (NO EXPLORATION) 
FOV_angles = cell(1,zn);  
FOV_OOPs = cell(1,zn); 
FOV_directors = cell(1,zn); 

%>>> EXPLORATION
FOV_thresholds = cell(1,zn); 
FOV_grid_sizes = cell(1,zn); 

%>>>SAVE THE ACTIN VECTORS 
ACTINFOV_angles = cell(1,zn); 

for k = 1:zn
    %Load the data 
    new_name = zline_images{1,k}; 
    new_name = strcat(new_name(1:end-4),'_ActinExploration.mat'); 
    temp = zline_images{1,k}; 
    new_path = fullfile(zline_path{1},temp(1:end-4)); 
    data = load(fullfile(new_path, new_name )); 
    
    
    % Perform the analysis including saving the image 
    im_struct = data.im_struct; 
    
    %If the user is filtering with actin, save the actin orientation
    %vectors 
    if settings.actin_filt
        ACTINFOV_angles{1,k} = im_struct.actin_struct.actin_orientim;  
    end 
    
    % If the user wants to perform a parameter exploration for actin
    % filtering
    if settings.exploration
        
        %Loop through the range and save the skeleton, continuous 
        %z-line length and the non zline amount. 
        actin_explore = data.actin_explore;
        
        %Store Non zline Fraction Values 
        FOV_nonzlinefrac{1,k} = actin_explore.non_zlinefracs; 
        FOV_zlinefrac{1,k} = actin_explore.zlinefracs; 
        FOV_prefiltered{1,k} = ...
            actin_explore.pre_filt*ones(size(actin_explore.post_filt)); 
        FOV_postfiltered{1,k} = actin_explore.post_filt;  

        %>>> ACTIN FILTERING: Continuous z-line length 
        FOV_lengths{1,k} = actin_explore.lengths; 
        FOV_medians{1,k} = actin_explore.medians; 
        FOV_sums{1,k} = actin_explore.sums; 

        %>>> ACTIN FILTERING: OOP 
        FOV_angles{1,k} = actin_explore.orientims; 

        %>>> EXPLORATION
        FOV_thresholds{1,k} = actin_explore.thresholds;  
        FOV_grid_sizes{1,k} = actin_explore.grid_sizes; 
    else
        %>>> EXPLORATION
        FOV_thresholds{1,k} = settings.actin_thresh; 
        FOV_grid_sizes{1,k} = settings.grid_size(1);
        
    end 
    
    %If the user wants to filter with actin, save the non_zline fraction
    if settings.actin_filt && ~settings.exploration
        %Fraction for each FOV 
        FOV_nonzlinefrac{1,k} = im_struct.nonzlinefrac; 
        FOV_zlinefrac{1,k} = im_struct.zlinefrac; 
        
        %Get the post-filtered skeleton - used for CS calculation 
        temp_post = im_struct.skel_final;
        temp_post = temp_post(:);
        temp_post(temp_post == 0) = []; 
        
        %Get the pre filtering skeleton - used for CS calculation 
        temp_pre = im_struct.skelTrim; 
        temp_pre = temp_pre(:); 
        temp_pre(temp_pre == 0) = []; 
        
        %Store values for the CS calculation 
        FOV_prefiltered{1,k} = length(temp_pre); 
        FOV_postfiltered{1,k} = length(temp_post); 
    end 
    
    % If the user wants to calculate continuous z-line length 
    if settings.tf_CZL && ~settings.exploration 
        
        %Close all other figures so there isn't a chance of plotting
        %over anything
        close all; 
        
        %Calculate the continuous z-line length 
        FOV_lengths{1,k} = continuous_zline_detection(im_struct, settings); 

        %Compute the median
        FOV_medians{1,k} = median( FOV_lengths{1,k} ); 
        
        %Compute the sum 
        FOV_sums{1,k} = sum( FOV_lengths{1,k} ); 
        
        %Create a histogram of the distances
        figure; histogram(FOV_lengths{1,k});
        set(gca,'fontsize',16)
        hist_name = strcat('Median: ', num2str(FOV_medians{1,k}),' \mu m');
        title(hist_name,'FontSize',18,'FontWeight','bold');
        xlabel('Continuous Z-line Lengths (\mu m)','FontSize',18,...
            'FontWeight','bold');
        ylabel('Frequency','FontSize',18,'FontWeight','bold');
        
        %Save histogram as a tiff 
        fig_name = strcat( im_struct.im_name, '_CZLhistogram');
        saveas(gcf, fullfile(im_struct.save_path, fig_name), 'tiffn');
        
        %Close all of the images 
        close all; 
        
    end 

    % If the user wants to calculate OOP - Will need to change when I'm
    % analyzing tissues. 
    if settings.tf_OOP && ~settings.exploration
        
        %Save this orientation matrix 
        FOV_angles{1,k} = im_struct.orientim;
        
        %Save the orientation vectors as a new vairable
        temp_angles = FOV_angles{1,k}; 
        
        %If there are any NaN values in the angles matrix, set them to 0.
        temp_angles(isnan(temp_angles)) = 0;
        
        %Create OOP_struct to save data 
        oop_struct = struct(); 
        
        %Calculate the OOP, director vector and director angle 
        [ oop, oop_struct.directionAngle, ~, ...
            oop_struct.director ] = calculate_OOP( temp_angles ); 

        %Save the values in the the FOV matrix 
        FOV_OOPs{1,k} = oop; 
        oop_struct.oop = oop; 
        FOV_directors{1,k} = oop_struct.directionAngle; 
        
        %Append summary file with OOP 
        save(fullfile(im_struct.save_path, strcat(im_struct.im_name,...
           '_OrientationAnalysis.mat')), 'oop_struct', '-append');
    end 
    
    % Close all figures
    close all; 
    
    % Clear the file name 
    clear filename
    
    
end 


%Create a struct for the outputs 
CS_results = struct(); 

%>>> Files 
CS_results.zline_path = zline_path;
CS_results.zline_images = zline_images; 

%>>> ACTIN FILTERING: Non zline Fractions
CS_results.FOV_nonzlinefrac = FOV_nonzlinefrac;
CS_results.FOV_zlinefrac = FOV_zlinefrac;
CS_results.FOV_prefiltered = FOV_prefiltered;
CS_results.FOV_postfiltered = FOV_postfiltered;
%>>> ACTIN FILTERING: Continuous z-line length
CS_results.FOV_lengths = FOV_lengths;
CS_results.FOV_medians = FOV_medians; 
CS_results.FOV_sums = FOV_sums; 
%>>> ACTIN FILTERING: OOP 
CS_results.FOV_angles = FOV_angles;  
CS_results.FOV_OOPs = FOV_OOPs; 
CS_results.FOV_directors = FOV_directors; 
%>>> EXPLORATION
CS_results.FOV_thresholds = FOV_thresholds; 
CS_results.FOV_grid_sizes = FOV_grid_sizes; 
%>>> ACTIN FILTERING: ACTIN ANGLES / OOP
CS_results.ACTINFOV_angles = ACTINFOV_angles; 

% Get today's date in string form.
date_format = 'yyyymmdd';
today_date = datestr(now,date_format);

%Declare the type of summary file 
tp = {'CS', 'SC'}; 

%Name of the summary file 
summary_file_name = strcat(name_CS, tp{settings.cardio_type},...
    '_Summary',today_date,'.mat');

%Combine the FOV and save plots and .mat file  
%If this is a tissue combine the FOV, otherwise save
if settings.cardio_type == 1 && settings.analysis
    %Combine the FOV 
    CS_results = combineFOV( settings, CS_results ); 
    
    %Remove unnecessary fiels
    CS_results = rmfield(CS_results, 'FOV_Grouped');
    CS_results = rmfield(CS_results, 'FOV_OOPs'); 
    CS_results = rmfield(CS_results, 'FOV_directors'); 
    CS_results = rmfield(CS_results, 'FOVstats_medians');
    CS_results = rmfield(CS_results, 'FOVstats_sums');
    CS_results = rmfield(CS_results, 'FOVstats_nonzlinefrac');
    CS_results = rmfield(CS_results, 'FOVstats_zlinefrac');
    CS_results = rmfield(CS_results,'FOVstats_OOPs'); 
    CS_results = rmfield(CS_results,'ACTINFOVstats_OOPs'); 
    
    %Create new struct to hold FOV data 
    FOV_results = struct();
    %Save the appropriate data fields
    FOV_results.zline_path = zline_path;
    FOV_results.zline_images = zline_images;
    FOV_results.FOV_nonzlinefrac = FOV_nonzlinefrac;
    FOV_results.FOV_zlinefrac = FOV_zlinefrac;
    FOV_results.FOV_prefiltered = FOV_prefiltered;
    FOV_results.FOV_postfiltered = FOV_postfiltered;
    FOV_results.FOV_lengths = FOV_lengths;
    FOV_results.FOV_medians = FOV_medians;
    FOV_results.FOV_sums = FOV_sums;
    FOV_results.FOV_angles = FOV_angles;
    FOV_results.FOV_thresholds = FOV_thresholds;
    FOV_results.FOV_grid_sizes = FOV_grid_sizes;
    FOV_results.ACTINFOV_angles = ACTINFOV_angles;

    %Remove the appropriate data fields from the CS_results struct 
    CS_results = rmfield(CS_results, 'FOV_nonzlinefrac');
    CS_results = rmfield(CS_results, 'FOV_zlinefrac');
    CS_results = rmfield(CS_results, 'FOV_prefiltered');
    CS_results = rmfield(CS_results, 'FOV_postfiltered');
    CS_results = rmfield(CS_results, 'FOV_lengths');
    CS_results = rmfield(CS_results, 'FOV_medians');
    CS_results = rmfield(CS_results, 'FOV_sums');
    CS_results = rmfield(CS_results, 'FOV_angles');
    CS_results = rmfield(CS_results, 'FOV_thresholds');
    CS_results = rmfield(CS_results, 'FOV_grid_sizes');
    CS_results = rmfield(CS_results, 'ACTINFOV_angles');
    
    %Save the summary file 
    if exist(fullfile(zline_path{1}, summary_file_name),'file') == 2
        save(fullfile(zline_path{1}, summary_file_name), ...
            'CS_results', 'FOV_results','-append')
    else
        save(fullfile(zline_path{1}, summary_file_name), ...
            'CS_results','FOV_results')
    end 
    
elseif settings.cardio_type == 2 && settings.analysis
    %Save the struct as Single Cell instead of Coverslip
    SC_results = CS_results;
    
    %Save the summary file 
    if exist(fullfile(zline_path{1}, summary_file_name),'file') == 2
        save(fullfile(zline_path{1}, summary_file_name), ...
            'SC_results', '-append')
    else
        save(fullfile(zline_path{1}, summary_file_name), ...
            'SC_results')
    end 
    
end 

%% Add to excel file 
%Create summary excel file  
%Store the number and name of the condition
GridSize = CS_results.CS_gridsizes';  
ActinThreshold = CS_results.CS_thresholds';    
MedianCZL = CS_results.CS_medians';   
TotalCZL = CS_results.CS_sums';  
NonZlineFraction = CS_results.CS_nonzlinefrac';  
ZlineFraction = CS_results.CS_zlinefrac';  
OOPzline = CS_results.CS_OOPs';  
OOPactin = CS_results.ACTINCS_OOPs'; 
TotalZline = CS_results.angle_count'; 
TotalActin = CS_results.ACTINangle_count'; 

%Get the name of each coverslip
CoverslipName = cell(size(TotalActin)); 
for k = 1:length(TotalActin)
    CoverslipName{k,1} = name_CS; 
end

%Save the data analyzed
DateAnalyzed_YYYYMMDD = cell(size(TotalActin)); 
%Get today's date
date_format = 'yyyymmdd';
today_date = datestr(now,date_format);
for k = 1:length(TotalActin)
    DateAnalyzed_YYYYMMDD{k,1} =today_date; 
end 

% CoverslipName = MultiCS_Data.name_CS;  
T = table(DateAnalyzed_YYYYMMDD,OOPzline,OOPactin,...
    ZlineFraction,NonZlineFraction,TotalZline, ...
    TotalActin, MedianCZL,...
    TotalCZL,GridSize,ActinThreshold); 

%%
%Write the sheet
filename = 'NRVM_Tissues_MultiCond_Summary_20190301.xlsx';
save_path = 'D:\NRVM_Tissues';
writetable(T,fullfile(save_path,filename),...
    'Sheet',1,'Range','A1'); 


