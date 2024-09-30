%% Prepare data of patient
%Load subject struct
%PATH = 'C:\Users\david\Documents\21_Polybox\03_Balgrist\BridgeT_Studie\04_Artificial_Data\subject_01'
PATH = 'C:\Users\david\Documents\21_Polybox\Shared\RogerBeyelerInternshipARMin\Analysis_Code_testdata\subject_07_b'
load([PATH '\subject_07.mat'])

%Iterate through each movement
FIGPATH = strcat(PATH,'\figures_conditions');
for i_mov=1:5
    if(~isempty(subject.movement(i_mov).condition))
    name_mov = subject.movement(i_mov).name;
    figh = figure()
        for i_mus = 1:6
                name_mus = subject.movement(i_mov).condition(1).repetition(1).emg_descr(i_mus);
                axh(i_mus) = subplot(3,2,i_mus);
                [plth,legtext] = plot_conditions(axh(i_mus),subject,i_mov,i_mus,'m1b1');
                set(gcf,'Visible','on'),
        end
        legend([plth{:}],legtext);
        linkaxes(axh,'y')
        FIGURE = strcat(FIGPATH,'\condcomp_',name_mov,'.fig');
        saveas(figh,char(FIGURE));
        close
    end
end
