%%

% %% 6. Create .csv file for further analysis in R
% oldName = cut_file;
% processed = 'processed_'; % because now the useless data have been discarded 
% formatSpec = '%1$s%2$s'; %define the order of combination for the two inputs in sprintf
% newName = sprintf(formatSpec, processed, oldName);
% save(newName, 'muscles_EMG');

%% 6. Plot all repetitions for each muscle
% 6.1 Create timeline for x-axis
% n_samples = size(muscles_EMG.upper_trapezius,1);
% time = zeros(n_samples,1);
% for i = 2:n_samples
%     time(i,1) = 100/n_samples*i;
% end
% 
% % 6.2 Create legend names
% n_rep = size(muscles_EMG.upper_trapezius,2);
% for i = 1:n_rep
%     number = char(i);
%     repetition.repetition_(number) = 0;
% end
% legend_names=fields(repetition);
% 
% % 6.3 Upper trapezius
% figure(987)
% plot(time,muscles_EMG.upper_trapezius)
% % title(cut_file)
% title ('Muscle Activity Upper Trapezius')
% xlabel('Movement Progress (%)')
% ylabel('Muscle Activity [\muV]')
% ylim([0 250])
% xlim([0 100])
% 
% % legend (legend_names)
% 
% % 6.4 Posterior deltoid
% figure(9437)
% plot(time,muscles_EMG.posterior_deltoid)
% % title(cut_file)
% title ('Muscle Activity Posterior Deltoid')
% xlabel('Movement Progress (%)')
% ylabel('Muscle Activity [\muV]')
% ylim([0 250])
% xlim([0 100])
% 
% % 6.5 Anterior deltoid
% figure(546)
% plot(time,muscles_EMG.anterior_deltoid)
% % title(cut_file)
% title ('Muscle Activity Anterior Deltoid')
% xlabel('Movement Progress (%)')
% ylabel('Muscle Activity [\muV]')
% ylim([0 250])
% xlim([0 100])
% 
% % % 6.6 Pectoralis Major
% figure(5436)
% plot(time,muscles_EMG.pectoralis_major)
% % title(cut_file)
% title ('Muscle Activity Pecotralis Major')
% xlabel('Movement Progress (%)')
% ylabel('Muscle Activity [\muV]')
% ylim([0 250])
% xlim([0 100])
% 
% % % 6.7 Biceps Brachii
% figure(443)
% plot(time,muscles_EMG.biceps_brachii)
% % title(cut_file)
% title ('Muscle Activity Biceps Brachii')
% xlabel('Movement Progress (%)')
% ylabel('Muscle Activity [\muV]')
% ylim([0 250])
% xlim([0 100])
% 
% % % 6.8 Triceps Brachii
% figure(76854)
% plot(time,muscles_EMG.triceps_brachii)
% % title(cut_file)
% title ('Muscle Activity Tricpes Brachii')
% xlabel('Movement Progress (%)')
% ylabel('Muscle Activity [\muV]')
% ylim([0 250])
% xlim([0 100])
% 




%% 4. Plot EMG Data
% movements = fieldnames(EMG_data);
% n_movements = length(movements);
% 
% figure(1)
% plot(EMG_data.movement_1)
% figure(2)
% plot(EMG_data.movement_2)
% figure(3)
% plot(EMG_data.movement_3)
% figure(4)
% plot(EMG_data.movement_4)
% figure(5)
% plot(EMG_data.movement_5)
% 
% %% 5. Plot EMG Data
% movements = fieldnames(EMG_data);
% n_movements = length(movements);
% 
% figure(6)
% plot(tnorm_EMG.movement_1)
% figure(7)
% plot(tnorm_EMG.movement_2)
% figure(8)
% plot(tnorm_EMG.movement_3)
% figure(9)
% plot(tnorm_EMG.movement_4)
% figure(10)
% plot(tnorm_EMG.movement_5)