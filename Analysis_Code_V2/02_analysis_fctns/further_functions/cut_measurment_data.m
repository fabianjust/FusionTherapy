function [repetition] = cut_measurment_data(emg_data,joint_angles,cutdata,moc_start,moc_stop,moc_Fs)
        %FIRST: Cut mocap data
        %Determine length of the interval & allocate memory
        d_ss = moc_stop-moc_start+1;
        mocap_srep = NaN(d_ss,5);

        %Cut MoCap joint angles of current repetition
        if(~isempty(joint_angles))
            mocap_srep(:,1) = joint_angles.shoulder1(moc_start:moc_stop);
            mocap_srep(:,2) = joint_angles.shoulder2(moc_start:moc_stop);
            mocap_srep(:,3) = joint_angles.shoulder3(moc_start:moc_stop);
            mocap_srep(:,4) = joint_angles.elbow(moc_start:moc_stop);
            mocap_srep(:,5) = joint_angles.pronation(moc_start:moc_stop);
        else
            mocap_srep = [];
        end
        
        mocap_endeff = cutdata.hand(1:3,moc_start:moc_stop);
        
        %Compute Joint velocities for every frame
        jointVelocities = NaN(d_ss,5);
        jointVelocities(2:(end-1),:) = 0.5*moc_Fs*(mocap_srep(3:end,:)-mocap_srep(1:(end-2),:));
        jointVelocities(1,:) = moc_Fs*(mocap_srep(2,:)-mocap_srep(1,:));
        jointVelocities(end,:) = moc_Fs*(mocap_srep(end,:)-mocap_srep((end-1),:));
       
        %Compute Joint accelerations for every frame
        jointAccelerations = NaN(d_ss,5);
        jointAccelerations(2:(end-1),:) = 0.5*moc_Fs*(jointVelocities(3:end,:)-jointVelocities(1:(end-2),:));
        jointAccelerations(1,:) = moc_Fs*(jointVelocities(2,:)-jointVelocities(1,:));
        jointAccelerations(end,:) = moc_Fs*(jointVelocities(end,:)-jointVelocities((end-1),:));

        %cut data with moc_start/stop indices (!!Different sampling freq!
        emg_start = floor(moc_start/moc_Fs*emg_data.fs);
        emg_stop = floor(moc_stop/moc_Fs*emg_data.fs);
        emg_srep = emg_data.data(emg_start:emg_stop,:);

        %THIRD: Write data to final struct
        %Assemble repetition struct
        repetition.t_start = moc_start/moc_Fs;
        repetition.t_stop = moc_stop/moc_Fs;
        repetition.moc_start = moc_start;
        repetition.moc_stop = moc_stop;
        repetition.jointAngles = mocap_srep;
        nrows = 240;
        ncols = size(mocap_srep,2);
        repetition.joint_angles_resized = imresize(mocap_srep,[nrows ncols],'bilinear');
        repetition.jointVelocities = jointVelocities;
        repetition.jointVelocitiesResized = imresize(jointVelocities,[nrows ncols],'bilinear');
        repetition.jointAccelerations = jointAccelerations;
        repetition.maxAbsJointVelocities= max(abs(jointVelocities),[],1);
        repetition.maxAbsJointAccelerations = max(abs(jointAccelerations),[],1);
        repetition.meanJointVelocities = mean(jointVelocities,1);
        repetition.moc_hand = mocap_endeff;
        repetition.moc_descr = {'Shoulder Abduction','Shoulder Flexion','Shoulder Rotation','Elbow Flexion','Pronation'};
        repetition.moc_Fs = 120;
        repetition.emgraw_start = emg_start;
        repetition.emgraw_stopp = emg_stop;
        repetition.emg_SRE = emg_srep;
        nrows = 4000;
        ncols = size(emg_srep,2);
        repetition.emg_resized = imresize(emg_srep,[nrows ncols],'bilinear');
        repetition.emg_descr = emg_data.data_descr;
        repetition.emgraw_Fs = emg_data.fs;
        repetition.bpm = cutdata.bpm;
end