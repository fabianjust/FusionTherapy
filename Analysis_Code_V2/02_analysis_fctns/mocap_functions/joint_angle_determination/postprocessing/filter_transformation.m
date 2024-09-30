%filter_transformation
%
%Author: David Mauderli - 2019
%
%DESCRIPTION: This function filters the data in vararin with two
%filters; First a median filter of order <order_med>, second a <order_lp>
%zero phase butterworth filter.
%
%INPUT:
%struct vararin: structure array of the following type:
%   vararin.field1 = 4x4xN matrix of homogeneous transformations
%   vararin.field2 = ...
%int order_med: Order of median filter
%int order_lp: Order of butterworth filter
%double cut_freq: Cutoff frequency of butterworth
%int sampling_freq: Sampling frequency of motion capture data
%
%OUTPUT:
%vararout: filtered version of vararin

function [vararout] = filter_transformation(vararin,order_med,order_lp,cut_freq,sampling_freq)

% Filter Design; Check if filter is stable
[B,A] = butter(order_lp,cut_freq/(sampling_freq/2));
assert(isstable(B,A),'filter_transformation:filter_stability','Butterworth filter is not stable')

%Iterate through each field of vararin:
segment_names = fieldnames(vararin);
for i_segment=1:length(segment_names)
    
    %Copy data of current field 
    curr_segment = char(segment_names{i_segment});
    curr_data = vararin.(curr_segment);
    
    %Check if dimensions match
    curr_size = size(curr_data);
    assert(all(curr_size(1:2)==[4,4]),'filter_transformation:input_error',...
        strcat(curr_segment,' has wrong dimensions!'))
    
    %Allocate Memory for further calculations
    len = size(curr_data,3);
    curr_data_filtered = zeros(4,4,len); %Contains filtered data
    filt_in = zeros(3,len); %Input for filter (cannot directly filter 4x4xN matrix)
    
    %Iterate through each column of curr_data
    for col=1:4
        
        %Copy current column to filt_in
        filt_in(1:3,:) = curr_data(1:3,col,:);
        
        %Apply median filter
        filt_in(1,:) = medfilt1(filt_in(1,:),order_med);
        filt_in(2,:) = medfilt1(filt_in(2,:),order_med);
        filt_in(3,:) = medfilt1(filt_in(3,:),order_med);
        
        %Apply butterworth filter
        filt_out = filtfilt(B,A,filt_in');
        
        %Write solution to curr_data_filtered
        curr_data_filtered(1:3,col,:) = filt_out';
    end
    
    %Finish curr_data_filtered (homogeneous transformation)
    curr_data_filtered(4,4,:) = curr_data(4,4,:);
    
    %Copy curr_data_filtered to output struct
    vararout.(curr_segment) = curr_data_filtered;
end
end