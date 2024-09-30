%Use to simulate mvc with emg_data class
function [y] = emg_pattern_mvc(T,emg_Fs,amplitude,sigma)
y = ones(T*emg_Fs,1);
y = y.*amplitude;
y = y + normrnd(0,sigma,length(y),1);
[b,a] = butter(4,0.3);
y = filtfilt(b,a,y);
end