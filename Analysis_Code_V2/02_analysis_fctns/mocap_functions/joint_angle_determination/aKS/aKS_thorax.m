function [segments] = aKS_thorax(segments)
% aKS_thorax calculates the anatomical coordinate system of the thorax
% This calculation does not follow the ISB norm
%
% Input
% SEGMETNS   Mean value of MoCap data from reference/calibration measurement
%                   segments structure array
% Output
% aKS_thorax   3x3 Matrix with anatomical coordinate system axis of the
%               thorax

%% Check Input
if ~isstruct(segments) 
    error('ERROR in calling SEGMENTS: Input is no structure array!')
end

%% Calculation of x-axis
% line perpendicular to the plane through sternum, left and right clavicula
% pointing ventral

% The plane is spanned by two vectors, the perpendicular line is given by
% the cross product of these vectors

v1 = segments.torso.torso_3_mean(1:3,1)-segments.torso.torso_1_mean(1:3,1);
v2 = segments.torso.torso_2_mean(1:3,1)-segments.torso.torso_1_mean(1:3,1);
x_torso = cross(v1,v2);
x_torso = x_torso/norm(x_torso);

%% Calculation of z-axis
% line between the left and the right clavicular marker
% pointing to the right

z_torso = segments.torso.torso_2_mean(1:3,1) - segments.torso.torso_3_mean(1:3,1);
z_torso = z_torso/norm(z_torso);

%% Calculation of y-axis
y_torso =  cross(z_torso, x_torso);
y_torso = y_torso/norm(y_torso);

%% Assign results to output
% The origin of the anatomical coordinate system is at the mean centroid
% position
R_aKS_thorax = [x_torso, y_torso, z_torso];
T =segments.torso.RefFrame_inWorld;
T(1:3,1:3) = R_aKS_thorax;
segments.torso.aKS = T;
end

