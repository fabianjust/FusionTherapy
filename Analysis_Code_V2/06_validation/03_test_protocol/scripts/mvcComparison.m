%%
PATH = 'C:\Users\david\Documents\21_Polybox\Shared\RogerBeyelerInternshipARMin\Testdata'
fs = 2000
Wn2=10/(fs/2); % Wn = cutoff frequency for filtering
Wn3=800/(fs/2);
[b2,a2]=butter(5,Wn2,'high'); %high pass filter coefficients: 5 = order of the filter
[b3,a3]=butter(5,Wn3,'low'); %low pass filter coefficients

mvcs = {'ecan','eext','efle','ppre','sfle'};
cases = {'3s','5s'};
colMap = lines(3);
for iMvc = 1:5
    figure()
    num = 0;
    for icase = 1:2
        
        FNAME = [PATH,'\emg_mvc_',mvcs{iMvc},'_',cases{icase},'.mat'];
        if isfile(FNAME)
            emgData(icase)=load(FNAME);
            num = num +1;
        else
            continue
        end
    end
    
    for iMus= 1:6
        subplot(3,2,iMus)
        for icase = 1:num
            y = filtfilt(b2,a2,emgData(icase).Data{iMus+1}); % EMG high filtering
            y = filtfilt(b3,a3,y); % EMG low filtering 
            y = abs(y); % rectifying (all data are turned to positive)
            y = smooth(y,500); % smoothing (envelope defined)
            line(emgData(icase).Data{1},y,'Color',colMap(icase,:));
            hold on
        end
        legend({'3 sec','5 sec','v2_5s'})
        xlabel('Time [s]')
        ylabel('SRE EMG \muV')
        title(['Muscle: ',get_nmus(iMus,true), ' MVC: ',mvcs{iMvc}]) 
    end
end
        