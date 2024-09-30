%mocap_calibration
%
%Author: Gabriela Gerber & David Mauderli - 2019
%
%DESCRIPTION: This function computes the struct segments_calibration from
%the calibration file and the jointcenter file. The segment calibration
%file contains the transformation from technical to anatomical CCS.
%
%INPUT:
%calibration_file: Absolute path to calibration file (csv)
%jointcenter_file: Absolute path to jointcenter file (csv)
%
%OUTPUT:
%segments_calibration: struct containing technical to anatomical CCS
%transforms


function [segments_calibration] = mocap_calibration(ref)
%% Check inputs
if ~((exist(ref.MOC_CAL)==2)&&(exist(ref.MOC_JCT)==2))
    msgID = 'mocap_calibration:files_missing';
    msg = 'Reference Files are missing';
    throw(MException(msgID,msg));
end

%% Preprocess Calibration Data
%Import calibration file
calibration_file = ref.MOC_CAL;
if exist(strcat(calibration_file(1:(end-3)),'mat'))==2
    load(strcat(calibration_file(1:(end-3)),'mat'));
else
    marker_calibration = import_mocap_data(calibration_file);
end

%Adress each marker to its corresponding segments
segments_cal = segment_extractor(marker_calibration);

%Compute centroid of each segment
segments_calibration = segment_centroids(segments_cal);

%Determine mean position of each centroid
segments_calibration = get_mean_pos_adapted(segments_calibration);

%Check if reference position is valid
[fail,segments_calibration,segment_fail] = check_ref_adapted(segments_calibration,0.05);
assert(fail==0,'mocap_calibration:refpos_fail',...
    'Displacement of markers during reference shot is too large!')

%% Preprocess Joint Rotation Data
%Import File
jointcenter_file = ref.MOC_JCT;
marker_rotation = import_mocap_data(jointcenter_file);
marker_rotation = fill_gaps(marker_rotation,6);

%Adress each marker to its corresponding segments
segments_rot = segment_extractor(marker_rotation);

%Compute centroid of each segment
segments_rotation = segment_centroids(segments_rot); 

%% Determine anatomical CCS of each segment
%Determine homogeneous transformation w.r.t. reference position of each
%frame in segments_rotation
orientierung_rotation = Einbettung_Pointfit_missingM(segments_calibration,segments_rotation);

%Determine jointcenter
segments_calibration = add_segment_joint_centers(segments_calibration,orientierung_rotation,{'uarm','torso','uarm_rotCenter'},true,500000);

%Specify anatomical coordinate systems
segments_calibration = aKS_lowerARM(segments_calibration);
segments_calibration = aKS_upperARM(segments_calibration);
segments_calibration = aKS_thorax_ISB(segments_calibration);

end