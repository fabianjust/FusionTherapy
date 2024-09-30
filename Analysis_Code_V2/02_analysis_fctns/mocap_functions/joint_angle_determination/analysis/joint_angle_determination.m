function [joint_angles] = joint_angle_determination(orientierung_anatomical)
% JOINT_ANGLE_DETERMINATION calculates the following joint angles:
%           shoulder horizontal abduction, shoulder flexion, shoulder rotation, elbow
%           flexion, lower arm pronation.
%           The joint angles are defined as in ARMin V.

joint_angles = struct();
R1 = orientierung_anatomical.torso;
R2 = orientierung_anatomical.uarm;
R3 = orientierung_anatomical.larm;
length = size(orientierung_anatomical.torso,3);

shoulder_1 = zeros(length,1);
shoulder_2 = zeros(length,1);
shoulder_3 = zeros(length,1);
elbow_1 = zeros(length,1);
elbow_2 = zeros(length,1);

for i = 1:length

%% 1. Horizontal shoulder adduction/abduction
x1 = R1(1:3,1,i);
y2 = -R2(1:3,2,i);
z1 = -R1(1:3,3,i);

% Projection to plane
n1 = cross(z1,x1);
n1_norm = n1/norm(n1);
y2_pro = y2 - n1_norm.*dot(y2,n1_norm);

% Preparation for angle calculation
p1 = dot(y2_pro,x1);
p2 = dot(y2_pro,z1);
norm1 = norm(y2_pro);
norm2 = norm(x1);
norm3 = norm(z1);

% Absolute adduction/abduction angle (angle between y2_pro and x1)
shoulder1_pos = acosd(p1/(norm1*norm2));

% Definition of positive and negative angles
a_comp = acosd(p2/(norm1*norm3)); 

if a_comp < 90 
    shoulder1 = shoulder1_pos; % adduction
else
    shoulder1 = -shoulder1_pos; % abduction
end

% Safe angle to matrix
shoulder_1(i,1) = shoulder1;

%% 2. Shoulder flexion/extension
y1 = -R1(1:3,2,i);
y2 = -R2(1:3,2,i);

p3 = dot(y2,y1);
norm4 = norm(y2);
norm5 = norm(y1);

% Angle between y1 and y2 
shoulder2 = acosd(p3/(norm4*norm5));
shoulder2 = shoulder2-90;

% Safe angle to matrix
shoulder_2(i,1) = shoulder2;

%% 3. Shoulder Rotation (internal and external)
y1 = R1(1:3,2,i);
x2 = R2(1:3,1,i);
z2 = R2(1:3,3,i);

% Projection of y1 to the xz-plane of sensor 2
n3 = cross(x2,z2); 
n3_norm = n3/norm(n3);
y1_pro = y1 - (n3_norm.*dot(y1,n3_norm));

% Preperation for angle calculation
p4 = dot(y1_pro,z2);
p5 = dot(y1_pro,x2);
norm6 = norm(y1_pro);
norm7 = norm(z2);
norm8 = norm(x2);

% Absolute shoulder rotation angle (angle between y1_pro and x2)
shoulder3_pos = acosd(p4/(norm6*norm7));
    
% Definition of positive and negative angles
a_comp = acosd(p5/(norm6*norm8)); 

if a_comp < 90 
    shoulder3 = -shoulder3_pos; % external rotation
else
    shoulder3 = shoulder3_pos; % internal rotation
end

% Safe angle to matrix
shoulder_3(i,1) = shoulder3;


%% 4. Elbow flexion angle
y2 = -R2(1:3,2,i);
y3 = -R3(1:3,2,i);

p6 = dot(y2,y3);
norm9 = norm(y2);
norm10 = norm(y3);

% Absolute elbow flexion angle (angle between y2 and y3)
elbow_korr = acosd(p6/(norm9*norm10));
elbow = elbow_korr * (-1);

% Safe angle to matrix
elbow_1(i,1) = elbow;

%% 5. Pronation/Supination
% x2 = -R2(1:3,1,i);
% x3 = -R3(1:3,1,i);
% z3 = R3(1:3,3,i);

 z2 = -R2(1:3,3,i);
 z3 = -R3(1:3,3,i);
 x3 = R3(1:3,1,i);
 
p7 = dot(z2,z3);  
p8 = dot(z2,x3);
norm11 = norm(z2);
norm12 = norm(z3);
norm13 = norm(x3);
    
% Absolute Pronation/Supination angle(angle between z2 and z3)
pronation_pos = acosd(p7/(norm11*norm12)); 

% Definition of positive and negative angles
a_comp = acosd(p8/(norm12*norm13));

if a_comp < 90 
    pronation = pronation_pos; % supination
else
    pronation = +pronation_pos; % pronation
end

% Safe angle to matrix
elbow_2(i,1) = pronation;

end

% Safe angle matrices to structure array
joint_angles.shoulder1 = shoulder_1;
joint_angles.shoulder2 = shoulder_2;
joint_angles.shoulder3 = shoulder_3;
joint_angles.elbow = elbow_1;
joint_angles.pronation = elbow_2;
end