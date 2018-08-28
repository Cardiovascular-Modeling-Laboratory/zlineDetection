% Copyright (C) 2016 Nils Persson

function ims = filterImage( ims, settings )

% Save the Options struct from settings 
Options = settings.Options;

%%%%%%%%%%%%%%%%%%%%%%%% Run Coherence Filter %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Start a wait bar 
hwait = waitbar(0,'Diffusion Filter...');

% Inputs are the grayscale image and the Options struct from settings 
[ ims.CEDgray, ims.v1x, ims.v1y ] = ...
    CoherenceFilter( ims.gray, Options );

% Conver the matrix to be an intensity image 
ims.CEDgray = mat2gray(ims.CEDgray);

% If the user would like to display the filtered image, display it
if settings.CEDFig
    figure; imshow(ims.CEDgray)
end

%%%%%%%%%%%%%%%%%%%%%%%%% Run Top Hat Filter %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Update waitbar 
waitbar(0.5,hwait,'Top Hat Filter...');

%Compute the top hat filter using the disk structuring element with the
%threshold defined by the user input tophat filter 
ims.CEDtophat = ...
    imadjust( imtophat( ims.CEDgray, strel( 'disk', settings.thpix ) ) );

% If the user would like to display the filtered image, display it
if settings.topHatFig
    figure; imshow(ims.CEDtophat); 
end


%%%%%%%%%%%%%%%%%%%%%%%%% Threshold and Clean %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
% Update waitbar 
waitbar(0.7,hwait,'Threshold and Clean...');

% Use adaptive thresholding - deleted this function so need to make sure
% that the new version - segmentImage does the same thing. 
ims.CEDbw = YBSimpleSeg(ims.CEDtophat);

% If the user would like to display the filtered image, display it
if settings.threshFig
    figure; imshow(ims.CEDbw)
end

% Remove small objects from binary image.
ims.CEDclean = bwareaopen(ims.CEDbw,settings.noisepix);

% If the user would like to display the filtered image, display it
if settings.noiseRemFig
    figure; imshow(ims.CEDclean)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Skeletonize %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Update waitbar 
waitbar(0.8,hwait,'Skeletonization...');

% Use Matlab skeletonization morphological function 
ims.skel = bwmorph(ims.CEDclean,'skel',Inf);

if settings.skelFig
    figure; imshow(ims.skel)
end

%Clean up the skeleton 
ims.skelTrim = cleanSkel(ims.skel,settings.maxBranchSize);

% If the user would like to display the filtered image, display it
if settings.skelTrimFig

    figure; imshow(ims.skelTrim)

end


%%%%%%%%%%%%%%%%%%%%%% Remove false z-lines %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create a mask to remove false z-lines 

% Save the mask under the image struct 

%%%%%%%%%%%%%%%%%%%%%%% Generate Angles Map %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Update waitbar 
waitbar(0.9,hwait,'Recovering Orientations...');

% Change the
Options.T = 1;

%Compute the orientation vectors at each position  
[~, ims.v1xn, ims.v1yn] = CoherenceFilter(ims.skelTrim,Options);

% Generate Angle Map by getting new angles from CED
ims.AngMap = atand(ims.v1xn./-ims.v1yn);


close(hwait)

end
