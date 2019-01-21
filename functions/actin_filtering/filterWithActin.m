% filterWithActin - This function will filter a z-line image with the
% director of small actin grids 
%
%
% Usage:
%  new_subfolder_name = appendName(subfolder_path, subfolder_name, create); 
%
% Arguments:
%       subfolder_path  - path where the new directory should be added 
%       subfolder_name  - name of new directory 
%       create          - boolean on whether the user would like to create 
%                           the directory as soon as it no longer exists
% Returns:
%       new_subfolder_name - directory that does not exist 
% 
% Tessa Morris
% Advisor: Anna Grosberg
% Cardiovascular Modeling Laboratory 
% University of California, Irvine 


function [ mask, actin_struct, dp ] = ...
    filterWithActin( im_struct, filenames, settings)

% Create a struct to hold all of the information for the actin image 
actin_struct = struct(); 

% Save the actin filename 
actin_struct.filename = filenames.actin; 

% Compute the orientation vectors for actin
[ actin_struct.actin_orientim, actin_struct.actin_reliability, ...
    actin_struct.actin_im ] = ...
    actinDetection( filenames.actin, settings, settings.disp_actin, ...
    im_struct.save_path); 

% If not doing a grid parameter exploration comput the director for each
% grid. If not then procceed to parameter exploration. 
if ~settings.grid_explore 
    % Compute the director for each grid 
    [ actin_struct.dims, actin_struct.oop, actin_struct.director, ...
        actin_struct.grid_info, actin_struct.visualization_matrix, ...
        actin_struct.director_matrix] = ...
        gridDirector( actin_struct.actin_orientim, settings.grid_size );

    % Save the image 
    if settings.disp_actin
        % Visualize the actin director on top of the z-line image by first
        % displaying the z-line image and then plotting the orinetation 
        %vectors. 
        figure;
        spacing = 15; color_spec = 'b'; 
        plotOrientationVectors(actin_struct.visualization_matrix,...
            mat2gray(im_struct.gray),spacing, color_spec) 

        % Save figure 
        saveas(gcf, fullfile(im_struct.save_path, ...
            strcat( im_struct.im_name, '_zlineActinDirector.tif' )), ...
            'tiffn');
    end 

    %Take the dot product sqrt(cos(th1 - th2)^2);
    dp = sqrt(cos(im_struct.orientim - actin_struct.director_matrix).^2); 
    
else
    %Set grid director ouputs to not numbers
    actin_struct.dims = NaN;
    actin_struct.oop = NaN;
    actin_struct.director = NaN; 
    actin_struct.grid_info = NaN; 
    actin_struct.visualization_matrix = NaN;
    actin_struct.director_matrix = NaN; 
    
    %Create a dot product matrix of all zeros
    dp = zeros(size(im_struct.orientim)); 
    
    disp('Parameter Exploration for actin detect grid sizes...'); 
end 
%Create mask 
mask = ones(size(im_struct.orientim)); 

% If the threshold is greater than 1 that means that the user would like to
% do a parameter exploration 
if settings.actin_thresh <= 1
    %If dot product is closer to 1, the angles are more parallel and should 
    %be removed
    mask(dp >= settings.actin_thresh) = 0; 
    %If dot product is closer to 0, the angles are more perpendicular and
    %should be kept
    mask(dp < settings.actin_thresh) = 1; 

    %The NaN postitions should be set equal to 1 (meaning no director for
    %actin)
    mask(isnan(mask)) = 1; 
else
    disp('Parameter Exploration for actin detect threshold...'); 
end 

end

