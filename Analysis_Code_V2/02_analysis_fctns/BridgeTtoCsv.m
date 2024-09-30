function [] = BridgeTtoCsv(PATH,iMov,iDiff,iSub)


% Collect all folders that have to be processed
fileList = dir(PATH);
fileList = fileList(startsWith({fileList.name},'subject')); %Only select subject folders
keep = false(1,length(fileList));
for i = 1:length(iSub)
    keep = or(keep,endsWith({fileList.name},num2str(iSub(i))));
end
fileList = fileList(keep);

% Number of subjects, movements, differences ==> Number of table rows
numSub = length(fileList);
numMov = length(iMov);
numDif = length(iDiff);
numRows = numSub*numMov*numDif;

% Initialize vectors
subjectNumber = NaN(numRows,1);
movementNumber = NaN(numRows,1);
differenceType = NaN(numRows,1);
differenceUpperTrapezius = NaN(numRows,1);
differencePosteriorDeltoid = NaN(numRows,1);
differenceAnteriorDeltoid = NaN(numRows,1);
differencePectoralisMajor = NaN(numRows,1);
differenceBicepsBrachii = NaN(numRows,1);
differenceLateralTriceps = NaN(numRows,1);

%Iterate through subject structure and write data to col vectors of table
curr_row = 0;
for i_sub = 1:numSub
    SUBJECT_FOLDER = [fileList(i_sub).folder,'\',fileList(i_sub).name];
    load([SUBJECT_FOLDER,'\analysis\',fileList(i_sub).name,'.mat'],'subject');
    for curr_iMov = iMov
        for curr_iDif = 1:3
            curr_row = curr_row + 1;
            subjectNumber(curr_row,1) = i_sub;
            movementNumber(curr_row,1) = curr_iMov;
            differenceType(curr_row) = curr_iDif;
            switch curr_iDif
                case 1
                    differenceUpperTrapezius(curr_row) = subject.movementRES(curr_iMov).diffRC(1);
                    differencePosteriorDeltoid(curr_row) = subject.movementRES(curr_iMov).diffRC(2);
                    differenceAnteriorDeltoid(curr_row) = subject.movementRES(curr_iMov).diffRC(3);
                    differencePectoralisMajor(curr_row) = subject.movementRES(curr_iMov).diffRC(4);
                    differenceBicepsBrachii(curr_row) = subject.movementRES(curr_iMov).diffRC(5);
                    differenceLateralTriceps(curr_row) = subject.movementRES(curr_iMov).diffRC(6);
                case 2
                    differenceUpperTrapezius(curr_row) = subject.movementRES(curr_iMov).diffBC(1);
                    differencePosteriorDeltoid(curr_row) = subject.movementRES(curr_iMov).diffBC(2);
                    differenceAnteriorDeltoid(curr_row) = subject.movementRES(curr_iMov).diffBC(3);
                    differencePectoralisMajor(curr_row) = subject.movementRES(curr_iMov).diffBC(4);
                    differenceBicepsBrachii(curr_row) = subject.movementRES(curr_iMov).diffBC(5);
                    differenceLateralTriceps(curr_row) = subject.movementRES(curr_iMov).diffBC(6);
                case 3
                    differenceUpperTrapezius(curr_row) = subject.movementRES(curr_iMov).diffBR(1);
                    differencePosteriorDeltoid(curr_row) = subject.movementRES(curr_iMov).diffBR(2);
                    differenceAnteriorDeltoid(curr_row) = subject.movementRES(curr_iMov).diffBR(3);
                    differencePectoralisMajor(curr_row) = subject.movementRES(curr_iMov).diffBR(4);
                    differenceBicepsBrachii(curr_row) = subject.movementRES(curr_iMov).diffBR(5);
                    differenceLateralTriceps(curr_row) = subject.movementRES(curr_iMov).diffBR(6);
            end
        end
            
    end
end

%Write table and save as .csv
BridgetData = table(subjectNumber,movementNumber,differenceType,...
    differenceUpperTrapezius, differencePosteriorDeltoid, differenceAnteriorDeltoid,...
    differencePectoralisMajor, differenceBicepsBrachii, differenceLateralTriceps);
writetable(BridgetData,[PATH,'\BridgetData.csv'])
end