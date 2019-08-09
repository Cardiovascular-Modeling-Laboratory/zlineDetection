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
[ actin_struct.actin_orientim, actin_struct.actin_im, ...
    actin_struct.actin_background, actin_struct.actin_anisodiffuse] = ...
    actinDetection( filenames.actin, settings, settings.disp_actin, ...
    im_struct.save_path); 


% If not doing a grid parameter exploration comput the director for each
% grid. If not then procceed to parameter exploration. 
if ~settings.grid_explore 
    
    % Caclulate the oop of actin to use in the grid director 
    [ actinOOP, ~, ~, ~ ] = calculate_OOP( actin_struct.actin_orientim ); 
    % Compute the director for each grid 
    [ actin_struct.dims, actin_struct.oop, actin_struct.director, ...
        actin_struct.grid_info, actin_struct.visualization_matrix, ...
        actin_struct.director_matrix] = ...
        gridDirector( actin_struct.actin_orientim, settings.grid_size,...
        actinOOP);

    % Save the image 
    if settings.disp_actin
        % Visualize the actin director on top of the z-line image by first
        % displaying the z-line image and then plotting the orinetation 
        %vectors. 
        figure;
        spacing = 15; color_spec = 'b'; 
        plotOrientationVectors(actin_struct.visualization_matrix,...
            mat2gray(im_struct.im_gray),spacing, color_spec) 

        % Save figure 
        saveas(gcf, fullfile(im_struct.save_path, ...
            strcat( im_struct.im_name, '_zlineActinDirector.tif' )), ...
            'tiffn');
    end 

    %Take the dot product sqrt(cos(th1 - th2)^2);
    dp = sqrt(cos(im_struct.orientim - actin_struct.director_matrix).^2); 
    
else
    %Set  director ouputs to not numbers
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
if ~settings.actinthresh_explore
    % Set the mask equal to the actin mask 
    mask = actin_struct.actin_background; 
    
    %If dot product is closer to 1, the angles are more parallel and should 
    %be removed
    mask(dp >= settings.actin_thresh) = 0; 
    %If dot product is closer to 0, the angles are more perpendicular and
    %should be kept
    mask(dp < settings.actin_thresh) = 1; 

    %The NaN postitions should be set equal to 1 (meaning no director for
    %actin)
    mask(isnan(mask)) = 1; 
    
    % Get the accepted z-lines 
    orientim_zlines_accepted = im_struct.orientim; 
    orientim_zlines_accepted(mask == 0) = 0; 
    
    %Get the directors of the remaining orientation vectors
    [ zlinegrid_DIMS, zlinegrid_OOPs, ~, ~, ~, zline_dirmat ] = ...
        gridDirector( orientim_zlines_accepted, settings.grid_size );
    
    %Compare the director of the remaining orientation vecotrs with the
    %original orientation vectors. 
    dp_zlines = sqrt(cos(im_struct.orientim - zline_dirmat).^2); 
    
    % Create a new mask, that is 1 where the old z-lines are parallel to
    % the director of the accepted z-lines and zero other wise. 
    mask2 = ones(size(dp_zlines)); 
    mask2(dp_zlines > settings.actin_thresh) = 1; 
    mask2(dp_zlines <= settings.actin_thresh) = 0; 
    mask2(isnan(dp_zlines)) = 0; 

    % Add back positions in the original skeleton that are parallel to the
    % accepted skeleton 
    addback_parallel = im_struct.skel_trim.*mask2.*~mask; 
    mask( addback_parallel == 1 ) = 1; 

    % Add isolated z-lines back into the skeleton. 
    skel_eliminated = im_struct.skel_trim.*~mask; 
    skel_eliminated_noisolated = bwareaopen( skel_eliminated, 2 );
    isolated_eliminated = skel_eliminated - skel_eliminated_noisolated; 
    mask( isolated_eliminated == 1 ) = 1;

    % Remove any isolated z-line pixels 
    zlineskel = im_struct.skel_trim.*mask; 
    zlineskel_noisolated = bwareaopen( zlineskel, 2 );
    isolated_accepted= zlineskel - zlineskel_noisolated; 
    mask( isolated_accepted == 1 ) = 0;
     
else
    disp('Parameter Exploration for actin detect threshold...'); 
end 

end

