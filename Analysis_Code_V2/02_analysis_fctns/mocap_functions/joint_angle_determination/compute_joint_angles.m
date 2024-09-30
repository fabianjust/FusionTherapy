%compute_joint_angles
%
%Author: Gabriela Gerber & David Mauderli - 2019
%
%DESCRIPTION: This function computes filtered joint angles for the bridget study
%
%INPUT:
%marker_tracking: struct containing measurment markers as fields. (output
%from import_mocap_data)
%segments_calibration: struct containing calibration information. (Output
%from mocap_calibration.m)
%
%OUTPUT:
%joint_angles: struct containing joint angles

function [joint_angles] = compute_joint_angles(marker_tracking, segments_calibration)

%Extract segments --> markers are distributed to their limb: uarm, torso,
%larm
segments_tra = segment_extractor(marker_tracking);
segments_tra = segment_centroids(segments_tra);

%Extract relevant limbs for joint angle determination
if isfield(segments_tra,'elb')
    segments_tracking.elb = segments_tra.elb;
end
segments_tracking.uarm = segments_tra.uarm;
segments_tracking.larm = segments_tra.larm;
segments_tracking.torso = segments_tra.torso;

%Compute joint angles
%1.) Pointfit: Compute transformations from reference position to current
%frame for every frame
orientierung_tracking = Einbettung_Pointfit_missingM(segments_calibration,segments_tracking);
%2.) Filter transformations --> median filter and butterworth lp
orientierung_tracking = filter_transformation(orientierung_tracking,20,8,5,120);
%3.) Transform from technical transformations to anatomical transformations
orientierung_anatomical = align_aKS(orientierung_tracking,segments_calibration);
%4.) Compute joint angles
joint_angles = joint_angle_determination(orientierung_anatomical);
end