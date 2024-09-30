%Plot raw emg data into axes axh
function [] = plotRaw(axh,subject,PATH,iMov,iCon,iMus,boolSre)
sname = subject.metainfo.sname;
RAWDATA = [PATH,'\emg\emg_',get_nmov(iMov),'_',get_ncon(iCon),'_S',num2str(subject.metainfo.snum),'.mat'];
emg_data = load_emg(RAWDATA);
if(boolSre)
    emg_data = emg_SRE(emg_data);
end
y_data = emg_data.data(:,iMus);
x_data = linspace(0,100,length(y_data));
mvcval = subject.muscle_info(iMus).mvc;
line(axh,x_data,y_data,'Color','black');
line(axh,[0,100],[mvcval, mvcval],'Color','red')
xlabel('Time [%]')
ylabel('EMG Signal [\muV]')
end