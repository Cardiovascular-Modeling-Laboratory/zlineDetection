function [ dims, oop, director, grid_info, visualization_matrix] = ...
    gridDirector( orientation_matrix, grid_size )
%This function will break an image up into grid_size(1) x grid_size(2)
%pieces and report the director and OOP 

%Get size of the matrix of orientation angles 
[m1, m2] = size(orientation_matrix); 

%Create an empty matrix that can be used to visualize the director in each
%grid
visualization_matrix = zeros(m1,m2); 
visualization_matrix(visualization_matrix == 0) = NaN; 

% Create grids of the sizes declared in grid size
if length(grid_size) == 1
    % If grid size is just a number, set the second dimension equal to the
    % first 
    grid_size(2) = grid_size(1); 
end 

% Make sure that the grid is whole numbers
grid_size = round(grid_size); 

% Start a grid position counter 
n = 1; 

% Save the number of grids 
tot_grids = length(1:grid_size(1):m1)*length(1:grid_size(2):m2); 

% Save the dimensions 
dims = zeros(tot_grids,4); 

% Save the OOP 
oop = zeros(tot_grids,1); 

% Save the director 
director = zeros(tot_grids,1); 

% Save number of nonzero pixels and the total number of pixels 
% [size1, size 2, total pixels, total nonzero pixels] 
grid_info = zeros(tot_grids,4); 

% Loop through the grid sizes
for d1 = 1:grid_size(1):m1
    for d2 = 1:grid_size(2):m2
        %Get the stopping positions 
        s1 = d1 + grid_size(1) - 1; 
        s2 = d2 + grid_size(2) - 1; 
        
        %If the stopping position is greater than the dimensions of the 
        %oirentation matrix, set it equal 
        if s1 > m1
            s1 = m1; 
        end 
        if s2 > m2
            s2 = m2; 
        end 
        
        %Isolate the grid 
        temp_grid = orientation_matrix(d1:s1, d2:s2); 
        
        %Save the size of the grid 
        [grid_info(n,1), grid_info(n,2)] = size(temp_grid); 
        
        %Transform into an array and count the number of pixels
        temp_array = temp_grid(:); 
        grid_info(n,3) = length(temp_array); 
        
        %Remove all of the nonzero positions and count the number of
        %points remaining 
        temp_array(temp_array == 0) = []; 
        grid_info(n,4) = length(temp_array); 
        
        % Calculate the OOP and director if there are orientation vecotrs
        % in the grid 
        if grid_info(n,4) > 0 
            %Calculate the OOP and director 
            [ oop(n,1), director_angle, ~ ] = ...
                calculate_OOP( temp_array ); 
            
            %Covert the director angle to radians
            director(n,1) = deg2rad(director_angle); 
        else
            % If there aren't any orientation vectors in the grid, set the
            % oop and director equal to zero. 
            oop(n,1) = NaN; 
            director(n,1) = NaN; 
        end 
        
        %Set the middle of the grid in the visualization matrix equal to
        %the director
        visualization_matrix(round((d1+s1)/2),round((d2+s2)/2)) = ...
            director(n,1); 
        
        %Save the dimensions 
        dims(n,1) = d1; dims(n,2) = s1; dims(n,3) = d2; dims(n,4) = s2; 
        
        %Increase the counter 
        n = n+1; 
    end 
end 


end

