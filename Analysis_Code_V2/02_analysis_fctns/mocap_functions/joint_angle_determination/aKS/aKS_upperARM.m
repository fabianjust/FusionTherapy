function [segments] = aKS_upperARM(segments)
% aKS_upperARM calculates the anatomical coordinate system of the upper ARM
% according to ISB norm

% Input
% SEGMENTS_ROTCENTER: Mean value of MoCap data from reference/calibration measurement
%               segments structure array
%               structure array containing center of rotation for gleno-
%               humeral joint 
%                   GHG: center of rotation (Coordinates)
% Output
% aKS_upperARM: 3x3 Matrix with anatomical coordinate system axis of the
%               upper arm
%
% CAUTION:      This skript has not yet been tested with data

%% Check Input
if ~isstruct(segments) 
    error('ERROR in calling SEGMENTS: Input is no structure array!')
end

%% Calculation of x-axis
% line perpendicular to the plane formed by lateral epicondyle, medial epicondyle and 
% glenohumeral rotation center, pointing forward
% (Our calibration procedure is not performed in the anatomical positon.
% Therefore, the x-axis will be pointing medially.)
% The plane is spanned by two vectors, the perpendicular line is given by
% the cross product of these vectors

v1 = segments.elb.elb_2_mean(1:3,1) - segments.uarm.uarm_rotCenter(1:3,1);
v2 = segments.elb.elb_1_mean(1:3,1) - segments.uarm.uarm_rotCenter(1:3,1);
x_uARM = cross(v1,v2);
x_uARM = x_uARM/norm(x_uARM);

% Check if x is pointing in the right direction


%% Calculation of y-axis
% line connecting glenohumeral rotation center and the midpoint of lateral and medial 
% epicondyle, pointing to glenohumeral rotation center

M = [segments.elb.elb_2_mean(1:3,1)'; segments.elb.elb_1_mean(1:3,1)'];
M = mean(M);
M = M';

y_uARM = segments.uarm.uarm_rotCenter(1:3,1) - M;
y_uARM = y_uARM/norm(y_uARM);

% Check if y is pointing towards GHG

%% Caluclation of z-axis
% line perpendicular to x and y axis (right handed coordinate system)
z_uARM = cross (x_uARM, y_uARM);
z_uARM = z_uARM/norm(z_uARM);

%% Assign results to Output 
% The origin of the anatomical coordinate system is at the mean centroid
% position
R_aKS_uArm = [x_uARM, y_uARM, z_uARM];
T =segments.uarm.RefFrame_inWorld;
T(1:3,1:3) = R_aKS_uArm;
segments.uarm.aKS = T;
end

