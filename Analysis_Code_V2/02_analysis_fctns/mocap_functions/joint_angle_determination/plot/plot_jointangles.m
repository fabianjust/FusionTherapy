function [figh, axh] = plot_jointangles(joint_angles,Fs,subject,movement,condition)
        figh = figure();
        axh = axes();
        x = 1:length(joint_angles.shoulder1);
        x = x/Fs;
        plot(x,joint_angles.shoulder1)
        hold on
        plot(x,joint_angles.shoulder2)
        hold on 
        plot(x,joint_angles.shoulder3)
        hold on
        plot (x,joint_angles.elbow)
        hold on
        plot (x,joint_angles.pronation)
        xlabel('time [sec]')
        ylabel ('angle [deg]')
        legend('Abduktion', 'Elevation', 'Rotation', 'Extension', 'Pronation')
        title_text = strcat("Joint angles: Subject ", subject, ", ", movement,", ",condition);
        title(title_text)
        clear x
end