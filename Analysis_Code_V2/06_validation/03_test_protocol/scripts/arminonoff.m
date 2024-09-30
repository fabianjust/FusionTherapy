PATH = 'C:\Users\david\Documents\21_Polybox\Shared\RogerBeyelerInternshipARMin\Testdata'
fs = 2000
Wn2=10/(fs/2); % Wn = cutoff frequency for filtering
Wn3=800/(fs/2);
[b2,a2]=butter(5,Wn2,'high'); %high pass filter coefficients: 5 = order of the filter
[b3,a3]=butter(5,Wn3,'low'); %low pass filter coefficients
envelope = NaN(length(emg_data.Data{1}),6);

mvcs = {'ecan','eext','efle','ppre','sfle'};
cases = {'3s','5s','v2_5s'};

for iMvc = 1:5
    for iMus= 1:6
        for icase = 1:3
            FNAME(icase) = [PATH,'\emg_mvc_',mvcs{iMvc},'_',cases{1},'.mat'];
            if isfile(FNAME(icase))
                emgData(icase)=load(FNAME);
                num = 3;
            else
                num = 2;
            end
        end
        
        figure()
        for icase = 1:3
            

        for i_muscle=2:7
            EMGfilt1 = filtfilt(b2,a2,emg_data.Data{i_muscle}); % EMG high filtering
            EMGfilt = filtfilt(b3,a3,EMGfilt1(:)); % EMG low filtering 
            RECT_emg = abs(EMGfilt); % rectifying (all data are turned to positive)
            EMG_envelope = smooth(RECT_emg,500); % smoothing (envelope defined)

        end
        legend({'Upper Trapezius','Posterior Deltoid','Anterior Deltoid',...
            'Pectoralis Major','Biceps Brachii','Lateral Triceps'})
