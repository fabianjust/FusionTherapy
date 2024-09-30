% EMG ANALYSIS
% This script can be used for the analysis of EMG data in the BridgeT
% study.
% Before you can use this script cut data:
%           create_EMGraw_adapted.m
%           This code should be used only once for each dataset, as it
%           creates a new .mat file.

% Other functions: EMGelaboration_adapted.m, cut_5Percent.m,
% normalize_time.m, muscle_array.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 1. Choose file
% cut file verwenden!
[cut_file,path_cutEMg] = uigetfile({'*.mat';},...
                          'File Selector');

%% 2. Filter, Smooth and Rectify EMG Data                      
EMG_data = EMGelaboration_adapted(cut_file);

%% 3. Cut Data (5%)
EMG_cut = cut_5Percent(EMG_data);

%% 4. Normalize Time
tnorm_EMG = normalize_time(EMG_cut);

%% 5. Create Muscle Array -> adapted to leave out first and last repetition
muscles_EMG = muscle_array(tnorm_EMG);

%% 6. Normalize to Maximum Voluntary Contraction
muscles_EMG_normalized = maximum_voluntary_contraction(muscles_EMG);
%% 7. Confidence Interval (95%)
EMG_mean = mean_EMG(muscles_EMG);
EMG_std = std_EMG(muscles_EMG);
n = size(muscles_EMG.upper_trapezius, 2);
time_points = size(muscles_EMG.upper_trapezius, 1);
Z = 1.96; % -> Annahme normalverteilte Daten
CI = zeros(n,2);
muscles = fieldnames(EMG_mean);
EMG_CI = struct();

for i = 1:6
    current_muscle = char(muscles(i));
    muscle_mean = EMG_mean.(current_muscle);
    muscle_std = EMG_std.(current_muscle);

    for i = 1:time_points
        CI_lower = muscle_mean(i)-(Z*muscle_std(i)/sqrt(n));
        CI_upper = muscle_mean(i)+(Z*muscle_std(i)/sqrt(n));
        CI(i,1) = CI_lower;
        CI(i,2) = CI_upper;
    end
    EMG_CI.(current_muscle) = CI;
end 

% 6. Plots CI
% 6.1 Create timeline for x-axis
n_samples = size(muscles_EMG.upper_trapezius,1);
time = zeros(n_samples,1);
for i = 2:n_samples
    time(i,1) = 100/n_samples*i;
end

% 6.2 Upper trapezius
figure(987)
plot(time,EMG_CI.upper_trapezius)
title ('CI Muscle Activity Upper Trapezius')
xlabel('Movement Progress (%)')
ylabel('Muscle Activity [\muV]')
ylim([0 250])
xlim([0 100])
legend('lower boundary','upper boundary')

% 6.3 Posterior deltoid
figure(9437)
plot(time,EMG_CI.posterior_deltoid)
title ('CI Muscle Activity Posterior Deltoid')
xlabel('Movement Progress (%)')
ylabel('Muscle Activity [\muV]')
ylim([0 250])
xlim([0 100])
legend('lower boundary','upper boundary')

% 6.4 Anterior deltoid
figure(546)
plot(time,EMG_CI.anterior_deltoid)
% title(cut_file)
title ('CI Muscle Activity Anterior Deltoid')
xlabel('Movement Progress (%)')
ylabel('Muscle Activity [\muV]')
ylim([0 250])
xlim([0 100])
legend('lower boundary','upper boundary')

% % 6.5 Pectoralis Major
figure(5436)
plot(time,EMG_CI.pectoralis_major)
% title(cut_file)
title ('CI Muscle Activity Pecotralis Major')
xlabel('Movement Progress (%)')
ylabel('Muscle Activity [\muV]')
ylim([0 250])
xlim([0 100])
legend('lower boundary','upper boundary')

% % 6.6 Biceps Brachii
figure(443)
plot(time,EMG_CI.biceps_brachii)
% title(cut_file)
title ('CI Muscle Activity Biceps Brachii')
xlabel('Movement Progress (%)')
ylabel('Muscle Activity [\muV]')
ylim([0 250])
xlim([0 100])
legend('lower boundary','upper boundary')

% % 6.7 Triceps Brachii
figure(76854)
plot(time,EMG_CI.triceps_brachii)
% title(cut_file)
title ('CI Muscle Activity Tricpes Brachii')
xlabel('Movement Progress (%)')
ylabel('Muscle Activity [\muV]')
ylim([0 250])
xlim([0 100])
legend('lower boundary','upper boundary')

