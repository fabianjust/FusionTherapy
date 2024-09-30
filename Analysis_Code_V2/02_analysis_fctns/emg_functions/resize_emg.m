%resize_emg
%
%Author: David Mauderli - 2019
%
%DESCRIPTION: This function resizes the
%subject.movement.condition.repetition.emg array to nrows rows. The number
%of columns stays constant. The function does so for every movement,
%condition and repetition. NOTE: This is NO DIRECT TIME NORMALIZATION, as
%the corresponding timestamps can still be chosen arbitrarily. This
%function simply changes vector length and can thus be interpreted either as
%change in sampling frequency (same total time as before) or as a change in
%total time taken (same sampling frequency as before)
%
%function only changes vector length. T
%
%INPUT: subject struct from BridgeT study
%
%OUTPUT: subject struct from BridgeT study with manipulated
%subject.movement.condition.repetition.emg structs


function [vararout] = resize_emg(vararin,nrows)

vararout = vararin;

%Norm size of emg vectors for all movements to the same value
for i_mov=1:length(vararin.movement)
    for i_con=1:length(vararin.movement(i_mov).condition)
        for i_rep = 1:length(vararin.movement(i_mov).condition(i_con).repetition)
            emg_current = vararout.movement(i_mov).condition(i_con).repetition(i_rep).emg_SRE;
            ncols = size(emg_current,2);
            emg_current = imresize(emg_current,[nrows ncols],'nearest');
            vararout.movement(i_mov).condition(i_con).repetition(i_rep).emg_resized = emg_current;
        end
    end
end
end