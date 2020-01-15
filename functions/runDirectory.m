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

%%%%%%%%%% Initialize & Preallocate Cells / Matrices  %%%%%%%%%%%%%%%%%%%%%
% Get the number of z-line images 
zn = length(zline_images); 

%>>> Actin Segmentation
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
%>>> Sarcomere Distances 
FOV_sarcdistance = cell(1,zn);

% Get today's date in string form.
date_format = 'yyyymmdd';
today_date = datestr(now,date_format);

%>> Create a directory to save summaries (single cells only)
if settings.cardio_type == 2
    % Save in a new directory 
    SCsubfolder_name = strcat('SingleCell_RESULTS_',today_date); 
    % Create the new directory 
    SCsubfolder_name = addDirectory( zline_path{1}, SCsubfolder_name, ...
        true ); 
    SC_summarypath = fullfile(zline_path{1}, SCsubfolder_name); 
end 


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
    %Store the current actin filename (if we're doing actin filtering
    if settings.actin_filt
        filenames.actin = fullfile(actin_path{1}, actin_images{1,k});
    else 
        filenames.actin = NaN; 
    end
    
%>>>> ANALYZE IMAGE - Diffusion parameter exploration 
    if settings.diffusion_explore
        diffusionExploreImage( filenames, settings ); 
    else 
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
                [ oop_struct.ACTINoop, oop_struct.ACTINdirectionAngle, ~, ...
                    oop_struct.ACTINdirector ] = calculate_OOP( temp_angles ); 

                %Save the values in the the FOV matrix 
                ACTINFOV_OOPs{1,k} = oop_struct.ACTINoop;
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
            FOV_lengths{1,k} = zlineCZL(im_struct, settings); 
            
            %Compute the median
            FOV_medians{1,k} = median( FOV_lengths{1,k} ); 

            % Compute the mean 
            FOV_means{1,k} = mean( FOV_lengths{1,k} ); 

            %Compute the sum 
            FOV_sums{1,k} = sum( FOV_lengths{1,k} ); 

            %Create a histogram of the distances
            figure; histogram(FOV_lengths{1,k});
            set(gca,'fontsize',16)
            hist_name = strcat('Median: ', num2str(FOV_medians{1,k}),' \mu m');
            title(hist_name,'FontSize',18,'FontWeight','bold');
            xlabel('Continuous Z-line Lengths (\mu m)','FontSize',18,...
                'FontWeight','bold');
            ylabel('Count','FontSize',18,'FontWeight','bold');

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
        else
            oop_struct = NaN; 
        end 

        % Close all figures
        close all; 
        
        %>>>> Sarcomere Distance
        if settings.tf_sarcdist && ~settings.exploration
            % Create a struct to store the sarcomere distances 
            sarcdist_struct = struct(); 
            % Get the perpendicular orientation vectors (sarcomere
            % orientation vectors) 
            orientim_perp = FOV_angles{1,k} + pi/2;
            % Set all NaN values to 0 
            orientim_perp(isnan(orientim_perp)) = 0; 
            % Calculate sarcomere distances 
            [sarclength_mean, sarclength_stdev, ...
                allsarclengths_microns, allnonzerosarclengths_microns, ...
                ~, x_0, y_0, x_np, y_np] = ...
                calculateSarcLength(orientim_perp, settings.pix2um); 
            % Store nonzero sarcomere lengths to be combined for the entire
            % tissue 
            FOV_sarcdistance{1,k} = allnonzerosarclengths_microns; 
            % Store the sarcomere length mean, standard deviation, and
            % lengths in the sarcdist_struct 
            sarcdist_struct.sarclength_mean = sarclength_mean; 
            sarcdist_struct.sarclength_stdev = sarclength_stdev; 
            sarcdist_struct.allsarclengths = allsarclengths_microns;
            sarcdist_struct.x_0 = x_0; 
            sarcdist_struct.y_0 = y_0; 
            sarcdist_struct.x_np = x_np; 
            sarcdist_struct.y_np = y_np; 
            %Append summary file with the sarcomere distance struct  
            save(fullfile(im_struct.save_path, strcat(im_struct.im_name,...
               '_OrientationAnalysis.mat')), 'sarcdist_struct', '-append');
           
           % Only plot the sarcomere distances if requested by the user. 
           if settings.disp_sarcdist 
           % Plot sarcomere length image
            plotSarcLengthIM(mat2gray(im_struct.im), x_0, y_0, x_np, ...
               y_np, allsarclengths_microns); 
            fig_name = strcat( im_struct.im_name, '_sarcdist');
            saveas(gcf, fullfile(im_struct.save_path, fig_name), 'tiffn');
           end 
            % Plot sarcomere length histogram
            figure; plotSLhist(allnonzerosarclengths_microns, ...
                sarclength_mean, sarclength_stdev)
            fig_name = strcat( im_struct.im_name, '_sarcdisthistogram');
            saveas(gcf, fullfile(im_struct.save_path, fig_name), 'tiffn');
        end 
        close all; 
        
        % If this is a single cell, create a summary pdf. 
        if settings.cardio_type == 2
            % Store the summary path 
            im_struct.summary_path = SC_summarypath;
            singleCellSummarypdf(im_struct, settings, oop_struct); 
        end 
    
    
    end 
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
if settings.cardio_type == 1 && settings.analysis && ~settings.diffusion_explore
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
    % Sarcomere Distance
    CS_results.FOV_sarcdistance = FOV_sarcdistance; 
    
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
    
    %Save the summary file 
    if exist(fullfile(zline_path{1}, summary_file_name),'file') == 2
        save(fullfile(zline_path{1}, summary_file_name), ...
            'CS_results','FOV_results','settings','-append')
    else
        save(fullfile(zline_path{1}, summary_file_name), ...
            'CS_results','FOV_results','settings')
    end 
    
elseif settings.cardio_type == 2 && settings.analysis && ~settings.diffusion_explore
    %Save the CS results as NaN (so there won't be an error) 
    CS_results = NaN; 
    
    %Save the struct for single cells 
    SC_results = struct(); 

    %>>> Files 
    SC_results.zline_path = zline_path;
    SC_results.zline_images = zline_images; 
    %>>> Actin Filtering analysis 
    SC_results.nonzlinefrac = FOV_nonzlinefrac;
    SC_results.zlinefrac = FOV_zlinefrac;
    SC_results.prefiltered = FOV_prefiltered;
    SC_results.postfiltered = FOV_postfiltered;
    %>>> Continuous z-line length
    SC_results.lengths = FOV_lengths;
    SC_results.medians = FOV_medians; 
    SC_results.means = FOV_means; 
    SC_results.sums = FOV_sums; 
    %>>> Z-line Angle analysis
    SC_results.angles = FOV_angles;  
    SC_results.OOPs = FOV_OOPs; 
    SC_results.directors = FOV_directors; 
    SC_results.angle_count = FOV_anglecount; 
    %>>> EXPLORATION Parameters
    SC_results.thresholds = FOV_thresholds; 
    SC_results.grid_sizes = FOV_grid_sizes; 
    %>>> Actin angle analysis
    SC_results.ACTIN_angles = ACTINFOV_angles;
    SC_results.ACTINOOPs = ACTINFOV_OOPs; 
    SC_results.ACTINdirectors = ACTINFOV_directors; 
    SC_results.ACTIN_anglecount = ACTINFOV_anglecount; 
    
    %Save the summary file 
    if exist(fullfile(SC_summarypath, summary_file_name),'file') == 2
        save(fullfile(SC_summarypath, summary_file_name), ...
            'SC_results', 'settings', '-append')
    else
        save(fullfile(SC_summarypath, summary_file_name), ...
            'SC_results', 'settings')
    end 
    
    % Store all of the important information about the single cells 
    ImageName = SC_results.zline_images';
    MedianCZL = SC_results.medians';
    MeanCZL = SC_results.means'; 
    TotalCZL = SC_results.sums';
    ZlineFraction = SC_results.zlinefrac';
    NonZlineFraction = SC_results.nonzlinefrac';
    DirectorZline = SC_results.directors';
    DirectorActin = SC_results.ACTINdirectors';
    OOPzline = SC_results.OOPs';
    OOPactin = SC_results.ACTINOOPs';
    TotalZline = SC_results.angle_count';
    TotalActin = SC_results.ACTIN_anglecount';
    ActinThreshold = SC_results.thresholds';
    GridSize = SC_results.grid_sizes';    
    
    % Save the current date in a cell 
    DateAnalyzed_YYYYMMDD = cell(size(ImageName));
    ImagePath = cell(size(ImageName));
    for k=1:length(ImagePath) 
        DateAnalyzed_YYYYMMDD{k,1} = today_date; 
        ImagePath{k,1} = SC_results.zline_path{1}; 
    end
    
    % Create a summary excel sheet
    T = table(ImagePath, ImageName, DateAnalyzed_YYYYMMDD, ...
        MedianCZL, MeanCZL, TotalCZL, ZlineFraction, NonZlineFraction, ...
        DirectorZline, DirectorActin, OOPzline, OOPactin, ...
        TotalZline, TotalActin, ActinThreshold, ...
        GridSize); 

    %Write the sheet to memory 
    filename = strrep(summary_file_name,'.mat','.xlsx'); 
    filename = appendFilename( SC_summarypath, filename ); 
    writetable(T,fullfile(SC_summarypath,filename),...
        'Sheet',1,'Range','A1');     
    
else
    %Save the CS results as NaN (so there won't be an error) 
    CS_results = NaN; 
    
end 
    
end