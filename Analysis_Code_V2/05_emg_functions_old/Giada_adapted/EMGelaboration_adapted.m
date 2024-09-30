function [SRE] = EMGelaboration_adapted(myfile)% filename = 'cut_name.mat'

load(myfile);

%% Filter
%Wn=[49/(samplingRate/2) 51/(samplingRate/2)];
Wn2=10/(samplingRate/2); % Wn = cutoff frequency for filtering
Wn3=400/(samplingRate/2);
%[b,a]=butter(5,Wn,'stop');
[b2,a2]=butter(5,Wn2,'high'); %high pass filter coefficients: 5 = order of the filter
[b3,a3]=butter(5,Wn3,'low'); %low pass filter coefficients


%% Signal Processing
movements = fieldnames(EMGraw);
n_movements = length(movements);
Nmuscles = noChans-3; % 3 Synch-Channels
SRE=struct();

for i = 1:n_movements
    curr_movement = char(movements(i));
    EMGfilt1 = [];
    EMGfil = [];
    RECT_emg = [];
    EMG_envelope = [];
    envelope = [];
    
        for k=1:Nmuscles
            EMG = EMGraw.(curr_movement);
            % EMGfilt2(:,k) = filtfilt(b,a,EMG(:,k));
            EMGfilt1 = filtfilt(b2,a2,EMG(:,k)); % EMG high filtering
            EMGfilt = filtfilt(b3,a3,EMGfilt1(:)); % EMG low filtering 
            % signal(:,k) = EMGfilt(:,k) - mean(EMGfilt(:,k)); % remove offset -> haben wir im Moment nicht
            RECT_emg = abs(EMGfilt); % rectifying (all data are turned to positive)
            EMG_envelope = smooth(RECT_emg,500); % smoothing (envelope defined)
            envelope = [envelope,EMG_envelope];
            SRE.(curr_movement) = envelope;

           % meanEMG(k) = mean(EMG_envelope(:,k)); % mean of processed data for each muscle
        end
end

% FT_signal = fft(signal);
% PSD = ((1/samplingRate)/length(signal))*(abs(FT_signal)).^2;
% f_Nyq = samplingRate/2;
% frequency = (linspace(0,f_Nyq,length(PSD)/2))';

% figure
% plot(frequency,PSD(1:size(frequency)));
% xlabel('Freq [Hz]'); ylabel('mV^2/Hz');

% figure
% title(FILENAME);
% for i=1:6
%     subplot(3,2,i)
%     plot(t(1:end-1),RECT_emg(:,i)); 
%     ylabel('mV'); xlabel('time [s]');
%     title(channelNames{1,i});
%     hold on
%     plot(t(1:end-1),EMG_envelope(:,i),'r','LineWidth',1.5);
%     plot(t(1:end-1),ones(1,length(signal))*meanEMG(i),'k','LineWidth',1.5);
% end

end

