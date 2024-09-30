function spat_e = extractSpatioTemporalErrorPhases(participant, run, varargin)

% variableName = 'SpatioTemporalErrorPhases';

% Shifts theta/delta towards the theta/delta ref figure until the spatial
% error of the spatio temporal analysis is close to minimal. Then, output
% is shift vector, spatiotemp error mean, spatial error mean (minimized)
% and temporal error mean. The spatial error is then also calculated after
% scaling and shifting.

% PARTICIPANT can be either id or abbreviation
% RUN is run number
% VARARGIN{1} is BLOCK number
% VARARGIN{2} variable, which is the base for finding cycles

% Version 1 Date: 26.05.2011
% Version 1 Author: Roland Sigrist, Georg Rauter

% Update: 07.06.2011
% Author: Roland Sigrist

% Update: 03.02.2012
% Author: Roland Sigrist (scaling added)

% Update: 23.03.2013
% Author: Roland Sigrist (for multimodal study)

% Update: 24.07.2013
% Author: Roland Sigrist (for multimodal paper)

% Update: 23.11.2018
% Author: Ekin Basalp (for ADWI model error analysis)


%%%%%%%%%% TO DO TO DO
% spatError in spatErrorCyc umwandeln
% namen korrigieren

% cleanUp: use comparableStrokeTriplets anstatt redundantem code

study = getStudy();
plostate = false;

%% Check Varargin
% vararginsBlockVariableBase

%% Check Varargin
if isempty(varargin)
    block=0;
    if block ~= 0
        variableBase = study.runs(run.Number).blocks(block).cutVariable;
    else
        variableBase = study.runs(run.Number).blocks(1).cutVariable;
    end
    
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

run = run.Number; %


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load data if existing
% status='load';saveLoadExtracted_2013_03_Multimodal_V_VA_VH;

% run = run.Number;
% participant = lower(participant.Abbreviation);

% be = 'no'; % run even though saved data exists already
% if strcmp(be,'no')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Set paramaters

redby = 2; % 250 datapoints used. reduce datapoints to save computation time


%% Cycle data
TpCycles    = getData(participant, run, 'TpCycles', block);
cycData     = getData(participant, run, 'CycleData', block);
resamp      = getData(participant, run, 'CycleDataResampled', block);
%     cycData     = getCycleData(participant, run, block, variableBase);
%     resamp      = extractCycleDataResampled(participant, run, block, variableBase);

%     cycData     = cycData(TpCycles.cyc_nat); display('only cyc_nat included')
%     resamp      = resamp(TpCycles.cyc_nat); display('only cyc_nat included')

display(['Nr of cycles: ' num2str(length(cycData)) ' = ' num2str(length(resamp))])
display('first, last, and innatural cycles set to NaN')

