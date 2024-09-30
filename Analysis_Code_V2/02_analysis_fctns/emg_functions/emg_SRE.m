function [vararout] = emg_SRE(emg)

fs = emg.fs;
Wn2=10/(fs/2); % Wn = cutoff frequency for filtering
Wn3=800/(fs/2);
[b2,a2]=butter(5,Wn2,'high'); %high pass filter coefficients: 5 = order of the filter
[b3,a3]=butter(5,Wn3,'low'); %low pass filter coefficients

envelope = NaN(length(emg.data),6);
for i_muscle=1:6
    EMGfilt1 = filtfilt(b2,a2,emg.data(:,i_muscle)); % EMG high filtering
    EMGfilt = filtfilt(b3,a3,EMGfilt1(:)); % EMG low filtering 
    RECT_emg = abs(EMGfilt); % rectifying (all data are turned to positive)
    EMG_envelope = smooth(RECT_emg,500); % smoothing (envelope defined)
    envelope(:,i_muscle) = EMG_envelope;%EMG_envelope; %Write to solution vector
end

vararout.fs = fs;
vararout.data = envelope;
vararout.data_descr = emg.data_descr;
end