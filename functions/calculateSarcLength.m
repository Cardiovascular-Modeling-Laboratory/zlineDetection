% calculateSarcLength - function to calculate the sarcomere length in an
% image
%
% Arguments:
%   orientim_perp       - Matrix (size of image) of orientation vectors
%                           perpendicular to z-lines. Pixels without
%                           z-lines should be 0, orientation angles should
%                           be in radians
%   scale               - Scale of the image (pixels per micrometer)
%   Dist_Max_Micron     - Maximum distance between neighboring sarcomeres 
%                           in micrometers (suggested 10 microns)
%   Dist_Min_Micron     - Minimum distance between neighboring sarcomeres 
%                           in micrometers (suggested 0.1 microns)
%   Delta_Angle_deg     - Myofibril possible bending angle 
%                           (suggested 20 degrees)
% 
% Returns:
%   d_mean              - Average distance in microns
%   d_stdev             - Standard deviation of distance in microns
%   d_micron            - Distances in microns
%   d_micron_NZ         - Distances in mirocns with no zero values 
%   d                   - Distances in pixels 
%   x_0                 - X coordinate of nonzero indices
%   y_0                 - Y coordinate of nonzero indices
%   x_np                - X coordinate of the nearest positive pixel along 
%                           the direction theta_0
%   y_np                - Y coordinate of the nearest positive pixel along 
%                           the direction theta_0
%   d_micron_NZ         - Non-zero distances
%
% Suggested parameters: 
%   Dist_Max_Micron     - 10 microns
%   Dist_Min_Micron     - 0.1 microns
%   Delta_Angle_deg     - 20 degrees

