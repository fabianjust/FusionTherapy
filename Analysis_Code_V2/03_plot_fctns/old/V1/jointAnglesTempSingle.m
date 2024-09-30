for i_mov = [1,4,5]
    
    for i_con = [2,4,5]
        figure()
        current_file = subject.movement(i_mov).condition(i_con).repetition;
        n_rep = length(current_file);
        meanOfReps = zeros(240,5);
        
        for i_rep = 1:n_rep
            meanOfReps = meanOfReps + imresize(current_file(i_rep).joint_angles,[240,5],'nearest');
        end
        meanOfReps = meanOfReps/n_rep;
        switch i_con
            case 2
                subplot(1,1,1);
                titleText = 'Conventional Therapy';
            case 4
                subplot(1,1,1);
                titleText = 'Teach';
            case 5
                subplot(1,1,1);
                titleText = 'BridgeT';
        end
        plot(meanOfReps);
        
        title([get_nmov(i_mov),' - ', titleText]);
    end
    legend('Shoulder Abduction','Shoulder Flexion','Shoulder Rotation','Elbow Flexion','Pro/Sup');
end

        