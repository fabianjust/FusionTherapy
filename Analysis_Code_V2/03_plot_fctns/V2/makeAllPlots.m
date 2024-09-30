function [] = makeAllPlots(subject,savepath)
if nargin == 1
    savepath = uigetdir();
elseif nargin == 2
end

if ~isstruct(subject)
    try
        load(subject,'subject')
    catch ME
        rethrow(ME)
    end
end

SCALEPATH = [savepath,'\scaling'];
if ~isfolder(SCALEPATH)
    mkdir(SCALEPATH);
end
figuresScaleComparison(subject,SCALEPATH,true)

CONDPATH = [savepath,'\conditionComparison'];
if ~isfolder(CONDPATH)
    mkdir(CONDPATH);
end
figuresConditionComparison(subject,CONDPATH,true,true)

SIGNPATH = [savepath,'\signum'];
if ~isfolder(SIGNPATH)
    mkdir(SIGNPATH);
end
figuresSignComparison(subject,SIGNPATH,true)


end