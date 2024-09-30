function [] = plot_cfi(PATH, FNAME,SPEC)

%Load Subject File to Workspace
if nargin ==0
    [FNAME, PATH,~] = uigetfile('*.mat')
end
load([PATH, '\', FNAME])

%Assert that folder for saves exists
FIGPATH = strcat(PATH,'\plot_cfi');
if(~isfolder(FIGPATH))
    mkdir(FIGPATH)
end

%Iterate through movements and conditions and generate plots (One figure
%per movement, one subplot per muscle
for i_mov=1:5
    figh = figure();
    name_mov = subject.movement(i_mov).name;
    
    %Check that current movement.condition is not empty, else go to
    %next movement
    if(~isempty(subject.movement(i_mov).condition))
        %Create axes for every muscle
        for i_mus = 1:6
            axh(i_mus) = subplot(2,3,i_mus);
            
            %Plot the data
            name_mus = subject.movement(i_mov).condition(1).repetition(1).emg_descr(i_mus);
            [plth, leg_text] = plot_conditions(axh(i_mus),subject,i_mov,i_mus,4);
            
            %Title and legend
            title(get_nmus(i_mus,true));
            if i_mus == 1
                legend(plth,leg_text);
            end                           
        end
        linkaxes(axh,'y');
             
        %Save Figure
        if nargin == 3
            FIGURE = ...
                strcat(FIGPATH,'\cfi_',name_mov,'_',SPEC,'_S',FNAME((end-1):(end-0)),'.fig');
        else
            FIGURE = ...
                strcat(FIGPATH,'\cfi_',name_mov,'_S',FNAME((end-1):(end-0)),'.fig');
        end
            
        saveas(figh,char(FIGURE));
        close
    end
end
close
end