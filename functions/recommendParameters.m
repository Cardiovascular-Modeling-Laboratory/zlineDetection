% RECOMMENDPARAMETERS - Recommend parameters for images of cardiomyocytes

function [ settings ] = recommendParameters( )


%%%%%%%%%%%%%%%%%%% Coherence Filter Parameteres %%%%%%%%%%%%%%%%%%%%%%%%%%
% Set the sigma of gaussian smoothing before calculation of the image 
% Hessian.
settings.gauss_sigma = 10;

% Set the sigma of the Gaussian smoothing of the Hessian.
settings.orient_sigma = 30; 

% Total Diffusion Time 
settings.diffusion_time = 5; 

%%%%%%%%%%%%%%%%%%%%%% Top Hat Filter Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%

% Radius of the flat disk-shaped structuring element used for the top hat
% filter
settings.tophat_size = 1; 


%%%%%%%%%%%%%%%%%%% Threshold and Clean Parameters %%%%%%%%%%%%%%%%%%%%%%%%

% Size of small objects to be removed using bwareopen
settings.noise_area = 50; 

%%%%%%%%%%%%%%%%%%%% Skeletonization Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%

% Save the minimum branch size to be included in analysis 
settings.branch_size = 2; 

end

