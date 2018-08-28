% Copyright (C) 2016 Nils Persson 

function ims = YBSimpleSeg(ims)

%YBSeg Yanowitz-Bruckstein image segmentation with fiber unentanglement
%   SP is the structure path
%   File is the file path from current active dir
%   Dim is the image dimension in nm

ims.edge = edge(ims.gray,'canny');         % Apply a Canny edge finder - 1's at the edges, 0's elsewhere
ims.grayDouble = double(ims.gray);                     % Turn the grey image into double prec.
ims.edgeDouble = double(ims.edge);                     % Turn the edge image into double prec.
ims.initThresh = ims.grayDouble.*ims.edgeDouble;                        % Fill in the grey values of the edge pixels in a new image file                      

ims.threshSurf = YBiter(ims.initThresh);                    % Perform Yanowitz-Bruckstein surface interpolation to create threshold surface from edge gray values

ims.yb_bw = ims.gray>ims.threshSurf;                          % Segment the image; pixels above threshold surface are white, if not, black
ims.std_bw = im2bw(ims.img);
ims.yb_gray = mat2gray(ims.grayDouble-ims.threshSurf);

end