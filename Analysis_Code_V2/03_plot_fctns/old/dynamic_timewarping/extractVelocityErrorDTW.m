function velo_e = extractVelocityErrorDTW(participant, run, varargin)

variableName = 'VelocityErrorDTW';

% Get velocity measures (peaks, ratios, ...) of a block or run

% PARTICIPANT can be either id or abbreviation
% RUN is run number
% VARARGIN{1} is BLOCK number
% VARARGIN{2} % variable, which is the base for finding cycles
% (see extractTpCycles).


% Version 1 Date: 07.05.2013
% Version 1 Autor: Roland Sigrist

study = getStudy();

%% Check Varargin
% vararginsBlockVariableBase

%% Check Varargin
if isempty(varargin)
    block=0;
    variableBase = study.cutVariable{run.Number};
    
elseif ~isempty(varargin) && length(varargin)==1 && ischar(varargin{1})
    block=0;
    variableBase=varargin{1}; % variable, which is the base for finding cycles
    
elseif ~isempty(varargin) && length(varargin)==1 && isnumeric(varargin{1})
    block=varargin{1};
    if block ~= 0
        variableBase = study.runs(run.Number).blocks(block).cutVariable;
    else
        variableBase = study.runs(run.Number).blocks(1).cutVariable;
    end
    
elseif ~isempty(varargin) && length(varargin)==2 && isnumeric(varargin{1}) && ischar(varargin{2})
    block=varargin{1};
    variableBase = varargin{2}; % variable, which is the base for finding cycles
end

run = run.Number;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load data if existing
%status='load';saveLoadExtracted_2013_03_Multimodal_V_VA_VH;
%
% run = run.Number;
% participant = lower(participant.Abbreviation);
%
% be = 'no'; % run even though saved data exists already
% if strcmp(be,'no')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Set paramaters

redby = 2; % 250 datapoints used. reduce datapoints to save computation time

%% General check if there is any valid cycle
%    if isValidBlock(participant, run, block) == true

%% Cycle data
TpCycles    = getData(participant, run, 'TpCycles', block);
cycData     = getData(participant, run, 'CycleData', block);
resamp      = getData(participant, run, 'CycleDataResampled', block);

%         cycData     = getCycleData(participant, run, block, variableBase);
%         TpCycles    = getData(participant, run, 'TpCycles', block);
%         resamp      = extractCycleDataResampled(participant, run, block, variableBase);

cycData     = cycData(TpCycles.cyc_nat); display('only cyc_nat included')
resamp      = resamp(TpCycles.cyc_nat); display('only cyc_nat included')

display(['Nr of cycles: ' num2str(length(cycData)) ' = ' num2str(length(resamp))])
display('first, last, and innatural cycles set to NaN')

% Load Ref
load desiredTrajectory1refCyc
refCyc.theta = refCyc.theta(1:10:end);
refCyc.delta = refCyc.delta(1:10:end);

%% default e ng
velo_e.err_theta           = NaN;
velo_e.err_delta           = NaN;
velo_e.err_2D_abs          = NaN;
velo_e.err_2D_abs_drive    = NaN;
velo_e.err_2D_abs_recovery = NaN;

% update/addition by bekin (23.11.18)
velo_e.err_2D_veloCyc      = NaN;
velo_e.err_2D_veloCatch    = NaN;
velo_e.err_2D_veloRelease  = NaN;


velo_e.veloErrorWaterContact  = NaN;
velo_e.veloErrorAirContact    = NaN;


