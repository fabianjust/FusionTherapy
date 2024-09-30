function [std_EMG] = std_EMG(muscles_EMG)
%STD_EMG calculates the standard deviation of all repetitions for each muscle at every time point
field_names = fieldnames(muscles_EMG);
std_EMG = struct();
for i = 1:6
    current_muscle =char(field_names(i));
    current_data = muscles_EMG.(current_muscle);
    current_data = current_data';
    my_std = std(current_data);
    my_std = my_std';
    std_EMG.(current_muscle) = my_std;
end
end