if ~isempty(cycData)
    for cNr = 1:length(cycData)
        % set first, last, and innat cycles to NaN
        if isempty(find(TpCycles.cyc_nat==cNr)) | cNr == 1 | cNr == length(cycData) | ...
                (TpCycles.time_all(cNr-1) > 10 && cNr > 1) | (TpCycles.time_all(cNr+1) > 10 && cNr < length(cycData))
            % check if cycle before or after is not a cycle that is
            % more than 10s (e.g. because condition was interrupted).
            % This is important to extract spatiotemp error from the
            % phases, as the input data is used from the cycle before,
            % the current cycle, and the cycle afterwards
            
            spat_e.spatErrorCyc(cNr,1) = NaN;
            spat_e.tempErrorCyc(cNr,1) = NaN;
            
            spat_e.spatErrorDriveWat(cNr,1) = NaN;
            spat_e.spatErrorRecHor(cNr,1)   = NaN;
            spat_e.spatErrorCatch(cNr,1)    = NaN;
            spat_e.spatErrorRelease(cNr,1)  = NaN; 
            
            spat_e.spatErrorWaterContact(cNr,1)	= NaN;
            spat_e.spatErrorAirContact(cNr,1)  = NaN;
        else
            
            
            %% ASSIGN DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if (abs(mean(cycData(cNr).theta_r)) >= 0) == false % if cycle contains NaN set to NaN
                
                spat_e.spatErrorCyc(cNr,1) = NaN;
                spat_e.tempErrorCyc(cNr,1) = NaN;
                
                spat_e.spatErrorDriveWat(cNr,1) = NaN;
                spat_e.spatErrorRecHor(cNr,1)   = NaN;
                spat_e.spatErrorCatch(cNr,1)    = NaN;
                spat_e.spatErrorRelease(cNr,1)  = NaN;
                
                spat_e.spatErrorWaterContact(cNr,1)	= NaN;
                spat_e.spatErrorAirContact(cNr,1)   = NaN;                
                                
            else
                %% Baseline, Catch Trials and Retention
                % use resampled data, use standard reference trajectory from file
                %                     if strcmp(isCondition(participant, run, block),'BLorCTorRE')
                if strcmp(variableBase,'Theta Right')
                    
                    display(['run: ' num2str(run) '; block: ' num2str(block) '; cut variable: ' variableBase '-> desiredTrajectory1 loaded'])
                    
                    % Load Ref
                    load desiredTrajectory1refCyc
                    refCyc.theta = refCyc.theta(1:10:end);
                    refCyc.delta = refCyc.delta(1:10:end);
                    
                    % ref % THREE CYCLES
                    xref(:,1) = [refCyc.theta(1:redby:end); refCyc.theta(1:redby:end); refCyc.theta(1:redby:end)];
                    xref(:,2) = [refCyc.delta(1:redby:end); refCyc.delta(1:redby:end); refCyc.delta(1:redby:end)];
                    
                    Tref = study.RefCycleDuration*3; % THREE CYCLES!!!
                    
                    %  Meas % THREE CYCLES (before, current, after)
                    xmeas(:,1) = [resamp(cNr-1).theta_r(1:redby:end) resamp(cNr).theta_r(1:redby:end) resamp(cNr+1).theta_r(1:redby:end)];
                    xmeas(:,2) = [resamp(cNr-1).delta_r(1:redby:end) resamp(cNr).delta_r(1:redby:end) resamp(cNr+1).delta_r(1:redby:end)];
                    Tmeas = cycData(cNr+1).Time(end) - cycData(cNr-1).Time(1);
                    
                    %% Training (not Catch Trials)
                    % use not-resampled data act and ref
                elseif strcmp(variableBase,'Theta Reference Right')
                    
                    display([study.runs(run).blocks(block).blockName ', block ' num2str(block) ', cut variable: ' variableBase])
                    
                    % ref % THREE CYCLES
                    xref(:,1) = [cycData(cNr-1).thetaRef_r(1:redby:end); cycData(cNr).thetaRef_r(1:redby:end); cycData(cNr+1).thetaRef_r(1:redby:end)];
                    xref(:,2) = [cycData(cNr-1).deltaRef_r(1:redby:end); cycData(cNr).deltaRef_r(1:redby:end); cycData(cNr+1).deltaRef_r(1:redby:end)];
                    Tref = cycData(cNr+1).Time(end) - cycData(cNr-1).Time(1);
                    
                    % meas % THREE CYCLES
                    xmeas(:,1) = [cycData(cNr-1).theta_r(1:redby:end); cycData(cNr).theta_r(1:redby:end); cycData(cNr+1).theta_r(1:redby:end)];
                    xmeas(:,2) = [cycData(cNr-1).delta_r(1:redby:end); cycData(cNr).delta_r(1:redby:end); cycData(cNr+1).delta_r(1:redby:end)];
                    Tmeas = Tref;
                    
                elseif block == 0
                    error('Spatiotemporal analysis makes no sense for block = 0')
                end
                
                
                %% SPATIOTEMPORAL ERROR (NO SHIFTING) %%%%%%%%%%%%%%%%%%%%
                lambda = 0; % weight lambda (0 = spatial error maximally weighted)
                
                %% 23.11.2018 - bekin                   
                % !!! NOTE: Activate the script below for studies done without "ADWI" !!!              
