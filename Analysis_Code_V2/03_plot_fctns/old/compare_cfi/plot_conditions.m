%Description: This function generates plots that compare conventional,
%robotic and bridget emg signals for the movement "i_mov" and muscle
%"i_mus". Type specifies wether baseline shall be subtracted (1,2: no; 3,4:
%yes) or wether data shall be mvc-normed (1,3: no; 2,4: yes).

function [plth,leg_text] = plot_conditions(axh,vararin,i_mov,i_mus,type)

%Specify plotcolors
colors = [0    0.4470    0.7410;...
    0.8500    0.3250    0.0980;...
    0.9290    0.6940    0.1250;...
    0.4940    0.1840    0.5560;...
    0.4660    0.6740    0.1880;...
    0.3010    0.7450    0.9330;...
    0.6350    0.0780    0.1840];

%Prepare data according to specification
mov = vararin.movement(i_mov);

condition(1).name = 'conventional';
condition(1).mean = mov.condition(get_icon('cont')).emg_mean(:,i_mus);
condition(1).cfiwidth = mov.condition(get_icon('cont')).emg_cfiwidth(:,i_mus);
condition(2).name = 'robotic';
condition(2).mean = mov.condition(get_icon('robt')).emg_mean(:,i_mus);
condition(2).cfiwidth = mov.condition(get_icon('robt')).emg_cfiwidth(:,i_mus);
condition(3).name = 'bridget';
condition(3).mean = mov.condition(get_icon('bri')).emg_mean(:,i_mus);
condition(3).cfiwidth = mov.condition(get_icon('bri')).emg_cfiwidth(:,i_mus);

switch type
    %Type 1: no mvc, no baseline
    case 'm0b0'

    %Type 2: mvc, no baseline
    case 'm1b0'
        for i=1:3
            condition(i).mean = condition(i).mean/vararin.muscle_info(i_mus).mvc;
            condition(i).cfiwidth = condition(i).cfiwidth/vararin.muscle_info(i_mus).mvc;
        end
    %Type 3: no mvc, baseline
    case 'm0b1'
        baseline = mov.condition(get_icon('conb')).emg_mean(:,i_mus);
        condition(1).mean = condition(1).mean - baseline;
        baseline = mov.condition(get_icon('robb')).emg_mean(:,i_mus);
        condition(2).mean = condition(2).mean - baseline;
        condition(3).mean = condition(3).mean - baseline;
    %Type 4: mvc, baseline
    case 'm1b1'
        baseline = mov.condition(get_icon('conb')).emg_mean(:,i_mus);
        condition(1).mean = condition(1).mean - baseline;
        baseline = mov.condition(get_icon('robb')).emg_mean(:,i_mus);
        condition(2).mean = condition(2).mean - baseline;
        condition(3).mean = condition(3).mean - baseline;
        
        for i=1:3
            condition(i).mean = condition(i).mean/vararin.muscle_info(i_mus).mvc;
            condition(i).cfiwidth = condition(i).cfiwidth/vararin.muscle_info(i_mus).mvc;
        end
    end

n_frames = size(condition(1).mean,1);
x = linspace(0,100,n_frames)';
for i_con = 1:3
    y = condition(i_con).mean;
    plth{1,i_con} = plot(x,y,'Color',colors(i_con,:),'LineWidth',2,'LineStyle','-');
    hold on
    leg_text{1,i_con} = strcat("Mean ", condition(i_con).name);

    lower_bound = condition(i_con).mean - condition(i_con).cfiwidth;
    upper_bound = condition(i_con).mean + condition(i_con).cfiwidth;
    plot(x,lower_bound,'Color',colors(i_con,:),'LineWidth',1.5,'LineStyle','--');
    plot(x,upper_bound,'Color',colors(i_con,:),'LineWidth',1.5,'LineStyle','--');
    set(gcf,'Visible','off'),
end
hold off
%legend(plth,leg_text)
title(strcat("Condition comparison: ",mov.name,", ",mov.condition(1).repetition(1).emg_descr(i_mus)))
xlabel('Time [%]')
ylabel('Activity [uV]')

switch type
    case 'm1b0'
        ylabel('Activity/mvc')
    case 'm1b1'
        ylabel('Activity/mvc')
end
end