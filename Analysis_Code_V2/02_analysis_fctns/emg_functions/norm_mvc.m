%norm_mvc
%
%Author: David Mauderli
%
%DESCRIPTION: This function adds a field with mvc normed emg amplitudes to
%the subject struct of the BridgeT study.
%
%INPUT:
%struct vararin: As used according to BridgeT convention
%OUTPUT:
%struct vararin: Copy of vararin with
%vararin.movement.condition.repetition.emg_mvc added

function [vararout] = norm_mvc(vararin)

%Copy input
vararout = vararin;
%save mvc values
mvc = [vararin.muscle.mvc];

%Iterate through each movement, condition and repetition
for i_mov = 1:length(vararin.movement)
    for i_con = 1:length(vararin.movement(i_mov).condition)
        for i_rep = 1:length(vararin.movement(i_mov).condition(i_con).repetition)
            %Norm muscles 1:6 with mvc 1:6
            rep_curr = vararin.movement(i_mov).condition(i_con).repetition(i_rep);
            emg_mvc = rep_curr.emg./mvc;
            %Write to output
            vararout.movement(i_mov).condition(i_con).repetition(i_rep).emg_mvc = emg_mvc;
        end
    end
end
end