% YBITER - Yanowitz/Bruckstein surface interpolation
%
% This function will segment the image using the Yanowitz-Bruckstein 
% image segmentation with fiber unentanglement.
% The gray values of these edge pixels are fixed in the initial threshold 
% surface and the remaining surface is obtained by solving the Laplace 
% equation through successive over-relaxation
%
%
% Usage:
%  Vf = YBiter(V0); 
%
% Arguments:
%       V0          - 
% Returns:
%       Vf          - 
% 
% Suggested parameters: None
% 
% See also: YBiter
%
% Copyright (C) 2016 Nils Persson 
%
% Annotated / Modified by Tessa Morris 

function Vf = YBiter(V0)
%YBiter Yanowitz/Bruckstein surface interpolation
%The input to this function is a grayscale image. In this usage, the image
%has been initialy thresholded 

% Initialize a variable w
w = 1;

% Get the size of the input image  
[ m, n ] = size( V0 );

% Initialy set the value to the 
InitVal = mean( V0( V0~=0 ) ); 

% A logical array of pixels to update on each iteration
Vupdate = V0==0;           
Vupdate(1,:) = 0;
Vupdate(:,1) = 0;
Vupdate(m,:) = 0;
Vupdate(:,n) = 0;

% Put the average edge values in the non-edge cells
V0(V0==0)=InitVal;         

% Initialize the updated threshold surface
Vnew = zeros(m,n);         
Vold = V0;

iter = 0;
maxiter = 40;

while iter<maxiter
    iter = iter+1;
    
    Lap = del2(Vold);
    Vnew = Vold + Vupdate .* (w .* Lap);
    Vold = Vnew;
    
end

Vf = Vnew;

end