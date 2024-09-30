function [ploth, legh] = plotSignum(axh,subject,iMov,iDiff,iMus,boolLegend)

weight = subject.primaryOutcome(iMov).muscleWeights(iMus);
overlap = subject.primaryOutcome(iMov).signum(iDiff).correlation(iMus);
switch iDiff
    case 1
        iCons = [1,2];
        nCons = {'Conventional','Teach'};
        titleTxt = ['Sign of derivatives: ',getFullName(get_nmov(iMov)),' - ',get_nmus(iMus,true), newline,...
            'Overlap: ',num2str(overlap),' Weight: ',num2str(weight)];
    case 2
        iCons = [1,3];
        nCons = {'Conventional','Imitate'};
        titleTxt = ['Sign of derivatives: ',getFullName(get_nmov(iMov)),' - ',get_nmus(iMus,true), newline,...
            'Overlap: ',num2str(overlap),' Weight: ',num2str(weight)];
    case 3
        iCons = [2,3];
        nCons = {'Teach','Imitate'};
        titleTxt = ['Sign of derivatives: ',getFullName(get_nmov(iMov)),' - ',get_nmus(iMus,true), newline,...
            'Overlap: ',num2str(overlap),' Weight: ',num2str(weight)];
    otherwise
        msgID = 'plotSignum:invalidInput';
        msgTxt = 'iDiff must be either 1,2 or 3';
        throw(MException(msgID,msgTxt));
end

x=linspace(0,100,4000);
for iter = 1:2
    smoSig(:,iter) = subject.primaryOutcome(iMov).signum(iCons(iter)).meanSmoothed(:,iMus);
    rawSig(:,iter) = subject.primaryOutcome(iMov).meanCfi(iCons(iter)).mean(:,iMus);
    derSigns(:,iter) = (subject.primaryOutcome(iMov).signum(iCons(iter)).derivativeSign(:,iMus) == 1);
    maxVals(iter) = max(smoSig(:,iter)); minVals(iter) = min(smoSig(:,iter));
end
lowerB = min(maxVals); upperB = max(minVals);
corrGate(:,1) = subject.primaryOutcome(iMov).signum(iDiff).correlationGate(:,iMus);


cMap = lines(2);
ploth(1) = line(axh,x,rawSig(:,1),'LineStyle','-','Color',cMap(1,:));
legh{1} = [nCons{1}, ' raw mean'];
ploth(2) = line(axh,x,rawSig(:,2),'LineStyle','-','Color',cMap(2,:));
legh{2} = [nCons{2}, ' raw mean'];
ploth(3) = line(axh,x,smoSig(:,1),'LineStyle','-.','Color',cMap(1,:));
legh{3} = [nCons{1},' smoothed mean'];
ploth(4) = line(axh,x,smoSig(:,2),'LineStyle','-.','Color',cMap(2,:));
legh{4} = [nCons{2},' smoothed mean'];
ploth(5) = line(axh,x(1:end-1),derSigns(:,1)*(maxVals(1)-minVals(1))+minVals(1),'LineStyle',':','Color',cMap(1,:));
legh{5} = [nCons{1},' derivative Sign'];
ploth(6) = line(axh,x(1:end-1),derSigns(:,2)*(maxVals(2)-minVals(2))+minVals(2),'LineStyle',':','Color',cMap(2,:));
legh{6} = [nCons{2},' derivative Sign'];
ploth(7) = line(axh,x(1:end-1),corrGate*0.1*(max(maxVals)-min(minVals))+0.5*(min(minVals)+max(maxVals)),...
    'LineStyle',':','Color',[186,85,211]/255,'LineWidth',2);
legh{7} = ['Sign Overlap'];

title(titleTxt)
if boolLegend
    legend(legh,'Location','best');
end
xlabel('Time [%]')
ylabel('MVC normed EMG signal')

 
end