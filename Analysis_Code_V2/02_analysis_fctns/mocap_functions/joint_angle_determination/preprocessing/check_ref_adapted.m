function [fail, S_out, segment_fail] = check_ref(S_in,thres)
%
% CHECK_REF proofs whether trial provides a usefull reference.
%   In the case of all centroids lying in a sphere based on threshold the
%   reference is accepted and the mean centroid is written as a field for each segment.
%
% Input:
%   S_in    Structure array with segments.
%              Each segment is a field containing markers associated with
%              a segment and their coordinates, and the centroids per
%              frame.
%  THRES   radius of the sphere, default = 0.5mm
%
%
% Output:
%   fail       If trail is acceptable as reference, fail = 0
%   S_out  Structure array with segments. S_in is updated with mean
%              centroid (fieldname: Centroid_mean).
%   segment_fail   A flag is given for each segment. 
%                        0 indicates accepted reference.
%
% Used functions: check_ref_centroid
%
% Written:  17.04.2005
% Revised: 17.04.2005 (Wolf)
%

fail = 0;
S_out = S_in;
segment_fail=[];

%---Check input--------------------
if ~isstruct(S_in) 
    error('ERROR in calling CHECK_REF: Input is no structure array!')
end

if nargin < 2
    thres = 0.005;
end

%---Proof-----------
segment_names = fieldnames(S_in);

for i = 1: length(segment_names)
    temp_segment = char(segment_names{i});
    [segment_fail.(temp_segment),S_out.(temp_segment).Centroid_mean, S_out.(temp_segment).RefFrame_inWorld] = check_ref_centroid_adapted(S_in.(temp_segment).Centroid,thres);
    
    if segment_fail.(temp_segment)
        fail = 1;
    end
    
end