% %                 [~,~,~, spatCyc, tempCyc, spatDriveWat, spatRecHor, spatCatch, spatRelease,...
% %                     np_opt, cyc_idx, drive_idx, rec_idx, catch_idx, release_idx] = ...
% %                     bellmann_giese_varyingduration_phases(xref,xmeas,lambda,Tref,Tmeas);

                % For the studies with ADWI, run the script below (Phase definitions are slightly changed compared to Model2013):                
                [~, ~, ~, spatCyc, tempCyc, spatDriveWat, spatRecHor, spatCatch, spatRelease   ,...
                 np_opt , cyc_idx         , drive_idx   , rec_idx   , catch_idx, release_idx   ,...
                 spatDriveWaterContact, spatRecAirContact, driveWaterOnly_idx, recAllAir_idx] = bellmann_giese_varyingduration_phases_Adwi(xref,xmeas,lambda,Tref,Tmeas);
                
                %% Reassign results for output
                spat_e.spatErrorCyc(cNr,1)      = spatCyc;
                spat_e.tempErrorCyc(cNr,1)      = tempCyc;
                spat_e.spatErrorDriveWat(cNr,1)	= spatDriveWat;
                spat_e.spatErrorRecHor(cNr,1)	= spatRecHor;
                spat_e.spatErrorCatch(cNr,1)	= spatCatch;
                spat_e.spatErrorRelease(cNr,1)	= spatRelease;
                
                spat_e.spatErrorWaterContact(cNr,1)	= spatDriveWaterContact;
                spat_e.spatErrorAirContact(cNr,1)   = spatRecAirContact;                
                
                %%
                if true == plostate
                    
                    figure()
                    hold on
                    plot(xmeas(:,1),xmeas(:,2),'k','linewidth',2);
                    plot(xref(:,1),xref(:,2),'g','linewidth',2);
                    xlabel('first dimension of xmeas and xref');
                    ylabel('second dimension of xmeas and xref');
                    
                    hline(-5.16/180*pi,'b') % oar touches water
                    
                    %Draw connecting lines between corresponding samples:
                    for index=1:length(np_opt)
                        plot([xref(index,1),xmeas(np_opt(index),1)],[xref(index,2),xmeas(np_opt(index),2)],'y');
                    end
                    
                    for index=1:length(cyc_idx)
                        plot([xref(cyc_idx(index),1),xmeas(np_opt(cyc_idx(index)),1)],[xref(cyc_idx(index),2),xmeas(np_opt(cyc_idx(index)),2)],'-k');
                    end
                    
                    for index=1:length(drive_idx)
                        plot([xref(drive_idx(index),1),xmeas(np_opt(drive_idx(index)),1)],[xref(drive_idx(index),2),xmeas(np_opt(drive_idx(index)),2)],'-g');
                    end
                    
                    for index=1:length(rec_idx)
                        plot([xref(rec_idx(index),1),xmeas(np_opt(rec_idx(index)),1)],[xref(rec_idx(index),2),xmeas(np_opt(rec_idx(index)),2)],'-b');
                    end
                    
                    for index=1:length(catch_idx)
                        plot([xref(catch_idx(index),1),xmeas(np_opt(catch_idx(index)),1)],[xref(catch_idx(index),2),xmeas(np_opt(catch_idx(index)),2)],'-r');
                    end
                    
                    for index=1:length(release_idx)
                        plot([xref(release_idx(index),1),xmeas(np_opt(release_idx(index)),1)],[xref(release_idx(index),2),xmeas(np_opt(release_idx(index)),2)],'-m');
                    end
                    
                    % Start points of ref and meas
                    %                         plot(xmeas(1,1),xmeas(1,2),'*r')
                    %                         plot(xref(1,1),xref(1,2),'gd')
                    % set(gca,'FontSize',24)
                    legend('measured trajectory xmeas' ,'reference trajectory (xref)','correspondence of samples','Location','NorthEast')
                    axis equal
                    legend('measured' ,'reference','Location','NorthEast')
                    xlabel('horizontal angle [rad]')
                    ylabel('vertical angle [rad]')
                end
                
                %%
                
                %                     % Plot for paper with 125 datapoints
                %                     if true == true
                %                         graph = study.graph;
                %                         if cNr == 22 % example part 16, BL, worst performance, median value
                %                         %if cNr ==69 % example part 4, RE2, best performance, median value
                %                             if strcmp(isInGroup(participant),'V')
                %                                 gColIdx = 1;
                %                             elseif strcmp(isInGroup(participant),'AV')
                %                                 gColIdx = 2;
                %                             elseif strcmp(isInGroup(participant),'VH')
                %                                 gColIdx = 3;
                %                             end
                %
                %                             figure()
                %                             hold on
                %                             plot(xref(cyc_idx,1)*180/pi,xref(cyc_idx,2)*180/pi,...
                %                                 'k','linewidth',2);
                %                             plot(xmeas(cyc_idx,1)*180/pi,xmeas(cyc_idx,2)*180/pi,...
                %                                 'color', graph.gCol(gColIdx,:)*graph.gDark(gColIdx),'linewidth',2);
                %
                %                             %Draw connecting lines between corresponding samples:
                %                             for index=1:length(cyc_idx)
                %                                 plot([xref(cyc_idx(index),1),xmeas(np_opt(cyc_idx(index)),1)]*180/pi,...
                %                                     [xref(cyc_idx(index),2),xmeas(np_opt(cyc_idx(index)),2)]*180/pi,...
                %                                     'color', graph.gCol(gColIdx,:)*graph.gDark(gColIdx),'linewidth',1);
                %                             end
                %                             % set(gca,'FontSize',24)
                %                             xlim([-25,20])
                %                             ylim([-19,34])
                %                             axis equal
                %                             legend('target trajectory' ,'subject trajectory',num2str(st.spatErrorCyc(cNr,1)*180/pi,3),'Location','NorthEast')
                %                             xlabel('horizontal angle [°]')
                %                             ylabel('vertical angle [°]')
                %
                %                             set(gcf, 'PaperPosition', [1 1 16 12]);
                %                             fileName =  ['./figures/spattempExamples_' participant '_run' num2str(run) '_cycle' num2str(cNr) '.eps'];
                %                             print('-depsc', fileName);
                %                         end
                %                     end
                
                
                %% Clean up
                clearvars -except st study cycData TpCycles resamp ...
                    participant run block variableName redby ...
                    variableBase plostate spat_e
                
            end
        end
    end
else
    spat_e.spatErrorCyc      = [];
    spat_e.tempErrorCyc      = [];
    
    spat_e.spatErrorDriveWat = [];
    spat_e.spatErrorRecHor   = [];
    spat_e.spatErrorCatch    = [];
    spat_e.spatErrorRelease  = [];    
    
    
    spat_e.spatErrorWaterContact = [];
    spat_e.spatErrorAirContact   = [];
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
d=spat_e;
%     status='save';saveLoadExtracted_2013_03_Multimodal_V_VA_VH;
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% elseif strcmp(be,'yes')
%     st=d;
% end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
