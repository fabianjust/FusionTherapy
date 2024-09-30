function [subject] = mvc_percentage(mvcs) % add subject
% MVC_new defins the MVC for each muscle and saves it to the subject struct

for i = 1:length(mvcs)
    % 1. Get relevant raw data
    i_mus = get_imus(mvcs(i).muscle);
    mvc_mean_all = zeros(1,3);
    
    for k = 1:3 % Number of MVC repetitions
    mvc_data_all = mvcs(i).MVC(k).Repetition;
    mvc_data_movement = load(mvc_data_all);
    mvc_muscle = mvc_data_movement.Data(i+1);
    mvc_muscle_i = mvc_muscle{1, 1};  
   
    % 2. Get SRE of raw data
    fs = mvc_data_movement.samplingRate;
    Wn2=10/(fs/2); % Wn = cutoff frequency for filtering
    Wn3=800/(fs/2);
    [b2,a2]=butter(5,Wn2,'high'); %high pass filter coefficients: 5 = order of the filter
    [b3,a3]=butter(5,Wn3,'low'); %low pass filter coefficients
    
    
    EMGfilt1 = filtfilt(b2,a2,mvc_muscle_i); % EMG high filtering
    EMGfilt = filtfilt(b3,a3,EMGfilt1); % EMG low filtering 
    RECT_emg = abs(EMGfilt); % rectifying (all data are turned to positive)
    EMG_envelope = smooth(RECT_emg,500); % smoothing (envelope defined)
    
    % 3. Determine MVC value for one repetition
    mvc_sorted = sort(EMG_envelope,'descend'); % sorts all elements of EMG_envelope in descending order
    mvc_top5 = mvc_sorted(1:ceil(length(mvc_sorted)*0.05)); % get top 5% of all values
    mvc_mean_rep = mean(mvc_top5); % mean of the top 5% of a single mvc repetition
    mvc_mean_all(1,k) = mvc_mean_rep; % save mvc mean of a single repetition
    end
    
    % 4. Determine final MVC value of all three repetitions
    i_mvc = max(mvc_mean_all); % Take maximum mvc value of the tree repetitions
    
    % 5. Save mvc information to subject struct
    subject.muscle_info(i_mus).mus_name = mvcs(i).muscle;
    subject.muscle_info(i_mus).mvc_name = mvcs(i).name;
    subject.muscle_info(i_mus).mvc = i_mvc;
end


end

