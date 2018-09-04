% CLEANSKEL - Skeleton pruning 
%
% The prupose of this function is to prune a skeleton according to the
% minimum branch length 
%
% Usage:
%  Vf = YBiter(V0); 
%
% Arguments:
%       skel        - 
%       maxBranchLen- 
% Returns:
%       skel2       - 
% 
% Suggested parameters: maxBranchLen
% 
% See also: YBiter
%
% Annotated / Modified by Tessa Morris 
% Copyright (C) 2016 Nils Persson 
%

function skel2 = cleanSkel( skel, maxBranchLen )
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
Nubs2 = DB+DE<maxBranchLen;

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
skel2 = bwareaopen(skel2,maxBranchLen);

end

