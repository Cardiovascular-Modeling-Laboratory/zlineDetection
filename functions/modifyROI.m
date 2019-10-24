% select_ROI - This function will be used to selct regions of the image 
% that should either be included or not inlcuded in analysis 
% 
% Arguments:
%   im          - grayscale image 
%   binim_skel  - binary skeleton 
%   include     - boolean statement: If include is true then the mask 
%                   will only include the selected regions. If include is 
%                   false, the mask will exclude the selected regions. 
% 
% Returns:    
%   mask        - matrix that is 0 where the user doesn't want to include
%                   data and 1 where the user des want to include data. 
% 
% Tessa Morris 
% The Edwards Lifesciences Center for Advanced Cardiovascular Technology
% 2418 Engineering Hall
% University of California, Irvine
% Irvine, CA  92697-2700

function [ mask ] = modifyROI( im, binim_skel, include, background)

if nargin < 4
    background = zeros(size(binim_skel)); 
end 

%Create a mask of all zeros. Any position that is zero at the end of 
%the analysis will be removed from analysis 
if include 
    mask = zeros(size(binim_skel)); 
else 
    mask = ones(size(binim_skel)); 
end

index = 0;
hold on
while index < 1
    
    if include 
        disp(['Select ROI to include in further analysis'...
            '(double-click to close the ROI)']);
    else
        disp(['Select ROI to exclude from further analysis'...
            '(double-click to close the ROI)']);
    end 
    
%     % Generate the colormask 
%     colorMask = zeros(size(mask,1), size(mask,2), 3);
%     color = [219, 3, 252]./255;
%     for h = 1:3
%         colorMask(:,:,h) = color(h).*~background;
%     end
% 
    %Plot the skeleton on top of the image
    labeled_im  = labelSkeleton( im, binim_skel ); 
    hold on; 
%     himage = imshow(colorMask);
%     himage.AlphaData = 0.2;
    
    %Select ROI and overlay the mask 
    BW = roipoly(labeled_im);

    
    % Ask the user if they'd like to remove parts of the background  
    answer = questdlg('Would you like to select the ROI?', ...
	'ROI','Accept ROI','Reject ROI','Accept ROI');

    % Handle response
    switch answer
        case 'Accept ROI'
            if include 
                %Add the selected ROI to the mask 
                mask = mask + BW; 
                %Set any region in the mask that is greater than one equal to 1
                mask(mask > 1) = 1; 
            else 
                %Reverse the ROI mask 
                BW2 = ~BW; 
                %Multiply the reversed ROI mask times the mask to set regions equal
                %to zero 
                mask = bsxfun(@times, BW2, mask); 
                %Multiply the reverse ROI mask times the binary skeleton so that it
                %will be removed for the next iteration
                binim_skel = bsxfun(@times, binim_skel, mask);
            end 
    end
   
    
    % Ask the user if they'd like to remove parts of the background  
    answer = questdlg('Would you like to select another ROI?', ...
	'Another ROI','Yes','No','Yes');
    switch answer
        case 'Yes'
            disp('Select another ROI...') 
        otherwise 
           index = 1;
           clc; 
    end
end


end

