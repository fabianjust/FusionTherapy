function [orientierung_anatomical] = align_aKS(orientierung_tracking,segments_calibration)
% ALIGN_AKS applies the transformation of the rigid body to the anatomical
%          coordinatesystem in the reference position
% 
% INPUT: 
%     orientierung_tracking: sturcture array with 4x4xn transformation
%                            matrices for each segment
%     segments_calibration:  structure arrac containing the anatomical
%                            coordinate systems in the reference position
%                            for each segment
%
% OUTPUT:
%     orientierung_anatomical: sturcutre array containing the orientation
%                             of the anatomical coordinate system for each
%                             segment at each timepoint (4x4xn)


segment_names = {'torso','uarm','larm'};
orientierung_anatomical = struct();
M_neu = zeros(4,4,size(orientierung_tracking.torso,3));

for i = 1: length(segment_names)
    temp_segment = char(segment_names{i});
    for k = 1:size(orientierung_tracking.torso,3)
        orientierung_temp = orientierung_tracking.(temp_segment);
        M_neu(:,:,k) = orientierung_temp(:,:,k)*segments_calibration.(temp_segment).aKS;
    end
    orientierung_anatomical.(temp_segment) = M_neu;
end
end

