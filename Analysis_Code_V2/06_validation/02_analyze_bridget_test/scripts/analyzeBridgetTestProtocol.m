%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%analyze_BridgeT Test Protocol%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1.) Simulation Properties
moc_Fs = 120;
emg_Fs = 2000;
nRep = 12;
secPerRep = 4;
T_rec = nRep*secPerRep;
FOLDER = 'C:\Users\david\Documents\21_Polybox\Shared\RogerBeyelerInternshipARMin\Analysis_Code\Analysis_Code_V2\06_validation\data\subject_01'

%% 2.) Simulate Ideal MoCap Calibration
%Reference Position
calibration_movement = mocap_data(moc_Fs,5);
calibration_movement.setMarkersRefpos(0.2,0.35,0.35);
const = @(t)(0);
calibration_movement.setTheta({const, const, const, const, const},zeros(1,5));
calibration_movement.simulate(1,1);
calibration_movement.save(FOLDER, '\mocap\moc_Calibration_S01.csv')

%Jointcenter File
sinabd = @(t)(-45*sin(2*pi/2*t+0));
sinele = @(t)(-45*sin(2*pi/2*t+pi/2));
sinrot = @(t)(-45*sin(2*pi/2*t+pi/4)+70);
calibration_movement.setTheta({sinabd,sinele,sinrot,@(t)(90),const},zeros(1,5));
calibration_movement.simulate(1,1);
calibration_movement.save(FOLDER, '\mocap\moc_Jointcenter_S01.csv')
clear calibration_movement

%% 3.) Test 1: Signal on Muscle in = Signal on Muscle out?

%MOCAP: Sinusoid Abduction movement for cutdata.
%Create instance of mocap simulation
moc = mocap_data(moc_Fs,T_rec);
%Define skeleton
moc.setMarkersRefpos(0.2,0.35,0.35);
%Define functions for joint angles (joint-time-space)
const = @(t)(0);
sinabd = @(t)(45/2*sin(2*pi/4*t)-45/2);
moc.setTheta({sinabd, const, const, const, const},[0,0,0,0,0]);
%Simulate Movement and save
moc.simulate(1,3);
moc.save(FOLDER,'\mocap\moc_abd_conb_S01.csv')
conditions = {'cont','robb','robt','bri'};
for i =1:(length(conditions))
    copyfile([FOLDER,'\mocap\moc_abd_conb_S01.csv'],...
        [FOLDER,'\mocap\moc_abd_',conditions{i},'_S01.csv'])
end

%EMG: MVC = 1 for each muscle
emg = emg_data(emg_Fs,5);
emg_mvc1 = @(t)(emg_pattern_mvc(5,emg_Fs,10000,0));
emg.simulate({emg_mvc1,emg_mvc1,emg_mvc1,emg_mvc1,emg_mvc1,emg_mvc1},true);
emg.save(FOLDER,'\emg\emg_mvc_ecan_S01.mat');
emg_mvc1 = @(t)(emg_pattern_mvc(5,emg_Fs,1000,0));
emg.simulate({emg_mvc1,emg_mvc1,emg_mvc1,emg_mvc1,emg_mvc1,emg_mvc1},true);
emg.save(FOLDER,'\emg\emg_mvc_sfle_S01.mat');
emg_mvc1 = @(t)(emg_pattern_mvc(5,emg_Fs,100,0));
emg.simulate({emg_mvc1,emg_mvc1,emg_mvc1,emg_mvc1,emg_mvc1,emg_mvc1},true);
emg.save(FOLDER,'\emg\emg_mvc_ppre_S01.mat');
emg_mvc1 = @(t)(emg_pattern_mvc(5,emg_Fs,10,0));
emg.simulate({emg_mvc1,emg_mvc1,emg_mvc1,emg_mvc1,emg_mvc1,emg_mvc1},true);
emg.save(FOLDER,'\emg\emg_mvc_efle_S01.mat');
emg_mvc1 = @(t)(emg_pattern_mvc(5,emg_Fs,100000,0));
emg.simulate({emg_mvc1,emg_mvc1,emg_mvc1,emg_mvc1,emg_mvc1,emg_mvc1},true);
emg.save(FOLDER,'\emg\emg_mvc_eext_S01.mat');


