function [] = ...
    diffusionParameterExploration(im_struct, settings)

%Add inputs to path 
addpath('coherencefilter_version5b');
addpath('continuous_zline_detection');

% Variable diffusion parameters 
%Sigma of the Gaussian smoothing of the Hessian.
var_rho = 1:0.5:3.5;
% Total Diffusion Time 
var_diffusiontime = 1:8; 
%Save all of the iterations. 
nit = length(var_rho)*length(var_diffusiontime); 

settings.disk_size = 10; 

%Store the current parameters 
id_explore = zeros(2,nit); 
%Save all of the diffusion matrices
im_anisodiffuse = cell(1,nit); 
%Save all of the skeletons (before masking) 
skel_initial = cell(1,nit); 
%Save all of the skeltons (after masking but before actin filtering); 
skel_masked = cell(1,nit); 
%Save all of the final skeletons
skel_final= cell(1,nit); 
    
%Save_path 
save_path = 'D:\Richard_Zline\2019_03_14\SeedDate2019-02-22_NRVM_ISO_well12_w10_w4mCherry\ParameterExploration'; 
%Start a counter 
n = 1; 
%Loop through all of the diffusion times and rho values 
for d = 1:length(var_diffusiontime)
    for r = 1:length(var_rho)
        %Save current parameters
        id_explore(1,n) = var_rho(r);
        id_explore(2,n) = var_diffusiontime(d); 
        %Save the current diffusion time and rho values 
        settings.Options.rho = var_rho(r); 
        settings.Options.T = var_diffusiontime(d); 
        
        %Create a save_name 
        save_name = strcat(im_struct.im_name, '_DT',...
            num2str(var_diffusiontime(d)), '_rho', ...
            num2str(var_rho(r)*10)); 
        
        %Calculate the first orientation vectors 
        [ im_gray, im_anisodiffuse{1,n}, im_tophat, orientim, reliability ] = ...
            orientInfo( im_struct.im, settings.Options, settings.tophat_size); 
        
        % Use adaptive thresholding to convert to binary image
        [ im_binary, surface_thresh ] = ...
            segmentImage( im_tophat ); 

        % Remove regions that are not reliable (less than 0.5)
        im_binary( reliability < settings.reliability_thresh) = 0; 

        % Remove small objects from binary image.
        im_binaryclean = bwareaopen( im_binary, ...
            settings.noise_area );

        % Use Matlab skeletonization morphological function, convert to a skeleton,
        % fill inside spaces and then conver to a skeleton again.
        skel = bwmorph( im_binaryclean, 'skel', Inf );
        skel = bwmorph( skel, 'fill' );
        skel = bwmorph( skel, 'skel', Inf );

        % Clean up the skeleton 
        skel_initial{1,n} = skel; 
        
        % Save the mask. 
        imwrite( skel_initial{1,n}, fullfile(save_path, ...
            strcat( save_name, '_skelInitial.tif' ) ),...
            'Compression','none');

        %Create initial mask 
        mask = imbinarize(im_anisodiffuse{1,n});
        %Save the masked skeleton 
        skel(~mask) = 0; 
        skel_masked{1,n} = skel; 
    
        % Save the mask. 
        imwrite( skel, fullfile(save_path, ...
            strcat( save_name, '_skelMasked.tif' ) ),...
            'Compression','none');
        %Remove vectors that are not on the skelton 
        orientim(skel_masked{1,n} == 0) = NaN; 
        
        %Filter with actin 
        dp = sqrt(cos(orientim - im_struct.actin_struct.director_matrix).^2); 
        
        %Create mask 
        mask2 = mask; 
        %If dot product is closer to 1, the angles are more parallel and  
        %should be removed
        mask2(dp >= settings.actin_thresh) =false; 
        %If dot product is closer to 0, the angles are more perpendicular 
        %and should be kept
        mask2(dp < settings.actin_thresh) = true;  
        %The NaN postitions should be set equal to 0 (meaning no director 
        %for actin)
        mask2(isnan(mask2)) = false; 

        skel(~mask2) = false; 
        
        skel_final{1,n} = cleanSkel( skel, settings.branch_size );
       
        
        % Save the mask. 
        imwrite( skel_final{1,n}, fullfile(save_path, ...
            strcat( save_name, '_skelActinFiltered.tif' ) ),...
            'Compression','none'); 
        
        
        %Get the positions to plot in the skelton to plot 
        [x,y] = find(skel_final{1,n} == 1);
      
        %Plot skeleton on top of image 
        figure; imshow(mat2gray(im_gray)); 
        hold on; 
        plot(y,x, '.','color','y');
        % Save figure 
        saveas(gcf, fullfile(save_path, ...
            strcat( save_name, '_IM_SKEL.tif' )), ...
            'tiffn');    
        
        %Close all figures
        close all; 
        %Increase counter 
        n = n+1; 
    end
end

% Save the data 
save(fullfile(save_path, strcat(im_struct.im_name,...
    '_DiffusionParameterExploration.mat')), 'im_struct', 'settings',...
    'id_explore','im_anisodiffuse','skel_initial','skel_masked',...
    'skel_final' );

end

