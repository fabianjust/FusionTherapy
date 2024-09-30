for i_mov = [1,4,5]
    figure()
    for i_con = [2,4,5]
        current_file = subject.movement(i_mov).condition(i_con).repetition;
        n_rep = length(current_file);
        meanOfReps = zeros(240,5);
        moc_std = zeros(240,5,n_rep);
        switch i_con
            case 2
                ax(i_con)=subplot(1,3,1);
                titleText = 'Conventional Therapy';
            case 4
                ax(i_con)=subplot(1,3,2);
                titleText = 'Teach';
            case 5
                ax(i_con)=subplot(1,3,3);
                titleText = 'BridgeT';
        end
        for i_rep = 1:n_rep
            meanOfReps = meanOfReps + imresize(current_file(i_rep).joint_angles,[240,5],'nearest');
            moc_std(:,:,i_rep) = imresize(current_file(i_rep).joint_angles,[240,5],'nearest');
            %plot(linspace(0,2,240),imresize(current_file(i_rep).joint_angles,[240,5],'nearest'),'k')
            hold on
        end
        meanOfReps = meanOfReps/n_rep;
        moc_std = std(moc_std,0,3);
        Z = 1.96; % -> Annahme normalverteilte Daten
        moc_cfiwidth = Z*moc_std./sqrt(n_rep);
        
        
        
        plot(linspace(0,2,240),meanOfReps,'LineWidth',1.25);
        hold on
        plot(linspace(0,2,240),meanOfReps+moc_cfiwidth,'r--');
        plot(linspace(0,2,240),meanOfReps-moc_cfiwidth,'r--');
        grid on
        title([get_nmov(i_mov),' - ', titleText]);
        xticks(0:0.25:2)
        yticks(-200:10:200)
        xlabel('Time [s]')
        ylabel('Joint Angles [?]')
    end
    
    linkaxes(ax,'y')
    legend('Shoulder Abduction','Shoulder Flexion','Shoulder Rotation','Elbow Flexion','Pro/Sup','Interval of Confidence');
end

        