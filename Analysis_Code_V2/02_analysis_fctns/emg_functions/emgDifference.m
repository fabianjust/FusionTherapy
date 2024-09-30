%emg_DTW
%
%DESCRIPTION: This function norms (MVC) mean emg signals of the bridget study and
%computes the mean differences (con-rob, con-bri, rob-bri) according to
%diffType. The function accepts the subject struct (see BridgeT guideline)
%and a char[] diffType (either dtw or normal). It outputs vararin and adds
%the field movementRES.

function [vararout] = emgDifference(vararin,diffType)
vararout = vararin;
for i_mov = 1:length(vararin.movement)
    c_mov = vararin.movement(i_mov).condition;
    
   
    if(~isempty(c_mov)) %Make sure there is measurment data for the current movement, else continue
        %% Copy relevant data, subtract baseline and norm MVC
        %Copy of mean emg values from input
        mean_conb = c_mov(1).emg_mean;
        mean_con = c_mov(2).emg_mean;
        mean_robb = c_mov(3).emg_mean;
        mean_rob = c_mov(4).emg_mean;
        mean_bri = c_mov(5).emg_mean;
        
        %Copy mean joint angle values from input
        meanJointAng_con = c_mov(2).jointAngles_mean;
        meanJointAng_rob = c_mov(4).jointAngles_mean;
        meanJointAng_bri = c_mov(5).jointAngles_mean;

        %Subtract baseline and norm mvc
        meanMVC_con = (mean_con - mean_conb)./[vararin.muscle_info.mvc];
        meanMVC_rob = (mean_rob - mean_robb)./[vararin.muscle_info.mvc];
        meanMVC_bri = (mean_bri - mean_robb)./[vararin.muscle_info.mvc];
        %Norm CFI with MVC values
        cfiMVC_con = c_mov(2).emg_cfiwidth./[vararin.muscle_info.mvc];
        cfiMVC_rob = c_mov(4).emg_cfiwidth./[vararin.muscle_info.mvc];
        cfiMVC_bri = c_mov(5).emg_cfiwidth./[vararin.muscle_info.mvc];
        
        %% Compute all 3 differences (rob-con, bri-con, bri-rob) by the method specified
        %Take difference in mean EMG signals according to specified
        %<diffType>
        nEmgFrames = size(meanMVC_con,1);
        nMocFrames = size(meanJointAng_con,1);
        switch diffType
            case 'emgDtw'      %Dynamic Time Warping applied on EMG
                %Compute DTW Indices
                [meanMVC_rob_warped_c, iOpt_RC] = DTW_corefctn(meanMVC_con,meanMVC_rob,0,2,2);
                [meanMVC_bri_warped_c, iOpt_BC] = DTW_corefctn(meanMVC_con,meanMVC_bri,0,2,2);
                [meanMVC_bri_warped_r, iOpt_BR] = DTW_corefctn(meanMVC_rob,meanMVC_bri,0,2,2);
                %Difference of DTW warped signals
                meanMVC_diffRC = mean(abs(meanMVC_con-meanMVC_rob_warped_c),1);
                meanMVC_diffBC = mean(abs(meanMVC_con-meanMVC_bri_warped_c),1);
                meanMVC_diffBR = mean(abs(meanMVC_rob-meanMVC_bri_warped_r),1);
            case 'emgRms'   %Regular Subtraction
                meanMVC_diffRC = sqrt(mean((meanMVC_con-meanMVC_rob).^2,1));
                meanMVC_diffBC = sqrt(mean((meanMVC_con-meanMVC_bri).^2,1));
                meanMVC_diffBR = sqrt(mean((meanMVC_rob-meanMVC_bri).^2,1));
                iOpt_RC = 1:nEmgFrames; iOpt_BC = 1:nEmgFrames; iOpt_BR = 1:nEmgFrames;
            case 'mocDtw'
                %Resize MoCap Joint Angle vector if it's not the same size
                %as EMG signal
                if nEmgFrames ~= nMocFrames
                    meanJointAng_con = imresize(meanJointAng_con,[nEmgFrames,5],'bilinear');
                    meanJointAng_rob = imresize(meanJointAng_rob,[nEmgFrames,5],'bilinear');
                    meanJointAng_bri = imresize(meanJointAng_bri,[nEmgFrames,5],'bilinear');
                end
                %DTW on Joint angle signals
                [~, iOpt_RC] = DTW_corefctn(meanJointAng_con,meanJointAng_rob,0,2,2);
                [~, iOpt_BC] = DTW_corefctn(meanJointAng_con,meanJointAng_bri,0,2,2);
                [~, iOpt_BR] = DTW_corefctn(meanJointAng_rob,meanJointAng_bri,0,2,2);
                %Warp emg signals accordingly and compute differences
                meanMVC_diffRC = mean(abs(meanMVC_con-meanMVC_rob(iOpt_RC,:)));
                meanMVC_diffBC = mean(abs(meanMVC_con-meanMVC_bri(iOpt_BC,:)));
                meanMVC_diffBR = mean(abs(meanMVC_rob-meanMVC_bri(iOpt_BR,:)));
            otherwise       %Otherwise: no method defined --> ERROR
                msgtext = ['Differency type ', diffType, ' not defined.'];
                msgID = 'emgDifference:diffType_not_found';
                ME = MException(msgID,msgtext);
                throw(ME)                
        end
        
        %% Compare sign of emg derivatives
        % Evaluate Sign of SRE EMG Derivative
        smoothedMeanMVC_con = zeros(nEmgFrames,6);
        smoothedMeanMVC_rob = zeros(nEmgFrames,6);
        smoothedMeanMVC_bri = zeros(nEmgFrames,6);
        
        %Smooth mean EMG of each condition.
        smoothFactor = 1000;
        filterType = 'moving';
        for i_mus=1:6
            smoothedMeanMVC_con(:,i_mus)= smooth(meanMVC_con(:,i_mus),smoothFactor, filterType);
            smoothedMeanMVC_rob(:,i_mus)= smooth(meanMVC_rob(:,i_mus),smoothFactor, filterType);
            smoothedMeanMVC_bri(:,i_mus)= smooth(meanMVC_bri(:,i_mus),smoothFactor, filterType);
        end
        %Compute finite difference (factor irrelevant!) and its sign
        diffMeanMVC_con = smoothedMeanMVC_con(2:end,:)-smoothedMeanMVC_con(1:end-1,:);
        diffMeanMVC_rob = smoothedMeanMVC_rob(2:end,:)-smoothedMeanMVC_rob(1:end-1,:);
        diffMeanMVC_bri = smoothedMeanMVC_bri(2:end,:)-smoothedMeanMVC_bri(1:end-1,:);
        signCon = sign(diffMeanMVC_con);
        signRob = sign(diffMeanMVC_rob);
        signBri = sign(diffMeanMVC_bri);
        
        %compare signs between different conditions
        signRC = signCon==signRob;
        signBC = signCon==signBri;
        signBR = signRob==signBri;
        
        equalSignFactorRC = sum(signRC,1)/(nEmgFrames-1);
        equalSignFactorBC = sum(signBC,1)/(nEmgFrames-1);
        equalSignFactorBR = sum(signBR,1)/(nEmgFrames-1);
        
        %% Find scaling factors for which rms error becomes minimal
        scFacRC = zeros(6,1); minRmsRC = zeros(6,1);
        scFacBC = zeros(6,1); minRmsBC = zeros(6,1);
        scFacBR = zeros(6,1); minRmsBR = zeros(6,1);
        tol = 1e-6;
        for i_mus = 1:6
            [scFacRC(i_mus), minRmsRC(i_mus)] = scaleMinRms(meanMVC_con(:,i_mus),meanMVC_rob(:,i_mus),tol);
            [scFacBC(i_mus), minRmsBC(i_mus)] = scaleMinRms(meanMVC_con(:,i_mus),meanMVC_bri(:,i_mus),tol);
            [scFacBR(i_mus), minRmsBR(i_mus)] = scaleMinRms(meanMVC_rob(:,i_mus),meanMVC_bri(:,i_mus),tol);
        end
        
        %% Compute scaling factors for every muscle and condition
        %Weights are mean(max(mean_i)-min(mean_i)), for i={con,rob,bri}. Further 
        %we norm the weights such that their sum adds up to 1.
        maxMinCon = max(meanMVC_con,[],1)-min(meanMVC_con,[],1);
        maxMinRob = max(meanMVC_rob,[],1)-min(meanMVC_rob,[],1);
        maxMinBri = max(meanMVC_bri,[],1)-min(meanMVC_bri,[],1);
        maxMinAll = mean([maxMinCon;maxMinRob;maxMinBri],1);
        muscleWeights = maxMinAll/sum(maxMinAll);
        
        %% Write primaryOutcome field
        %Write solution to data structure
        %Raw DTW difference Data
        vararout.primaryOutcome(i_mov).dtw(1).error = meanMVC_diffRC;
        vararout.primaryOutcome(i_mov).dtw(2).error = meanMVC_diffBC;
        vararout.primaryOutcome(i_mov).dtw(3).error = meanMVC_diffBR;
        for i = 1:3
            vararout.primaryOutcome(i_mov).dtw(i).weightedMeanError = ...
                sum(vararout.primaryOutcome(i_mov).dtw(i).error.*muscleWeights);
        end
        vararout.primaryOutcome(i_mov).dtw(1).indices = iOpt_RC;
        vararout.primaryOutcome(i_mov).dtw(2).indices = iOpt_BC;
        vararout.primaryOutcome(i_mov).dtw(3).indices = iOpt_BR;
        vararout.primaryOutcome(i_mov).dtw(1).type = [diffType, ': Con - Rob'];
        vararout.primaryOutcome(i_mov).dtw(2).type = [diffType, ': Con - Bri'];
        vararout.primaryOutcome(i_mov).dtw(3).type = [diffType, ': Rob - Bri'];
        %RMS minimized DTW difference Data
        vararout.primaryOutcome(i_mov).rmsOpt(1).scaledRms = minRmsRC';
        vararout.primaryOutcome(i_mov).rmsOpt(2).scaledRms = minRmsBC';
        vararout.primaryOutcome(i_mov).rmsOpt(3).scaledRms = minRmsBR';
        for i = 1:3
            vararout.primaryOutcome(i_mov).rmsOpt(i).weightedMeanRms = ...
                sum(vararout.primaryOutcome(i_mov).rmsOpt(i).scaledRms.*muscleWeights);
        end
        vararout.primaryOutcome(i_mov).rmsOpt(1).scaleFactor = scFacRC;
        vararout.primaryOutcome(i_mov).rmsOpt(2).scaleFactor = scFacBC;
        vararout.primaryOutcome(i_mov).rmsOpt(3).scaleFactor = scFacBR;
        vararout.primaryOutcome(i_mov).rmsOpt(1).type = 'rmsError: Con - Rob';
        vararout.primaryOutcome(i_mov).rmsOpt(2).type = 'rmsError: Con - Bri';
        vararout.primaryOutcome(i_mov).rmsOpt(3).type = 'rmsError: Rob - Bri';
        %Signum Data
        vararout.primaryOutcome(i_mov).signum(1).correlation = equalSignFactorRC;
        vararout.primaryOutcome(i_mov).signum(2).correlation = equalSignFactorBC;
        vararout.primaryOutcome(i_mov).signum(3).correlation = equalSignFactorBR;
        for i = 1:3
            vararout.primaryOutcome(i_mov).signum(i).weightedMean = ...
                sum(vararout.primaryOutcome(i_mov).signum(i).correlation.*muscleWeights);
        end
        vararout.primaryOutcome(i_mov).signum(1).correlationGate = signRC;
        vararout.primaryOutcome(i_mov).signum(2).correlationGate = signBC;
        vararout.primaryOutcome(i_mov).signum(3).correlationGate = signBR;
        vararout.primaryOutcome(i_mov).signum(1).correlationName = 'Correlation: Con - Rob';
        vararout.primaryOutcome(i_mov).signum(2).correlationName = 'Correlation: Con - Bri';
        vararout.primaryOutcome(i_mov).signum(3).correlationName = 'Correlation: Rob - Bri';
        vararout.primaryOutcome(i_mov).signum(1).meanSmoothed = smoothedMeanMVC_con;
        vararout.primaryOutcome(i_mov).signum(2).meanSmoothed = smoothedMeanMVC_rob;
        vararout.primaryOutcome(i_mov).signum(3).meanSmoothed = smoothedMeanMVC_bri;
        vararout.primaryOutcome(i_mov).signum(1).derivativeSign = signCon;
        vararout.primaryOutcome(i_mov).signum(2).derivativeSign = signRob;
        vararout.primaryOutcome(i_mov).signum(3).derivativeSign = signBri;
        vararout.primaryOutcome(i_mov).signum(1).smoothFactor = smoothFactor;
        vararout.primaryOutcome(i_mov).signum(2).smoothFactor = smoothFactor;
        vararout.primaryOutcome(i_mov).signum(3).smoothFactor = smoothFactor;
        vararout.primaryOutcome(i_mov).signum(1).smoothType =  filterType;
        vararout.primaryOutcome(i_mov).signum(2).smoothType =  filterType;
        vararout.primaryOutcome(i_mov).signum(3).smoothType =  filterType;
        vararout.primaryOutcome(i_mov).signum(1).meanName =  'con';
        vararout.primaryOutcome(i_mov).signum(2).meanName =  'rob';
        vararout.primaryOutcome(i_mov).signum(3).meanName =  'bri';
        
        %Raw Data
        vararout.primaryOutcome(i_mov).meanCfi(1).mean = meanMVC_con;
        vararout.primaryOutcome(i_mov).meanCfi(2).mean = meanMVC_rob;
        vararout.primaryOutcome(i_mov).meanCfi(3).mean = meanMVC_bri;
        vararout.primaryOutcome(i_mov).meanCfi(1).cfi = cfiMVC_con;
        vararout.primaryOutcome(i_mov).meanCfi(2).cfi = cfiMVC_rob;
        vararout.primaryOutcome(i_mov).meanCfi(3).cfi = cfiMVC_bri;
        vararout.primaryOutcome(i_mov).meanCfi(1).type = 'Conventional';
        vararout.primaryOutcome(i_mov).meanCfi(2).type = 'Teach';
        vararout.primaryOutcome(i_mov).meanCfi(3).type = 'Imitate';
        %Descriptions and weighting factors
        vararout.primaryOutcome(i_mov).rowNames = {'ut','pd','ad','pm','bb','lt'};
        vararout.primaryOutcome(i_mov).movDescr = get_nmov(i_mov);
        vararout.primaryOutcome(i_mov).muscleWeights = muscleWeights;
        
    end
  
end
end

