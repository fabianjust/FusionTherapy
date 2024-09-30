function [] = plot_moc_recording(path, speed)

if nargin==0
    [FNAME,FOLDER,~ ]= uigetfile('.csv')
    marker_tracking = import_mocap_data([FOLDER,'\',FNAME]);
    speed=1
elseif nargin == 2
    
    marker_tracking = import_mocap_data(path);
end
%% Collect Data

n_frames = length(marker_tracking.torso_1);
torso = NaN(n_frames,8,3);
uarm = NaN(n_frames,4,3);
larm = NaN(n_frames,6,3);
elb = NaN(n_frames,2,3);
hand = NaN(n_frames,2,3);
for xyz=1:3
        for i=1:8
            marname = strcat('torso_',num2str(i));
            torso(:,i,xyz) = marker_tracking.(marname)(xyz,:);
        end
        for i=1:4
        marname = strcat('uarm_',num2str(i));
        uarm(:,i,xyz) = marker_tracking.(marname)(xyz,:);
        end
        for i=1:2
        marname = strcat('elb_',num2str(i));
        elb(:,i,xyz) = marker_tracking.(marname)(xyz,:);
        end
        for i=1:6
        marname = strcat('larm_',num2str(i));
        larm(:,i,xyz) = marker_tracking.(marname)(xyz,:);
        end
        for i=1:2
        marname = strcat('hand_',num2str(i));
        hand(:,i,xyz) = marker_tracking.(marname)(xyz,:);
        end
end

%% Plot
moc_Fs = 120;
des_Fs = 15/speed;

figure()
subplot(1,1,1)
for frame = 1:moc_Fs/des_Fs:n_frames
    tic
    scatter3(torso(frame,:,1),torso(frame,:,2),torso(frame,:,3),'k*')
    hold on
    scatter3(uarm(frame,:,1),uarm(frame,:,2),uarm(frame,:,3),'b*')
    scatter3(elb(frame,:,1),elb(frame,:,2),elb(frame,:,3),'r*')
    scatter3(larm(frame,:,1),larm(frame,:,2),larm(frame,:,3),'m*')
    scatter3(hand(frame,:,1),hand(frame,:,2),hand(frame,:,3),'g*')
    xlim([-0.3,1.2])
    ylim([-0.1,1.4])
    zlim([-1,0.5])
    tw = toc;
    pause(1/des_Fs-tw);
    hold off
end

end