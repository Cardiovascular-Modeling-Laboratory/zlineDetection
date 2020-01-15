% combineFOV - For usage with zlineDetection.m ONLY. It is used to combine 
% the FOV for a single coverslip
%
% Usage: 
%   CS_results = combineFOV( settings, CS_results )
%
% Arguments:
%   settings    - zlineDetection parameters 
%                   Class Support: STRUCT
%   CS_results  - Contains information for each FOV in a CS
%                   Class Support: STRUCT
% Returns:
%   CS_results  - Combined information for all FOV in a CS 
%                   Class Support: STRUCT
%
% Dependencies: 
%   MATLAB Version >= 9.5 
%   Statistics and Machine Learning Toolbox Version 11.4
%   Functions: 
%       calculate_OOP.m
%       combineFOV.m
%       concatCells.m
%
% Tessa Morris
% Advisor: Anna Grosberg, Department of Biomedical Engineering 
% Cardiovascular Modeling Laboratory 
% University of California, Irvine 

function [CS_results] = combineFOV( settings, CS_results )

%Properly ordered FOV values
FOV_Grouped = struct; 

%Convert exploration values from cell to matrix 
FOV_Grouped.FOV_thresholds = ...
    concatCells( CS_results.FOV_thresholds, true );  
FOV_Grouped.FOV_grid_sizes = ...
    concatCells( CS_results.FOV_grid_sizes, true );  

%Get unique threshold values 
unique_thresh = unique(FOV_Grouped.FOV_thresholds); 
attot = length(unique_thresh); 
%Get unique grid sizes
unique_grids = unique(FOV_Grouped.FOV_grid_sizes); 
gtot = length(unique_grids); 

%Get the number of FOV 
zn = length(CS_results.zline_images); 

%Get the total number of conditions. Set to 1 if there was no exploration 
if settings.actinthresh_explore || settings.grid_explore 
    tot = attot*gtot; 
else
    tot = 1; 
end 

%%%%%%%%%%%%%%%%%%%%%%%% Initialize CS Matrices  %%%%%%%%%%%%%%%%%%%%%%%%%%
%>>> Continuous Z-line Length
CS_results.CS_lengths = cell(1,tot); 
CS_results.CS_medians = zeros(1,tot); 
CS_results.CS_sums = zeros(1,tot);  
CS_results.CS_means = zeros(1,tot);  
CS_results.CS_skewness = zeros(1,tot);  
CS_results.CS_kurtosis  = zeros(1,tot);  
        
%>>> Non Zline & Zline Fractions 
CS_results.CS_nonzlinefrac = zeros(1,tot);
CS_results.CS_zlinefrac = zeros(1,tot);

%>>> ZLINE OOP 
CS_results.CS_angles = cell(1,tot); 
CS_results.CS_OOPs = zeros(1,tot);
CS_results.CS_directors = zeros(1,tot);
CS_results.angle_count = zeros(1,tot); 

%>>> ACTIN OOP 
CS_results.ACTINCS_angles = cell(1,tot); 
CS_results.ACTINCS_OOPs = zeros(1,tot);
CS_results.ACTINCS_directors = zeros(1,tot);
CS_results.ACTINangle_count = zeros(1,tot); 

%>>> EXPLORATION VALUES 
CS_results.CS_thresholds = zeros(1,tot);
CS_results.CS_gridsizes = zeros(1,tot);

%%%%%%%%%%%%%%%%%%% GROUP EXPLORATION VALUES  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize cells to store grouped data so that all of the cells will be
% in (FOV, exploration parameter) format 
FOV_Grouped.FOV_lengths = cell(zn,tot);
FOV_Grouped.FOV_angles = cell(zn,tot); 
FOV_Grouped.FOV_prefiltered = zeros(1,tot);
FOV_Grouped.FOV_postfiltered = zeros(1,tot);
FOV_Grouped.ACTINFOV_angles = cell(zn,tot);

