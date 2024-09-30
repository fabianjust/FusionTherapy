%Use to simulate sawtooth signal with emg_data class
function [y] = emg_pattern1(t,t_cycle,amplitude,t_phase,sigma)
t = t-t_phase;
bool_flat = mod(t,t_cycle)<=(0.5*t_cycle);
y(bool_flat) = 0;

t_new = t(~bool_flat);
y(~bool_flat) = amplitude*(mod(t_new,t_cycle)-0.5*t_cycle)/(0.5*t_cycle);
y = y + normrnd(0,sigma,1,length(y));
[b,a] = butter(4,0.3);
y = filtfilt(b,a,y)';


end