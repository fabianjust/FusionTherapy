function [mean_EMG] = mean_EMG(muscles_EMG)
%MEAN_EMG calculates the mean of all repetitions for each muscle at every time point
field_names = fieldnames(muscles_EMG);
mean_EMG = struct();
for i = 1:6
    current_muscle =char(field_names(i));
    current_data = muscles_EMG.(current_muscle);
    my_mean = mean(current_data,2);
    mean_EMG.(current_muscle) = my_mean;
end
end

