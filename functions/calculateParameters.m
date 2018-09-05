function [ settings ] = calculateParameters( )
%Recommend parameters for the image based on fiber width.

% Coherence Filter Parameters
%Gaussian Smoothing
settings.gauss_sigma = 10;
%Orientation Smoothing
settings.orient_sigma = 30; 

% Top Hat Filter Parameters
settings.tp_size = 30; 

% Thresholding Parameters
settings.global_thresh = 0.3; 


% These parameters can have some biological basis
% Noise Removal Parameters
settings.noise_area = 1500; 

% Skeletonization Parameters
settings.branch_size = 80; 

%Diffusion Time 
settings.diffusion_time = 5; 

end

