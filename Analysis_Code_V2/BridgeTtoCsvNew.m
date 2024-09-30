function [] = BridgeTtoCsv(PATH,iMov,iDiff,iSub)


% Collect all folders that have to be processed
fileList = dir(PATH);
fileList = fileList(startsWith(string({fileList.name}),'subject')); %Only select subject folders
keep = false(1,length(fileList));
for i = 1:length(iSub)
    pattern = [num2str(iSub(1,i)),'.mat'];
    keep = or(keep,endsWith(string({fileList.name}),pattern));
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

RMSUpperTrapezius = NaN(numRows,1);
RMSPosteriorDeltoid = NaN(numRows,1);
RMSAnteriorDeltoid = NaN(numRows,1);
RMSPectoralisMajor = NaN(numRows,1);
RMSBicepsBrachii = NaN(numRows,1);
RMSLateralTricpes = NaN(numRows,1);

RMSscaleUpperTrapezius = NaN(numRows,1);
RMSscalePosteriorDeltoid = NaN(numRows,1);
RMSscaleAnteriorDeltoid = NaN(numRows,1);
RMSscalePectoralisMajor = NaN(numRows,1);
RMSscaleBicepsBrachii = NaN(numRows,1);
RMSscaleTricepsBrachii = NaN(numRows,1);

