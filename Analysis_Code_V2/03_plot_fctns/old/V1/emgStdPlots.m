function [] = emgStdPlots(PATH,namesMov,namesCon,namesMus)
if namesMov == 'all'
    namesMov = {'abd','fle','mj1'};
if namesCon == 'all'
    namesCon = {'conb','robb','cont','robt','bri'};
end
if namesMus == 'all'
    namesMus = {'ut','pd','ad','pm','bb','lt'};
end


%% Prepare Path variables & Check Input
% Get Subject structure Path
if nargin == 4
    SUBJECT = PATH;
elseif nargin == 1
    [FNAME, PATH, ~] = uigetdir();
    SUBJECT = [PATH,'\',FNAME];
end

% Get subject folder Path
tempPath = strsplit(SUBJECT,'\');
PATH = strjoin(tempPath(1:(end-2)),'\');

% Check Inputs, correct if error
if ~iscell(namesMov)
    namesMov = {namesMov};
end
if ~iscell(namesCon)
    namesCon = {namesCon};
end
if ~iscell(namesMus)
    namesMus = {namesMus};
end

% Commonly used variables:
numMov = length(namesMov);
numCon = length(namesCon);
numMus = length(namesMus);

% %% Create Raw Data Plots
% % Check if raw folder is present
% RAWPLOT = [PATH,'\analysis\rawPlots'];
% if ~isfolder(RAWPLOT)
%     mkdir(RAWPLOT)
% end
% 
% myData = emg_plt(SUBJECT);
% for j_mov = 1:numMov
%     for j_mus = 1:numMus
%         for j_con = 1:5
%             myData.plotRaw(namesMov{j_mov}, {get_ncon(j_con)}, namesMus{j_mus}, false, true);
%         end
%         myData.draw(true,3,2);
%         FNAME = [RAWPLOT,'\rp_',namesMov{j_mov},'_',namesMus{j_mus},'.fig'];
%         myData.save(FNAME);
%         myData.newFigure();
%     end
%     
% end
% close all
% 
% %% Create SRE Plots
% % Check if raw folder is present
% SREPLOT = [PATH,'\analysis\SREPlots'];
% if ~isfolder(SREPLOT)
%     mkdir(SREPLOT)
% end
% 
% myData = emg_plt(SUBJECT);
% for j_mov = 1:numMov
%     for j_mus = 1:numMus
%         myData.plotRaw(namesMov{j_mov}, {'conb','robb'}, namesMus{j_mus}, true, true);
%         myData.plotRaw(namesMov{j_mov}, {'cont','robt','bri'}, namesMus{j_mus}, true, true);
%         myData.draw(true);
%         FNAME = [SREPLOT,'\SRErp_',namesMov{j_mov},'_',namesMus{j_mus},'.fig'];
%         myData.save(FNAME);
%         myData.newFigure();
%     end
% end
% close all

%% Create Repetition Plots
REPPLOT = [PATH,'\analysis\REPPlots'];
if ~isfolder(REPPLOT)
    mkdir(REPPLOT)
end

myData = emg_plt(SUBJECT);
for j_mov = 1:numMov
    for j_mus = 1:numMus
        myData.plotRep(namesMov(j_mov), namesCon, namesMus(j_mus), true, true, true,true)
        myData.draw(false,3,2);
        FNAME = [REPPLOT,'\REPrp_',namesMov{j_mov},'_',namesMus{j_mus},'.fig'];
        myData.save(FNAME);
        myData.newFigure();
    end
end
close all

%% Create Condition Comparison Plot
condPLOT = [PATH,'\analysis\condPlots'];
if ~isfolder(condPLOT)
    mkdir(condPLOT)
end

myData = emg_plt(SUBJECT);
for j_mov = 1:numMov
    for j_mus = 1:numMus
        myData.plotComp(namesMov{j_mov},namesMus{j_mus}, true)
        myData.draw(true);
        FNAME = [condPLOT,'\condrp_',namesMov{j_mov},'_',namesMus{j_mus},'.fig'];
        myData.save(FNAME);
        myData.newFigure();
    end
    for j_mus = 1:numMus
        myData.plotComp(namesMov{j_mov},namesMus{j_mus}, true)
    end
    myData.draw(false,3,2);
    FNAME = [condPLOT,'\condrp_',namesMov{j_mov},'_summary','.fig'];
    myData.save(FNAME);
    myData.newFigure();
end
close all

%% Create dtw
dtwPLOT = [PATH,'\analysis\dtwPlots'];
if ~isfolder(dtwPLOT)
    mkdir(dtwPLOT)
end
types = {'rc','bc','br'};
myData = emg_plt(SUBJECT);
for j_mov = 1:numMov
    for j_type = 1:3
        for j_mus = 1:numMus
            myData.plotDTW(namesMov{j_mov}, namesMus{j_mus},types{j_type}, true)
        end
        myData.draw(false,3,2);
        FNAME = [dtwPLOT,'\dtwrp_',namesMov{j_mov},'_',types{j_type},'.fig'];
        myData.save(FNAME);
        myData.newFigure();
    end
end
close all
end