% Specially group data if the user did an exploration 
if settings.exploration

    %Loop through all of the conditions 
    for z = 1:zn 
        %Store the information for the current image 
        current_prefilt = CS_results.FOV_prefiltered{1,z};
        current_postfilt = CS_results.FOV_postfiltered{1,z};
        current_lengths = CS_results.FOV_lengths{1,z};
        current_angles = CS_results.FOV_angles{1,z};
        current_grids = CS_results.FOV_grid_sizes{1,z};
        current_threshs = CS_results.FOV_thresholds{1,z};  
        ACTINcurrent_angles = CS_results.ACTINFOV_angles{1,z};     

        %Start a counter 
        n = 1;

%>>> GRID EXPLORE 
        for g = 1:gtot
            %Set include grids to be the same size as the current grid
            include_grid = zeros(size(current_grids)); 
            %Set the values that are not equal to unique grid value equal to
            %NaN; 
            include_grid(current_grids ~= unique_grids(g)) = NaN;

%>>> ACTIN EXPLORE 
            for a = 1:attot
                %Set include thresh to be the same size as the current grid
                include_thresh = zeros(size(current_threshs)); 
                %Set the values that are not equal to unique grid value equal 
                %to NaN; 
                include_thresh(current_threshs ~= unique_thresh(a)) = NaN;

                %Add the include values for the grid and thresholds
                include = include_thresh + include_grid; 

                %Find the position where include is not NaN 
                p = find(~isnan(include));

                %Store the current z-line angles 
                FOV_Grouped.FOV_angles{z,n} = current_angles{p,1};
                
                %Store the current ACTIN angles 
                FOV_Grouped.ACTINFOV_angles{z,n} = ACTINcurrent_angles;
                
                %Add the pre and post filtered number of pixels 
                FOV_Grouped.FOV_prefiltered(1,n) = ...
                   FOV_Grouped.FOV_prefiltered(1,n) + current_prefilt(p,1);

                FOV_Grouped.FOV_postfiltered(1,n) = ...
                   FOV_Grouped.FOV_postfiltered(1,n) + current_postfilt(p,1);

               %Save the CZL if the user did a parameter exploration or
                %requested to see the continuous z-line length
                if settings.tf_CZL
                    %Store the values at the current grids 
                    FOV_Grouped.FOV_lengths{z,n} = current_lengths{p,1};
                else 
                    FOV_Grouped.FOV_lengths{z,n} = []; 
                end   
                
                %First iteration through the FOV save the unique grid and
                %threshold values 
                if z == 1
                    %Store the current grid and threshold values 
                    CS_results.CS_gridsizes(1,n) = unique_grids(g); 
                    CS_results.CS_thresholds(1,n) = unique_thresh(a);
                end  
                
                %Increase counter 
                n = n+1; 

            end 
        end
    end 
