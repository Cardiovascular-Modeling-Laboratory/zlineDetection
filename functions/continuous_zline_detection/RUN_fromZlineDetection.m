clear;
close all; 
%This is the script that the user should run. 
%This script will allow the user to eitehr select multiple fields of view 
%or just one and run the continuous z-line detection 

%Turn off warning for the image is too big to fit on screen, display at 67%
msgID = 'images:initSize:adjustingMag'; 
warning('off', msgID)
unanswered = true; 

%Select all the images to analyze. 
disp('Select the original sarcomere images.');
[image_files,image_path]= uigetfile({'*.TIF';'*.tif';'*.*'},...
    'Select Image File...','MultiSelect','on');

%Select the corresponding output from SarcDetect.
disp('Select the corresponding outputs from SarcDetect');
[analysis_files,analysis_path]= uigetfile(fullfile(...
    image_path, '*sarcDetect.Settings.mat;*sarcOrientation.mat;*.mat'),...
    'Select the SarcDetect output...','MultiSelect','on');

%Ask the user for the threshold values. 
dot_product_error = input(['Please enter the dot product threshold'...
' (0.96-0.99) ']);

%Get the number of image files 
cell_image_files = cellstr(image_files); 
[~, number_of_images] = size(cell_image_files); 

%Get the number of SarcDetect output files 
cell_analysis_files = cellstr(analysis_files); 
[~, number_of_analysis] = size(cell_analysis_files); 

%Sort the cell names 
cell_analysis_files = sort(cell_analysis_files);
cell_image_files = sort(cell_image_files);

%Check to make sure the user selected the correct number of files. 
if number_of_analysis ~= number_of_images
    %Right now it just displays a warning, but I would eventually like
    %the program to go back to the select files point and have the user
    %reselect (possibly use a while loop); 
    warning(['The number of analysis files is not equal ',...
        'to the image files or you have only selected one file.', ...
        ' Please stop the program and try again.']); 
   
else
    %Save the number of files
    total_files = number_of_analysis;
    
    %If there is more than one FOV, make a summary file. 
    if number_of_images > 1 
        %Get today's date in string form.
        date_format = 'yyyy_mm_dd';
        today_date = datestr(now,date_format);

        %Create a summary file name 
        summary_file_name = strcat(today_date, ...
            '_zline_summary.mat');

        %Save and create a summary file
        save(fullfile(image_path, summary_file_name), ...
            'cell_image_files', 'cell_analysis_files');
        
        %Create a cell to store all distances 
        all_lengths = cell(1,total_files); 
        all_medians = cell(1,total_files); 
    end 

    %Start the timer. 
    tic; 
    
    %Loop through all of the image files
    for n = 1:total_files
        %Save string versions of the current file of interest
        currentAnalysisFile = cell_analysis_files{n}; 
        current_image_file = cell_image_files{n}; 

        %Load the analysis output
        varargout = load(fullfile(analysis_path, ...
            currentAnalysisFile));
        
        %Load the image struct and settings
        im_struct = varargout.im_struct;
        settings = varargout.settings;
        
        %>>>>>>Correct mistake with orientation vectors
        im_struct.orientim(~im_struct.skel_final) = NaN; 
        save(fullfile(analysis_path, currentAnalysisFile), 'im_struct', ...
            '-append');
        
        %Save the orientation vectors and pixel to micron conversion
        angles = im_struct.orientim;
        pix2um = settings.pix2um; 
        
        %Set the NaNs to zeros
        angles(isnan(angles)) = 0;
        
        %Calculate the continuous z-line length 
        [ all_lengths{1,n} ] = continuous_zline_detection(angles, ...
            pix2um, image_path, current_image_file, dot_product_error, ...
            false); 
        
        %Compute the median
        all_medians{1,n} = median( all_lengths{1,n} ); 
        
        
        %If there is more than one FOV, save a summary file
        if number_of_images > 1 
            %Append the summary file 
            save(fullfile(image_path, summary_file_name), 'all_lengths', ...
                'all_medians','-append');
        end 
        
        %Close all of the images 
        close all; 

        %Display progress
        percentdone = (n*100)/number_of_images; 
        time_min = toc / 60; 

        disp(['Finished with FOV: ', current_image_file(1:end-4)]);
        disp(['The program is ', num2str(percentdone), '% done.'...
            ' Time Elapsed: ', num2str(time_min), ' minutes.']); 

        %Close figures
        close all 

        %Clear variables
        clear varargout angles matches
    end 

end