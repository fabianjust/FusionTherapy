%build_cutdata
%
%Author: David Mauderli - 2019
%
%DESCRIPTION: This function reads the data relevant for end-effector
%cutting from segments_tra. The data is written into the struct cutdata
%that contains...
%...mean start marker position
%...mean stop marker position
%...hand 1 marker position for the whole recording
%...movement name
%...condition name
%If start/stop positions are missing, the user can also enter the positions
%by hand.
%
%INPUT:
%segments_tra: from segments_extractor
%movement: movement name
%condition: condition name
%
%OUTPUT:
%cutdata: struct containing information relevant to cut emg data.

function [cutdata] = build_cutdata(marker_tracking, movement, condition, bpm)

%Assign endeffector position to cutdatta structure
cutdata.hand = marker_tracking.hand_1;
%Assert that data has no nan entries
assert(~any(any(isnan(cutdata.hand))),'build_cutdata:nan_error',...
    strcat('marker hand_1 in ',movement,', ',condition,...
    ' contains NaN entries. Please fix the data vector'))

%Obtain starting coordinates
%If they are not defined, the user can input manually
if(isfield(marker_tracking,'start_1'))
    %Take mean from non nan start_1 marker frames
    start_non_nan = ~any(isnan(marker_tracking.start_1));
    cutdata.start = mean(marker_tracking.start_1(:,start_non_nan),2);
end
if(~isfield(marker_tracking,'start_1')||any(isnan(cutdata.start)))
    figure();
    line(cutdata.hand(1,:),cutdata.hand(2,:),cutdata.hand(3,:));
    hold on
    scatter3(cutdata.hand(1,1),cutdata.hand(2,1),cutdata.hand(3,1),'r*')    
    scatter3(cutdata.hand(1,2:120),cutdata.hand(2,2:120),cutdata.hand(3,2:120),'ro')
    axis equal
    xlabel('x')
    ylabel('y')
    zlabel('z')
    title(strcat('Trajectory of hand marker: ',movement, ', ',condition ));
    x = input('Enter start x-coordinate')
    y = input('Enter start y-coordinate')
    z = input('Enter start z-coordinate')
    cutdata.start = [x;y;z];
close
end

if(isfield(marker_tracking,'stop_1'))
    stop_non_nan = ~any(isnan(marker_tracking.stop_1));
    cutdata.stop = mean(marker_tracking.stop_1(:,stop_non_nan),2);
end
if(~isfield(marker_tracking,'stop_1')||any(isnan(cutdata.stop)))
    figure();
    line(cutdata.hand(1,:),cutdata.hand(2,:),cutdata.hand(3,:));
    hold on
    scatter3(cutdata.hand(1,1),cutdata.hand(2,1),cutdata.hand(3,1),'r*')    
    scatter3(cutdata.hand(1,2:120),cutdata.hand(2,2:120),cutdata.hand(3,2:120),'ro')
    axis equal
    title(strcat('Trajectory of hand marker: ',movement,', ', condition));
    xlabel('x')
    ylabel('y')
    
    zlabel('z')
    x = input('Enter stop x-coordinate')
    y = input('Enter stop y-coordinate')
    z = input('Enter stop z-coordinate')
    cutdata.stop = [x;y;z];
    close 
end

cutdata.movement = movement;
cutdata.condition = condition;
%Obtain matching bpm value from metainfo
if iscell(bpm)
    comp_i = strcmp(bpm,movement);
    cutdata.bpm = bpm{comp_i,2};
else
    cutdata.bpm = bpm;
end
end