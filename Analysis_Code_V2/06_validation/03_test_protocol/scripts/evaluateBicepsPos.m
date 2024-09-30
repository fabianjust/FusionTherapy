%%
PATH = 'C:\Users\david\Documents\21_Polybox\Shared\RogerBeyelerInternshipARMin\Analysis_Code\Analysis_Code_V2\06_validation\03_test_protocol\data\subject_10'
mocFiles = {'moc_fle_conb_S10.csv','moc_fle_cont_S10.csv'};
emgFiles = {'emg_fle_conb_S10.mat','emg_fle_cont_S10.mat'};
cases = {'conb','cont'};
for jCase = 1:2
    
    %Assemble absolute filenames
    currentMocFile = [PATH,'\mocap\',mocFiles{jCase}];
    currentEmgFile = [PATH,'\emg\',emgFiles{jCase}];
    
    %Import mocap data
    marker_tracking = import_mocap_data(currentMocFile);
    marker_tracking = fill_gaps(marker_tracking,6);

    %Create structure with all data we need in order to cut emg and
    %jointangles
    cutdata = build_cutdata(marker_tracking,'fle',currentMocFile, 60);

    %Find start/stop timestamps. If ef (errorflag) is true, skip the current file.
    [t_start, t_stop, moc_start, moc_stop, ef] = find_startstop(cutdata,120,0.3,12,true);
        
    %Import emg data and apply SRE
    emg_data = load_emg_biceps_comparison(currentEmgFile);
    emg_data = emg_SRE(emg_data);
    
    for i_rep=1:length(t_start)
        %Cut EMG and MoCap data with mocap indices
        repetition = cut_measurment_data(emg_data,[],cutdata,moc_start,moc_stop,120,i_rep);
        %Add current repetition to data structure
        subject.movement(1).condition(jCase).repetition(i_rep) = repetition;
    end
    subject.movement(1).name = 'fle';
    subject.movement(1).condition(jCase).name = cases{jCase};
    
    muscles = {'pd','ad','pm','bb','lt','b2'};
    mvcFiles = {'emg_mvc_ecan_S10.mat','emg_mvc_sfle_S10.mat',...
        'emg_mvc_ppre_S10.mat','emg_mvc_efle_S10.mat','emg_mvc_eext_S10.mat','emg_mvc_efle_S10.mat'};
    mvcNames = {'ecan','sfle','ppre','efle','eext','efle'};
    
    for i_mus = 1:6
        currentMvcFile = [PATH,'\emg\',mvcFiles{i_mus}];
        i_mvc = compute_mvc(currentMvcFile,i_mus);
        subject.muscle_info(i_mus).mus_name = muscles{i_mus};
        subject.muscle_info(i_mus).mvc_name = mvcNames{i_mus};
        subject.muscle_info(i_mus).mvc = i_mvc;
    end
    
end

subject = resize_emg(subject,4000);
subject = meanandcfd_of_conditions(subject);

contSig = subject.movement(1).condition(2).emg_mean(:,[4,6]);
conbSig = subject.movement(1).condition(1).emg_mean(:,[4,6]);
conDiff = contSig-conbSig;
mvcs = [subject.muscle_info([4,6]).mvc];

conDiffMVC = conDiff./mvcs;
conbSigMVC = conbSig./mvcs;
contSigMVC = contSig./mvcs;

%% Plotting
figure()
x = linspace(0,1,4000);

subplot(2,1,1)

plot(x,conDiff)
legend({'Biceps BridgeT','Biceps Seniam'})
xlabel('Normed Time')
ylabel('EMG Activity [\muV]')
title('No MVC, Baseline subtracted')

subplot(2,1,2);

plot(x,conDiffMVC)
legend({'Biceps BridgeT','Biceps Seniam'})
xlabel('Normed Time')
ylabel('MVC Normed EMG Activity')
title('MVC, Baseline subtracted')

    


