function [y] = emgSRE11(emg_signal)
fs = 2000
Wn2=10/(fs/2); % Wn = cutoff frequency for filtering
Wn3=800/(fs/2);
[b2,a2]=butter(5,Wn2,'high'); %high pass filter coefficients: 5 = order of the filter
[b3,a3]=butter(5,Wn3,'low'); %low pass filter coefficients

y = filtfilt(b2,a2,emg_signal); % EMG high filtering
y = filtfilt(b3,a3,y); % EMG low filtering 
y = abs(y); % rectifying (all data are turned to positive)
y = smooth(y,500); % smoothing (envelope defined)
end