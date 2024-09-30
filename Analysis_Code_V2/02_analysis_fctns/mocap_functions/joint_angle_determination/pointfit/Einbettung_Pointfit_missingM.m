function [orientierung] = Einbettung_Pointfit_missingM(segments_calibration,segments_tracking)

% INPUT
% segments_calibration: structure array of reference data
% segments_tracking: structure array of tracking data

% OUTPUT
% Orientierung: structure array mit pointfit Output (Translationsmatrix) zu
% jedem Zeitpunkt für alle Segmente

%% 6. Pointfit einbetten und Anpassen für die Verfügbarkeit der Marker

% 6.1 Mittelwerte der Marker in Kalibrierungsposition extrahieren
segment_names = fieldnames(segments_calibration);
mean_calibration = struct();

for i = 1:length(segment_names)
    temp_segment = char(segment_names{i});
    fields = fieldnames(segments_calibration.(temp_segment));
    for k = 1 : length(fields)
      temp_field = char(fields{k});
      if regexp(temp_field,'mean')
          mean_calibration.(temp_field) = segments_calibration.(temp_segment).(temp_field);
      end
    end 
    
end


% 6.2 Zugehörige Marker extrahieren während Bewegung(für jedes Segment)
segment_names = {'torso','uarm','larm'};
segment_relevant = struct();

% Initialisation für Abschnitt 6.4
n_frames = size(segments_tracking.torso.torso_1,2);
M_orientation_segment = [];
all_T = zeros(4,4,n_frames);
orientierung = struct();

for i = 1:3
  temp_segment = char(segment_names{i});
  fields = fieldnames(segments_tracking.(temp_segment));
  missing_counter = 0;
  for k = 1 : length(fields)
      temp_field = char(fields{k});
      segment_relevant.(temp_segment).(temp_field) = segments_tracking.(temp_segment).(temp_field);
  end  
%   if strcmp(temp_segment,'uarm') || strcmp(temp_segment,'larm') % Ellbengobenmarker gehören auch zu den Segmenten
%       segment_relevant.(temp_segment).elb_1 = segments_tracking.elb.elb_1;
%       segment_relevant.(temp_segment).elb_2 = segments_tracking.elb.elb_2;
 
  % 6.3 Marker in Kalibration und Messung vorhanden (für jeden Zeitpunkt)
  for j = 1:n_frames
        frame = j;
       [M_usable_cal,M_usable_tracking] = missing_marker_detection(mean_calibration,segment_relevant,temp_segment, frame);
       
       % 6.4 Prüfen, ob Ellengobenmarker hinzugefügt werden muss
%        if size(M_usable_tracking,2)<3
%            if strcmp(temp_segment,'uarm') || strcmp(temp_segment,'larm') % Ellbengobenmarker gehören auch zu den Segmenten
%            elb1_tracking = segments_tracking.elb.elb_1;
%            elb2_tracking = segments_tracking.elb.elb_2;
%            elb1_calibration = segments_calibration.elb.elb_1_mean;
%            elb2_calibration = segments_calibration.elb.elb_2_mean;
%            elb1_tracking = elb1_tracking(:,frame);
%            elb2_tracking = elb2_tracking(:,frame);
%            
%            check_NaN = isnan(elb1_tracking);
%            if sum(check_NaN)==0
%                 M_usable_tracking = [M_usable_tracking,elb1_tracking];
%                 check_NaN2 = isnan(elb1_calibration);
%                 if sum(check_NaN2)==0
%                     M_usable_cal = [M_usable_cal,elb1_calibration];
%                 else
%                     warning('WARNING: Calibration Marker is missing');
%                  end
%            end
%            
%             check_NaN = isnan(elb2_tracking);
%            if sum(check_NaN)==0
%                 M_usable_tracking = [M_usable_tracking,elb2_tracking];
%                 check_NaN2 = isnan(elb2_calibration);
%                 if sum(check_NaN2)==0
%                     M_usable_cal = [M_usable_cal,elb2_calibration];
%                 else
%                     warning('WARNING: Calibration Marker is missing');
%                  end
%            end
%            end
%        end
       
       % 6.5 Orientierung im Raum bestimmen (für jedes Segment zu jedem
       % Zeitpunt
       [temp_T, missing_counter] = pointfit_adapted(M_usable_tracking,M_usable_cal, all_T, frame, n_frames, missing_counter);
       all_T(:,:,j) = temp_T;
  end
  orientierung.(temp_segment) = all_T;
end  