for cNr = 1:length(cycData)
        
    %% ASSIGN DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if (abs(mean(cycData(cNr).theta_r)) >= 0) == false % if cycle contains NaN set to NaN
        
        % Velocity error calculated here is not really meaningful.
        % It corresponds to the temporal error of the
        % spatiotemporal analysis. Thus, use the temporal error.
        % Reasons: here, the matching of the samples is not
        % reasonable, the direction of the velocity vector is not
        % taken into account, and resampling is weird. rs
        
        velo_e.err_theta(cNr,1)           = NaN;
        velo_e.err_delta(cNr,1)           = NaN;
        velo_e.err_2D_abs(cNr,1)          = NaN;
        velo_e.err_2D_abs_drive(cNr,1)    = NaN;
        velo_e.err_2D_abs_recovery(cNr,1) = NaN;
        
        % update/addition by bekin (23.11.18)
        velo_e.err_2D_veloCyc(cNr,1)      = NaN;
        velo_e.err_2D_veloCatch(cNr,1)    = NaN;
        velo_e.err_2D_veloRelease(cNr,1)  = NaN;  
        
        
        velo_e.veloErrorWaterContact(cNr,1)  = NaN; 
        velo_e.veloErrorAirContact(cNr,1)    = NaN; 
        
    else
        
        %% Baseline, Catch Trials and Retention
        % use RESAMPLED data, use standard reference trajectory from file
        %if strcmp(isCondition(participant, run, block),'BLorCTorRE')
        if strcmp(variableBase,'Theta Right')
            
            % Ref velocity
            f(cNr).ref_velo_theta = diff(refCyc.theta')/study.SamplingRate;
            f(cNr).ref_velo_delta = diff(refCyc.delta')/study.SamplingRate;
            
            f(cNr).ref_velo_2D = sqrt(...
                (diff(refCyc.theta')).^2 +...
                (diff(refCyc.delta')).^2) ./ ...
                study.SamplingRate;
            
            % changed 26.3.2013: resampled velocity must be
            % corrected by cycle time, otherwise velocity is wrong
            
            resamp(cNr).act_velo_theta = diff(resamp(cNr).theta_r)/...
                study.SamplingRate...
                /(TpCycles.time_nat(cNr)/study.RefCycleDuration);
            
            resamp(cNr).act_velo_delta = diff(resamp(cNr).delta_r)/...
                study.SamplingRate...
                /(TpCycles.time_nat(cNr)/study.RefCycleDuration);
            
            resamp(cNr).act_velo_2D = (sqrt(...
                (diff(resamp(cNr).theta_r)).^2 +...
                (diff(resamp(cNr).delta_r)).^2) ./ ...
                study.SamplingRate)...
                /(TpCycles.time_nat(cNr)/study.RefCycleDuration);
            
            x1 = f(cNr).ref_velo_2D(1:redby:end)';
            x2 = resamp(cNr).act_velo_2D(1:redby:end)';
            lambda = 0;
            y1 = zeros(size(x1)); % "not calculated" as data are 1D
            y2 = zeros(size(x2)); % "not calculated" as data are 1D
            T1 = [1:length(x1)];
            T2 = [1:length(x2)];  % as resampled velocity is divided by cycle time, this is correct. T1 = T2 is okay.
            
            %%
            % 23.11.2018 - bekin
            % !!! NOTE: Activate the script below for studies done without "ADWI" !!!            
% %             [spat_error_mean,spatDrive,spatRecovery,np_opt,drive_idx,rec_idx]= bellmann_giese_varyingduration_velocity(x1,x2,y1,y2,lambda,T1,T2);
            
            % For the studies with ADWI, the script below(Phase definitions are slightly changed compared to Model2013):
            [velo_error_mean, ~, veloCyc, veloCatch, veloDrive, veloRelease, veloRecovery, ...
             np_opt         ,    cyc_idx, catch_idx, drive_idx, release_idx, rec_idx     ,...
             veloDriveWaterContact, veloRecAirContact, driveWaterVelo_idx, recAirVelo_idx] = bellmann_giese_varyingduration_velocity_Adwi(x1,x2,y1,y2,lambda,T1,T2);
            
            velo_e.err_2D_abs(cNr,1)          = velo_error_mean;
            velo_e.err_2D_abs_drive(cNr,1)    = veloDrive;
            velo_e.err_2D_abs_recovery(cNr,1) = veloRecovery;
            
            velo_e.err_2D_veloCyc(cNr,1)      = veloCyc;
            velo_e.err_2D_veloCatch(cNr,1)    = veloCatch;
            %e.err_2D_veloDrive(cNr,1)   = veloDrive;
            velo_e.err_2D_veloRelease(cNr,1)  = veloRelease;
            %e.err_2D_veloRecovery(cNr,1)= veloRecovery;
            
            
            velo_e.veloErrorWaterContact(cNr,1) = veloDriveWaterContact;
            velo_e.veloErrorAirContact(cNr,1)   = veloRecAirContact;            
            
                                   
            velo_e.err_theta(cNr,1) = NaN;
            velo_e.err_delta(cNr,1) = NaN;
            
            
            %% Training with concurrent feedback
            %elseif strcmp(isCondition(participant, run, block),'TR')
        elseif strcmp(variableBase,'Theta Reference Right')
            
            f(cNr).ref_velo_theta = diff(cycData(cNr).thetaRef_r)/...
                study.SamplingRate;
            
            f(cNr).ref_velo_delta = diff(cycData(cNr).deltaRef_r)/...
                study.SamplingRate;
            
            f(cNr).ref_velo_2D = sqrt(...
                (diff(cycData(cNr).thetaRef_r)).^2 +...
                (diff(cycData(cNr).deltaRef_r)).^2) ./ ...
                study.SamplingRate;
            
            % Act velocity (not resampled)
            f(cNr).act_velo_theta = diff(cycData(cNr).theta_r)/...
                study.SamplingRate;
            
            f(cNr).act_velo_delta = diff(cycData(cNr).delta_r)/...
                study.SamplingRate;
            
            f(cNr).act_velo_2D = sqrt(...
                (diff(cycData(cNr).theta_r)).^2 +...
                (diff(cycData(cNr).delta_r)).^2) ./ ...
                study.SamplingRate;
            
            x1 = f(cNr).ref_velo_2D(1:redby:end);
            x2 = f(cNr).act_velo_2D(1:redby:end);
            lambda = 0;
            y1 = zeros(size(x1));
            y2 = zeros(size(x2));
            T1 = [1:length(x1)];
            T2 = [1:length(x2)];
                        
            % 23.11.2018 - bekin
            % !!! NOTE: Activate the script below for studies done without "ADWI" !!!            
% %             [velo_error_mean,veloDrive,veloRecovery,np_opt,drive_idx,rec_idx]= bellmann_giese_varyingduration_velocity(x1,x2,y1,y2,lambda,T1,T2);
            
            % For the studies with ADWI, the script below(Phase definitions are slightly changed compared to Model2013):
            [velo_error_mean, ~, veloCyc, veloCatch, veloDrive, veloRelease, veloRecovery , ...
             np_opt         ,    cyc_idx, catch_idx, drive_idx, release_idx, rec_idx      , ...
             veloDriveWaterContact, veloRecAirContact, driveWaterVelo_idx, recAirVelo_idx ] = bellmann_giese_varyingduration_velocity_Adwi(x1,x2,y1,y2,lambda,T1,T2);            
            
            velo_e.err_2D_abs(cNr,1)          = velo_error_mean;
            velo_e.err_2D_abs_drive(cNr,1)    = veloDrive;
            velo_e.err_2D_abs_recovery(cNr,1) = veloRecovery;           
            
            velo_e.err_2D_veloCyc(cNr,1)      = veloCyc;
            velo_e.err_2D_veloCatch(cNr,1)    = veloCatch;
            velo_e.err_2D_veloRelease(cNr,1)  = veloRelease;
            
            
            velo_e.veloErrorWaterContact(cNr,1) = veloDriveWaterContact;
            velo_e.veloErrorAirContact(cNr,1)   = veloRecAirContact;                  
            
            
            velo_e.err_theta(cNr,1) = NaN;
            velo_e.err_delta(cNr,1) = NaN;            
        end
    end
    
    %% Display
    if true == false
        
        figure()
        hold on
        plot(x1,'g','linewidth',2);
        plot(x2,'k','linewidth',2);
        
        %Draw connecting lines between corresponding samples:
        for index=1:length(np_opt)
            plot([index,np_opt(index)],[x1(index),x2(np_opt(index))],'k');
        end
        
        for index=1:length(drive_idx)
            plot([drive_idx(index),np_opt(drive_idx(index))],[x1(drive_idx(index)),x2(np_opt(drive_idx(index)))],'g');
        end
        
        for index=1:length(rec_idx)
            plot([rec_idx(index),np_opt(rec_idx(index))],[x1(rec_idx(index)),x2(np_opt(rec_idx(index)))],'b');
        end
        
        xlabel('sample');
        ylabel('velocity [rad/s]');
        
        legend('ref','act','Location','NorthEast')
        
    end
    
    % Plot for paper with 125 datapoints
    if true == false
        graph = evalin('base','graph');
        if cNr == 21 % example part 23, BL, worst performance, median value
            %if cNr == 31 % example part 9, RE2, best performance, median value
            if strcmp(isInGroup(participant),'V')
                gColIdx = 1;
            elseif strcmp(isInGroup(participant),'AV')
                gColIdx = 2;
            elseif strcmp(isInGroup(participant),'VH')
                gColIdx = 3;
            end
            
            figure()
            hold on
            plot(x1*180/pi,'k','linewidth',2);
            plot(x2*180/pi,...
                'color', graph.gCol(gColIdx,:)*graph.gDark(gColIdx),'linewidth',2);
            
            %Draw connecting lines between corresponding samples:
            for index=1:length(np_opt)
                plot([index,np_opt(index)],[x1(index),x2(np_opt(index))]*180/pi,...
                    'color', graph.gCol(gColIdx,:)*graph.gDark(gColIdx),'linewidth',1);
            end
            
            % set(gca,'FontSize',24)
            xlim([1,125])
            % ylim([-19,14])
            legend('target velocity','subject velocity',num2str(velo_e.err_2D_abs(cNr,1)*180/pi,3),'Location','NorthEast')
            
            set(gca,'XTick', [0:25:125])
            % set(gca,'XTick', [])
            set(gca, 'xticklabel', {'0','0.5','1','1.5','2','2.5'})
            xlabel('time [s]');
            ylabel('velocity [°/s]');
            
            %set(gcf, 'PaperPosition', [1 1 16 12]);
            set(gcf, 'PaperPosition', [1 1 10.5 4.87]);
            fileName =  ['./figures/velocityDTWexample_' participant '_run' num2str(run) '_cycle' num2str(cNr) '.eps'];
            print('-depsc', fileName);
        end
    end
    
end

%    elseif isValidBlock(participant, run, block) == false
%
%         e.err_theta             = NaN;
%         e.err_delta             = NaN;
%         e.err_2D_abs            = NaN;
%         e.err_2D_abs_drive      = NaN;
%         e.err_2D_abs_recovery   = NaN;
%
%     end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
d=velo_e;

%     status='save';saveLoadExtracted_2013_03_Multimodal_V_VA_VH;
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% elseif strcmp(be,'yes')
%     e=d;
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

