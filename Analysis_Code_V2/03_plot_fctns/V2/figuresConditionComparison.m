function [figh] = figuresConditionComparison(subject, Path, boolClose,boolBaseline)


counter = 0;
counter2 = 0;

for i_mov = [1,4,5]
    counter2 = counter2+1;
    fighAllMuscles(counter2) = figure();
    
    for i_mus = 1:6
        if i_mus==1
            boolLegend = true;
        else
            boolLegend = false;
        end
        axh(i_mus) = subplot(3,2,i_mus,axes(fighAllMuscles(counter2)));
        plotConditionComparison(axh(i_mus),subject,get_nmov(i_mov),get_nmus(i_mus,false),boolBaseline,boolLegend);
        
        counter = counter + 1;
        figh(counter) = figure();
        plotConditionComparison(axes(),subject,get_nmov(i_mov),get_nmus(i_mus,false),boolBaseline,true);
        if ~isempty(Path)
            FNAME = [Path, '\meanEmgComp_', get_nmov(i_mov),'_',get_nmus(i_mus,false),'.fig'];
            saveas(figh(counter),char(FNAME));
        end
        if boolClose
            close
        end
    end
     if ~isempty(Path)
        FNAME = [Path, '\meanEmgCompAllMus_', get_nmov(i_mov),'_',get_nmus(i_mus,false),'.fig'];
        saveas(fighAllMuscles(counter2),char(FNAME));
     end
end
figh = [figh, fighAllMuscles];
end