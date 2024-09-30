%Script that simulates mocap and emg measurments.

%% Config
moc_Fs = 120;
emg_Fs = 2000;
T = 4*12;
FOLDER = 'C:\Users\david\Documents\21_Polybox\03_Balgrist\BridgeT_Studie\04_Artificial_Data\subject_01'

%% Reference Files
%Reference Position
calibration_movement = mocap_data(moc_Fs,5);
calibration_movement.setMarkersRefpos(0.2,0.35,0.35);
const = @(t)(0);
calibration_movement.setTheta({const, const, const, const, const},zeros(1,5));
calibration_movement.simulate();
calibration_movement.save(FOLDER, '\mocap\moc_Calibration_S01.csv')

%Jointcenter File
sinabd = @(t)(-45*sin(2*pi/2*t+0));
sinele = @(t)(-45*sin(2*pi/2*t+pi/2));
sinrot = @(t)(-45*sin(2*pi/2*t+pi/4)+70);
calibration_movement.setTheta({sinabd,sinele,sinrot,@(t)(90),const},zeros(1,5));
calibration_movement.simulate();
calibration_movement.save(FOLDER, '\mocap\moc_Jointcenter_S01.csv')
clear calibration_movement
%% ABDUCTION MOCAP
%Create instance of mocap simulation
moc = mocap_data(moc_Fs,T);
%Define skeleton
moc.setMarkersRefpos(0.2,0.35,0.35);
%Define functions for joint angles (joint-time-space)
const = @(t)(0);
sinabd = @(t)(45/2*sin(2*pi/4*t)-45/2);
moc.setTheta({sinabd, const, const, const, const},[2,2,1,1,0]);
%Simulate Movement and save
moc.simulate();
moc.save(FOLDER,'\mocap\moc_abd_conb_S01.csv')
conditions = {'cont','robb','robt','bri'};
for i =1:(length(conditions))
    copyfile([FOLDER,'\mocap\moc_abd_conb_S01.csv'],...
        [FOLDER,'\mocap\moc_abd_',conditions{i},'_S01.csv'])
end
%% MVC EMG
emg = emg_data(emg_Fs,5);
%Empty can MVC
emg_mvc1 = @(t)(emg_pattern_mvc(5,emg_Fs,800,40));
emg_mvc2 = @(t)(emg_pattern_mvc(5,emg_Fs,50,40));
emg.simulate({emg_mvc1,emg_mvc1,emg_mvc2,emg_mvc2,emg_mvc2,emg_mvc2});
emg.save(FOLDER,'\emg\emg_mvc_ecan_S01.mat');
%Shoulder flexion MVC
emg.simulate({emg_mvc2,emg_mvc2,emg_mvc1,emg_mvc2,emg_mvc2,emg_mvc2});
emg.save(FOLDER,'\emg\emg_mvc_sfle_S01.mat');
%Palm Press MVC
emg.simulate({emg_mvc2,emg_mvc2,emg_mvc2,emg_mvc1,emg_mvc2,emg_mvc2});
emg.save(FOLDER,'\emg\emg_mvc_ppre_S01.mat');
%Elbow flexion
emg.simulate({emg_mvc2,emg_mvc2,emg_mvc2,emg_mvc2,emg_mvc1,emg_mvc2});
emg.save(FOLDER,'\emg\emg_mvc_efle_S01.mat');
%Elbow extension
emg.simulate({emg_mvc2,emg_mvc2,emg_mvc2,emg_mvc2,emg_mvc2,emg_mvc1});
emg.save(FOLDER,'\emg\emg_mvc_eext_S01.mat');
%% ABDUCTION EMG
emg = emg_data(emg_Fs,T);
%Conventional Baseline
emg_fctn_hndl = @(t)(emg_pattern1(t,4,50,-1,10));
emg.simulate({emg_fctn_hndl,emg_fctn_hndl,emg_fctn_hndl,emg_fctn_hndl,emg_fctn_hndl,emg_fctn_hndl});
emg.save(FOLDER,'\emg\emg_abd_conb_S01.mat');
%Conventional Therapy
emg_fctn_hndl = @(t)(emg_pattern1(t,4,500,-1,10));
emg.simulate({emg_fctn_hndl,emg_fctn_hndl,emg_fctn_hndl,emg_fctn_hndl,emg_fctn_hndl,emg_fctn_hndl});
emg.save(FOLDER,'\emg\emg_abd_cont_S01.mat');
%Robot Baseline
emg_fctn_hndl = @(t)(emg_pattern1(t,4,50,-1,10));
emg.simulate({emg_fctn_hndl,emg_fctn_hndl,emg_fctn_hndl,emg_fctn_hndl,emg_fctn_hndl,emg_fctn_hndl});
emg.save(FOLDER,'\emg\emg_abd_robb_S01.mat');
%Robot Therapy
emg_fctn_hndl = @(t)(emg_pattern1(t,4,500,-1,10));
emg.simulate({emg_fctn_hndl,emg_fctn_hndl,emg_fctn_hndl,emg_fctn_hndl,emg_fctn_hndl,emg_fctn_hndl});
emg.save(FOLDER,'\emg\emg_abd_robt_S01.mat');
%Bridget
emg_fctn_hndl = @(t)(emg_pattern1(t,4,500,-1,10));
emg.simulate({emg_fctn_hndl,emg_fctn_hndl,emg_fctn_hndl,emg_fctn_hndl,emg_fctn_hndl,emg_fctn_hndl});
emg.save(FOLDER,'\emg\emg_abd_bri_S01.mat');

%% Plot for check
t_emg = 1:(1/emg_Fs):10;
t_moc = 1:(1/moc_Fs):10;
figure()
subplot(3,1,1)
plot(t_moc,moc.A_theta(1,1:length(t_moc)))
subplot(3,1,2)
plot(t_emg,emg.Data{1,2}(1:length(t_emg)))
subplot(3,1,3)
plot(t_emg,emg.Data{1,10}(1:length(t_emg)))
