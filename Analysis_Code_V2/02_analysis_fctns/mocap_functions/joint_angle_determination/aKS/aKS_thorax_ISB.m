function [segments] = aKS_thorax_ISB(segments)
% aKS_thorax_ISB calculates the anatomical coordinate system of the thorax
% This calculation follows the ISB norm
%
% Input
% SEGMETNS   Mean value of MoCap data from reference/calibration measurement
%                   segments structure array
% Output
% aKS_thorax   4x4 Matrix with anatomical coordinate system axis of the
%               thorax saved in structure array

%% Check Input
if ~isstruct(segments) 
    error('ERROR in calling SEGMENTS: Input is no structure array!')
end

%% Calculation of y-axis
% The line connecting the midpoint between PX and T8 and the midpoint 
% between IJ and C7, npointing upward

% Calculation of midpoints
% M1: PX and T8
% M2: IJ and C7

M1 = [segments.torso.torso_6_mean';segments.torso.torso_8_mean'];
M1 = mean(M1);
M1 = M1(1:3)';

M2 = [segments.torso.torso_1_mean';segments.torso.torso_7_mean'];
M2 = mean(M2);
M2 = M2(1:3)';

y_torso = M2-M1;
y_torso = y_torso/norm(y_torso);

%% Calculation of z-axis
% The line perpendicular to the plane formed by IJ, C7, and the midpoint 
% between PX and T8, pointing to the right.

% The plane is spanned by two vectors, the perpendicular line is given by
% the cross product of these vectors

v1 = segments.torso.torso_1_mean(1:3,1) - M1; 
v2 = segments.torso.torso_7_mean(1:3,1) - M1;

z_torso = cross(v1,v2);
z_torso = z_torso/norm(z_torso);

%% Calculation of x-axis
x_torso =  cross(y_torso, z_torso);
x_torso = x_torso/norm(x_torso);

%% Assign results to output
% The origin of the anatomical coordinate system is at the mean centroid
% position
R_aKS_thorax = [x_torso, y_torso, z_torso];
T =segments.torso.RefFrame_inWorld;
T(1:3,1:3) = R_aKS_thorax;
segments.torso.aKS = T;
end
