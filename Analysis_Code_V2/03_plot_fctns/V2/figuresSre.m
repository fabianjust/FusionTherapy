function [] = figuresSre(subject,PATH)

iFig = 0;
for iMov = [1,4,5]
    for iMus = 1:6
        iFig = iFig + 1;
        figh(iFig) = figure();
        iAx = 0;
        for iCon = [3,1,4,2,5]
            iAx = iAx + 1;
            axh(iCon) = subplot(3,2,iAx);
            plotSre(axh(iCon),subject,PATH,iMov,iCon,iMus,true)
            titleTxt = ['SRE EMG: ', get_nmus(iMus,true), newline,... 
                getFullName(get_nmov(iMov)),' - ', getFullName(get_ncon(iCon))];
            title(titleTxt)
        end
        fname = ['\analysis\sre\SRE_',get_nmov(iMov),'_',get_nmus(iMus,false),'.fig'];
            
        saveas(figh(iFig),char([PATH,fname]))
    end
end

end