%% Apply constant signals on each muscle:
%conb = 0, cont = 1000, robb = 500, robt = 1000, bri = 800
emgHigh = @(t)(1000*linspace(1,1,length(t)));
emgBase = @(t)(500*linspace(1,1,length(t)));
emgBri = @(t)(800*linspace(1,1,length(t)));
emgLow = @(t)(0*linspace(1,1,length(t)));
emg = emg_data(emg_Fs,T_rec);
for i_mus = 1:6
    try
    delete([FOLDER,'\analysis\moc_abd_bri_S01_preprocessed.mat'])
    delete([FOLDER,'\analysis\moc_abd_robt_S01_preprocessed.mat'])
    delete([FOLDER,'\analysis\moc_abd_robb_S01_preprocessed.mat'])
    delete([FOLDER,'\analysis\moc_abd_conb_S01_preprocessed.mat'])
    delete([FOLDER,'\analysis\moc_abd_cont_S01_preprocessed.mat'])
    delete([FOLDER,'\analysis\subject_01.mat'])
    end
    %Set all functions to constant zero
    emgFctn = {emgLow, emgLow, emgLow, emgLow, emgLow, emgLow};
    %simulate and save
    emg.simulate(emgFctn,false);
    emg.save(FOLDER,'\emg\emg_abd_conb_S01.mat');
    
    %Build functions for cont/robt: current muscle has high activity
    emgFctn{i_mus} = emgHigh;
    %simulate and save
    emg.simulate(emgFctn,false);
    emg.save(FOLDER,'\emg\emg_abd_cont_S01.mat');
    emg.save(FOLDER,'\emg\emg_abd_robt_S01.mat');
    
    %Build functions for robb: current muscle has high activity
    emgFctn{i_mus} = emgBase;
    %simulate and save
    emg.simulate(emgFctn,false);
    emg.save(FOLDER,'\emg\emg_abd_robb_S01.mat');
    
    %Build functions for bri: current muscle has medium activity
    emgFctn{i_mus} = emgBri;
    %simulate and save
    emg.simulate(emgFctn,false);
    emg.save(FOLDER,'\emg\emg_abd_bri_S01.mat');
    
    % BridgeT analysis
    SUBJECT = [FOLDER,'\analysis\subject_01.mat'];
    analyze_BridgeT(FOLDER);

    
    %Make Plots of input data
    myData = emg_plt(SUBJECT);
    PLOTFOLDER = [FOLDER,'\analysis\input'];
    if ~isfolder(PLOTFOLDER)
        mkdir(PLOTFOLDER)
    end
    
    for i_mus2 = 1:6
        figure()
        for j_con = 1:5
            myData.plotRaw('abd', {get_ncon(j_con)}, get_nmus(i_mus2,false), true, true);
        end
        myData.draw(true,3,2);
        FNAME = [PLOTFOLDER,'\input_simulate_',get_nmus(i_mus,false),'_mus_',get_nmus(i_mus2,false),'.fig'];
        myData.save(FNAME);
        myData.newFigure();
    end
    
    %Make Plots of output data
    PLOTFOLDER = [FOLDER,'\analysis\condPlot'];
    if ~isfolder(PLOTFOLDER)
        mkdir(PLOTFOLDER)
    end
    for i_mus2 = 1:6
    myData.plotComp('abd',get_nmus(i_mus2,false), true)
    end
    myData.draw(true,3,2);
    FNAME = [PLOTFOLDER,'\condPlot_',get_nmus(i_mus,false),'.fig'];
    myData.save(FNAME);
    myData.newFigure();
    close all
    
end

%% 




