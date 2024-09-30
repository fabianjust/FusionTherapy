function [muscles_EMG_normalized] = maximum_voluntary_contraction(muscles_EMG)
% MAXIMUM_VOLUNATRY_CONTRACTION normalizes the EMG output to MVC and
% displays the results as percentage of MCV (%MVC)
% MVC is defined as the maximum EMG amplitude in the isometric
% contraction.

% lodad MVC data
MVC_UT = EMGelaboration_adapted('cut_MVC_UT');
MVC_PD = EMGelaboration_adapted('cut_MVC_PD');
MVC_AD = EMGelaboration_adapted('cut_MVC_AD');
MVC_PM = EMGelaboration_adapted('cut_MVC_PM');
MVC_BB = EMGelaboration_adapted('cut_MVC_BB');
MVC_TB = EMGelaboration_adapted('cut_MVC_TB');

% change datatype from struct to matrix
MVC.UT_data = cell2mat(struct2cell(MVC_UT));
MVC.PD_data = cell2mat(struct2cell(MVC_PD));
MVC.AD_data = cell2mat(struct2cell(MVC_AD));
MVC.PM_data = cell2mat(struct2cell(MVC_PM));
MVC.BB_data = cell2mat(struct2cell(MVC_BB));
MVC.TB_data = cell2mat(struct2cell(MVC_TB));

% determine MVC value for each muscle and safe it in MVC structure
fieldnames = fields(MVC);
n_muscles = length(fieldnames);

for i = 1:n_muscles
    newfield = char(fieldnames(i));
    newfield = newfield(1:2);
    
    max_contraction = 
    
    
    
    MVC.(newfield)= max_contraction;
    
end

% % Assign MVC data to corresponding muscle
% muscles_EMG.UT_MVC1 = MVC_UT;
% muscles_EMG.PD_MVC1 = MVC_PD;
% muscles_EMG.AD_MVC1 = MVC_AD;
% muscles_EMG.PM_MVC1 = MVC_PM;
% muscles_EMG.BB_MVC1 = MVC_BB;
% muscles_EMG.TB_MVC1 = MVC_TB;

% % Determine MVC value for each muscle
% fieldnames = fields(muscles_EMG);
% n_fields = length(fieldnames);
% 
% for i = 1:n_fields
%     if endsWith(fieldnames(i),'MVC1')
%         muscles_
%         
%     end
% end




end

