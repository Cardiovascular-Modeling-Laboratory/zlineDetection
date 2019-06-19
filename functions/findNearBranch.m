% cleanSkel - Prune a skeleton by removing branches that are less than the 
% supplied branch length 
%
% Usage:
%  out = findNearBranch(i,j,DB,m,n)
%
% Arguments:
%   i       - location (dimension 1) of branch to be trimmed 
%               Class Support: positive, real integer greater than 1, less
%               than image dimension 1
%   j       - location (dimension 2) of branch to be trimmed 
%               Class Support: positive, real integer greater than 1, less
%               than image dimension 2
%   DB      - geodesic distance between skeleton and branchpoints 
%               Class Support: numeric array of class single that has
%               the same size as the input binary skeleton 
%   m       - size of first dimension of the image's binary skeleton 
%               Class Support: positive, real integer greater than 1
%   n       - size of second dimension of the image's binary skeleton 
%               Class Support: positive, real integer greater than 1
% 
% Returns:
% 	out     - index of the nearest branch 
%               Class Support: positive, real integer greater than 1, less
%               than image dimensions
% 
% Dependencies: 
%   MATLAB Version >= 9.5 
%
%
% Annotated by: Tessa Morris
%   Advisor: Anna Grosberg, Department of Biomedical Engineering 
%   Cardiovascular Modeling Laboratory 
%   University of California, Irvine 
% Created by: Nils Persson ( GTFiber-Mac/Functions/findNearBranch.m )
%   Persson, Nils E., et al. "Automated analysis of orientational order
%   in images of fibrillar materials." Chemistry of Materials 29.1 
%   (2016): 3-14.

function out = findNearBranch(i,j,DB,m,n)

if DB(i,j)==0 || isnan(DB(i,j)) || isinf(DB(i,j))
    out = sub2ind(size(DB),i,j);
    return
else
    hood = zeros(8,3);
    hood(:,1:2) = [i-1, j-1;...
            i-1, j;...
            i-1, j+1;...
            i, j-1;...
            i, j+1;...
            i+1, j-1;...
            i+1, j;...
            i+1, j+1];
    if i==1
        hood([1,2,3],:)=[];
    elseif i==m
        hood([6,7,8],:)=[];
    end
    if j==1
        hood([1,4,6],:)=[];
    elseif j==n
        hood([3,5,8],:)=[];
    end
    hood(:,3) = DB(sub2ind(size(DB),hood(:,1),hood(:,2)));
    [mind, minind] = min(hood(:,3),[],1);
    out = findNearBranch(hood(minind,1),hood(minind,2),DB,m,n);
end

end