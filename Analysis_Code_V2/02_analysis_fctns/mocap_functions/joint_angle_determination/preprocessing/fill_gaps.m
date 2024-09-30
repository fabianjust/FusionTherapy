%fill_gaps
%
%Author: David Mauderli - 2019
%
%DESCRIPTION: This function fills gaps of size <gap_size> in the measurment
%data struct <vararin> by moving average filtering the corresponding
%sections. Data that is not missing will not be altered.
%
%INPUT:
%struct vararin: Contains measurment data structure
%int gap_size: Maximum gap size that still should be filled
%
%OUTPUT:
%vararout: Completed version of vararin

function [vararout] = fill_gaps(vararin, gap_size)

%Iterate through markers
marker_names = fieldnames(vararin);
for i_segment=1:length(marker_names)
    
    %Copy data
    curr_segment = char(marker_names{i_segment});
    curr_data = vararin.(curr_segment);
   
    %Fill gaps
    curr_data_filled = fillmissing(curr_data,'movmean',gap_size+1,2);
    
    %Write to solution
    vararout.(curr_segment) = curr_data_filled;

end
end