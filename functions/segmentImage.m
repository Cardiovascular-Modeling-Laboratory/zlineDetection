% SEGMENTIMAGE - adaptive thresholding to remove background from image 
%
% This function will segment the image using the Yanowitz-Bruckstein 
% image segmentation with fiber unentanglement.
% The gray values of these edge pixels are fixed in the initial threshold 
% surface and the remaining surface is obtained by solving the Laplace 
% equation through successive over-relaxation
%
%
% Usage:
%  [ yb_bw, std_bw, yb_gray ] = segmentImage( im ); 
%
% Arguments:
%       im          - Image to be segmented. For best results, this image
%                       should have been filtered using diffusion & top hat
%                       filtering
% Returns:
%       seg_im      - Segmented image where pixels above the threshold
%                       surface are white, back otherwise
%       surface_thresh - Threshold surface 
% 
% Suggested parameters: None
% 
% See also: YBiter

function [ seg_im, surface_thresh ] = segmentImage( im )

% Convert the image to be grayscale and conver to double precision 
[ gray_im ] = double( makeGray( im ) );

% Apply a Canny edge finder - 1's at the edges, 0's elsewhere and convert
% to double precision 
edges = double ( edge( gray_im,'canny' ) );

% Fill in the grey values of the edge pixels in a new image file                      
% edge_intensities = gray_im.*edges;
initial_thresh = gray_im.*edges;

% % Set all of the zeros equal to NaN.                     
% edge_intensitiesNAN = edge_intensities;
% edge_intensitiesNAN(edge_intensitiesNAN == 0) = NaN;
% 
% % Create an image that is the average of the edge pixels. 
% comp(1) = round( size(gray_im,1) / 10 ); 
% comp(2) = round( size(gray_im,2) / 10 ); 
% avgIM = averageImage( edge_intensitiesNAN, comp ); 
% 
% % Dilate the edges using a structuring element
% disk_element = strel( 'disk', 3*settings.tophat_size );
% dilated_edges = imdilate( edges, disk_element );
% 
% % Multiply the dilated edges times the averaged image 
% initial_thresh = dilated_edges.*avgIM; 
% % Add in intensities of edges
% initial_thresh(edges == 1) = 0; 
% initial_thresh = initial_thresh + edge_intensities; 

% Set the value of the dilated edges equal to the average 

% Perform Yanowitz-Bruckstein surface interpolation to create threshold
% surface from edge gray values
% surface_thresh = YBiter( initial_thresh );
% Set the number of iterations 
maxiter = 40; 
surface_thresh = YBiter( initial_thresh, maxiter ); 

% Segment the image. Pixels above threshold surface are white, black
% otherwise
seg_im = gray_im > surface_thresh;
% seg_im = seg_im.*dilated_edges; 

end

