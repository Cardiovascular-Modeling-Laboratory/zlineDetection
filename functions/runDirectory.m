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
[ zline_images, zline_path, zn ] = ...
    load_files( {'*w1mCherry*.TIF';'*w1mCherry*.tif';'*.*'}, ...
    'Select images stained for z-lines...'); 

% Stop if the user hit the cancel button
if isequal(zline_path, 0); 
    disp('No z-line files selected. Press "Run Folder" to try again.'); 
    return; 
end


% If the user would like to filter with actin, have them select the actin
% images 
if settings.actin_filt
    [ actin_images, actin_path, an ] = ...
        load_files( {'*GFP*.TIF';'*GFP*.tif';'*.*'}, ...
        'Select images stained for actin...');
    
    % Make sure that the actin files were selected.
    if isequal(actin_path, 0); 
        disp('No actin files selected. Press "Run Folder" to try again.'); 
        return; 
    end
    
    % If the number of actin and z-line files are not equal, have the user
    % try again. 
    if an ~= zn
        disp('The number of z-line files does not equal the number of actin files.'); 
        disp(strcat('Actin Images: ', num2str(an), ...
            'Z-line Images: ', num2str(zn))); 
        disp('Press "Run Folder" to try again.'); 
        return; 
    end
    
    % Sort the z-line and actin files. Ideally this means that they'll be
    % called in the correct order. 
    zline_images = sort(zline_images); 
    actin_images = sort(actin_images); 
else
    actin_images = NaN; 
    actin_path = NaN; 
    an = NaN; 
end 


