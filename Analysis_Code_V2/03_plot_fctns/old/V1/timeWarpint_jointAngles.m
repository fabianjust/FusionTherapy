%% Plot Joint Angle Mapping
x = linspace(0,1,4000)
cmap = lines(5);
for i_mov = [1,4,5]
    i_RC = mocDTW.movementRES(i_mov).i_dtwRC;
    i_BC = mocDTW.movementRES(i_mov).i_dtwBC;
    i_BR = mocDTW.movementRES(i_mov).i_dtwBR;
    figure()
    counter = 0;
    ax(1) = subplot(1,3,1)
    plot(x,mocDTW.movement(i_mov).condition(2).jointAngles_mean)
    legend({'Abd','SFle','SRot','EFLE','Eext'})
    grid on
    grid minor
    title(['Conventional: ',get_nmov(i_mov)])
    ylabel('Angle [?]')
    xlabel('Normed Time')
    
    ax(2) =subplot(1,3,2)
    hold on
    for i=1:5
        line(x,mocDTW.movement(i_mov).condition(4).jointAngles_mean(:,i),'Color',cmap(i,:))
        line(x,mocDTW.movement(i_mov).condition(4).jointAngles_mean(i_RC,i),'LineStyle','--','Color',cmap(i,:))
    end
    hold off
    legend({'Abd','SFle','SRot','EFLE','Eext'})
    grid on
    grid minor
    title(['Teach Mapped to Conventional: ',get_nmov(i_mov)])
    ylabel('Angle [?]')
    xlabel('Normed Time')
    
    ax(3) =subplot(1,3,3)
    hold on
    for i=1:5
        plot(x,mocDTW.movement(i_mov).condition(5).jointAngles_mean(:,i),'Color',cmap(i,:))
        plot(x,mocDTW.movement(i_mov).condition(5).jointAngles_mean(i_BC,i),'LineStyle','--','Color',cmap(i,:))
    end
    grid on
    grid minor
    legend({'Abd','SFle','SRot','EFLE','Eext'})
    title(['Imitate Mapped to Conventional: ',get_nmov(i_mov)])
    ylabel('Angle [?]')
    xlabel('Normed Time')
    
      
    
   linkaxes(ax,'xy')
end
        
%% Plot effect on EMG
x = linspace(0,1,4000)

for i_mov = [1,4,5]
    figure()
    counter = 0;
    for i_mus = 1:6
        max_con = max(mocDTW.movementRES(i_mov).meanMVC_con(:,i_mus))
        max_rob = max(mocDTW.movementRES(i_mov).meanMVC_rob(:,i_mus))
        max_bri = max(mocDTW.movementRES(i_mov).meanMVC_bri(:,i_mus))
        max_con =1
        max_rob = 1
        max_bri =1
        counter = counter + 1;
        ax(i_mus)= subplot(3,2,counter)
        plot(x,mocDTW.movementRES(i_mov).meanMVC_con(:,i_mus)/max_con,'k')
        hold on
        plot(x,mocDTW.movementRES(i_mov).meanMVC_rob(:,i_mus)/max_rob,'r')
        plot(x,mocDTW.movementRES(i_mov).meanMVC_bri(:,i_mus)/max_bri,'b')
        i_RC = mocDTW.movementRES(i_mov).i_dtwRC;
        i_BC = mocDTW.movementRES(i_mov).i_dtwBC;
        i_BR = mocDTW.movementRES(i_mov).i_dtwBR;
        plot(x,mocDTW.movementRES(i_mov).meanMVC_rob(i_RC,i_mus)/max_rob,'r--')
        plot(x,mocDTW.movementRES(i_mov).meanMVC_bri(i_BC,i_mus)/max_bri,'b--')
        title(['Movement', get_nmov(i_mov),' muscle: ',get_nmus(i_mus,false)])
        xlabel('Normed Time')
        ylabel('Normed EMG Signal')
        grid on 
        grid minor
    end
    legend({'con','rob','bri','rob-->con','bri-->con'})
end
        