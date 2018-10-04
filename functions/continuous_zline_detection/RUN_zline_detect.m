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
[sarcDetect_files,sarcDetect_path]= uigetfile(fullfile(...
    image_path, '*sarcDetect.Settings.mat;*sarcOrientation.mat;*.mat'),...
    'Select the SarcDetect output...','MultiSelect','on');

%Ask the user for the threshold values. 
dot_product_error = input(['Please enter the dot product threshold'...
' (0.96-0.99) ']);

%Ask the user if this is a test
test_set = input('Are these test images? Yes = 1, No = 0:  ');

%Get the number of image files 
cell_image_files = cellstr(image_files); 
[~, number_of_images] = size(cell_image_files); 

%Get the number of SarcDetect output files 
cell_sarcDetect_files = cellstr(sarcDetect_files); 
[~, number_of_sarcDetect] = size(cell_sarcDetect_files); 

%Sort the cell names 
cell_sarcDetect_files = sort(cell_sarcDetect_files);
cell_image_files = sort(cell_image_files);

%Check to make sure the user selected the correct number of files. 
if number_of_sarcDetect ~= number_of_images
    %Right now it just displays a warning, but I would eventually like
    %the program to go back to the select files point and have the user
    %reselect (possibly use a while loop); 
    warning(['The number of sarcDetect files is not equal ',...
        'to the image files or you have only selected one file.', ...
        ' Please stop the program and try again.']); 
   
else 
    total_files = number_of_sarcDetect; 

    %Run images
    if test_set == 1
        %Loop through all of the image files
        for n = 1:total_files
            %Save string versions of the current file of interest
            current_sarcDetect_file = cell_sarcDetect_files{n}; 
            current_image_file = cell_image_files{n}; 

            %Load the sarcDetect output
            varargout = load(fullfile(sarcDetect_path, ...
                current_sarcDetect_file));

            %Save the sarcDetect Ouput 
            angles = varargout.orientim;
            pix2um = 6.22; 

            %Calculate the continuous z-line length 
            [ distances_um ] = continuous_zline_detection(angles, pix2um, ...
                image_path, current_image_file, dot_product_error, test_set); 

            %Close all of the images 
            close all; 

            %Create a histogram of the distances
            figure; histogram(distances_um(:));
            hist_name = strcat('Histogram: ', current_image_file(11:end-4));
            hist_name = strrep(hist_name,'_',' ');
            title(hist_name,'FontSize',12,'FontWeight','bold');
            xlabel('Continuous Z-line Lengths (\mu m)','FontSize',12,...
                'FontWeight','bold');
            ylabel('Frequency','FontSize',12,'FontWeight','bold');

            %Save histogram 
            saveas(gcf, fullfile(image_path, ...
                strcat('hist_',current_image_file)), 'tif');

            %Close histogram 
            close all; 
        end 
    else
        %Determine whether the files are .sarcOrientation.mat or
        %.sarcDetect.Settings.mat. If they are the former the orientation 
        %angles need to be converted (perpendicular and for the latter they do
        %not. 

        %The sarcOrientation.mat files will not have the pix2um conversion.
        %Initalize the variable here. 
        pix2um = []; 

        %Inialize all lengths vector just incase there is more than one file
        %type
        all_lengths = []; 

        %Start a timer
        tic 

        %Loop through all of the files and determine the file type  
        for k = 1:number_of_images

            %Save string versions of the current file of interest
            current_sarcDetect_file = cell_sarcDetect_files{k}; 
            current_image_file = cell_image_files{k}; 

            %Load the sarcDetect output
            varargout = load(fullfile(sarcDetect_path, ...
            current_sarcDetect_file));

            %Figure out the ending of the sarcDetect file 
            %*sarcDetect.Settings.mat or *sarcOrientation.mat'
            %If the sarcDetect output ends with .sarcOrientation.mat then it 
            %needs to convert orientim to orientimperp and also enter in the 
            %calibration factor (pix2um)
            matches = strfind(current_sarcDetect_file,...
                '.sarcDetect.Settings.mat');

            if isempty(matches) == true
                %Check to make sure the file names match by removing the 
                %'.sarcOrientation.mat' and comparing the two strings
                concat_image_name = strcat( current_image_file, ...
                '.sarcOrientation.mat' ); 
                string_comparison = strcmp( concat_image_name, ...
                   current_sarcDetect_file) ; 

                %Display a warning if the two names do not match. 
                if string_comparison == 0
                    warning(['The image name and the sarcDetect filename', ...
                        'do not match.']); 
                end 

                %Load in the perpendicular orientation angles and convert
                %them to be the original orientation angles 
                orientim_perp = varargout.orientim_perp;
                angles = orientimperp2orientim( orientim_perp ); 

                %If the pixel to micron conversion is empty (hasn't been 
                %declared yet) then have the user enter the value.
                %Otherwise, use the existing value. This assumes that all
                %fields of view will have the same pixel to micron
                %conversion. 
                if isempty(pix2um)
                    pix2um = input(['Enter calibration factor in ',...
                        'pixels per micrometer (Coolsnap 63x=9.8,',... 
                        '40x=6.22, 20x=3.085): ']);
                end 


            %If the files are sarcDetect files, then load the orientation 
            %angles and pixel to micron conversion (after checking if the 
            %filenames are the same   
            else 
                 %Check to make sure the file names match by removing the 
                %'.sarcDetect.Settings.mat' and comparing the two strings
                concat_image_name = strcat( current_image_file, ...
                '.sarcDetect.Settings.mat'); 
                string_comparison = strcmp( current_image_file, ...
                    current_sarcDetect_file);

                %Display a warning if the two names do not match. 
                if string_comparison == 0
                    warning(['The image name and the sarcDetect filename', ...
                        'do not match.']); 
                end 

                %Store the orientim angles 
                angles = varargout.orientim;

                %Store the pix2um measurement from the sarcDetect output. 
                pix2um = varargout.pix2um; 
            end

            %Calculate the continuous z-line length 
            [ distances_um ] = continuous_zline_detection(angles, pix2um, ...
                image_path, current_image_file, dot_product_error, test_set); 

            %If there is more than one FOV, make a summary file. 
            if number_of_images > 1 
                all_lengths = [all_lengths; distances_um];

                %Save the summary file if it's the last FOV
                if k == number_of_images 
                    % Run the statistics 
                    [ stat_summary ] = get_statistics( all_lengths );

                    %Get today's date in string form.
                    date_format = 'yyyy_mm_dd';
                    today_date = datestr(now,date_format);

                    %Create a summary file name 
                    summary_file_name = strcat(today_date, ...
                        'zline_summary.mat');

                    %Save the file name 
                    save(fullfile(image_path, summary_file_name), ...
                        'cell_image_files', 'cell_sarcDetect_files', ...
                        'all_lengths','stat_summary');
                end 
            end 

            %Display progress
            percentdone = (k*100)/number_of_images; 
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

end