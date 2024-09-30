%add_segment_joint_centers
%
%Author: David Mauderli - 2019
%
%DESCRIPTION: This function adds the global coordinates of the joint
%centers in reference position to the calib data structure
%
%INPUT:
%calib: structure to which the joint centers should be added
%transforms: structure that contains the transforms for each frame
%segments: list of the following type:
%{'name proximal segment','name distal segment','joint name';'name prox...}
%
%OUTPUT:
%varout: equal to calib with the segments added


function [varout, val] = add_segment_joint_centers(calib,transforms,segments,make_plot,N_it)

%Prepare data structures
varout = calib;
N_segments = size(segments,1);

% Check input parameters
for i=1:N_segments
    assert(isfield(calib,segments{i,1}),'segment_joint_centers:input_error',...
        ['Segment is missing in input 1: ', segments{i,1}])
    assert(isfield(transforms,segments{i,1}),'segment_joint_centers:input_error',...
        ['Segment is missing in input 2: ', segments{i,1}])
    assert(isfield(calib,segments{i,2}),'segment_joint_centers:input_error',...
        ['Segment is missing in input 1: ', segments{i,2}])
    assert(isfield(transforms,segments{i,2}),'segment_joint_centers:input_error',...
        ['Segment is missing in input 2: ', segments{i,2}])
end



%Add rotation centers
for i=1:N_segments

    Tp = transforms.(segments{i,1});
    Td = transforms.(segments{i,2});
    val = get_rot_center(Tp,Td,make_plot,N_it);      
    varout.(segments{i,1}).(segments{i,3}) = val;
    varout.(segments{i,2}).(segments{i,3}) = val;
end
end