function [fail,mean_centroid, RefFrame_inWorld] = check_ref_centroid(centroids,thres)
%
% CHECK_REF_CENTROID proofs whether trial provides a usefull reference.
%   In the case of all centroids lying in a sphere based on threshold the
%   reference is accepted and the mean centroid and position and orientation of reference frame described inWorld 
%   are given as an output. Thereby, local axes are orientated as world axes.
%
% Input:
%   CENTROIDS  4xn matrix of all acquired/calculated centroids
%   THRES          radius of the sphere, default = 0.5mm
%
% Output:
%   fail                flag, fail=0 if accepted reference else i=1
%   MEAN_CENTROID of accepted reference
%   T_SEG_INWORLD of accepted reference (4x4)
%
%
% Written:  14.04.2005
% Revised: 12.09.2005 (Wolf)
%

fail = 1;
mean_centroid = [];
RefFrame_inWorld = [];
%---Check input--------------------
if  ~any(size(centroids) == 4)
    error('ERROR in calling CHECK_REF_SEGMENT: Check input sizes of centroids!')
end

if size(centroids,1) ~= 4 & size(centroids,2) == 4
    centroids=centroids';
end

if nargin < 2
    thres = 0.005;
end

%---get rid of Nan entires------------
 all_frames = centroids;
 centroids=all_frames(:,~any(isnan(all_frames), 1));

%---Proof-----------
test_cube_length=2*thres/3;
centroid_quad = abs([min(centroids(1,:))-max(centroids(1,:)) min(centroids(2,:))-max(centroids(2,:)) min(centroids(3,:))-max(centroids(3,:))]);
test = (centroid_quad<test_cube_length);
if all(test)
    fail=0;
    mean_centroid=mean(centroids,2);
    RefFrame_inWorld = eye(4);
    RefFrame_inWorld(:,4) = mean_centroid;
end
return
    
