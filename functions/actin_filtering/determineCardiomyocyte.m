function [ grid_info, labels] = ...
    determineCardiomyocyte(actin_orientim,zline_orientim, grid_size)
%This function will compare the orientation vectors of actin and z-lines
%and return whether there there is a cardiomyocyte in the region 

%Get size of the matrix of orientation angles of zline and actin 
[zdim1, zdim2] = size(zline_orientim); 
[adim1, adim2] = size(actin_orientim); 

if zdim1 ~= adim1 || zdim2~=adim2
    disp('Actin and z-line images are not the same size.'); 
else 
    %Initialze a matrix the same size as the actin and z-line images that
    %will contain the following labels 
    %0: No actin & No zlines
    %1: Only actin 
    %2: Only zlines 
    %3: Both actin and z-lines
    labels = zeros(zdim1,zdim2); 
    
    %Create binary verisons of both actin and z-lines 
    zline_bin = zline_orientim; 
    zline_bin(isnan(zline_orientim)) = 0; 
    zline_bin( zline_orientim == 0 ) = 0; 
    zline_bin( zline_orientim > 0 ) = 1; 
    actin_bin = actin_orientim; 
    actin_bin(isnan(actin_orientim)) = 0; 
    actin_bin( actin_orientim == 0 ) = 0; 
    actin_bin( actin_orientim > 0 ) = 1; 
    
    % Create grids of the sizes declared in grid size
    if length(grid_size) == 1
        % If grid size is just one number, set the second dimension 
        % equal to the first 
        grid_size(2) = grid_size(1); 
    end 

    % Make sure that the grid is whole numbers
    grid_size = round(grid_size); 

    % Start a grid position counter 
    n = 1; 

    % Save the number of grids 
    tot_grids = length(1:grid_size(1):zdim1)*length(1:grid_size(2):zdim2); 

    % Save number of nonzero pixels and the total number of pixels 
    % [size1, size 2, total pixels, zline total nonzero pixels, 
    % actin total nonzero pixels ] 
    grid_info = zeros(tot_grids,5); 


    % Loop through the grid sizes
    for d1 = 1:grid_size(1):zdim1
        for d2 = 1:grid_size(2):zdim2
            %Get the stopping positions 
            s1 = d1 + grid_size(1) - 1; 
            s2 = d2 + grid_size(2) - 1; 
            
            %If the stopping position is greater than the dimensions of the 
            %oirentation matrix, set it equal 
            if s1 > zdim1
                s1 = zdim1; 
            end 
            if s2 > zdim2
                s2 = zdim2; 
            end 
        
            %Isolate the grid 
            isolated_zlines = zline_bin(d1:s1, d2:s2); 
            isolated_actin = actin_bin(d1:s1, d2:s2); 
            
            %Save the size of the grid 
            [grid_info(n,1), grid_info(n,2)] = size(isolated_zlines);
            
            %Transform into an array and count the number of pixels
            temp_array = isolated_zlines(:); 
            grid_info(n,3) = length(temp_array); 
            
            %Count the number of nonzero points for z-lines and actin 
            grid_info(n,4) = sum(isolated_zlines(:)); 
            grid_info(n,5) = sum(isolated_actin(:)); 
            
            %Set the labels for the labels matrix 
            %0: No actin & No zlines
            if grid_info(n,4) == 0 && grid_info(n,5) == 0 
                labels(d1:s1, d2:s2) = 0; 
            end 
            %1: Only actin 
            if grid_info(n,4) == 0 && grid_info(n,5) ~= 0 
                labels(d1:s1, d2:s2) = 1; 
            end 
            %2: Only zlines 
            if grid_info(n,4) ~= 0 && grid_info(n,5) == 0 
                labels(d1:s1, d2:s2) = 2; 
            end 
            %3: Actin & Zlines 
            if grid_info(n,4) ~= 0 && grid_info(n,5) ~= 0 
                labels(d1:s1, d2:s2) = 3; 
            end 
            
            %Increase count 
            n = n+1; 
        end
    end   
end 

end

