function [segments] = aKS_lowerARM(segments)
% aKS_lowerARM calculates the anatomical coordinate system of the lower ARM
% according to ISB norm

% Input
% SEGMENTS:    Mean value of MoCap data from reference/calibration measurement
%                   segments structure array
%
% Output
% aKS_lowerARM: 4x4 Matrix with anatomical coordinate system axis of the
%               lower arm in sturcture array

%% Check Input
if ~isstruct(segments) 
    error('ERROR in calling SEGMENTS: Input is no structure array!')
end

%% Calculation of x-axis
% line perpendicular to the plane through ulnar styloid, radial styloid and the midpoint
% between lateral and medial epicondyle, pointing forward

% Caluclation of the midpoint between the two epicondyles
M = [segments.elb.elb_2_mean'; segments.elb.elb_1_mean'];
M = mean(M);
M = M';

% The plane is spanned by two vectors, the perpendicular line is given by
% the cross product of these vectors

v1 = segments.larm.larm_5_mean(1:3,1) - M(1:3,1);
v2 = segments.larm.larm_6_mean(1:3,1) - M(1:3,1);
x_lARM = cross(v1,v2);
x_lARM = x_lARM/norm(x_lARM);

% Check if x is pointing in the right direction


%% Calculation of y-axis
% line connecting ulnar styloid and the midpoint between lateral and medial 
% epicondyle, pointing proximally

y_lARM = M(1:3,1) - segments.larm.larm_6_mean(1:3,1);
y_lARM = y_lARM/norm(y_lARM);

% Check if y is pointing proximally

%% Caluclation of z-axis
% line perpendicular to x and y axis (right handed coordinate system)
z_lARM = cross (x_lARM, y_lARM);
z_lARM = z_lARM/norm(z_lARM);

%% Assign results to Output 
% The origin of the anatomical coordinate system is at the mean centroid
% position
R_aKS_larm = [x_lARM, y_lARM, z_lARM];
T =segments.larm.RefFrame_inWorld;
T(1:3,1:3) = R_aKS_larm;
segments.larm.aKS = T;
end

