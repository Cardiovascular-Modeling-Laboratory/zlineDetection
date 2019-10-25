function [im_struct] = reanalyzeManualMask(im_struct,settings,...
    manual_background_removal)


% Store the save path 
[save_path, ~, ~] = fileparts(manual_background_removal.savefullname); 

% Save the user input mask 
mask = manual_background_removal.manual_mask; 

%Save the initital skeleton, with the manually masked regions removed. 
temp_skel = im_struct.skel_initial; 
temp_skel(mask == 0) = 0; 
im_struct.skel = temp_skel; 

% Clean up the skeleton 
im_struct.skel_trim = cleanSkel( im_struct.skel, settings.branch_size );

if settings.disp_skel
    % Open a figure and display the image 
    figure; imshow( im_struct.skel_trim ); 
    
    % Save the figure. 
    imwrite( im_struct.skel, fullfile(save_path, ...
        strcat( im_struct.im_name, '_SkeletonInitial_backRMV.tif' ) ),...
        'Compression','none');
    
end

%%%%%%%%%%%%%%%%%%%%%% Remove false z-lines %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% If the image should not be filtered with actin, set the final mask equal
% to the trimmed skeleton and save 

if ~settings.actin_filt
    % Save the mask 
    im_struct.mask = mask; 
    
    % Set the final skeleton equal to the trimmed skeleton
    im_struct.skel_final = im_struct.skel_trim; 
       
else
    % Store the image struct 
    actin_struct = im_struct.actin_struct; 

    %Take the dot product sqrt(cos(th1 - th2)^2);
    im_struct.dp = ...
        sqrt(cos(im_struct.noskel_orientim - ...
        actin_struct.director_matrix).^2); 
    
    % Initialize the mask 
    mask = zeros(size(im_struct.dp)); 
    
    %If dot product is closer to 1, the angles are more parallel and should 
    %be removed
    mask(im_struct.dp >= settings.actin_thresh) = 0; 
    %If dot product is closer to 0, the angles are more perpendicular and
    %should be kept
    mask(im_struct.dp < settings.actin_thresh) = 1; 

    %The NaN postitions should be set equal to 1 (meaning no director for
    %actin)
    mask(isnan(mask)) = 1; 
    
    % Store the temporary skeleton 
    temp_skel = im_struct.skel_trim; 

    % Add isolated z-lines back into the skeleton. 
    skel_eliminated = temp_skel.*~mask; 
    skel_eliminated_noisolated = bwareaopen( skel_eliminated, 2 );
    isolated_eliminated = skel_eliminated - skel_eliminated_noisolated; 
    mask( isolated_eliminated == 1 ) = 1;

    % Remove any isolated z-line pixels 
    zlineskel = temp_skel.*mask; 
    zlineskel_noisolated = bwareaopen( zlineskel, 2 );
    isolated_accepted= zlineskel - zlineskel_noisolated; 
    mask( isolated_accepted == 1 ) = 0;
    
    % Store the mask 
    im_struct.mask = mask; 
    
    % Multiply the mask by the trimmed skeleton to get the final skeleton.
    % Trim again to get 
    im_struct.skel_final =  im_struct.skel_trim;
    im_struct.skel_final(im_struct.mask == 0) = 0; 
    
    
    im_struct.skel_final_trimmed = cleanSkel( im_struct.skel_final, ...
        settings.branch_size );
end 

% If requested by the user, save the final actin mask 
if settings.disp_actin
    imwrite( im_struct.mask, fullfile(save_path, ...
        strcat( im_struct.im_name, '_Mask_backRMV.tif' ) ),...
        'Compression','none');
end

% Save the final skeleton. 
imwrite( im_struct.skel_final, fullfile(save_path, ...
    strcat( im_struct.im_name, '_SkeletonMasked_backRMV.tif' ) ),...
    'Compression','none');

%%%%%%%%%%%%%%%%% Report Final Orentation Vectors %%%%%%%%%%%%%%%%%%%%%%%%%

% Save the unfiltered orienation angles 
im_struct.noactinfilt_orientim = im_struct.noskel_orientim; 
im_struct.noactinfilt_orientim(~im_struct.skel_trim) = NaN; 

% Remove regions that were not part of the binary skeleton
im_struct.orientim(~im_struct.skel_final) = NaN; 

% Post filtering skeleton 
post_filt = im_struct.skel_final;
post_filt = post_filt(:);
post_filt(post_filt == 0) = []; 
% Pre filtering skeleton 
pre_filt = im_struct.skel_trim; 
pre_filt = pre_filt(:); 
pre_filt(pre_filt == 0) = []; 
% Calculate the non-sarcomeric alpha actinin 
% number of pixles eliminated / # total # of pixles positive for alpha
% actinin 
im_struct.nonzlinefrac = (length(pre_filt) - length(post_filt))/ ...
    length(pre_filt);
im_struct.zlinefrac = 1 - im_struct.nonzlinefrac; 

% Display that you're saving the data
disp('Saving Data Orientation Analysis Data...'); 

% Save the data 
save(manual_background_removal.savefullname,...
    'im_struct', '-append');

end