%Iterate through subject structure and write data to col vectors of table
curr_row = 0;
for i_sub = 1:numSub
    SUBJECT_FOLDER = [fileList(i_sub).folder,'\',fileList(i_sub).name];
    load(SUBJECT_FOLDER);
    for curr_iMov = iMov
        for curr_iDif = 1:3
            curr_row = curr_row + 1;
            subjectNumber(curr_row,1) = i_sub;
            movementNumber(curr_row,1) = curr_iMov;
            differenceType(curr_row) = curr_iDif;
            switch curr_iDif
                case 1
                    differenceUpperTrapezius(curr_row) = subject.primaryOutcome(curr_iMov).errorRC(1);
                    differencePosteriorDeltoid(curr_row) = subject.primaryOutcome(curr_iMov).errorRC(2);
                    differenceAnteriorDeltoid(curr_row) = subject.primaryOutcome(curr_iMov).errorRC(3);
                    differencePectoralisMajor(curr_row) = subject.primaryOutcome(curr_iMov).errorRC(4);
                    differenceBicepsBrachii(curr_row) = subject.primaryOutcome(curr_iMov).errorRC(5);
                    differenceLateralTriceps(curr_row) = subject.primaryOutcome(curr_iMov).errorRC(6);
                    
                    RMSUpperTrapezius(curr_row) = subject.primaryOutcome(curr_iMov).rmsOptDiffRC(1);
                    RMSPosteriorDeltoid(curr_row) = subject.primaryOutcome(curr_iMov).rmsOptDiffRC(2);
                    RMSAnteriorDeltoid(curr_row) = subject.primaryOutcome(curr_iMov).rmsOptDiffRC(3);
                    RMSPectoralisMajor(curr_row) = subject.primaryOutcome(curr_iMov).rmsOptDiffRC(4);
                    RMSBicepsBrachii(curr_row) = subject.primaryOutcome(curr_iMov).rmsOptDiffRC(5);
                    %RMSLateralTriceps(curr_row) = subject.primaryOutcome(curr_iMov).rmsOptDiffRC(6);
                    
                    RMSscaleUpperTrapezius(curr_row) = subject.primaryOutcome(curr_iMov).rmsScalingRC(1);
                    RMSscalePosteriorDeltoid(curr_row) = subject.primaryOutcome(curr_iMov).rmsScalingRC(2);
                    RMSscaleAnteriorDeltoid(curr_row) = subject.primaryOutcome(curr_iMov).rmsScalingRC(3);
                    RMSscalePectoralisMajor(curr_row) = subject.primaryOutcome(curr_iMov).rmsScalingRC(4);
                    RMSscaleBicepsBrachii(curr_row) = subject.primaryOutcome(curr_iMov).rmsScalingRC(5);
                    %RMSscaleTricepsBrachii(curr_row) = subject.primaryOutcome(curr_iMov).rmsScalingRC(6);
                    
                case 2
                    differenceUpperTrapezius(curr_row) = subject.primaryOutcome(curr_iMov).errorBC(1);
                    differencePosteriorDeltoid(curr_row) = subject.primaryOutcome(curr_iMov).errorBC(2);
                    differenceAnteriorDeltoid(curr_row) = subject.primaryOutcome(curr_iMov).errorBC(3);
                    differencePectoralisMajor(curr_row) = subject.primaryOutcome(curr_iMov).errorBC(4);
                    differenceBicepsBrachii(curr_row) = subject.primaryOutcome(curr_iMov).errorBC(5);
                    differenceLateralTriceps(curr_row) = subject.primaryOutcome(curr_iMov).errorBC(6);
                    
                    RMSUpperTrapezius(curr_row) = subject.primaryOutcome(curr_iMov).rmsOptDiffBC(1);
                    RMSPosteriorDeltoid(curr_row) = subject.primaryOutcome(curr_iMov).rmsOptDiffBC(2);
                    RMSAnteriorDeltoid(curr_row) = subject.primaryOutcome(curr_iMov).rmsOptDiffBC(3);
                    RMSPectoralisMajor(curr_row) = subject.primaryOutcome(curr_iMov).rmsOptDiffBC(4);
                    RMSBicepsBrachii(curr_row) = subject.primaryOutcome(curr_iMov).rmsOptDiffBC(5);
                    %RMSLateralTricpes(curr_row) = subject.primaryOutcome(curr_iMov).rmsOptDiffBC(6);
                    
                    RMSscaleUpperTrapezius(curr_row) = subject.primaryOutcome(curr_iMov).rmsScalingBC(1);
                    RMSscalePosteriorDeltoid(curr_row) = subject.primaryOutcome(curr_iMov).rmsScalingBC(2);
                    RMSscaleAnteriorDeltoid(curr_row) = subject.primaryOutcome(curr_iMov).rmsScalingBC(3);
                    RMSscalePectoralisMajor(curr_row) = subject.primaryOutcome(curr_iMov).rmsScalingBC(4);
                    RMSscaleBicepsBrachii(curr_row) = subject.primaryOutcome(curr_iMov).rmsScalingBC(5);
                    %RMSscaleLateralTriceps(curr_row) = subject.primaryOutcome(curr_iMov).rmsScalingBC(6);
                    
                case 3
                    differenceUpperTrapezius(curr_row) = subject.primaryOutcome(curr_iMov).errorBR(1);
                    differencePosteriorDeltoid(curr_row) = subject.primaryOutcome(curr_iMov).errorBR(2);
                    differenceAnteriorDeltoid(curr_row) = subject.primaryOutcome(curr_iMov).errorBR(3);
                    differencePectoralisMajor(curr_row) = subject.primaryOutcome(curr_iMov).errorBR(4);
                    differenceBicepsBrachii(curr_row) = subject.primaryOutcome(curr_iMov).errorBR(5);
                    differenceLateralTriceps(curr_row) = subject.primaryOutcome(curr_iMov).errorBR(6);
                    
                    RMSUpperTrapezius(curr_row) = subject.primaryOutcome(curr_iMov).rmsOptDiffBR(1);
                    RMSPosteriorDeltoid(curr_row) = subject.primaryOutcome(curr_iMov).rmsOptDiffBR(2);
                    RMSAnteriorDeltoid(curr_row) = subject.primaryOutcome(curr_iMov).rmsOptDiffBR(3);
                    RMSPectoralisMajor(curr_row) = subject.primaryOutcome(curr_iMov).rmsOptDiffBR(4);
                    RMSBicepsBrachii(curr_row) = subject.primaryOutcome(curr_iMov).rmsOptDiffBR(5);
                    RMSLateralTricpes(curr_row) = subject.primaryOutcome(curr_iMov).rmsOptDiffBR(6);
                    
                    RMSscaleUpperTrapezius(curr_row) = subject.primaryOutcome(curr_iMov).rmsScalingBR(1);
                    RMSscalePosteriorDeltoid(curr_row) = subject.primaryOutcome(curr_iMov).rmsScalingBR(2);
                    RMSscaleAnteriorDeltoid(curr_row) = subject.primaryOutcome(curr_iMov).rmsScalingBR(3);
                    RMSscalePectoralisMajor(curr_row) = subject.primaryOutcome(curr_iMov).rmsScalingBR(4);
                    RMSscaleBicepsBrachii(curr_row) = subject.primaryOutcome(curr_iMov).rmsScalingBR(5);
                    %RMSscaleLateralTriceps(curr_row) = subject.primaryOutcome(curr_iMov).rmsScalingBR(6);
            end
        end
            
    end
end

%Write table and save as .csv
BridgetData = table(subjectNumber,movementNumber,differenceType,...
    differenceUpperTrapezius, differencePosteriorDeltoid, differenceAnteriorDeltoid,...
    differencePectoralisMajor, differenceBicepsBrachii, differenceLateralTriceps,RMSUpperTrapezius,...
    RMSPosteriorDeltoid,RMSAnteriorDeltoid,RMSPectoralisMajor,RMSBicepsBrachii,RMSLateralTriceps,...
    RMSscaleUpperTrapezius,RMSscalePosteriorDeltoid,RMSscaleAnteriorDeltoid,RMSscalePectoralisMajor,...
    RMSscaleBicepsBrachii,RMSscaleLateralTriceps);
writetable(BridgetData,[PATH,'\BridgetData.csv'])
end