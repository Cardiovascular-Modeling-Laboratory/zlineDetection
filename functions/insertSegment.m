function [image, d] = insertSegment(image, segment, dim1, dim2, disp_fig)

%Get the size of the image
[sze1, sze2 ] = size(image); 

%Get the size of the segment 
[seg1, seg2] = size(segment); 


if dim1+seg1 <= sze1 && dim2+seg2 <= sze2
    %Save the dimensions 
    d(1) = dim1; 
    d(2) = dim2; 
    d(3) = dim1+seg1-1; 
    d(4) = dim2+seg2-1; 
    
    %Save the segment 
    image(d(1):d(3), d(2):d(4)) = segment; 
    
    %Display figure if requested
    if nargin == 5 
        if disp_fig 
            imshow(image); 
        end
    end 

    
else
    disp('Segment will not fit in image.'); 
%     dim1+seg1 <= sze1 && dim2+seg2 <= sze2
    disp(strcat(num2str(dim1+seg1), '>', num2str(sze1))); 
    disp(strcat(num2str(dim2+seg2), '>', num2str(sze2))); 
    d = NaN; 
end

end

