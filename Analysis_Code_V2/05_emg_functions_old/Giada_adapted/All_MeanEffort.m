% First, for every subject run the Create_EMGraw and then EffortComp_Giada_short, so that you will
% have all the meanEffort matrices saved in a unique folder

%% choose the folder where the meanEffort matrices are saved
folder_name = uigetdir([],'Select subject folder'); 
cd(folder_name)

%% Create a dataset (ALL_MEI) with the meanEffort matrices of all the subjects
FolderFiles = dir('*.mat'); % array FolderFiles with all the names of the files in the folder (verticale)
nFiles = length(FolderFiles); % number of matrices in the folder = number of subjects
for nF = 1:nFiles
    current_MEI = load(FolderFiles(nF).name); %load a matrix
    All_MEI{1, nF} = current_MEI.meanEffort; % store the matrix in the dataset All_MEI: at the end every column of the dataset will contain the MEI matrix of 1 subject
end

%% Calculate the mean of all the subjects for every condition (15 values)
% the MEI of the M1P1 condition of all the subjects are summed up and then divided by the sbject number 
concatenated_matrices = cat(3, All_MEI{1,1:nFiles}); % concatenate the matrices to create a 5x3x20 array 
mean_conditions = mean (concatenated_matrices, 3); % calculate the by element mean of the matrices

% to TEST if the functions work ;)
% (All_MEI{1,1}(2,3) + All_MEI{1,2}(2,3) + All_MEI{1,3}(2,3) + All_MEI{1,4}(2,3) + All_MEI{1,5}(2,3) + All_MEI{1,6}(2,3) + All_MEI{1,7}(2,3) + All_MEI{1,8}(2,3) + All_MEI{1,9}(2,3) + All_MEI{1,10}(2,3) + All_MEI{1,11}(2,3) + All_MEI{1,12}(2,3) + All_MEI{1,13}(2,3) + All_MEI{1,14}(2,3) + All_MEI{1,15}(2,3) + All_MEI{1,16}(2,3) + All_MEI{1,17}(2,3) + All_MEI{1,18}(2,3) + All_MEI{1,19}(2,3) + All_MEI{1,20}(2,3))/20

%% Create the coloured matrix for mean_conditions
figure = figure(1);
imagesc(mean_conditions);
colormap(flipud(autumn)); 

textStrings = num2str(mean_conditions(:),'%0.3f');  %# Create strings from the matrix values, %0.x = numero decimali
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