function [M_usable_cal,M_usable_tracking] = missing_marker_detection(segments_calibration,segments_tracking,temp_segment, frame)
%MISSING_MARKER_DEETECTION detects missing markers for a given time frame
%and creates a matrix with only visible markers for this time
%frame
%
% INPUT:
%    segments_calibration: calibration data (mean values)
%    segments_tracking: tracking data
%    temp_segment: the function will be applied in a for-loop (segments)
%                  temp_segment defines the temporary segment
%    frame: current frame 
% OUTPUT: 
%    Usable_Marker_cal: 4xn matrix containing homogeneous coordinates of
%    all segment markers that are measured in the calibration data 
%
%    Usable_Marker_tracking: 4xn matrix containing homogeneous coordinates
%    of all segment markers that are measured in the tracking data
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Definition ouf output variables
M_usable_cal = [];
M_usable_tracking = [];

% Alle Marker des Segments durchchecken
fields = fieldnames(segments_tracking.(temp_segment));
 for k = 1 : length(fields)
     temp_field = char(fields{k});
     temp_pos_tracking1 = segments_tracking.(temp_segment).(temp_field);
     temp_pos_tracking = temp_pos_tracking1(:,frame);
     % Wurde der tracking Marker aufgenommen? Ist der Eintrag NaN?
     % Falls nicht NaN -> Eintrag in Matrix speichern
     check_NaN = isnan(temp_pos_tracking);
     if sum(check_NaN)==0
         M_usable_tracking = [M_usable_tracking,temp_pos_tracking];
         temp_cal_marker = [temp_field,'_mean'];
         % temp_segment correction für Ellenbogenmarker
         temp_segment_old = temp_segment;
%          if strncmp(temp_field,'elb',3)
%              temp_segment = 'elb';
%          else
%              temp_segment = temp_segment_old;
%          end
         temp_pos_cal = segments_calibration.(temp_cal_marker);
         check_NaN2 = isnan(temp_pos_cal);
         % Warining codieren, falls der tracking marker fehlt!!!
         
         % Matrix für calibration erstellen
         if sum(check_NaN2)==0
             M_usable_cal = [M_usable_cal,temp_pos_cal];
%              if strncmp(temp_field,'elb',3)
%              temp_segment = temp_segment_old;
%              end
         else
             warning('WARNING: Calibration Marker is missing');
         end
     end
 end


end

