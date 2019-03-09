% RUNDIRECTORY - A function to select images and then call functions to
% analyze them 
%
%
% Usage:
%  runDirectory( settings );
%
% Arguments:
%          settings         - structural array containing settings for 
%                               analysis 
% 
% Tessa Morris
% Advisor: Anna Grosberg
% Cardiovascular Modeling Laboratory 
% University of California, Irvine 

function [ CS_results ] = ...
    runDirectory( settings, zline_path, zline_images,...
    actin_path, actin_images, name_CS )
%This function will take file names as an input and then loop through them,
%calling the analyze function

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
FOV_anglecount = cell(1,zn); 
%>>> EXPLORATION
FOV_thresholds = cell(1,zn); 
FOV_grid_sizes = cell(1,zn); 

%>>>SAVE THE ACTIN VECTORS 
ACTINFOV_angles = cell(1,zn);  
ACTINFOV_OOPs = cell(1,zn); 
ACTINFOV_directors = cell(1,zn); 
ACTINFOV_anglecount = cell(1,zn); 

%%%%%%%%%%%%%%%%%%%%%% Loop through & Analyze Each FOV  %%%%%%%%%%%%%%%%%%%

%Begin a timer 
tic; 
% Loop through all of the image files 
for k = 1:zn 
    %Display information about the image 
    dispmsg = strcat('Analyzing Image ', {' '},num2str(k), ' of ', {' '}, ...
        num2str(zn));
    disp(dispmsg);
    toc
        
    % Create a struct of file names 
    filenames = struct; 
    
    % Store the current z-line filename 
    filenames.zline = fullfile(zline_path{1}, zline_images{1,k});

%>>>> ACTIN FILTERING, save filename 
    %Store hte current actin filename (if we're doing actin filtering
    if settings.actin_filt
        filenames.actin = fullfile(actin_path{1}, actin_images{1,k});
    else 
        filenames.actin = NaN; 
    end 
%>>>> ANALYZE IMAGE 
    % Perform the analysis including saving the image 
    im_struct = analyzeImage( filenames, settings ); 

%>>>> CALCULATE OOP 
    %Create an OOP struct if the user requested. 
    if settings.tf_OOP && ~settings.exploration 
        %Create OOP_struct to save data 
        oop_struct = struct(); 
    end 
    
%>>>> FILTER WITH ACTIN 
    %If the user is filtering with actin, save the actin orientation
    %vectors and calculate FOV if requested 
    if settings.actin_filt
        ACTINFOV_angles{1,k} = im_struct.actin_struct.actin_orientim;
        
        %Save the orientation vectors as a new vairable
        temp_angles = ACTINFOV_angles{1,k}; 
        
        %Remove any NaN values or zero values 
        temp_angles(isnan(temp_angles)) = [];
        temp_angles(temp_angles == 0) = []; 
        
        %Save length
        ACTINFOV_anglecount{1,k} = length(temp_angles); 
        
        if settings.tf_OOP && ~settings.exploration 

            %Calculate the OOP, director vector and director angle 
            [ ACTINoop, oop_struct.ACTINdirectionAngle, ~, ...
                oop_struct.ACTINdirector ] = calculate_OOP( temp_angles ); 

            %Save the values in the the FOV matrix 
            ACTINFOV_OOPs{1,k} = ACTINoop; 
            oop_struct.oop = ACTINoop; 
            ACTINFOV_directors{1,k} = oop_struct.ACTINdirectionAngle; 
        end 
    end 
    
%>>>> EXPLORE FILTER WITH ACTIN 
    % If the user wants to perform a parameter exploration for actin
    % filtering
    if settings.exploration
        %Store the struct containing the actin parameters
        actin_explore = settings.actin_explore; 
        
        %Loop through the range and save the skeleton, continuous 
        %z-line length and the non zline amount. 
        actin_explore = ...
            exploreFilterWithActin( im_struct, settings, actin_explore);
        
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

        %>>> EXPLORATION PARAMETERS
        FOV_thresholds{1,k} = actin_explore.thresholds;  
        FOV_grid_sizes{1,k} = actin_explore.grid_sizes; 
    else
        %>>> STORE ORIENTATION VECTORS
        FOV_angles{1,k} = im_struct.orientim; 
        
        % get number of nonzero orientation vectors 
        %Save the orientation vectors as a new vairable
        temp_angles = FOV_angles{1,k}; 
        
        %If there are any NaN values in the angles matrix, set them to 0.
        temp_angles(isnan(temp_angles)) = [];
        temp_angles(temp_angles == 0) = []; 
        
        %Get the number of nonzero orientation angles 
        FOV_anglecount{1,k} = length(temp_angles); 
        
        %>>> EXPLORATION PARAMETERS
        FOV_thresholds{1,k} = settings.actin_thresh; 
        FOV_grid_sizes{1,k} = settings.grid_size(1);
           
    end 
    
%>>>> FILTER WITH ACTIN     
    %If the user filtered with actin, save the non_zline fraction
    if settings.actin_filt && ~settings.exploration
        %Fraction for each FOV 
        FOV_nonzlinefrac{1,k} = im_struct.nonzlinefrac; 
        FOV_zlinefrac{1,k} = im_struct.zlinefrac; 
        
        %Get the post-filtered skeleton - used for CS calculation 
        temp_post = im_struct.skel_final;
        temp_post = temp_post(:);
        temp_post(temp_post == 0) = []; 
        
        %Get the pre filtering skeleton - used for CS calculation 
        temp_pre = im_struct.skel_trim; 
        temp_pre = temp_pre(:); 
        temp_pre(temp_pre == 0) = []; 
        
        %Store values for the CS calculation 
        FOV_prefiltered{1,k} = length(temp_pre); 
        FOV_postfiltered{1,k} = length(temp_post); 
    end 
    
%>>>> CONTINUOUS Z-LINE LENGTH 
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

%>>>> OOP 
    % If the user wants to calculate OOP. This is only useful when
    % the user is analyzing single cells 
    if settings.tf_OOP && ~settings.exploration 
        %Save the orientation vectors as a new vairable
        temp_angles = FOV_angles{1,k}; 
        
        %If there are any NaN values in the angles matrix, set them to 0.
        temp_angles(isnan(temp_angles)) = 0;
                
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

%%%%%%%%%%%%%%%%%% Summarize Results for Entire Coverslip %%%%%%%%%%%%%%%%%

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
    
    %Combine the FOV 
    CS_results = combineFOV( settings, CS_results ); 
    
    %Remove unnecessary fiels
    CS_results = rmfield(CS_results, 'FOV_Grouped');
%     CS_results = rmfield(CS_results, 'FOV_OOPs'); 
%     CS_results = rmfield(CS_results, 'FOV_directors'); 
    CS_results = rmfield(CS_results, 'FOVstats_medians');
    CS_results = rmfield(CS_results, 'FOVstats_sums');
    CS_results = rmfield(CS_results, 'FOVstats_nonzlinefrac');
    CS_results = rmfield(CS_results, 'FOVstats_zlinefrac');
%     CS_results = rmfield(CS_results,'FOVstats_OOPs'); 
%     CS_results = rmfield(CS_results,'ACTINFOVstats_OOPs'); 
    
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
    %ZLINE 
    FOV_results.FOV_angles = FOV_angles;
    FOV_results.FOV_OOPs = FOV_OOPs; 
    FOV_results.FOV_directors = FOV_directors;
    FOV_results.FOV_anglecount = FOV_anglecount; 
    FOV_results.FOV_thresholds = FOV_thresholds;
    FOV_results.FOV_grid_sizes = FOV_grid_sizes;
    FOV_results.ACTINFOV_angles = ACTINFOV_angles;
    FOV_results.ACTINFOV_OOPs = ACTINFOV_OOPs; 
    FOV_results.ACTINFOV_directors = ACTINFOV_directors; 
    FOV_results.ACTINFOV_anglecount = ACTINFOV_anglecount; 
    
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
            'CS_results','FOV_results','settings','-append')
    else
        save(fullfile(zline_path{1}, summary_file_name), ...
            'CS_results','FOV_results','settings')
    end 
    
