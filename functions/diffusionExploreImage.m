% diffusionExploreAnalyzeImage - Main function to create binary skeleton and compute
% orientation vectors of an image. It will load an image and convert it 
% to grayscale and then perform (1) coherence-enhancing anisotropic  
% diffusion filtering (2) top hat filetering (3) convert to binary using
% adaptive thresholding (3) skeletonize (4) prune automatically (5) prune
% manually. 
%
% Usage:
%   [ im_struct ] = diffusionExploreAnalyzeImage( filenames, settings );
%
% Arguments:
%   filename    - A string containing the path, filename, and extension
%                   of the image 
%   settings    - A structure array that contains the following
%                   information (from the GUI) 
% 
% Returns:
%   im_struct   - A structural array containing the following
%                   information
%
% Dependencies: 
%   MATLAB Version >= 9.5 
%   Image Processing Toolbox Version 10.3
%   coherencefilter_version5b   Dirk-Jan Kroon 2010, University of Twente
%   zlineDetection Functions: 
%       YBiter.m
%       addDirectory.m
%       analyzeImage.m
%       calculate_OOP.m
%       cleanSkel.m
%       findNearBranch.m
%       makeGray.m
%       orientInfo.m
%       ridgeorient.m
%       segmentImage.m
%       storeImageInfo.m
%       actin_filtering/actinDetection.m
%       actin_filtering/filterWithActin.m
%       actin_filtering/gridDirector.m
%       actin_filtering/plotOrientationVectors.m
%
%
% Tessa Morris
% Advisor: Anna Grosberg, Department of Biomedical Engineering 
% Cardiovascular Modeling Laboratory 
% University of California, Irvine


function [ im_struct ] = diffusionExploreImage( filenames, settings )

%%%%%%%%%%%%%%%%%%%%%%%% Initalize Image Info %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Store the image information
[ im_struct ] = storeImageInfo( filenames.zline );

% Create a new folder in the image directory with the same name as the 
% image file if it does not exist. If it does exist, add numbers until it
% no longer exists and then create it 
create = true; 
new_subfolder = ...
    addDirectory( im_struct.im_path,...
    strcat(im_struct.im_name,'_diffusionExplore'), create ); 

% Save the name of the new path 
im_struct.save_path = fullfile(im_struct.im_path, new_subfolder); 

%Create a grayscale version of the image (if it was not already in
%grayscale) 
[ im_struct.gray ] = makeGray( im_struct.im ); 

% Get the size of the image
[d1, d2] = size(im_struct.im); 

%%%%%%%%%%%%%%%%%%% Initalize Exploration Parameters %%%%%%%%%%%%%%%%%%%%%%
% Get the range of rho values 
var_rho = ...
    settings.diffusion_explore_parameters.rho_min:...
    settings.diffusion_explore_parameters.rho_step:...
    settings.diffusion_explore_parameters.rho_max; 

% Get the range of diffusion times 
var_diffusiontime =  ...
    settings.diffusion_explore_parameters.difftime_min:...
    settings.diffusion_explore_parameters.difftime_step:...
    settings.diffusion_explore_parameters.difftime_max; 

% Get the number of variable parameters 
pn = length(var_rho); 
dtn = length(var_diffusiontime); 

% Total number of iterations 
tot = pn*dtn; 

% Store iteration number 
it = 0; 

% Create a matrix to store parameters associated with each analyzed image. 
diffusion_parameters = zeros(2,tot); 

% Create matrices to store the following analyzes images 
im_anisodiffuse = zeros(d1, d2, tot);
im_tophat = zeros(d1, d2, tot);
im_binary = zeros(d1, d2, tot);
surface_thresh = zeros(d1, d2, tot);
skel_initial = zeros(d1, d2, tot);
% skel_final = zeros(d1, d2, tot);


%%%%%%%%%%%%%% Analyze the Image Using the Parameters %%%%%%%%%%%%%%%%%%%%%
for t = var_diffusiontime
    
    %Set the diffusion time 
    settings.Options.T = t; 
                
    for p = var_rho 
        
        %Set the rho
        settings.Options.rho = p; 
        
        % Increate the counter 
        it = it + 1; 
        
        % Store the current diffusion parameters 
        diffusion_parameters(1,it) = t; 
        diffusion_parameters(2,it) = p; 

        % Save variables as strings 
        p_string = num2str(p); 
        dt_string = num2str(t); 

        % Replace '.' with 'p' for decimals
        dt_string = strrep(dt_string, '.', 'p'); 
        p_string = strrep(p_string, '.', 'p'); 
        
        % Save a string to append names with 
        param_string = strcat('DT', dt_string,'_rho', p_string); 

        % Diffusion filter the image 
        [ CEDgray, ~, ~ ] = ...
            CoherenceFilter( im_struct.gray, settings.Options );
        
        % Convert matrix to be an intensity image and store in the image
        % struct 
        im_anisodiffuse(:,:,it) = mat2gray( CEDgray );

        % Save the anisotropic diffusion filtered image 
        imwrite( im_anisodiffuse(:,:,it), fullfile(im_struct.save_path, ...
            strcat( im_struct.im_name, param_string,...
            '_DiffusionFiltered.tif' ) ), 'Compression','none');
        
        % Run Top Hat Filter
        im_tophat(:,:,it) = imadjust( imtophat( im_anisodiffuse(:,:,it), ...
            strel( 'disk', settings.tophat_size ) ) );
        
        % Save the top hat filtered image 
        imwrite( im_tophat(:,:,it), fullfile(im_struct.save_path, ...
            strcat( im_struct.im_name, param_string,...
            '_TopHatFiltered.tif' ) ), 'Compression','none');
        
        % Use adaptive thresholding to convert to binary image
        [ im_binary(:,:,it), surface_thresh(:,:,it) ] = ...
            segmentImage( im_tophat(:,:,it) ); 

        % Save binary image
        imwrite( im_binary(:,:,it), fullfile(im_struct.save_path, ...
            strcat( im_struct.im_name, param_string,...
            '_Binariazed.tif' ) ), 'Compression','none');
        % Save surface threshold
        imwrite( im_tophat(:,:,it), fullfile(im_struct.save_path, ...
            strcat( im_struct.im_name, param_string,...
            '_Surface.tif' ) ), 'Compression','none');
        
        % Remove small objects from binary image.
        im_binaryclean = bwareaopen( im_binary(:,:,it),...
            settings.noise_area );
        
        %Convert to skeleton and save 
        skel = bwmorph( im_binaryclean, 'skel', Inf );
        skel = bwmorph( skel, 'fill' );
        skel = bwmorph( skel, 'skel', Inf );
        
        % Clean up the skeleton 
        skel_initial(:,:,it) = cleanSkel( skel, settings.branch_size );
    
        % Save the figure. 
        imwrite( skel_initial(:,:,it), fullfile(im_struct.save_path, ...
            strcat( im_struct.im_name, param_string,...
            '_SkeletonInitial.tif' ) ), 'Compression','none');
    end 

end 

% Save all of the matrices in the image struct 
diffexp_struct = struct(); 
diffexp_struct.im_anisodiffuse = im_anisodiffuse;
diffexp_struct.im_tophat = im_tophat;
diffexp_struct.im_binary = im_binary;
diffexp_struct.surface_thresh = surface_thresh;
diffexp_struct.skel_initial = skel_initial;

% Save the data 
save(fullfile(im_struct.save_path, strcat(im_struct.im_name,...
    '_DiffusionExplore_OrientationAnalysis.mat')), 'im_struct', ...
    'diffexp_struct','settings');

end
