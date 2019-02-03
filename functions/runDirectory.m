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

%>>> ACTIN FILTERING: Non Sarc Fractions (NO EXPLORATION) 
FOV_nonsarc = cell(1,zn);
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
    
    %Store hte current actin filename (if we're doing actin filtering
    if settings.actin_filt
        filenames.actin = fullfile(actin_path{1}, actin_images{1,k});
    else 
        filenames.actin = NaN; 
    end 
    
    % Perform the analysis including saving the image 
    im_struct = analyzeImage( filenames, settings ); 
    
    % If the user wants to perform a parameter exploration for actin
    % filtering
    if settings.exploration
        %Store the struct containing the actin parameters
        actin_explore = settings.actin_explore; 
        
        %Loop through the range and save the skeleton, continuous 
        %z-line length and the non sarc amount. 
        actin_explore = ...
            exploreFilterWithActin( im_struct, settings, actin_explore);
        
        %Store Non Sarc Fraction Values 
        FOV_nonsarc{1,k} = actin_explore.non_sarcs; 
        FOV_prefiltered{1,k} = actin_explore.pre_filt; 
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
        FOV_grid_sizes{1,k} = settings.grid_size(1);  d
        
    end 
    
    %If the user wants to filter with actin, save the non_sarc fraction
    if settings.actin_filt && ~settings.exploration
        %Fraction for each FOV 
        FOV_nonsarc{1,k} = im_struct.non_sarc; 
        
        %Get the post-filtered skeleton - used for CS calculation 
        temp_post = im_struct.skel_final;
        temp_post = temp_post(:);
        temp_post(temp_post == 0) = []; 
        
        %Get the pre filtering skeleton - used for CS calculation 
        temp_pre = im_struct.skelTrim; 
        temp_pre = temp_pre(:); 
        temp_pre(temp_pre == 0) = []; 
        
        %Store values for the CS calculation 
        FOV_prefiltered{1,k} = temp_pre; 
        FOV_postfiltered{1,k} = temp_post; 
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
        FOV_sums{1,k} = sum(FOV_lengths{1,k}); 
        
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
        [ oop_struct.oop, oop_struct.directionAngle, ~, ...
            oop_struct.director ] = calculate_OOP( temp_angles ); 

        %Save the values in the the FOV matrix 
        FOV_OOPs{1,k} = oop_struct.oop; 
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

%Create a struct for the outputs 
CS_results = struct(); 

%>>> Files 
CS_results.zline_path = zline_path;
CS_results.zline_images = zline_images; 

%>>> ACTIN FILTERING: Non Sarc Fractions
CS_results.FOV_nonsarc = FOV_nonsarc;
CS_results.FOV_prefiltered = FOV_prefiltered;
CS_results.FOV_postfiltered = FOV_postfiltered;
%>>> ACTIN FILTERING: Continuous z-line length
CS_results.FOV_lengths = FOV_lengths;
CS_results.FOV_medians = FOV_medians; 
CS_results.FOV_sums = FOV_sums; 
%>>> ACTIN FILTERING: OOP 
CS_results.FOV_angles = FOV_angles;  
CS_results.FOV_OOPs = FOV_angles; 
CS_results.FOV_directors = FOV_directors; 
%>>> EXPLORATION
CS_results.FOV_thresholds = FOV_thresholds; 
CS_results.FOV_grid_sizes = FOV_grid_sizes; 


%Combine the FOV and save plots and .mat file  
%If this is a tissue combine the FOV, otherwise save
if settings.cardio_type == 1
    %Combine the FOV 
    CS_results = combineFOV( settings, CS_results ); 
    %Save the combined FOV 
else
    SC_results = CS_results;
    %Save the FOV results 
end 
        
% %>>> Summarize actin parameter exploration for an entire coverslip. 
% %    Otherwise create a summary filename 
% 
% if settings.exploration && settings.cardio_type == 1 && zn>1 
%     %This function will combine and plot all results. This involves
%     %re-loading all of the data. 
%     [output_struct.CS_actinexplore] = ...
%             combineFOV( settings, zline_images, zline_path ); 
%         
%     %Close all 
%     close all; 
% elseif zn>1 
%     %Get today's date in string form.
%     date_format = 'yyyymmdd';
%     today_date = datestr(now,date_format);
% 
%     %Declare the type of summary file 
%     tp = {'CS', 'SC'}; 
% 
%     %Name of the summary file 
%     summary_file_name = strcat(name_CS, tp{settings.cardio_type},...
%         '_Summary',today_date,'.mat');
% end 
% 
% %>>> Summarize Continuous Z-line Length if there was not an exploration 
% if ~settings.exploration && settings.tf_CZL && zn>1 
%     %Create coverslip continuous z-line struct
%     CS_CZL = struct(); 
%             
%     %Save the path and image names 
%     CS_CZL.zline_images = zline_images;
%     CS_CZL.zline_path = zline_path; 
%             
%     %Save the data
%     CS_CZL.FOV_lengths = all_lengths;
%     CS_CZL.FOV_medians = all_medians;
%     CS_CZL.FOV_sums = all_sums; 
%     
%     %Compute the mean and standard deviation of the medians 
%     CS_CZL.mean_median = mean(CS_CZL.FOV_medians); 
%     CS_CZL.std_median = std(CS_CZL.FOV_medians);
%     %Compute the mean and standard deviation of the sums
%     CS_CZL.mean_sums= mean(CS_CZL.FOV_sums); 
%     CS_CZL.std_sums = std(CS_CZL.FOV_sums);
%     
%     if settings.cardio_type == 1
%         %Concatenate the lengths matrix 
%         CS_CZL.CS_lengths = concatCells( CS_CZL.FOV_lengths,false ); 
%             
%         %Compute the median 
%         CS_CZL.CS_median = median(CS_CZL.CS_lengths); 
%             
%         %Compute the sum 
%         CS_CZL.CS_sum = sum(CS_CZL.CS_lengths); 
%     end 
%     
%     %Save as an output 
%     output_struct.CS_CZL = CS_CZL; 
%     
%     %Save the summary file 
%     if exist(fullfile(zline_path{1}, summary_file_name),'file') == 2
%         save(fullfile(zline_path{1}, summary_file_name), ...
%             'CS_CZL', '-append')
%     else
%         save(fullfile(zline_path{1}, summary_file_name), ...
%             'CS_CZL')
%     end 
% 
% end 
% 
% %>>> Summarize OOP if there was not an exploration 
% if ~settings.exploration && settings.tf_OOP && zn>1
%     %Create coverslip continuous z-line struct
%     CS_OOP = struct(); 
%             
%     %Save the path and image names 
%     CS_OOP.zline_images = zline_images;
%     CS_OOP.zline_path = zline_path; 
%      
%     if settings.cardio_type == 1
%         %Save the angles 
%         CS_OOP.FOVangles = angles; 
% 
%         %Concatenate the lengths matrix 
%         CS_OOP.CS_angles = concatCells( CS_OOP.FOVangles,true ); 
% 
%         %Remove all NaN Values
%         temp = CS_OOP.CS_angles; 
%         temp(isnan(temp)) = []; 
%         CS_OOP.CS_angles = temp; 
% 
%         %Calculate the OOP 
%         [ CS_OOP.OOP, CS_OOP.directorAngle, ~, ...
%         CS_OOP.director ] = calculate_OOP( CS_OOP.CS_angles  ); 
%     else 
%         %Store the OOP and director 
%         CS_OOP.CS_oops = oops; 
%         %Create a cell to store all of the direction angles 
%         CS_OOP.CS_directors=directors; 
%     end 
%     
%     %Save the data
%     if exist(fullfile(zline_path{1}, summary_file_name),'file') == 2
%         save(fullfile(zline_path{1}, summary_file_name), ...
%             'CS_OOP', '-append')
%     else
%         save(fullfile(zline_path{1}, summary_file_name), ...
%             'CS_OOP')
%     end
% 
%     %Save as an output
%     output_struct.CS_OOP = CS_OOP; 
% end 
    
end