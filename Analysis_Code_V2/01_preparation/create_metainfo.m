%new_subject
%
%Author: David Mauderli - 2019
%
%DESCRIPTION: This function generates a basic folder structur for
%measurment data of the BridgeT study 2019. It prints the randomized order
%of movements to test and asks for subject information to enter.
%
%INPUT:
%
%OUTPUT:
%

function[] = create_metainfo()

%% Get Subject folder and load randomization order
SUBJECT = uigetdir('Select a folder to allocate the new subject in');
load([SUBJECT,'\randomization.mat'],'names_randomized');

%% User enter meta information from Case Report Form
% Create dialog box
subject_descr = {...
    'Subject Number',...
    'Gender',...
    'Birth Year',...
    'Weight [kg]',...
    'Height [cm]'};
subject_info = inputdlg(subject_descr,'Enter Subject Information')';


%% Write Data Structure
%Randomization
metainfo.movs = names_randomized;
metainfo.bpm = {'abd',60;'ele',60;'rot',60;'fle',60;'mj1',50};
%Condition list
metainfo.cons = {'conb','cont','robb','robt','bri'};

%Muscle and corresponding mvc list
muscles = {'ut','pd','ad','pm','bb','lt'};
mvcs = {'ecan','ecan','sfle','ppre','efle','eext'};
for i=1:6
    metainfo.muscle(i).name = muscles{i};
    metainfo.muscle(i).mvc = mvcs{i};
end

%Age
metainfo.birthyr = str2num(subject_info{3});

%Gender
metainfo.gender = subject_info{2};

%Height
metainfo.height = str2double(subject_info{5});

%Weight
metainfo.weight = str2double(subject_info{4});

%Date
metainfo.date = datetime('today');


%Subject number
metainfo.snum = subject_info{1};
metainfo.sname = strcat('subject_',metainfo.snum);

%% Save to mat and generate directory for subject
%Create directories
if(~exist(SUBJECT))
    mkdir([SUBJECT, '\', metainfo.sname]);
end
EMG = strcat(SUBJECT,'\emg');
if(~exist(EMG))
    mkdir(EMG);
end
MOCAP = strcat(SUBJECT,'\mocap');
if(~exist(MOCAP))
    mkdir(MOCAP);
end
MOCAP_RAW = strcat(SUBJECT,'\mocap_raw');
if(~exist(MOCAP_RAW))
    mkdir(MOCAP_RAW);
end
ANALYSIS = strcat(SUBJECT,'\analysis');
if(~exist(ANALYSIS))
    mkdir(ANALYSIS);
end
save(strcat(SUBJECT,'\metainfo.mat'),'metainfo')

end