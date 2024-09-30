% For every subject run Create_EMGraw first, this to create the 'cut_subjectNumber.mat' files
% with only the 15 seconds of the measurements that are needed

%% SET THE PARAMETERS FOR THE MUSCLES THAT YOU WANT TO DISCARD
muscleColumn = 1; % write the number of the column in EMGraw which corresponds to the muscle you want to discard
nDiscarded = 1; % write the total number of muscles you want to discard
% 139 eliminato 4, trapezio
% 152 eliminato 1, anterio delt

%% Load subject's Dataset and muscles are ordered in the following manner 
% AD = Anterior Deltoid
% PM = Pectoralis Major
% BB = Biceps Brachialis
% UT = Upper Trapezius
% PD = Posterior Deltoid
% LT = Lateral Triceps

folder_name = uigetdir([],'Select subject folder');
cd(folder_name)

files = dir('cut*.mat'); % create an array with the name of the cut_files in the 'name' column

for i = 1:length(files)
    load(files(i).name); %load all the files (one at a time)
    EMGraw(:,[muscleColumn])=[]; % column number which corresponds to the muscle you want to discard
    Dataset{1,i} = EMGraw; %Dataset: at the end the array contains all EMGraw matrices of all the trials. Different trials in different columns on the first line. Number of column = number of trials
end

%% Compute the Average EMG for each muscle in every trials
% TO CHANGE: make noChans = noChans - number of muscles you are discarding
noChans = noChans - nDiscarded; %
for j = 1:length(files) %correspond to the number of trials, which correspond to the number of column in Dataset
        meanEMG = EMGelaboration( Dataset{1,j}, samplingRate, noChans ); % mean = horizontal vector containing mean of the 6 muscles on 6 different columns. One 'mean' vector for each trial calculated
        meanEMGDataset(j,:) = meanEMG; % array: every line correspond to one trial, every column = mean of a muscle
%     clear meanEMG
end

%% Compute the weight of each muscle to the gravity support.
% Higher is the contribution of the muscle to the physiological support (higher difference btw active and passive states),
% higher its weight is. => w = 1-LP/GP
for p = 1:5 % 5 because in this case 5 positions tested -> eg: weight(position 1, channel 1= .... = weight of the muscle corresponding to channel 1
    for k = 1 : noChans-1 % for 6 muscles
        weight(p,k) = 1 - meanEMGDataset(5+p,k)/meanEMGDataset(p,k); % = (locked position x, channel k) / (gravitation Px,channel k)
        % weight = matrix with 5 lines (5 positions) and 6 columns (weight of the 6 muscles)
    end
end

%% The average EMG of each muscle is normalized between 0 and 1 (0 = locking condition, 1 = gravitiy condition with no compensation)
% The mean Effort is computed as the mean of the normalized activation of
% each muscle in each compensation method.
for p = 1:5 %5 positions -> if only 4positions: turn all the 5 to 4
    for i = 1:3 % 3 conditions (M1, M2, M3) 
        for k = 1 : noChans-1 % 6 muscles
            normMEAN(i,k) = meanEMGDataset(5+p+i*5,k)/(meanEMGDataset(p,k)-meanEMGDataset(5+p,k)) - meanEMGDataset(5+p,k)/(meanEMGDataset(p,k)-meanEMGDataset(5+p,k));
            %normMEAN = mean(position y, muscle x)/(mean(Gy)-mean(Ly) - mean(Ly)/(mean(Gy)-mean(Ly))
            normMEAN(i,k) = normMEAN(i,k)*weight(p,k); % matrix of normalized and weighted mean of every muscles in the columns, methods in the lines
        end
        meanEffort(p,i) = sum(normMEAN(i,:))/ sum(weight(p,:)); % for Pp, Mi: sum of means of muscles 1-6 / sum of weights for this position p
        %meanEffort = matrix with MEI: lines = positions 1 to 5, columns = methods 1 to 3
    end
end

%% Saving meanEffort matrix 
% I save all the meanEffort matrices in a unique folder (mine is called meanEffort_All)
% The matrices are saved as meanEffort_subjectNumber: eg: meanEffort_113
% This because then is easier to load all of them and to create a unique dataset
constantName = 'meanEffort_';
[filepath, subjectNumber, ext] = fileparts(cd); % extract name of folder from the folder path (the current directory (cd) should be the folder named with the subject number, eg. 113)
formatSpec = '%1$s%2$s'; %define the order of combination for the two inputs in sprintf
filename = sprintf(formatSpec, constantName, subjectNumber);
% CHANGE: change the path, choose the path that corresponds to the folder where you want to save all the matrices
save(fullfile('C:\Users\Gïada\Desktop\Internship_plus\EMG_Study\meanEffort_All\', filename), 'meanEffort');


%% Matrix with colors
figure = figure(1);
imagesc(meanEffort);
colormap(flipud(autumn)); %look at colormap in google to find other combinationsof colors

textStrings = num2str(meanEffort(:),'%0.3f');  %# Create strings from the matrix values, %0.x = numero decimali
textStrings = strtrim(cellstr(textStrings));  %# Remove any space padding

[x,y] = meshgrid(1:5);   %# Create x and y coordinates for the strings

for st = 1:15
       hStrings = text(x(st),y(st),textStrings(st),...      %# Plot the strings
           'HorizontalAlignment','center');
end

set(gca,'XTick',1:3,...                         %# Change the axes tick marks
        'XTickLabel',{'Method 1','Method 2','Method 3'},...  %#   and tick labels
        'YTick',1:5,...
        'YTickLabel',{'Position 1','Position 2','Position 3','Position 4','Position 5'},...
        'TickLength',[0 0]);

%% Saving picture.jpg of the matrix
cFigureName = 'ColouredMEI_';
formatSpecFig = '%1$s%2$s%3$s'; %define the order of combination for the inputs in sprintf
formato = '.jpg';
figureName = sprintf(formatSpecFig, cFigureName, subjectNumber, formato);
% CHANGE: change the path, choose the path that corresponds to the folder where you want to save all figures (in my case: MEI_MatrixColours)
saveas(gcf, fullfile('C:\Users\Gïada\Desktop\Internship_plus\EMG_Study\MEI_MatrixColours\', figureName));
