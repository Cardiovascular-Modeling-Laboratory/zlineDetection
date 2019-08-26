function [ distance_storage, rmCount, zline_clusters] = ...
    calculate_lengths( processed_image, zline_clusters, specialVis)
%This function calculates the length and plotted the sarcomere 

% Add a case where a figure isn't opened (for visualization and summary
% purposes) 
if nargin < 3
    specialVis = false; 
end 

if ~specialVis 
    figure; 
    lin_val = 2; 
else
    lin_val = 0.5; 
end 
imshow(processed_image);
hold on;

%Create a storage for the calculated distances. 
distance_storage = zeros(length(zline_clusters),1); 

%Count the number of boundaries that are removed due to begin NaN 
rmCount = 0; 

for k=1:length(zline_clusters)  
    %Set exclude equal to false 
    exclude = false; 
        
    %Initialize the variable boundary to store the contents of the kth
    %entry in cell array B. 
    boundary = zline_clusters{k};
    
    %Check if the boundary is empty, if so do not include otherwise,
    %continue with analysis 
    if isnan(boundary)
        exclude = true; 
   
    %If the boundary is not empty or NaN calculate the distance  
    else
        % Check to make sure there are more than two boundaries 
        if length(boundary) > 2
            %Calculate the distance between each boundary and its next neighbor
            [ between_coordinates ] = ...
                coordinate_distances( boundary(:,1), boundary(:,2) ); 

            %Find the length from one coordinate to the closest one. 
            %Inialize coordinate length 
            coord_length = 0; 
            for h = 2:length( boundary(:,1) )
                coord_length = coord_length +  between_coordinates(h, h-1); 
            end
        else
            exclude = true; 
        end 
                
    end 
   
    if exclude
        %Save the distance and coordinates as NaN.
        distance_storage(k) = NaN; 
        
        %Increase count
        rmCount = rmCount + 1; 
    else 
        
        %Save distance
        distance_storage(k) = coord_length; 
        
        %Plot boundaries (large LineWidth)
        plot( boundary(:,2), boundary(:,1) , '-', 'LineWidth', lin_val);      
    
    end
    
end

end

