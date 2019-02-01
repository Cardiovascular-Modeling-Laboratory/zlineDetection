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

function [ output_struct ] = ...
    runDirectory( settings, zline_path, zline_images,...
    actin_path, actin_images, name_CS )
%This function will take file names as an input and then loop through them,
%calling the analyze function

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
        
        %If the user is only doing an actin threshold exploration, but no
        %grid exploration 
        if settings.actinthresh_explore && ~settings.grid_explore
            %Loop through the range and save the skeleton, continuous 
            %z-line length and the non sarc amount. 
            exploreFilterWithActin( im_struct, settings, actin_explore);
        end 
        
        %If the user is exploring both the grid sizes and the actin
        %threshold,
        if settings.actinthresh_explore && settings.grid_explore
            %Loop through the range and save the skeleton, continuous 
            %z-line length and the non sarc amount. 
            exploreGrids(im_struct, settings, actin_explore);
        end 
        
        %If the user only wants to perform a grid exploration, but no actin
        %threshold exploration
        if ~settings.actinthresh_explore && settings.grid_explore
            %This may not be fully functional -- need to double check to
            %see if it works.
             exploreGrids(im_struct, settings, actin_explore);
        end 
    end 
    
    
    % If the user wants to calculate continuous z-line length 
    if settings.tf_CZL && ~exploration
        
        %Initialize variables 
        if k == 1
            %Create a cell to store all of the CZL data 
            all_lengths = cell(1,zn); 
            all_medians = zeros(1,zn); 
            all_sums = zeros(1,zn);  
        end 
        
        %Close all other figures so there isn't a chance of plotting
        %over anything
        close all; 
        
        %Calculate the continuous z-line length 
        all_lengths{1,k} = continuous_zline_detection(im_struct, settings); 
        
        %Compute the median
        all_medians(1,k) = median( all_lengths{1,k} ); 
        
        %Compute the sum 
        all_sums(1,k) = sum(all_lengths{1,k}); 
        
        %Create a histogram of the distances
        figure; histogram(all_lengths{1,k});
        set(gca,'fontsize',16)
        hist_name = strcat('Median: ', num2str(all_medians(1,k)),' \mu m');
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
    if settings.tf_OOP && ~exploration
        %Initialize variables 
        if k == 1
            %Create a cell to store all of the CZL data 
            angles = cell(1,zn);  
            %Create a vector  to store all of the OOPs
            oops = zeros(1,zn); 
            %Create a cell to store all of the direction angles 
            directors = zeros(1,zn); 
        end 
        
        %Save this orientation matrix 
        angles{1,k} = im_struct.orientim;
        
        %Save the orientation vectors as a new vairable
        temp_angles = angles{1,k}; 
        
        %If there are any NaN values in the angles matrix, set them to 0.
        temp_angles(isnan(temp_angles)) = 0;
        %Create a structural array to store the OOP information 
        oop_struct = struct();
        %Calculate the OOP, director vector and director angle 
        [ oop_struct.OOP, oop_struct.directorAngle, ~, ...
            oop_struct.director ] = calculate_OOP( temp_angles ); 
        %Store the OOP and director 
        oops(1,zn) = oop_struct.OOP; 
        %Create a cell to store all of the direction angles 
        directors(1,zn) = oop_struct.directorAngle; 
            
        
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
output_struct = struct(); 

%>>> Summarize parameter exploration for an entire coverslip, otherwise 
%   create a summary filename 
    if settings.exploration && settings.cardio_type == 1
        %This function will combine and plot all results 
        [output_struct.CS_actinexplore] = ...
                combineFOV( settings, zline_images, zline_path ); 
        %Close all 
        close all; 
    else 
        %Get today's date in string form.
        date_format = 'yyyymmdd';
        today_date = datestr(now,date_format);
        
        %Declare the type of summary file 
        tp = {'CS', 'SC'}; 
        
        %Name of the summary file 
        summary_file_name = strcat('SC', tp{settings.cardio_type},...
            '_Summary',today_date,'.mat');
    end 

%>>> Summarize Continuous Z-line Length if there was not an exploration 
if ~settings.exploration && settings.tf_CZL
    %Create coverslip continuous z-line struct
    CS_CZL = struct(); 
            
    %Save the path and image names 
    CS_CZL.zline_images = zline_images;
    CS_CZL.zline_path = zline_path; 
            
    %Save the data
    CS_CZL.FOV_lengths = all_lengths;
    CS_CZL.FOV_medians = all_medians;
    CS_CZL.FOV_sums = all_sums; 
    
    %Compute the mean and standard deviation of the medians 
    CS_CZL.mean_median = mean(CS_CZL.FOV_medians); 
    CS_CZL.std_median = std(CS_CZL.FOV_medians);
    %Compute the mean and standard deviation of the sums
    CS_CZL.mean_sums= mean(CS_CZL.FOV_sums); 
    CS_CZL.std_sums = std(CS_CZL.FOV_sums);
    
    if settings.cardio_type == 1
        %Concatenate the lengths matrix 
        CS_CZL.CS_lengths = concatCells( CS_CZL.FOV_lengths,false ); 
            
        %Compute the median 
        CS_CZL.CS_median = median(CS_CZL.CS_lengths); 
            
        %Compute the sum 
        CS_CZL.CS_sum = sum(CS_CZL.CS_lengths); 
    end 
    
    %Save as an output 
    output_struct.CS_CZL = CS_CZL; 
    
    %Save the summary file 
    if exist(fullfile(zline_path{1}, summary_file_name),'file') == 2
        save(fullfile(zline_path{1}, summary_file_name), ...
            'CS_CZL', '-append')
    else
        save(fullfile(zline_path{1}, summary_file_name), ...
            'CS_CZL')
    end 

end 

%>>> Summarize OOP if there was not an exploration 
if ~settings.exploration && settings.tf_OOP
    %Create coverslip continuous z-line struct
    CS_OOP = struct(); 
            
    %Save the path and image names 
    CS_OOP.zline_images = zline_images;
    CS_OOP.zline_path = zline_path; 
     
    if settings.cardio_type == 1
        %Save the angles 
        CS_OOP.FOVangles = angles; 

        %Concatenate the lengths matrix 
        CS_OOP.CS_angles = concatCells( CS_OOP.FOVangles,true ); 

        %Remove all NaN Values
        temp = CS_OOP.CS_angles; 
        temp(isnan(temp)) = []; 
        CS_OOP.CS_angles = temp; 

        %Calculate the OOP 
        [ CS_OOP.OOP, CS_OOP.directorAngle, ~, ...
        CS_OOP.director ] = calculate_OOP( CS_OOP.CS_angles  ); 
    else 
        %Store the OOP and director 
        CS_OOP.SC_oops = oops; 
        %Create a cell to store all of the direction angles 
        CS_OOP.SC_directors=directors; 
    end 
    
    %Save the data
    if exist(fullfile(zline_path{1}, summary_file_name),'file') == 2
        save(fullfile(zline_path{1}, summary_file_name), ...
            'CS_OOP', '-append')
    else
        save(fullfile(zline_path{1}, summary_file_name), ...
            'CS_OOP')
    end

    %Save as an output
    output_struct.CS_OOP = CS_OOP; 
end 
    
end