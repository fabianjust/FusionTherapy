%prepare_measurment_data
%
%Author: David Mauderli - 2019
%
%DESCRIPTION: This function generates the structure array subject, which
%contains the filtered, normalized, rectified and cutted EMG signal of
%every movement-condition EMG. The user first specifies a subject_** folder
%to process. The function then creates a struct containing all matching
%measurment data. Then the mocap anatomical coordinate system is
%calibrated. Afterwards it computes joint angles, filters and rectifies emg
%data and finally cuts emg data into its repetitions (based on maximum and
%minimum distance from start/stop).
%
%INPUT:
%
%OUTPUT:
%struct subject: structure array that contains all cutted emg data


function [subject] = analyze_BridgeT(path)
%% Get file paths of measurment files to be processed
%NOTE conventions: path variables in capital letters
%User specifies measurment data folder to process
if nargin ==0
    SUBJECT = uigetdir(pwd,'Enter subject_** path');
else
    SUBJECT = path;
end

%Load metainfo file --> It contains information we will need for further
%processing
METAINFO = strcat(SUBJECT,'\metainfo.mat'); %Metainfo file
load(METAINFO);

%Collect all filepaths --> list with all files to process
[exp_files, mvcs, ref] = collect_files(SUBJECT,metainfo);

%% Calibration of MoCap Data
%Call the calibration procedure in order to obtain the anatomical
%coordinate systems. Check if segments_calibration.mat has already been
%computed.
try
    SEGMENTS_CALIBRATION = strcat(SUBJECT,'\analysis\segments_calibration_S',metainfo.snum,'.mat');
    if(exist(SEGMENTS_CALIBRATION)==2)
        load(SEGMENTS_CALIBRATION)
    else
        segments_calibration = mocap_calibration(ref);
        save(SEGMENTS_CALIBRATION,'segments_calibration');
    end
    ref.ignore = false;
catch ME
    warning('MoCap Reference Missing: No Jointangles will be computed')
    ref.ignore = true;
end

%% Cut EMG/MOCAP repetition-wise --> subject.movement.condition.repetition
%Iterate through each file that has been collected above. Cut EMG with
%MOCAP data into N repetitions.
moc_Fs = 120;
for i = 1:length(exp_files)

    %Find movement number (We use a convention, so that each indice
    %corresponds to the same movement/condition for every subject)
    n_mov = exp_files(i).movement;
    i_mov = get_imov(n_mov);

    %Find condition number
    n_con = exp_files(i).condition;
    i_con = get_icon(n_con);
    
    %MOCAP: LOAD MOCAP DATA
    %Check if mocap data has already been processed before
    %If not: Process it and save for next time
    %If yes: Load variables
    i_fname = strfind(exp_files(i).MOC_FNAME,'\moc_');
    FILE_I = ...
        [SUBJECT,'\analysis',...
        exp_files(i).MOC_FNAME(i_fname:(end-4)),'_preprocessed.mat'];
    if(exist(FILE_I)==0)
        %Load MoCap Data, fill small gaps and extract segments
        marker_tracking = import_mocap_data(exp_files(i).MOC_FNAME);
        marker_tracking = fill_gaps(marker_tracking,6);
        
        if ~ref.ignore      %If ignore flag set: no jointangles will be computed
            %Compute jointangles
            joint_angles = compute_joint_angles(marker_tracking,segments_calibration);
        else
            joint_angles = [];
        end
       
        %Create structure with all data we need in order to cut emg and
        %jointangles
        cutdata = build_cutdata(marker_tracking,exp_files(i).movement,exp_files(i).condition, metainfo.bpm);

        %Find start/stop timestamps. If ef (errorflag) is true, skip the current file.
        [t_start, t_stop, moc_start, moc_stop, ef] = find_startstop(cutdata,moc_Fs,0.3,12,true);
        if ef==true
            warning(strcat(exp_files(i).movement,' ,',exp_files(i).condition,' has been skipped!'))
            continue
        end
        
        %Import emg data and apply SRE
        emg_data = load_emg(exp_files(i).EMG_FNAME);
        emg_data = emg_SRE(emg_data);
        
        %Save variables (save time in future iterations)
        save(FILE_I,'cutdata','joint_angles','t_start','t_stop',...
            'moc_start','moc_stop','emg_data')
    else
        load(FILE_I,'cutdata','joint_angles','t_start','t_stop',...
            'moc_start','moc_stop','emg_data');
    end   
    
    %CUT THE DATA: ITERATE THROUGH INTERVALS OF INTEREST AND CUT DATA. THEN
    %ADD CUTTED REPETITION DATA TO STRUCT
    for i_rep=1:length(t_start)

        %Cut EMG and MoCap data with mocap indices
        repetition = cut_measurment_data(emg_data,joint_angles,cutdata,moc_start(i_rep),moc_stop(i_rep),moc_Fs);
        %Add current repetition to data structure
        subject.movement(i_mov).condition(i_con).repetition(i_rep) = repetition;
        
        %Add mocement and condition names
        subject.movement(i_mov).name = n_mov;
        subject.movement(i_mov).condition(i_con).name = exp_files(i).condition;
    end
   
end
%% Compute Means,Max values, etc... (summarize repetitions) --> subject.movement.condition
subject = evaluateRepetitions(subject);
%% Copy metainfo to structure --> subject.metainfo
subject.metainfo = metainfo;

%% Compute MVC values for each muscle --> subject.muscle_info
% for i = 1:length(mvcs)
%     i_mus = get_imus(mvcs(i).muscle);
%     i_mvc = compute_mvc(mvcs(i).MVC,i_mus);
%     subject.muscle_info(i_mus).mus_name = mvcs(i).muscle;
%     subject.muscle_info(i_mus).mvc_name = mvcs(i).name;
%     subject.muscle_info(i_mus).mvc = i_mvc;
% end
subject = mvc_glidingWindow(subject,mvcs);
%% Compute differences between conditions (Dynamic Time Warping) --> subject.movementRES
subject = emgDifference(subject,'emgDtw');

%% Save Data
%Save file
SUBJECT_STRUCT = strcat(SUBJECT,'\analysis\subject_',metainfo.snum,'.mat');

%Check if file already exists -->Ask user if its ok to overwrite
if(exist(SUBJECT_STRUCT)==2)
    msg = strcat(strrep(SUBJECT_STRUCT,'\','\\'), ' already exists. Save anyway and override old version?');
    h = questdlg(msg,'Yes','No');
    switch h
        case 'Yes'
            save(SUBJECT_STRUCT,'subject');
        otherwise
            save(strcat(SUBJECT_STRUCT(1:(end-4)),'_n.mat'),'subject');
    end
else
    save(SUBJECT_STRUCT,'subject');
end
        
    
end