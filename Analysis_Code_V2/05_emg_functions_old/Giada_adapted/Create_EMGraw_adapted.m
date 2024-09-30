% EMGraw = INPUT for the EMGelaboration function

folder_name = uigetdir([],'Select subject folder');
cd(folder_name)

files_long = dir('*.mat'); % array files_long with all the names of the files

for i = 1:length(files_long)
    load(files_long(i).name); %load all the files but one at a time

    logical = (Data{1,8} > 9000); % logical = 1 when the ARMin trigger is on = when signal >9000

    % In our measurement we have several triggers in one EMG trial
    % The different movements have to be distinguished from each other
    
    begin = [];
    stop = [];
    m = 1;
    EMGraw = struct();
    check1 = 0;
    check2 = 0;
    for k = 2:length(logical) % find indices, where logical changes
        if logical(k-1) ==0 && logical(k)==1
            begin = k;
            check1 = 1;
        end
        if logical(k-1) ==1 && logical(k)==0
            stop = k;
            check2 = 1;
        end
        
        if check1 ==1 && check2==1
            newData = [];
            for p = 1:noChans-3 % noChans-3 = number of muscles (3 additional channes for sync-boxes)
                newData = [newData,Data{1,p+1}(begin:stop,1)]; % EMGraw contains only the values of the 6 muscles where trigger is on
            end
            nummer = string(m);
            movement = strcat('movement_',nummer);
            EMGraw.(movement) = newData;
            check1 = 0;
            check2 = 0;
            m = m+1;    
        end
        
    end


oldName = files_long(i).name;
cut = 'cut_'; % because now the useless data have been discarded 
formatSpec = '%1$s%2$s'; %define the order of combination for the two inputs in sprintf
newName = sprintf(formatSpec, cut, oldName);
save(newName, 'EMGraw', 'channelNames', 'noChans', 'samplingRate');
end
