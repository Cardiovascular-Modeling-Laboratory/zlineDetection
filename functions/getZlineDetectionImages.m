% initializeZlineDetectionInput - Asks the use to select z-line images,
% actin images, and declare conditions to use with z-line detection 
%
% Usage:
%  [zline_images, zline_path, name_CS,...
%         actin_images, actin_path, cond] ...
%         = getZlineDetectionImages(settings); 
% 
% Arguments:
%   settings        - Contains settings for z-line detection 
%                       Class Support: STRUCT 
%   txt_exclude     - Optional argument of text to exclude from filenames
%                       when comparing 
%                       Class Support: Cell (of strings)
% Returns:
%   zline_images    - Cell to hold z-line image name(s)
%                       Class Support: Cell 
%   zline_path      - Cell to hold z-line path name(s)
%                       Class Support: Cell 
%   name_CS         - Cell to hold the coverslip name(s) 
%                       Class Support: Cell 
%   actin_images    - Cell to hold actin image name(s)
%                       Class Support: Cell 
%   actin_path      - Cell to hold actin path name(s)
%                       Class Support: Cell 
%   cond            - Condition numbers
%                       Class Support: settings.num_cs x 1 vector  
%
% 
% Dependencies: 
%   MATLAB Version >= 9.5 
%
%
% Tessa Morris
% Advisor: Anna Grosberg
% Cardiovascular Modeling Laboratory 
% University of California, Irvine 

function [zline_images, zline_path, name_CS,...
        actin_images, actin_path, cond] ...
        = getZlineDetectionImages(settings, txt_exclude)
%This function will be used to run multiple coverslips and obtain a summary
%file

if nargin ==1 
    %Possible stains/wells that could included in filenames and should be
    %excluded in concatination of filenames
    string1 = {'w1','w2','w3','w4','w5'};
    string2 = {'Cy7','mCherry','GFP','DAPI'};
    txt_exclude = combineStrings(string1,string2);
end 
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
if settings.num_cs > 1 
    previous_path = settings.SUMMARY_path; 
else 
    previous_path = pwd; 
end 

% Close anything tha tis open 
close all; 

%Start counting variable
k = 1; 

while k < settings.num_cs + 1 

    %Boolean statement to keep going unless there is an issue
    keepGoing = true; 
    
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
    %Save the name of the directory
    if(strcmp(pathparts{1,potential_end},'RenamedTifsForZlineDetect') || strcmp(pathparts{1,potential_end},'RenamedTifs')) %If there was a directory made by the ImageJ macro to post-process MERLIN images, step back in a directory
        name_CS{k,1} = pathparts{1,potential_end-1};
    else
        name_CS{k,1} = pathparts{1,potential_end};
    end
    
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
            disp(strcat('Actin Images: ',{' '}, num2str(an(k,1)), ...
                'Z-line Images: ',{' '}, num2str(zn(k,1)))); 
            %Set keepGoing equal to false so they keep selecting. 
            keepGoing = false; 
        else 
            % If there is more than one FOV, then sort the images 
            if an(k,1) > 1 
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
            declareCondition(settings.cond_names, k, settings.num_cs,...
            name_CS{k,1}); 
        
        %Display the condition the user selected 
        disp_message = strcat('For Coverslip:',{' '},name_CS{k,1},...
            ', Condition Selected:',{' '}, ...
            settings.cond_names{cond(k,1),1}); 
        disp(disp_message{1}); 
    end 
    
    % Check to make sure that the user does not want to reselect this
    % coverslip 
    acceptCoverslip = questdlg('Would you like to accept the selection and keep going?', ...
        'Accept Input','Yes','No','Yes');
    %Re select this coverslip
    if strcmp('No',acceptCoverslip)
        %Set keepGoing equal to false so they keep selecting. 
        keepGoing = false; 
    end
    
    % Only increase the counter if there were no issues with the data
    % selection
    if keepGoing 
        k = k + 1; 
    else
        disp('Fix any errors and reselect coverslip.'); 
    end
end
end