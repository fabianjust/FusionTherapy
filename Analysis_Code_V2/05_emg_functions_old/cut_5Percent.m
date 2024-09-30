function [EMG_cut] = cut_5Percent(EMG_data)
% CUT_5PERCENT cuts away the first and last five percent of the data

% 1. General initialisation
movements = fieldnames(EMG_data);
n_movements = length(movements);
EMG_cut = struct();

% 2. Cut each movement
for i=1:n_movements
     field = char(movements(i));
     curr_data = EMG_data.(field);
     n_samples = size(curr_data,1);
     Perc_5 = 0.05*n_samples;
     start = ceil(Perc_5);
     stop = floor(n_samples-Perc_5);
     data_cut = curr_data(start:stop,:);
     
     % 3. Safe cut data in structure array
     EMG_cut.(field) = data_cut;
end

