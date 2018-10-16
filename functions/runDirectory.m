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

function [  ] = runDirectory( settings )
%This function will take file names as an input and then loop through them,
%calling the analyze function

% Prompt the user to select the images they would like to analyze. 
[ image_files, image_path, n ] = ...
    load_files( {'*.TIF';'*.tif';'*.*'} ); 

% Stop if the user hit the cancel button
if isequal(image_path, 0); return; end

% Loop through all of the image files 
for k = 1:n 
    % Store the current filename 
    filename = strcat(image_path{1}, image_files{1,k});
    
    % Perform the analysis including saving the image 
    im_struct = analyzeImage( filename, settings ); 
    
    % If the user wants to calculate continuous z-line length 
    if settings.tf_CZL 

        if k == 1
            %Create a cell to store all distances 
            all_lengths = cell(1,n); 
            all_medians = cell(1,n); 
            
            %If there is more than one image being analyzed, create a summary
            %file 
            if n > 1
                %Get today's date in string form.
                date_format = 'yyyy_mm_dd';
                today_date = datestr(now,date_format);

                %Create a summary file name 
                summary_file_name = strcat(today_date, ...
                    '_zline_summary.mat');

                %Save and create a summary file
                save(fullfile(image_path{1}, summary_file_name), ...
                    'cell_image_files', 'cell_analysis_files');
            end 
        end 
        
        %Calculate the continuous z-line length 
        all_lengths{1,k} = continuous_zline_detection(im_struct, settings); 
        
        %Compute the median
        all_medians{1,k} = median( all_lengths{1,n} ); 
        
        %Create a histogram of the distances
        figure; histogram(all_lengths{1,k});
        set(gca,'fontsize',16)
        hist_name = strcat('Median: ', num2str(all_medians{1,k}),' \mu m');
        title(hist_name,'FontSize',18,'FontWeight','bold');
        xlabel('Continuous Z-line Lengths (\mu m)','FontSize',18,...
            'FontWeight','bold');
        ylabel('Frequency','FontSize',18,'FontWeight','bold');
        
        %Save histogram as a tiff 
        fig_name = strcat( im_struct.im_name, '_CZLhistogram');
        saveas(gcf, fullfile(im_struct.save_path, fig_name), 'tiffn');
        
        %If there is more than one FOV, save a summary file
        if n > 1 
            %Append the summary file 
            save(fullfile(image_path{1}, summary_file_name), 'all_lengths', ...
                'all_medians','-append');
        end 
        
        %Close all of the images 
        close all; 
        
    end 

    % If the user wants to calculate OOP
    if settings.tf_OOP && k == 1
        disp('NOT YET IMPLEMENTED: OOP'); 
        %settings.cardio_type
    end 
    
    % Close all figures
    close all; 
    
    % Clear the file name 
    clear filename
   
end 

end