elseif settings.cardio_type == 2 && settings.analysis
    %Save the CS results as NaN (so there won't be an error) 
    CS_results = NaN; 
    
    %Save the struct for single cells 
    SC_results = struct(); 

    %>>> Files 
    SC_results.zline_path = zline_path;
    SC_results.zline_images = zline_images; 
    %>>> ACTIN FILTERING: Non zline Fractions
    SC_results.nonzlinefrac = FOV_nonzlinefrac;
    SC_results.zlinefrac = FOV_zlinefrac;
    SC_results.prefiltered = FOV_prefiltered;
    SC_results.postfiltered = FOV_postfiltered;
    %>>> ACTIN FILTERING: Continuous z-line length
    SC_results.lengths = FOV_lengths;
    SC_results.medians = FOV_medians; 
    SC_results.sums = FOV_sums; 
    %>>> Z-LINE ANGLES / OOP 
    SC_results.angles = FOV_angles;  
    SC_results.OOPs = FOV_OOPs; 
    SC_results.directors = FOV_directors; 
    SC_results.angle_count = FOV_anglecount; 
    %>>> EXPLORATION
    SC_results.thresholds = FOV_thresholds; 
    SC_results.grid_sizes = FOV_grid_sizes; 
    %>>> ACTIN FILTERING: ACTIN ANGLES / OOP
    SC_results.ACTIN_angles = ACTINFOV_angles;
    SC_results.ACTINOOPs = ACTINFOV_OOPs; 
    SC_results.ACTINdirectors = ACTINFOV_directors; 
    SC_results.ACTIN_anglecount = ACTINFOV_anglecount; 
    
    %Save the summary file 
    if exist(fullfile(zline_path{1}, summary_file_name),'file') == 2
        save(fullfile(zline_path{1}, summary_file_name), ...
            'SC_results', 'settings', '-append')
    else
        save(fullfile(zline_path{1}, summary_file_name), ...
            'SC_results', 'settings')
    end 
else
    %Save the CS results as NaN (so there won't be an error) 
    CS_results = NaN; 
    
end 
    
end