function [d_mean, d_stdev, d_micron, d_micron_NZ, d, x_0, y_0, x_np, ...
    y_np] = calculateSarcLength(orientim_perp, scale, Dist_Max_Micron, ...
    Dist_Min_Micron, Delta_Angle_deg)
    % Set parameters if not supplied     
    if nargin < 5
        Delta_Angle_deg = 20;
        if nargin < 4
            Dist_Min_Micron = 0.1; 
            if nargin < 3
                Dist_Max_Micron = 10; 
                if nargin < 2
                    scale = 6.22; 
                end 
            end 
        end 
         
    end 
    
    %Convert parameters from pixels to microns 
    d_max = Dist_Max_Micron*scale;
    d_min = Dist_Min_Micron*scale;
    if d_min < 1
        d_min = 1; 
    end
    Delta_theta = deg2rad(Delta_Angle_deg);

    %The number of pixels in the y and x directions in the image
    [N_y, N_x] =  size(orientim_perp);
    
    %Make the range vectors for x_0 and y_0
    x_0_vec = 1:1:N_x;
    y_0_vec = (1:1:N_y)';
    %Make a matrix populated with coordinates
    x_0_mat = repmat(x_0_vec,N_y,1);
    y_0_mat = repmat(y_0_vec,1,N_x);
    
    %Linear vectors that have all the thetas and coordinates
    theta_full_lin = orientim_perp(:);
    x_0_full_lin = x_0_mat(:);
    y_0_full_lin = y_0_mat(:);
    
    %Find the non-zero indicies
    Non_Zero_Ind = find(orientim_perp);
    
    %Create non-zero theta and coorinates
    theta_temp = orientim_perp(Non_Zero_Ind);
    theta = asin(sin(theta_temp)); %This will ensure taht the "non-zero" theta's are moved to be between -\pi and \pi
    x_0 = x_0_mat(Non_Zero_Ind);
    y_0 = y_0_mat(Non_Zero_Ind);
    N_PosPix = length(theta);
    
    %Create the bounds for delta_x and delta_y
    Delta_x_min = ceil(d_max*cos((pi/2)+Delta_theta));
    Delta_x_max = ceil(d_max);
    Delta_y_min = ceil(-d_max);
    Delta_y_max = ceil(d_max);
    %Create the range vectors for Delta_x and Delta_y
    Delta_x_vec = Delta_x_min:1:Delta_x_max;
    Delta_y_vec = (Delta_y_min:1:Delta_y_max)';
    %Find the number of points in both directions
    N_dx = length(Delta_x_vec);
    N_dy = length(Delta_y_vec);
    %Create the matricies populated with the Delta coordinates
    Delta_x_mat = repmat(Delta_x_vec,N_dy,1);
    Delta_y_mat = repmat(Delta_y_vec,1,N_dx);
    %Linear vectors with delta coordinates
    Delta_x = Delta_x_mat(:);
    Delta_y = Delta_y_mat(:);
    %Calculate the corresponding polar coordinates
    r = sqrt((Delta_x.^2) + (Delta_y.^2));
    alpha = atan2(Delta_y,Delta_x);
    
    %Initilize the distance matrix and nearest neighbor coordinates
    d = (N_x+N_y).*zeros(size(theta));
    x_np = zeros(size(theta));
    y_np = zeros(size(theta));
    %Cycle through the different pixels (hopefully we'll edit this away to make the code more efficient)
    for pix = 1:N_PosPix
        %Find the minimum and maximum angle
        Angle_min = theta(pix) - Delta_theta;
        Angle_max = theta(pix) + Delta_theta;
        %Identify the delta indicies that correspond to the angles within
        %the sector
        Sector_Ang_Included = (alpha > Angle_min.*ones(size(alpha))).*(alpha < Angle_max.*ones(size(alpha)));
        %Identify the delta indicies that correspond to both angles and
        %radial positions within the sector
        Sector_Included = ((r.*Sector_Ang_Included)< d_max.*ones(size(r))).*((r.*Sector_Ang_Included) > d_min.*ones(size(r)));
        %Find the delta coordinates that are included
        Delta_x_in = Delta_x(find(Sector_Included));
        Delta_y_in = Delta_y(find(Sector_Included));
        %Find the x,y for these included coordiantes and check that they
        %are inside the image
        x_temp = x_0(pix).*ones(size(Delta_x)) + Delta_x;
        y_temp = y_0(pix).*ones(size(Delta_y)) + Delta_y;
        Ind_x_inIm = ((x_temp>0).*(x_temp<=N_x));
        Ind_y_inIm = ((y_temp>0).*(y_temp<=N_y));
        Ind_inIm = Ind_x_inIm.*Ind_y_inIm;
        SecIm_Included = Ind_inIm.*Sector_Included;
        x = x_temp(find(SecIm_Included));
        y = y_temp(find(SecIm_Included));
        %Write the distance for these coordinates
        Dist_all = r(find(SecIm_Included));
        %Calculate the linear theta indicies of these coordinates
        Lin_Ind_Full = (x-ones(size(x))).*N_y + y;
        %Identify the full thetas -- the ones that include the empty pixels
        %that correspond to these coordinates. Note that the order of these
        %will correpond to the order that the x,y coordinates are listed
        %in, thus corresponding to the order that the distances are listed
        All_pix_Incl_theta = theta_full_lin(Lin_Ind_Full);
        %Out of these identify the positive pixels, and the corresponding
        %coordinates and distances
        PosPix_Included_Ind = find(All_pix_Incl_theta);
        Dist_pos = Dist_all(PosPix_Included_Ind);
        x_i = x(PosPix_Included_Ind);
        y_i = y(PosPix_Included_Ind);
        %Check if there are any nearest neighbors
        if isempty(PosPix_Included_Ind)
            x_np(pix) = x_0(pix);
            y_np(pix) = y_0(pix);
        else
            [d(pix),Pix_ind] = min(Dist_pos);            
            %Record the coordinate of the nearest positive pixel along the
            %direction \theta_0
            x_np(pix) = x_i(Pix_ind);
            y_np(pix) = y_i(Pix_ind);
        end
    end
    %The distance in microns
    d_micron = d./scale;
    %Remove zero distances 
    d_micron_NZ = d_micron;
    d_micron_NZ(d_micron_NZ == 0) = []; 
    %The mean distance
    d_mean = mean(d_micron_NZ);
    d_stdev = std(d_micron_NZ);
end

