function [ distance_storage, rmCount, zline_clusters] = ...
    calculate_lengths( processed_image, zline_clusters)
%This function calculates the length and plotted the sarcomere 
figure; 
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
    
    %Additionally, if there are less than three detected edges, remove the
    %boundary
    elseif size(boundary,1) < 3
        exclude = true; 
        zline_clusters{k} = NaN; 
    %If the boundary is not empty or NaN calculate the distance  
    else
        
        %Calculate the distance between each boundary and its next neighbor
        [ between_coordinates ] = ...
            coordinate_distances( boundary(:,1), boundary(:,2) ); 

        %Find the length from one coordinate to the closest one. 
        %Inialize coordinate length 
        coord_length = 0; 
        for h = 2:length( boundary(:,1) )
            coord_length = coord_length +  between_coordinates(h, h-1); 
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
        plot( boundary(:,2), boundary(:,1) , '-', 'LineWidth', 2);      
    
    end
    
end

end