% Loop through all of the image files 
for k = 1:zn 
    % Create a struct of file names 
    filenames = struct; 
    
    % Store the current z-line filename 
    filenames.zline = fullfile(zline_path{1}, zline_images{1,k});
    
    % Store the current actin filename if applicable 
    if settings.actin_filt
        filenames.actin = fullfile(actin_path{1}, actin_images{1,k});
        
        % On the first iteration, if this is a parameter exploration,
        % prompt the user for the range
        if settings.actin_thresh > 1 && k == 1
            
            %Prompt Questions
            thresh_prompt = {'Minimum Threshold:','Max Threshold:',...
                'Step Size:'};
            %Title of prompt
            thresh_title = 'Actin Filtering Parameter Exploration';
            %Dimensions
            thresh_dims = [1 35];
            %Default inputs
            thresh_definput = {'0.05','1','0.05'};
            %Save answers
            thresh_answer = inputdlg(thresh_prompt,thresh_title,...
                thresh_dims,thresh_definput);
            
            %Ask if they'd also like to do grid size exploration. 
            grid_q = questdlg(...
                'Would you also like to do a grid size exploration?',...
                'Yes', 'No'); 
            if strcmp(grid_q, 'Yes')
                grid_prompt = {'Smallest Grid:','Largest Grid:',...
                'Step Size:'};
                grid_title = 'Grid Size Exploration';
                grid_dims = [1,35];
                grid_definput = {'10', '30','10'}; 
                grid_answer = inputdlg(grid_prompt,grid_title,...
                grid_dims,grid_definput);
                
                %Create a new setting 
                settings.grid_explore = true; 
            else
                settings.grid_explore = false; 
            end
        elseif k==1 && sum(settings.grid_size) == 0
                grid_prompt = {'Smallest Grid:','Largest Grid:',...
                'Step Size:'};
                grid_title = 'Grid Size Exploration';
                grid_dims = [1,35];
                grid_definput = {'10', '30','10'}; 
                grid_answer = inputdlg(grid_prompt,grid_title,...
                grid_dims,grid_definput);
                
                %Create a new setting 
                settings.grid_explore = true; 
            else
                settings.grid_explore = false; 
                
        end 
    else
        filenames.actin = NaN; 
        settings.grid_explore = false; 
    end 
    
    % Perform the analysis including saving the image 
    im_struct = analyzeImage( filenames, settings ); 
    
    
    % If the user wants to perform a parameter exploration for actin
    % filtering
    if settings.actin_thresh > 1 || settings.grid_explore
        %Create a struct to hold all of the relevant information for the
        %actin parameter exploration
        actin_explore = struct(); 
        
        if settings.actin_thresh > 1
            %Store the answers to the exploration prompt for the rang eof
            %threshold values 
            actin_explore.min_thresh = str2double(thresh_answer{1});
            actin_explore.max_thresh = str2double(thresh_answer{2});
            actin_explore.thresh_step = str2double(thresh_answer{3});

            %Check to make sure that the values are in range 
            actin_explore.min_thresh(actin_explore.min_thresh<0) = 0; 
            actin_explore.max_thresh(actin_explore.min_thresh>1) = 1; 
            actin_explore.thresh_step(actin_explore.thresh_step <= 0 || ...
                actin_explore.thresh_step >= 1) = 0.05;
            
            %If the user just wants to explore the actin threshold, but not
            %do a grid exploration 
            if ~settings.grid_explore 
                %Loop through the range and save the skeleton, continuous 
                %z-line length and the non sarc amount. 
                exploreFilterWithActin( im_struct, settings, actin_explore);
            else 
                %Store grid sizes 
                actin_explore.grid_min = str2double(grid_answer{1});
                actin_explore.grid_max = str2double(grid_answer{2});
                actin_explore.grid_step = str2double(grid_answer{3});
                
                %Look at the different grids. 
                exploreGrids(im_struct, settings, actin_explore);
            end 
        else
            disp('To be implemented...'); 
            disp('Just do a grid exploration with a set actin threshold.');
            %Store grid sizes 
            actin_explore.grid_min = str2double(grid_answer{1});
            actin_explore.grid_max = str2double(grid_answer{2});
            actin_explore.grid_step = str2double(grid_answer{3});
            %Look at the different grids. 
            exploreGrids(im_struct, settings, actin_explore);
        end 
    end 
    
    
    % If the user wants to calculate continuous z-line length 
    if settings.tf_CZL && settings.actin_thresh <=1 

        if k == 1
            %Create a cell to store all distances 
            all_lengths = cell(1,zn); 
            all_medians = cell(1,zn); 
            
            %If there is more than one image being analyzed, create a summary
            %file 
            if zn > 1
                %Get today's date in string form.
                date_format = 'yyyy_mm_dd';
                today_date = datestr(now,date_format);

                %Create a summary file name 
                summary_file_name = strcat(today_date, ...
                    '_zline_summary.mat');

                %Save and create a summary file
                save(fullfile(zline_path{1}, summary_file_name), ...
                    'all_lengths', 'all_medians', 'image_files');
            end 
        end 
        
        %Calculate the continuous z-line length 
        all_lengths{1,k} = continuous_zline_detection(im_struct, settings); 
        
        %Compute the median
        all_medians{1,k} = median( all_lengths{1,k} ); 
        
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
        if zn > 1 
            %Append the summary file 
            save(fullfile(zline_path{1}, summary_file_name), 'all_lengths', ...
                'all_medians','-append');
        end 
        
        %Close all of the images 
        close all; 
        
    end 

    % If the user wants to calculate OOP - Will need to change when I'm
    % analyzing tissues. 
    if settings.tf_OOP && settings.actin_thresh <=1 
        %Save the orientation vectors as a new vairable
        angles = im_struct.orientim; 
        %If there are any NaN values in the angles matrix, set them to 0.
        angles(isnan(angles)) = 0;
        %Create a structural array to store the OOP information 
        oop_struct = struct();
        %Calculate the OOP 
        [ oop_struct.OOP, oop_struct.directorAngle, ~ ] = ...
            calculate_OOP( angles ); 
        %Append summary file with OOP 
        save(fullfile(im_struct.save_path, strcat(im_struct.im_name,...
           '_OrientationAnalysis.mat')), 'oop_struct', '-append');
    end 
    
    % Close all figures
    close all; 
    
    % Clear the file name 
    clear filename
   
end 

end