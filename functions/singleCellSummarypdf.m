function [] = singleCellSummarypdf(im_struct, settings, oop_struct)

% Create booleans for the type of analysis that was done 
didCZL = settings.tf_CZL; 
didActin = settings.actin_filt; 
didOOPz = settings.tf_OOP; 
didOOPa = didActin & didOOPz; 

% Check to make sure that some kind of analysis was done.
% If not, do not create summary 
didAnalysis = didCZL || didActin || didOOPz; 

if didAnalysis
    % Store the zline image 
    zline_im = mat2gray(im_struct.im); 
    
    % Get size of the z-line image 
    [zdim1,zdim2] = size(zline_im);
    
    % Number of times to repeat zline image 
    rep_num = 1; 
    
    % Determine if there needs to be two or three repeated images 
    if didActin 
        rep_num = rep_num + 1; 
    end 
    if didCZL 
        rep_num = rep_num + 1; 
    end 
    
    % Buffer spacing 
    bf = 10; 
    
    % Initialize a summary image 
    tempd1 = bf*(rep_num+1)+zdim1*rep_num; 
    tempd2 = zdim2+2*bf; 
    sum_template = zeros(tempd1,tempd2); 
    
    % Insert zline image at top of the summary image 
    dim1 = bf; 
    dim2 = bf; 
    [sum_template, celldim1] = ...
        insertSegment(sum_template, zline_im, dim1, dim2, false); 
    
    % Create actin filtering image 
    if didActin
        
        % Store the pre and post filtered skeletons 
        prefilt_skel = im_struct.skel_trim; 
        postfilt_skel = im_struct.skel_final_trimmed; 
        
        % Remove all of the positions in the pre filtered skeleton that
        % also appear in the post filtered skeleton 
        prefilt_skel(postfilt_skel == 1) = 0; 
       
        
        % In the image, the post_fitered skeleton will be red [1,0,0] and
        % the pre_filtered skeleton will be green [0,128,0]
        R = zline_im.*~prefilt_skel.*~postfilt_skel; 
        R( postfilt_skel == 1) = 1; 
        R( prefilt_skel == 1) = 0; 
        G = zline_im.*~prefilt_skel.*~postfilt_skel;  
        G( postfilt_skel == 1) = 0; 
        G( prefilt_skel == 1) = 1; 
        B =zline_im.*~prefilt_skel.*~postfilt_skel;  
        B( postfilt_skel == 1) = 0; 
        B( prefilt_skel == 1) = 0; 
        
        
        % Insert RGB actin filtering image into the summary image 
        dim1 = celldim1(3); 
        dim2 = bf;  
        [sum_templateR, celldim2] = ...
            insertSegment(sum_template, R, dim1, dim2, false); 
        [sum_templateG, ~] = ...
            insertSegment(sum_template, G, dim1, dim2, false); 
        [sum_templateB, ~] = ...
            insertSegment(sum_template, B, dim1, dim2, false); 
    end 
    
    if didCZL
        % Create image to plot continuous z-lines on top of 
        
        if ~didActin
            dim1 = celldim1(3); 
            dim2 = bf;  
        
            [summary_image, ~] = ...
                insertSegment(sum_template, zline_im, dim1, dim2, false);
            
        else
            dim1 = celldim2(3); 
            dim2 = bf;  
            [sum_templateR, ~] = ...
                insertSegment(sum_templateR, zline_im, dim1, dim2, false);
            [sum_templateG, ~] = ...
                insertSegment(sum_templateG, zline_im, dim1, dim2, false);
            [sum_templateB, ~] = ...
                insertSegment(sum_templateB, zline_im, dim1, dim2, false);
            
            % Save summary image in the template 
            summary_image = zeros(tempd1,tempd2,3); 
            summary_image(:,:,1) = sum_templateR; 
            summary_image(:,:,2) = sum_templateG; 
            summary_image(:,:,3) = sum_templateB; 
        end 
        
        % Create orientation vector image 
        angles = insertSegment(zeros(tempd1,tempd2), im_struct.orientim, ...
                    dim1, dim2, true);
        angles(isnan(angles)) = 0; 
        
         
        %Set the dot prodcut threshold 
        dot_product_error = settings.dp_threshold;        
        
        %Find the nonzero positions of this matrix and get their values. 
        [ nonzero_rows, nonzero_cols] = find(angles);
        [ all_angles ] = get_values(nonzero_rows, nonzero_cols, ...
            angles);

        %Find the boundaries of the edges
        [m,n] = size(angles);

        %Find the positions in the orientation matrix of the candidate neighbors
        [ candidate_rows, candidate_cols ] = ...
            neighbor_positions( all_angles , nonzero_rows, nonzero_cols);

        %Correct for boundaries. If any of the neighbors are outside of the
        %dimensions, their positions will be set to NaN 
        [ corrected_rows, corrected_cols ] = ...
            boundary_correction( candidate_rows, candidate_cols, m, n ); 


        %Find the dot product and remove points that are less than the acceptable
        %error. First set any neighbors that are nonzero in the orientation
        %matrix equal to NaN
        [ dp_rows, dp_cols] = compare_angles( dot_product_error,...
            angles, nonzero_rows, nonzero_cols, corrected_rows, corrected_cols);
        
        % Cluster the neighbors 
        [ zline_clusters, cluster_tracker ] = cluster_neighbors( dp_rows, ...
            dp_cols, m, n, false);
        
         % Plot the z-lines images 
        [ distance_storage, rmCount, zline_clusters ] = ...
            calculate_lengths( summary_image, zline_clusters);
        
    end 
    
end 

%     save(fullfile(im_struct.save_path, strcat(im_struct.im_name,...
%        '_OrientationAnalysis.mat')), 'CZL_struct', '-append');
end

