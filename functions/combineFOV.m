function [CS_results] = combineFOV( settings, CS_results )
% This function will combine the FOV for a single coverslip

%%%%%%%%%%%%%%%%%%%% Convert Cells to Matrices %%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Properly ordered FOV values
FOV_Grouped = struct; 

%>>> ACTIN FILTERING: Non Sarc Fractions (NO EXPLORATION) 
FOV_Grouped.FOV_nonzlinefrac = ...
    concatCells( CS_results.FOV_nonzlinefrac, true ); 
FOV_Grouped.FOV_zlinefrac = ...
    concatCells( CS_results.FOV_zlinefrac, true ); 

%>>> ACTIN FILTERING: Continuous z-line length (NO EXPLORATION) 
FOV_Grouped.FOV_medians = concatCells( CS_results.FOV_medians, true ); 
FOV_Grouped.FOV_sums = concatCells( CS_results.FOV_sums, true ); 

%>>> ACTIN FILTERING: OOP (NO EXPLORATION) 
FOV_Grouped.FOV_OOPs = concatCells( CS_results.FOV_OOPs, true );  

%>>> EXPLORATION
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

%%%%%%%%%%%%%%%%%%%%%%%% Initialize Matrices  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%>>> Continuous Z-line Length
CS_results.CS_lengths = cell(1,tot); 
CS_results.CS_medians = zeros(1,tot); 
CS_results.CS_sums = zeros(1,tot);  
% FOV_lengths = cell(1,tot); 
CS_results.FOVstats_medians = zeros(2,tot); %1: mean 2: stdev 
CS_results.FOVstats_sums = zeros(2,tot);  %1: mean 2: stdev 

%>>> Non Zline & Zline Fractions 
CS_results.CS_nonzlinefrac = zeros(1,tot);
CS_results.FOVstats_nonzlinefrac = zeros(2,tot);%1: mean 2: stdev 
CS_results.CS_zlinefrac = zeros(1,tot);
CS_results.FOVstats_zlinefrac = zeros(2,tot);%1: mean 2: stdev 

%>>> OOP 
CS_results.CS_angles = cell(1,tot); 
CS_results.CS_OOPs = zeros(1,tot);
CS_results.FOVstats_OOPs = zeros(2,tot);%1: mean 2: stdev 
CS_results.angle_count = zeros(1,tot); 

%>>> ACTIN OOP 
CS_results.ACTINCS_angles = cell(1,tot); 
CS_results.ACTINCS_OOPs = zeros(1,tot);
CS_results.ACTINFOVstats_OOPs = zeros(2,tot);%1: mean 2: stdev 
CS_results.ACTINangle_count = zeros(1,tot); 

%>>> EXPLORATION
CS_results.CS_thresholds = zeros(1,tot);
CS_results.CS_gridsizes = zeros(1,tot);


