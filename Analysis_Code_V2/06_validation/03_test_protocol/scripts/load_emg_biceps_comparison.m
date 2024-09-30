%load:emg
%
%Author: David Mauderli - 2019
%
%DESCRIPTION: This function loads the raw emg data and cuts it to the mocap
%recording gate (mocap-emg sync signal).
%
%INPUT:
%char[] EMG_FNAME: Path to emg file
%
%OUTPUT:
%struct emg: emg data with channel description and sampling freq.

function [emg] = load_emg(EMG_FNAME)

%Load raw emg file 
muscles = {'pd','ad','pm','bb','lt','b2'};
emg_raw = load(EMG_FNAME);

%Select the start and stop indices:
%First we compute a logical vector that is 1 for all sync voltages above
%100 mV. Then we search for the first region of 10 consecutive 1's in this
%vector. I did this to prevent the code from chosing a possible outlier as
%starting indice!
is_inrectime = abs(emg_raw.Data{9})>100;
is_inrectime = conv(is_inrectime,ones(100,1));
is_inrectime = is_inrectime >= 100;
is_inrectime = find(is_inrectime);
i_start = is_inrectime(1)-99;
i_stop = is_inrectime(end)-99;


%Select all points that are within our mocap sync window.
emg.data_descr = muscles;
emg.data = zeros(i_stop-i_start+1,6);
for i=1:6
    temp_data = emg_raw.Data{i+2};
    emg.data(:,i) = temp_data(i_start:i_stop);
end

emg.fs = emg_raw.samplingRate;

end