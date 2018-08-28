function [  ] = segmentImage( im )
%This function will segment the image using the Yanowitz-Bruckstein 
%image segmentation with fiber unentanglement

% Convert the image to be grayscale. 
[ gray_im ] = makeGray( im );

% Convert to double precision 
grayDouble = double(ims.gray);

% Apply a Canny edge finder - 1's at the edges, 0's elsewhere
edges = edge( gray_im,'canny' );

% Convert to double precision 
edgesDouble = double(edges);

% Fill in the grey values of the edge pixels in a new image file                      
initThresh = ims.grayDouble.*ims.edgeDouble;

% Perform Yanowitz-Bruckstein surface interpolation to create threshold
% surface from edge gray values
threshSurf = YBiter(ims.initThresh);

% Segment the image. Pixels above threshold surface are white, black
% otherwise
yb_bw = gray_im > threshSurf;

% Convert image to binary image by thresholding
std_bw = im2bw( im );

% Subtract the surface from the gray image and convert the matrix to an
% intensity image 
yb_gray = mat2gray( grayDouble - threshSurf );

end

