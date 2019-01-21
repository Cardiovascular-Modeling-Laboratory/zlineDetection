function plotOrientationVectors(orientim, im, spacing, color_spec)

    if fix(spacing) ~= spacing
    error('spacing must be an integer');
    end

%     % Linewidth
%     lw = 2;             
    % Length of orientation lines
    len = 0.8*spacing;  

    %Remove zeros and find positions of nonzeros 
    grid_size = size(orientim);
    [X_im,Y_im] =  meshgrid(1:1:grid_size(2),1:1:grid_size(1));
    orient = orientim(orientim~=0);
    x_cor = X_im(orientim~=0);
    y_cor = Y_im(orientim~=0);

    %Subsample the orientation data according to the specified spacing
    xoff = len/2*cos(orient);    
    yoff = len/2*sin(orient);   

    
    % Determine placement of orientation vectors
    x = x_cor-xoff;
    y = y_cor-yoff;      

    %Determine the size of the orientation line 
    u_x = len.*cos(orient);
    u_y = len.*sin(orient);
    
    %Display the image. 
    BW = mat2gray(im);
    imshow(BW); 
    hold on; 

    %Plot the orientation angles 
    quiver(x,y,u_x,u_y,0,'linewidth',2, 'color', color_spec);

    axis equal, axis ij,  hold off

end 