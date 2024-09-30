%filter_emg
%
%Author: Gabriela Gerber, adapted by David Mauderli
%
%DESCRIPTION: This function iterates through the vararin (subject) struct
%and filters every repetition with a series of filters. It copies vararin
%to vararout and adds a new field to the repetitions field.
%
%INPUT:
%struct vararin: subject struct with cuttet emg data
%OUTPUT:
%struct vararout: vararin with new file that contains filtered data

function [vararout] = filter_emg(vararin)

vararout = vararin;

%% Design Filter
%Design high pass and low pass filter for later use
fs = vararin.movement(1).condition(1).repetition(1).emgraw_Fs;
Wn2=10/(fs/2); % Wn = cutoff frequency for filtering
Wn3=800/(fs/2);
[b2,a2]=butter(5,Wn2,'high'); %high pass filter coefficients: 5 = order of the filter
[b3,a3]=butter(5,Wn3,'low'); %low pass filter coefficients

%% Filter all emg data
%Iterate through every movement, condition and repetition: Filter and
%rectify
for i_mov = 1:length(vararin.movement)
    for i_con = 1:length(vararin.movement(i_mov).condition)
        for i_rep = 1:length(vararin.movement(i_mov).condition(i_con).repetition)
            assert(vararin.movement(i_mov).condition(i_con).repetition(i_rep).emgraw_Fs == fs,...
               'filter_emg:fs_error','Sampling Frequency is not equal for all emg takes!')
            
            %Copy current emg (of current repetition)
            curr_emg = vararin.movement(i_mov).condition(i_con).repetition(i_rep).emgraw;
            
            %Allocate memory
            n_frames = size(curr_emg,1);
            n_muscles = size(curr_emg,2);
            envelope = NaN(n_frames,n_muscles);
                
            %Iterate through every muscle -->Filter row-wise
            for i_muscle=1:n_muscles
                 EMGfilt1 = filtfilt(b2,a2,curr_emg(:,i_muscle)); % EMG high filtering
                 EMGfilt = filtfilt(b3,a3,EMGfilt1(:)); % EMG low filtering 
                 RECT_emg = abs(EMGfilt); % rectifying (all data are turned to positive)
                 EMG_envelope = smooth(RECT_emg,500); % smoothing (envelope defined)
                 envelope(:,i_muscle) = EMG_envelope; %Write to solution vector
            end            
            if(any(any(isnan(envelope))))
                warning('filter_emg:filter_error','filter output contains NaNs')
            end
            
            %Overwrite emg data in output 
            vararout.movement(i_mov).condition(i_con).repetition(i_rep).emg = envelope;
            
        end
    end
end


end