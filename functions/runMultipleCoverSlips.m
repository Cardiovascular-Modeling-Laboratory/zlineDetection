function [] = runMultipleCoverSlips(settings)
%This function will be used to run multiple coverslips and obtain a summary
%file

%If the user wants to compare conditions, ask them how many 

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

%Set previous path equal to the current location 
previous_path = pwd; 

%Have the user select the different directories for the coverslips
for k = 1:settings.num_cs 
    
    %Display message telling the user which coverslip they're on 
    disp_message = strcat('Selecting Coverslip',{' '}, num2str(k),...
        {' '}, 'of', {' '}, num2str(settings.num_cs)); 
    disp(disp_message); 
    
    % Prompt the user to select the images they would like to analyze. 
    [ zline_images{k,1}, zline_path{k,1}, zn(k,1) ] = ...
        load_files( {'*w1mCherry*.TIF;*w1mCherry*.tif;*w1Cy7*.tif'}, ...
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
    
    potential_end = size(pathparts,2); 
    while isempty(pathparts{1,potential_end})
        potential_end = potential_end -1; 
    end 
    %Save the name of the directory 
    name_CS{k,1} = pathparts{1,potential_end}; 
    
    %If the user is actin filtering, have them select the files 
    if settings.actin_filt
        [ actin_images{k,1}, actin_path{k,1}, an(k,1) ] = ...
            load_files( {'*GFP*.TIF;*GFP*.tif'}, ...
            'Select images stained for actin...',previous_path);

        % If the number of actin and z-line files are not equal,
        % warn the user
        if an ~= zn
            disp(['The number of z-line files does not equal',...
                'the number of actin files.']); 
            disp(strcat('Actin Images: ',{' '}, num2str(an), ...
                'Z-line Images: ',{' '}, num2str(zn))); 
            disp('Press "Run Folder" to try again.'); 
            return; 
        end
    
        % Sort the z-line and actin files. Ideally this means that 
        % they'll be called in the correct order. 
        zline_images{k,1} = sort(zline_images{k,1}); 
        actin_images{k,1} = sort(actin_images{k,1}); 
    
    else
        actin_images = NaN; 
        actin_path = NaN; 
        an = NaN; 
    end  
    
    %Declare conditions for the selected coverslip 
    cond(k,1) = declareCondition(settings.cond_name, k, settings.num_cs); 
    
end 

%Loop through and run each FOV in each CS 
clear k 
for k = 1:settings.num_cs 
    %Run the analysis
    [ outputs ] = ...
        runDirectory( settings, zline_path, zline_images,...
        actin_path, actin_images, name_CS ); 
    
    %Create an input struct
    inputs = struct(); 
    
    %If exploration - compare conditions and coverslips 
    if settings.exploration 
        if k == 1
            %Save the medians for each coverslip 
            MultiCS_medians = zeros(zn(k,1),settings.num_cs); 
            %Save the medians for each coverslip 
            MultiCS_sums = zeros(zn(k,1),settings.num_cs); 
            %Save the medians for each coverslip 
            MultiCS_nonsarc = zeros(zn(k,1),settings.num_cs);
            %Save the medians for each coverslip 
            MultiCS_grid_sizes = zeros(zn(k,1),settings.num_cs);
            MultiCS_actin_threshs = zeros(zn(k,1),settings.num_cs);
        end 
        
        %Store the actin struct
        CS_actinexplore = outputs.CS_actinexplore; 
        
        %Save the values of each category
        MultiCS_medians(:,k) = CS_actinexplore.CS_median;
        MultiCS_sums(:,k) = CS_actinexplore.CS_sum;
        MultiCS_nonsarc(:,k) = CS_actinexplore.CS_nonsarc;
        MultiCS_grid_sizes(:,k) = CS_actinexplore.CS_explorevalues(:,1);
        MultiCS_actin_threshs(:,k) = CS_actinexplore.CS_explorevalues(:,2);
    end 
    
    %If ~explore & actin filtering
    if ~exploration && settings.actin_filt
        if k == 1
            Multi_nonsarc = zeros(zn(k,1),settings.num_cs); 
        end 
    end 
    
    
    %If ~exploration & czl 
    if ~exploration && settings.tf_CZL
        
        if k == 1
            %Save the lengths for each CS
            Multilengths = cell(zn(k,1),settings.num_cs);
            %Save the median value 
            Multimedians = zeros(zn(k,1),settings.num_cs);
            %Save the median value 
            Multisums = zeros(zn(k,1),settings.num_cs);
        end 
        %Store the continuous z-line lengths struct 
        CS_CZL = outputs.CS_CZL; 
         
    end 
    %If ~exploration & oop
    if ~exploration && settings.tf_OOP
        %Store the OOP struct 
        CS_OOP = outputs.CS_OOP; 
    end 
end 

end