else
    %%%%%%%%%%%%%%% NO EXPLORATION: GROUP VALUES  %%%%%%%%%%%%%%%%%%%%%%%%%
    for k = 1:zn
        %Store the analysis values 
        FOV_Grouped.FOV_lengths{k,1} = CS_results.FOV_lengths{1,k};
        FOV_Grouped.FOV_angles{k,1} = CS_results.FOV_angles{1,k};
        FOV_Grouped.ACTINFOV_angles{k,1} = CS_results.ACTINFOV_angles{1,k};
        
        FOV_Grouped.FOV_prefiltered(k,1) = CS_results.FOV_prefiltered{1,k};
        FOV_Grouped.FOV_postfiltered(k,1) = CS_results.FOV_postfiltered{1,k};
    end
    
    %Store the exploration values
    CS_results.CS_thresholds = settings.actin_thresh;
    CS_results.CS_gridsizes = settings.grid_size(1);    
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% COMBINE FOV %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Loop through and calculate the values for all of the different combination  
for t = 1:tot
    
    %Create arrays to store the angles and lengths temporarily 
    grouped_lengths = [];
    grouped_angles = []; 
    ACTINgrouped_angles = []; 
    % Loop through all of the FOV 
    for z = 1:zn 
        
        if settings.exploration || settings.tf_CZL
            %CZL: Store the current FOV in an array and convert to be n x 1
            current_length = FOV_Grouped.FOV_lengths{z,t}; 
            current_length = current_length(:); 
            
            %CZL: Save in the temp vector. 
            grouped_lengths = [grouped_lengths;current_length]; 
       
        end 
        
        if settings.exploration || settings.tf_OOP
            %ANGLES: Store the current FOV in an array and convert to be 
            %n x 1
            current_angles = FOV_Grouped.FOV_angles{z,t}; 
            current_angles = current_angles(:); 
        
            %ANGLES: Save in the temp vector. 
            grouped_angles = [grouped_angles;current_angles]; 
        end 
        
        if settings.actin_filt
            %ANGLES: Store the current FOV in an array and convert to be 
            %n x 1
            ACTINcurrent_angles = FOV_Grouped.ACTINFOV_angles{z,t}; 
            ACTINcurrent_angles = ACTINcurrent_angles(:); 
        
            %ANGLES: Save in the temp vector. 
            ACTINgrouped_angles = [ACTINgrouped_angles;ACTINcurrent_angles]; 
            
        end 
        
    end 
    
    %Save all of the lengths, calculate the median and sum 
    CS_results.CS_lengths{1,t} = grouped_lengths;
    CS_results.CS_medians(1,t) = median(CS_results.CS_lengths{1,t}); 
    CS_results.CS_sums(1,t) = sum(CS_results.CS_lengths{1,t});   
    
    % Calculate the mean, skewness, and kurtosis
    CS_results.CS_means(1,t) = mean(CS_results.CS_lengths{1,t}); 
    CS_results.CS_skewness(1,t) = skewness(CS_results.CS_lengths{1,t}); 
    CS_results.CS_kurtosis(1,t) = kurtosis(CS_results.CS_lengths{1,t}); 

    %Store all of the z-line orientation angles 
    CS_results.CS_angles{1,t} = grouped_angles;
    %Calculate number of nonzero orientation vectors
    grouped_angles(isnan(grouped_angles)) = []; 
    grouped_angles(grouped_angles == 0) = []; 
    CS_results.angle_count(1,t) = length(grouped_angles); 
    %Calculate OOP 
    if settings.exploration || settings.tf_OOP 
        [CS_results.CS_OOPs(1,t), CS_results.CS_directors(1,t),...
            ~, ~ ] = calculate_OOP( grouped_angles ); 
    else         
        CS_results.CS_OOPs(1,t) = NaN; 
         CS_results.CS_directors(1,t) = NaN; 
    end 
    
    %Save all of the ACTIN angles
    CS_results.ACTINCS_angles{1,t} = ACTINgrouped_angles;
    %Calculate number of nonzero orientation vectors
    ACTINgrouped_angles(isnan(ACTINgrouped_angles)) = []; 
    ACTINgrouped_angles(ACTINgrouped_angles == 0) = []; 
    CS_results.ACTINangle_count(1,t) = length(ACTINgrouped_angles); 
    %Calculate OOP 
    if settings.actin_filt
        [CS_results.ACTINCS_OOPs(1,t), ...
            CS_results.ACTINCS_directors(1,t), ~, ~ ] = ...
            calculate_OOP( ACTINgrouped_angles );         
    else 
        CS_results.ACTINCS_OOPs(1,t) = NaN; 
        CS_results.ACTINCS_directors(1,t) = NaN; 
    end 
    
    %Calculate the non-zline fraction 
    CS_results.CS_nonzlinefrac(1,t) = ...
        (sum(FOV_Grouped.FOV_prefiltered(:,t)) - ...
        sum(FOV_Grouped.FOV_postfiltered(:,t)))/ ...
        sum(FOV_Grouped.FOV_prefiltered(:,t));
    
    %Calculate z-line fraction 
    CS_results.CS_zlinefrac(1,t) = 1 - CS_results.CS_nonzlinefrac(1,t); 
        
end 

end 