function [ mask ] = select_ROI( im, binim_skel, include )
%This function will be used to seelct regions of the image that should be
%included in analysis 
%If include is true then the mask will only include the selected regions 
%If include is false, the mask will exclude the selected regions 

%Create a mask of all zeros. Any position that is zero at the end of 
%the analysis will be removed from analysis 
if include 
    mask = zeros(size(binim_skel)); 
else 
    mask = ones(size(binim_skel)); 
end 

index = 0;
hold on
while index < 1;
    
    if include 
        disp(['Select ROI to include in further analysis'...
            '(double-click to close the ROI)']);
    else
        disp(['Select ROI to exclude from further analysis'...
            '(double-click to close the ROI)']);
    end 
    
    %Plot the skeleton on top of the image
    labeled_im  = labelSkeleton( im, binim_skel ); 
    
    %Select ROI and overlay the mask 
    BW = roipoly(labeled_im);

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
    
    %Ask the user if they would like to exclude another ROI.
    b = input('Select another ROI to include? (yes = 0, no = 1): ');
    if b == 0
       disp('Image accepted' )
    else
       disp('Select another ROI...')
       index = 1;
    end
    
end


end

