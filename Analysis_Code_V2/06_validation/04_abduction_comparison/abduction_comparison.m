%%
%Collect files
cmap = lines(6);
PATH = 'C:\Users\david\Documents\21_Polybox\Shared\RogerBeyelerInternshipARMin\Testdata\peter_911';
basename = {'\emg_abd_bri_'}
conditions = {'v3','v4','v5','v6'}
conditions_names = {'Bridget 100','Bridget 70', 'Baseline','Bridget 100 new'}
for i_con = 1:length(conditions)
    FNAME = [PATH,basename{1},conditions{i_con},'_S11.mat'];
    emgData(i_con) = load_emg(char(FNAME));
end

for i_mus = 1:6
    figure()
    for i_con = 1:length(conditions)
        x = 1:1:length(emgData(i_con).data);
        x = x/2000;
        line(x,emgSRE11(emgData(i_con).data(:,i_mus)),'Color',cmap(i_con,:));
        hold on;
    end
    xlabel('Time [s]')
    ylabel('SRE EMG [\muV]')
    title(['Muscle: ',get_nmus(i_mus,true)])
    legend(conditions_names)
    name= [PATH,basename{1},'plot_abd_',get_nmus(i_mus,false),'.fig'];
    saveas(gcf,char(name));
end
  %%
  %Collect files
cmap = lines(6);
PATH = 'C:\Users\david\Documents\21_Polybox\Shared\RogerBeyelerInternshipARMin\Testdata\peter_911';
basename = {'\emg_mj1_'}
conditions = {'bri','bri_v2','robb','robt'}
conditions_names = {'Imitate 100','Imitate 100 v2','Baseline','Teach'}
for i_con = 1:length(conditions)
    FNAME = [PATH,basename{1},conditions{i_con},'_S11.mat'];
    emgData(i_con) = load_emg(char(FNAME));
end

for i_mus = 1:6
    figure()
    for i_con = 1:length(conditions)
        x = 1:1:length(emgData(i_con).data);
        x = x/2000;
        line(x,emgSRE11(emgData(i_con).data(:,i_mus)),'Color',cmap(i_con,:));
        hold on;
    end
    xlabel('Time [s]')
    ylabel('SRE EMG [\muV]')
    title(['Muscle: ',get_nmus(i_mus,true)])
    legend(conditions_names)
    name= [PATH,basename{1},'plot_mj1_',get_nmus(i_mus,false),'.fig'];
    saveas(gcf,char(name));
end
    