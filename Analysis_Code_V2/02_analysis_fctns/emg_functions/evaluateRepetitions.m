function [vararout] = evaluateRepetitions(vararin)

%Copy struct
vararout = vararin;

%Iterate through every movement and condition. 
for i_mov = 1:length(vararin.movement)
    for i_con = 1:length(vararin.movement(i_mov).condition)
       
        %Copy relevant struct (make code easier to read)
        repetition = vararin.movement(i_mov).condition(i_con).repetition;
        
        %Some constants...
        n_rep = length(repetition); %Number of repetitions
        nFraEmg = length(repetition(1).emg_resized); %Number of EMG frames
        nFraMoc = length(repetition(1).joint_angles_resized);%Number of MoCap frames
        
        %Summarize emg&mocap data of all repetitions in one array
        emgAll = zeros(nFraEmg,6,n_rep); %3D array containing all emgData
        jointAnglesAll = zeros(nFraMoc,5,n_rep); %3D array containing all mocapData
        jointVelocitiesAll = zeros(nFraMoc,5,n_rep);
        meanJointVelocitiesAll = zeros(n_rep,5);
        maxJointVelocitiesAll = zeros(n_rep,5);
        maxJointAccelerationsAll = zeros(n_rep,5);
        
        
        for i_rep = 1:n_rep
            emgAll(:,:,i_rep) = repetition(i_rep).emg_resized;
            jointAnglesAll(:,:,i_rep) = repetition(i_rep).joint_angles_resized;
            jointVelocitiesAll(:,:,i_rep) = repetition(i_rep).jointVelocitiesResized;
            meanJointVelocitiesAll(i_rep,:) = repetition(i_rep).meanJointVelocities;
            maxJointVelocitiesAll(i_rep,:) = repetition(i_rep).maxAbsJointVelocities;
            maxJointAccelerationsAll(i_rep,:) = repetition(i_rep).maxAbsJointAccelerations;
        end
        emg_mean = mean(emgAll,3); %Mean emg signal of all repetitions for every frame
        jointAngles_mean = mean(jointAnglesAll,3); %Mean joint angles of all repetitions for every frame and dof
        jointVelocities_mean = mean(jointVelocitiesAll,3);
        %Write to output
        vararout.movement(i_mov).condition(i_con).emg_mean = emg_mean;
        vararout.movement(i_mov).condition(i_con).jointAngles_mean = jointAngles_mean;
        vararout.movement(i_mov).condition(i_con).jointVelocities_mean = jointVelocities_mean;
        vararout.movement(i_mov).condition(i_con).jointVelocities_meanmean = mean(meanJointVelocitiesAll,1);
        vararout.movement(i_mov).condition(i_con).jointVelocities_meanmax = mean(maxJointVelocitiesAll,1);
        vararout.movement(i_mov).condition(i_con).jointAccelerations_meanmax = mean(maxJointAccelerationsAll,1);
        
        % Compute Std deviation and Confidence Intervals and add to struct
        emgStd = std(emgAll,0,3);
        jointAnglesStd = std(jointAnglesAll,0,3);
        vararout.movement(i_mov).condition(i_con).emg_std = emgStd;
        vararout.movement(i_mov).condition(i_con).jointAngles_std = jointAnglesStd;

        %Compute confidence interval width and add to struct
        Z = 1.96; % -> Annahme normalverteilte Daten
        emg_cfiwidth = Z*emgStd./sqrt(n_rep);
        jointAngles_cfiwidth = Z*jointAnglesStd./sqrt(n_rep);
        vararout.movement(i_mov).condition(i_con).emg_cfiwidth = emg_cfiwidth;
        vararout.movement(i_mov).condition(i_con).jointAngles_cfiwidth = jointAngles_cfiwidth;

end
end