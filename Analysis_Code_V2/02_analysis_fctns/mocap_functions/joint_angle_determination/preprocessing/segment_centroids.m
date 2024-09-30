function S_out = segment_centroids(S_in)
%
% SEGMENT_CENTROIDS provides centroid of each segment per frame.
%   Centroids are stored in input stucture array.
%
% Input:
%   S_in    Structure array with segments.
%              Each segment is a field containing markers associated with
%              segment and their coordinates per frame.
% 
% Output:
%   S_out  Structure array with segments. S_in is updated per segment with
%              the centroid per frame.
%
% Written: 15.04.2005
% Revised: 17.04.2005 (Wolf)
%

%---Check input------------------------------
if ~isstruct(S_in) 
    error('ERROR in calling SEGMENT_CENTROIDS: Input is no structure array!')
end

%---General initialization-----------------
segment_names = fieldnames(S_in);
S_out=S_in;

for i = 1: length(segment_names)
    temp_segment = char(segment_names{i});
    marker_names = fieldnames(S_in.(temp_segment));
    %---Allocate Centroid in S_in---------------------------------
    help_marker = char(marker_names{1});
    frames = size(S_in.(temp_segment).(help_marker),2);
    S_out.(temp_segment).Centroid = ones(4,frames);
    
    %---Extract coordinates----------------------------------------
    P_x=S_in.(temp_segment).(help_marker)(1,:);     
    P_y=S_in.(temp_segment).(help_marker)(2,:);
    P_z=S_in.(temp_segment).(help_marker)(3,:);
    
    for k=2:length(marker_names)
        help_marker = char(marker_names{k});
        P_x=[P_x; S_in.(temp_segment).(help_marker)(1,:)];
        P_y=[P_y; S_in.(temp_segment).(help_marker)(2,:)];
        P_z=[P_z; S_in.(temp_segment).(help_marker)(3,:)];
    end
    
    %---Calculate Centroid-----------------------------------------
    S_out.(temp_segment).Centroid(1,:) = mean(P_x,1);
    S_out.(temp_segment).Centroid(2,:) = mean(P_y,1);
    S_out.(temp_segment).Centroid(3,:) = mean(P_z,1);
end