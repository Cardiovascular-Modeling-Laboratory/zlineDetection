% cleanSkel - Prune a skeleton by removing branches that are less than the 
% supplied branch length 
%
% Usage:
%  skel2 = cleanSkel( skel, minBranchLen )
%
% Arguments:
% 	skel            - binary skeleton 
%                       Class Support: numeric or logical, must be 2-D,
%                       real and nonsparse
%   minBranchLen    - minimum size of a branch that for it to be kept
%                       in the binary skeleton 
%                       Class Support: positive number 
% 
% Returns:
% 	skel2           - pruned binary skeleton 
%                        Class Support: 2-D logical
% 
% Dependencies: 
%   MATLAB Version >= 9.5 
%   Image Processing Toolbox Version 10.3
%   Functions: findNearBranch.m
%
%
% Annotated / Modified by: Tessa Morris
%   Advisor: Anna Grosberg, Department of Biomedical Engineering 
%   Cardiovascular Modeling Laboratory 
%   University of California, Irvine 
% Created by: Nils Persson ( GTFiber-Mac/Functions/cleanSkel.m )
%   Persson, Nils E., et al. "Automated analysis of orientational order
%   in images of fibrillar materials." Chemistry of Materials 29.1 
%   (2016): 3-14.

function skel2 = cleanSkel( skel, minBranchLen )
% This function will prune the skeleton

% Find branch points of skeleton.
B = bwmorph(skel, 'branchpoints');

% Finds end points of skeleton.
E = bwmorph(skel, 'endpoints');

% Get the size of the image 
[m,n] = size(skel);

% Computes the geodesic distance transform given the binary image 
% and the seed locations specified by the mask, in this case, the binary
% image is the skeleton and the mask is either the branchpoints or the end
% points 

% Geodesic distance between skeleton and branchpoints 
DB = bwdistgeodesic(skel,B);

% Geodesic distance between skeleton and endpoints  
DE = bwdistgeodesic(skel,E);

% Find where the sum of the distances are less than the maxBranchLen input
% by the user
Nubs2 = DB+DE<minBranchLen;

% Subtract the branch points 
Nubs3 = Nubs2-B;

% Subtract from the skelton 
skel2 = skel-Nubs3;

% Find where there are "nubs"
NubsCheck = Nubs3 & DE>DB;

% Loop through all of the positive "nubs" 
for ind = find(NubsCheck)'
    
    %Determine the equivalent subscript value that corresponds to a given 
    %single index into an array
    [i,j] = ind2sub([m,n],ind);
    
    %Find the nearest branch 
    nearBranchInd = findNearBranch(i,j,DB,m,n);
    
    %Check 
    if DE(i,j)>=DE(nearBranchInd)
        skel2(i,j)=1;
    end
end

%Remove small objects from binary image
skel2 = bwareaopen(skel2,minBranchLen);

end

