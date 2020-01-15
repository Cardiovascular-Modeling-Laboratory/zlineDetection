function [c, bins] = plotSarcLengthIM(im,x_0,y_0,x_np,y_np,d_micron)

% Display the figure
figure; imshow(im); hold on; 

% Get the number of coordinates
n = length(x_0); 

%Chose image based on scale 
c = jet; 
nbins = size(c,1); 
bins = linspace(0,max(d_micron),nbins); 
% Create a colorscale 
for k = 1:n
    %Set binned equal to false 
    binned = false; 
    % Only plot if d_micron is greater than 0 
    if d_micron(k) > 0 
        %Start a counter for the bin 
        b = 1; 
        %Check which bin the value is in 
        while ~binned
            if d_micron(k) > bins(b) && d_micron(k) <= bins(b+1)
                % Plot with the color of the bin 
                plot([x_0(k),x_np(k)],[y_0(k),y_np(k)],'color',c(b,:)); 
                %Set binned to true
                binned = true; 
            else
                b = b+1; 
            end 
        end 
        
    end 
end 
end