%%%%%%%%%%%%%%%%%%% GROUP EXPLORATION VALUES  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%>>> Specially Group data (more than 1 value that are inconsistently valued
FOV_Grouped.FOV_lengths = cell(zn,tot);
FOV_Grouped.FOV_angles = cell(zn,tot); 

FOV_Grouped.FOV_prefiltered = zeros(1,tot);
FOV_Grouped.FOV_postfiltered = zeros(1,tot);

FOV_Grouped.ACTINFOV_angles = cell(zn,tot);
    
% Specially group data if the user did an exploration 
if settings.actinthresh_explore || settings.grid_explore 

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

        for g = 1:gtot
            %Set include grids to be the same size as the current grid
            include_grid = zeros(size(current_grids)); 
            %Set the values that are not equal to unique grid value equal to
            %NaN; 
            include_grid(current_grids ~= unique_grids(g)) = NaN;


            %First iteration, concat matrices to get statistics 
            if z == 1
                %Get grid values to exclude 
                exlude_grids = zeros(1,tot*zn); 
                exlude_grids(FOV_Grouped.FOV_grid_sizes ~= ...
                    unique_grids(g)) = NaN; 
            end

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

                %Save the CZL if the user did a parameter exploration or
                %requested to see the continuous z-line length
                if settings.exploration || settings.tf_CZL
                    %Store the values at the current grids 
                    FOV_Grouped.FOV_lengths{z,n} = current_lengths{p,1};
                else 
                    FOV_Grouped.FOV_lengths{z,n} = []; 
                end   

                %Store the current angles 
                FOV_Grouped.FOV_angles{z,n} = current_angles{p,1};
                
                %Store the current ACTIN angles 
%                 FOV_Grouped.ACTINFOV_angles{z,n} = ACTINcurrent_angles{p,1};
                FOV_Grouped.ACTINFOV_angles{z,n} = ACTINcurrent_angles;
                
                %Add the pre and post filtered number of pixels 
                FOV_Grouped.FOV_prefiltered(1,n) = ...
                   FOV_Grouped.FOV_prefiltered(1,n) + current_prefilt(p,1);

                FOV_Grouped.FOV_postfiltered(1,n) = ...
                   FOV_Grouped.FOV_postfiltered(1,n) + current_postfilt(p,1);

                %First iteration, concat matrices to get statistics 
                if z == 1 
                    %Get threshold values to exclude 
                    exlude_thresh = zeros(1,tot*zn); 
                    exlude_thresh(FOV_Grouped.FOV_thresholds ~= ...
                        unique_thresh(a)) = NaN; 

                    %Store the current grid and threshold values 
                    CS_results.CS_gridsizes(1,n) = unique_grids(g); 
                    CS_results.CS_thresholds(1,n) = unique_thresh(a);

                    %Store the median, sums, nonzline and OOPs that are included
                    include_medians = FOV_Grouped.FOV_medians;
                    include_sums = FOV_Grouped.FOV_sums;
                    include_nonzlinefrac = FOV_Grouped.FOV_nonzlinefrac;
                    include_zlinefrac = FOV_Grouped.FOV_zlinefrac;
                    include_OOP = FOV_Grouped.FOV_OOPs;

                    if ~isempty(FOV_Grouped.FOV_medians)
                        include_medians = include_medians ...
                            + exlude_grids + exlude_thresh;
                        include_medians(isnan(include_medians)) = []; 
                    end 

                    if ~isempty(FOV_Grouped.FOV_sums)
                        include_sums = include_sums ...
                            + exlude_grids + exlude_thresh;  
                        include_sums(isnan(include_sums)) = []; 
                    end 
                    if ~isempty(FOV_Grouped.FOV_nonzlinefrac)
                        include_nonzlinefrac = include_nonzlinefrac ...
                            + exlude_grids + exlude_thresh; 
                        include_nonzlinefrac(isnan(include_nonzlinefrac)) = []; 
                    end
                    if ~isempty(FOV_Grouped.FOV_zlinefrac)
                        include_zlinefrac = include_zlinefrac ...
                            + exlude_grids + exlude_thresh; 
                        include_zlinefrac(isnan(include_zlinefrac)) = []; 
                    end
                    if ~isempty(FOV_Grouped.FOV_OOPs)
                        include_OOP = include_OOP ...
                            + exlude_grids + exlude_thresh;  
                        include_OOP(isnan(include_OOP)) = []; 
                    end 

                    %Get the FOV stats 1: mean 2: stdev 
                    CS_results.FOVstats_medians(1,n) = mean(include_medians);
                    CS_results.FOVstats_medians(2,n) = std(include_medians);
                    CS_results.FOVstats_sums(1,n) = mean(include_sums); 
                    CS_results.FOVstats_sums(2,n) = std(include_sums); 
                    CS_results.FOVstats_nonzlinefrac(1,n) = ...
                        mean(include_nonzlinefrac);
                    CS_results.FOVstats_nonzlinefrac(2,n) = ...
                        std(include_nonzlinefrac);
                    CS_results.FOVstats_zlinefrac(1,n) = ...
                        mean(include_zlinefrac);
                    CS_results.FOVstats_zlinefrac(2,n) = ...
                        std(include_zlinefrac); 
                    CS_results.FOVstats_OOPs(1,n) = mean(include_OOP); 
                    CS_results.FOVstats_OOPs(2,n) = std(include_OOP); 
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
    
    %Save all of the angles and calculate the OOPs 
    CS_results.CS_angles{1,t} = grouped_angles;
    if settings.exploration || settings.tf_OOP 
        temp_angles = CS_results.CS_angles{1,t}; 
        temp_angles(isnan(temp_angles)) = 0;
        [CS_results.CS_OOPs(1,t), ~, ~, ~ ] = calculate_OOP( temp_angles ); 
        %Calculate the number of nonzero angles
        temp_angles(temp_angles == 0) = []; 
        CS_results.angle_count(1,t) = length(temp_angles); 
    else 
        CS_results.CS_OOPs(1,t) = NaN; 
    end 
    
    %Save all of the ACTIN angles and calculate the OOPs 
    CS_results.ACTINCS_angles{1,t} = ACTINgrouped_angles;
    if settings.actin_filt
        ACTINtemp_angles = CS_results.ACTINCS_angles{1,t}; 
        ACTINtemp_angles(isnan(ACTINtemp_angles)) = 0;
        [CS_results.ACTINCS_OOPs(1,t), ~, ~, ~ ] = ...
            calculate_OOP( ACTINtemp_angles ); 
        %Calculate the number of nonzero angles
        ACTINtemp_angles(ACTINtemp_angles == 0) = []; 
        CS_results.ACTINangle_count(1,t) = length(ACTINtemp_angles); 
    else 
        CS_results.ACTINCS_OOPs(1,t) = NaN; 
        CS_results.ACTINangle_count(1,t) = NaN; 
    end 
    
    %Calculate the non-zline fraction 
    CS_results.CS_nonzlinefrac(1,t) = ...
        (sum(FOV_Grouped.FOV_prefiltered(1,t)) - ...
        sum(FOV_Grouped.FOV_postfiltered(1,t)))/ ...
        sum(FOV_Grouped.FOV_prefiltered(1,t));
    
    %Calculate z-line fraction 
    CS_results.CS_zlinefrac(1,t) = 1 - CS_results.CS_nonzlinefrac(1,t); 
        
end 

%Store the FOV_Grouped struct 
CS_results.FOV_Grouped = FOV_Grouped; 

end 