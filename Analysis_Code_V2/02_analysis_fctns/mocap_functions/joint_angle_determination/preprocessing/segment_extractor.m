function segments = segment_extractor(marker)
%
% SEGMENT_EXTRACTOR extracts segments out of marker structure array.
%
% Input:
%   MARKER        structure array with (homogeneous) markers
%                           More than nine marker per segment are not
%                           allowed.
% 
% Output:
%   SEGMENTS    structure array with segments and their markers.
%
% Written: 15.04.2005
% Revised: 11.08.2005 (Wolf) : adapted for names containing underscore
%          11.07.2006 (Wolf): adapted for names with _ + letter
%          26.07.2006 (Wolf): TibSkin and Tib are now correct.
%

%---Preparation---
marker = orderfields(marker);
marker_names = char(fieldnames(marker));
[n_markers, c] = size(marker_names);
marker_names_double = double(marker_names);
ptr_space = (marker_names_double == 32);                % ATTENTION:  works different between v7.0.1 & v7.0.4! Latest version requires 32 whereas 7.0.1 requires 0 !
marker_names_length = c - sum(ptr_space,2);
segment_names = zeros(n_markers,max(marker_names_length)-1);

%---Get segment names---
for i = 1:n_markers
    i_marker = marker_names_double(i,1:marker_names_length(i));
    if any(i_marker==32)
        disp('ERROR in SEGMENT_EXTRACTOR: Currently, only marker names without space are valid.')
        return
    end
    i_ptr_underscore = find(i_marker == 95,1,'last');
    if ~isempty(i_ptr_underscore)
        if i_ptr_underscore+1 == marker_names_length(i) &  i_marker(end)>=48 & i_marker(end)<=57        % is it like tibia_1 ?
            segment_names(i,1:marker_names_length(i)-2) = i_marker(1:marker_names_length(i)-2);
        elseif i_ptr_underscore+2 == marker_names_length(i) &  i_marker(end)>=48 & i_marker(end)<=57  &  (i_marker(end-1)<48 | i_marker(end-1)>57)   % is it like tibia_u1 ?
            segment_names(i,1:marker_names_length(i)-1) = i_marker(1:marker_names_length(i)-1);
        else
             disp(['ERROR in SEGMENT_EXTRACTOR: ',char(i_marker),' as a marker name is not supported.'])
             return
        end
    else
        if  i_marker(end)>=48 & i_marker(end)<=57       % check if digit
            segment_names(i,:) = i_marker(1:end-1);
        else
            disp('ERROR in SEGMENT_EXTRACTOR: Currently, only marker names with a digit as last sign are valid.')
            return
        end
    end
end

segment_names = char(unique(cellstr(char(segment_names))));

%---Create segments as structure array and assign each markers---
segment_names_double = double(segment_names);
ptr_zeros = (segment_names_double == 32);                           % ATTENTION: might  work different between v7.0.1 & v7.0.4! See above.
segment_names_length = size(segment_names_double,2) - sum(ptr_zeros,2);

for i = 1:size(segment_names_double,1)
    i_segment = segment_names(i,1:segment_names_length(i));
    for j = 1:n_markers
        j_marker = marker_names(j,1:marker_names_length(j));
        if strncmp(i_segment,j_marker,length(i_segment)) & segment_names_length(i)+3>=marker_names_length(j)        % and is necessary to distinguish between Tib and TibSkin.
            segments.(i_segment).(j_marker) = marker.(j_marker);
        end
    end
end

return