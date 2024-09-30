%%plotConditionComparison
%DESCRIPTION: Plots mean EMG signal and confidence interval
%of all three conditions for one movement and one muscle.
%boolBaseline can be set to false if the plot shall be drawn without
%baseline subtraction.

function [ploth,legh] = plotConditionComparison(axh,subject,n_mov, n_mus, boolBaseline,boolLegend)

    %Get indices 
    i_mov = get_imov(n_mov);
    i_mus = get_imus(n_mus);
  
    %Collect plot data. (either with baseline or without)
    if boolBaseline %If baseline flag: take corresponding data
        data_con = subject.primaryOutcome(i_mov).meanCfi(1).mean(:,i_mus);
        data_rob = subject.primaryOutcome(i_mov).meanCfi(2).mean(:,i_mus);
        data_bri = subject.primaryOutcome(i_mov).meanCfi(3).mean(:,i_mus);
        titleText = ['Condition Comparison with Baseline',newline,...
            getFullName(n_mov),', ',getFullName(n_mus)];
    else %Else: Take data without baseline subtractopm
        valMVC = subject.muscle_info(i_mus).mvc; %This data is NOT mvc normed --> norm
        current_mov = subject.movement(i_mov).condition;
        data_con = current_mov(get_icon('cont')).emg_mean(:,i_mus)/valMVC;
        data_rob = current_mov(get_icon('robt')).emg_mean(:,i_mus)/valMVC;
        data_bri = current_mov(get_icon('bri')).emg_mean(:,i_mus)/valMVC;
        titleText = ['Condition Comparison without Baseline',newline,...
            getFullName(n_mov),', ',getFullName(n_mus)];
    end
    %Get confidence interval width
    cfiWidth_con = subject.primaryOutcome(i_mov).meanCfi(1).cfi(:,i_mus);
    cfiWidth_rob = subject.primaryOutcome(i_mov).meanCfi(2).cfi(:,i_mus);
    cfiWidth_bri = subject.primaryOutcome(i_mov).meanCfi(3).cfi(:,i_mus);
    
    %Get x-axis vector (0-100%)
    data_x = linspace(0,100,length(data_con));

    %Plot mean's and add legend description
    ploth(1) = line(axh,...
        data_x,data_con,'Color',[1,215/255,0],'LineStyle','-','LineWidth',1.5);
    legh{1} = 'Mean Conventional';
    
    ploth(2) = line(axh,...
        data_x,data_rob,'Color',[135/255,206/255,250/255],'LineStyle','-','LineWidth',1.5);
    legh{2} = 'Mean Teach';
    
    ploth(3) = line(axh,...
        data_x,data_bri,'Color','Black','LineStyle','-','LineWidth',1.5);
    legh{3} = 'Mean Imitate';
    
    %Plot intervals of confidence and add legend description
    ploth(4) = line(axh,...
        data_x,data_con+cfiWidth_con,'Color',[1,215/255,0],'LineStyle','--','LineWidth',1);
    line(axh,data_x,data_con-cfiWidth_con,...
        'Color',[1,215/255,0],'LineStyle','--','LineWidth',1);
    legh{4} = 'Confidence Interval Conventional';

    ploth(5) = line(axh,...
        data_x,data_rob+cfiWidth_rob,'Color',[135/255,206/255,250/255],'LineStyle','--','LineWidth',1);
    line(axh,data_x,data_rob-cfiWidth_rob,...
        'Color',[135/255,206/255,250/255],'LineStyle','--','LineWidth',1);
    legh{5} = 'Confidence Interval Teach';

    ploth(6) = line(axh,...
        data_x,data_bri+cfiWidth_bri,'Color','Black','LineStyle','--','LineWidth',1);
    line(axh,data_x,data_bri-cfiWidth_bri,...
        'Color','Black','LineStyle','--','LineWidth',1);
    legh{6} = 'Confidence Interval Imitate';
    
    %Set title and axeslabel
    title(axh,titleText);
    xlabel(axh,'Time [%]')
    ylabel(axh,'MVC normed EMG activity [-]')
    if boolLegend
        legend(axh,legh);
    end
    
end