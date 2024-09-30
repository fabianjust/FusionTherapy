function [ploth, legh] = plotScaling(axh,subject,iMov,iDiff,iMus,boolLegend)


switch iDiff
    case 1
        iCons = [1,2];
        nCons = {'Conventional','Teach'};
    case 2
        iCons = [1,3];
        nCons = {'Conventional','Imitate'};
    case 3
        iCons = [2,3];
        nCons = {'Teach','Imitate'};
    otherwise
        msgID = 'plotSignum:invalidInput';
        msgTxt = 'iDiff must be either 1,2 or 3';
        throw(MException(msgID,msgTxt));
end


x = linspace(0,100,4000)';
y1 = subject.primaryOutcome(iMov).meanCfi(iCons(1)).mean(:,iMus);
y2 = subject.primaryOutcome(iMov).meanCfi(iCons(2)).mean(:,iMus);
scaleFactor = subject.primaryOutcome(iMov).rmsOpt(iDiff).scaleFactor(iMus);
y2_scaled = y2*scaleFactor;
cmap = lines(2);
ploth(1) = line(axh,x,y1,'Color',cmap(1,:));
legh{1} = [nCons{1} , ' mean'];
ploth(2) = line(axh,x,y2,'Color',cmap(2,:));
legh{2} = [nCons{2}, ' mean'];
ploth(3) = line(axh,x,y2_scaled,'Color',cmap(2,:),'LineStyle','-.');
legh{3} = [nCons{2}, ' scaled mean'];

weight = subject.primaryOutcome(iMov).muscleWeights(iMus);
scaledDiff = subject.primaryOutcome(iMov).rmsOpt(iDiff).scaledRms(iMus);

titleTxt = [getFullName(get_nmov(iMov)),' - ',get_nmus(iMus,true),newline,...
    'S. Factor: ', num2str(scaleFactor),', RMS E.: ',num2str(scaledDiff),', Weight: ',num2str(weight)];
title(titleTxt);
if boolLegend
    legend(legh)
end
xlabel('Time [%]')
ylabel('MVC Normed EMG Signal [-]')
end