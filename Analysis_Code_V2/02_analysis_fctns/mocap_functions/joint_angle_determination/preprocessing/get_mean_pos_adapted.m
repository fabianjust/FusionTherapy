function S_out = get_mean_pos_adapted(S_in)
%
% GET_MEAN_POS provides mean marker position.
%   This function is useful creating the reference file.
%   All markers of S_in are evaluated and their mean position is written
%   out in S_out.
%
% Input:
%   S_in    Structure array with segments.
%              Each segment is a field containing markers associated with
%              a segment and their coordinates.
%
% Output:
%   S_out  like S_in but supplemented with mean marker positions.
%
% Written:  20.04.2005
% Revised: 11.08.2005 (Wolf): underscore in markername is now handled...
%                                   like calc_1.
%                 27.07.2006 (Wolf) minor bugs fixed.
%

%---Check input------------------------------
if ~isstruct(S_in) 
    error('ERROR in calling SEGMENT_CENTROIDS: Input is no structure array!')
end

%---General initialization-----------------
segment_names = fieldnames(S_in);
S_out=S_in;

%---Work through each segment------
for i = 1: length(segment_names)
    temp_segment = char(segment_names{i});
    n_segment_digits = length(temp_segment);
    fields = fieldnames(S_in.(temp_segment));
    %---Work through fields----------------
    for k = 1 : length(fields)
        temp_field = char(fields{k});
        if strncmp(temp_segment, temp_field,n_segment_digits)    % if it is marker of segment then
            var_name = [temp_field,'_mean'];
            
            %---Use only labeled frames (no missing markers, no NaN
            %error)---------------------------------------
           all_frames = S_in.(temp_segment).(temp_field);
           all_numerical_frames=all_frames(:,~any(isnan(all_frames), 1)); 
           S_out.(temp_segment).(var_name) = mean(all_numerical_frames,2);
           
            %---Check output----------------
            if any(isnan(S_out.(temp_segment).(var_name))) ==1
                error('ERROR in get_mean_pos: Output is NaN');
            end
        end
    end
    %  S_out.(temp_segment) = orderfields(S_out.(temp_segment));    % ASCII dictionary order
end
