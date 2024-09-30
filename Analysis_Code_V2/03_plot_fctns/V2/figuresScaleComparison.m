function [figh] = figuresScaleComparison(subject, Path, boolClose)

counter = 0;
for i_mov = [1,4,5]    
    for i_mus = 1:6
        counter = counter + 1;
        figh(counter) = figure();
        for i_diff = 1:3
            axh(i_diff) = subplot(1,3,i_diff);
            plotScaling(axh(i_diff),subject,i_mov,i_diff,i_mus,true);
        end       
        
        if ~isempty(Path)
            FNAME = [Path, '\scaling_', get_nmov(i_mov),'_',get_nmus(i_mus,false),'.fig'];
            saveas(figh(counter),char(FNAME));
        end
        if boolClose
            close
        end
    end
end
end