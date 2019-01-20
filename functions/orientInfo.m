% ORIENT ANALYSIS - this function will report the orientation information
% of an image 
% Usage:
%   = orientInfo(); 
%
% Arguments:
%       im          - image matrix 
%       settings    - struct contianing the following information:
% Returns:
%       settings    - structural array that contains the following
%                       parameters from the GUI:
function [ grayIM, CEDgray, CEDtophat, orientim, reliability ] = ...
    orientInfo( im, save_name, save_path, settings)

%%%%%%%%%%%%%%%%%%%%%%%%%% Initalize Image %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Save the Options struct from settings 
Options = settings.Options;

%Create a grayscale version of the image (if it was not already in
%grayscale) 
[ grayIM ] = makeGray( im ); 

%%%%%%%%%%%%%%%%%%%%%%%% Run Diffusion Filter %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Coherence-Enhancing Anisotropic Diffusion Filtering, which enhances
% contrast and calculates the orientation vectors for later usage. 
% The parameters (supplied by the GUI) are (1) Orientation Smoothing and
% (2) Diffusion Time 

% Inputs are the grayscale image and the Options struct from settings. 
% The output is the diffusion filtered image and eigenvectors - Not sure
% why this is important, but... 
[ CEDgray, ~, ~ ] = CoherenceFilter( grayIM, Options );

% Clear the command line 
clc; 

% Convert the matrix to be an intensity image 
CEDgray = mat2gray( CEDgray );

% If the user would like to display the filtered image, display it
if settings.disp_df
    % Open a figure and display the image
    figure; imshow( CEDgray );
    
    % Save the figure. 
    imwrite( CEDgray, fullfile(save_path, ...
        strcat( save_name, '_DiffusionFiltered.tif' ) ),...
        'Compression','none');

end

%%%%%%%%%%%%%%%%%%%%%%%%% Run Top Hat Filter %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Top Hat Filtering...');

%Compute the top hat filter using the disk structuring element with the
%threshold defined by the user input tophat filter. It then adjusts the
%image so that 1% of data is saturated at low and high intensities of the
%image 
CEDtophat = imadjust( imtophat( CEDgray, strel( 'disk', ...
    settings.tophat_size ) ) );

% If the user would like to display the filtered image, display it
if settings.disp_tophat
    % Open a figure and display the image
    figure; imshow( CEDtophat ); 
    
    % Save the figure. 
    imwrite( CEDtophat, fullfile(save_path, ...
        strcat( save_name, '_TopHatFiltered.tif' ) ),...
        'Compression','none');
    
end

%%%%%%%%%%%%%%%%%% Calculate Orientation Vectors %%%%%%%%%%%%%%%%%%%%%%%%%%

% Calculate orientation vectors
[orientim, reliability] = ...
    ridgeorient(CEDtophat, ...
    Options.sigma, Options.rho, Options.rho);

end

