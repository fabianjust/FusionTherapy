function [muscles_EMG] = muscle_array(tnorm_EMG)
%MUSCLE_ARRAY Stores EMG data from tnorm (sorted by repetition) in
%structure array sorted by muscle

% 1. General initialisation
muscles_EMG = struct();
repetitions = fields(tnorm_EMG);
n_repetitions = length(repetitions);
n_samples = size(tnorm_EMG.movement_1,1);
UT = zeros(n_samples,n_repetitions-2);
PD = zeros(n_samples,n_repetitions-2);
AD = zeros(n_samples,n_repetitions-2);
PM = zeros(n_samples,n_repetitions-2);
BB = zeros(n_samples,n_repetitions-2);
TB = zeros(n_samples,n_repetitions-2);
% muscle_names = {'upper_trapezius','post_deltoid','anterior_deltoid','pectoralis_major','biceps_brachii','triceps_brachii'};

% 2. Store repetition data in muscle matrix
for i=2:n_repetitions-1
    field = char(repetitions(i));
    daten = tnorm_EMG.(field);
    UT(:,i-1) = daten(:,1);
    PD(:,i-1) = daten(:,2);
    AD(:,i-1) = daten(:,3);
    PM(:,i-1) = daten(:,4);
    BB(:,i-1) = daten(:,5);
    TB(:,i-1) = daten(:,6);    
end

% 3. Assign muscle matrix to structure array
muscles_EMG.upper_trapezius = UT;
muscles_EMG.posterior_deltoid = PD;
muscles_EMG.anterior_deltoid = AD;
muscles_EMG.pectoralis_major = PM;
muscles_EMG.biceps_brachii = BB;
muscles_EMG.triceps_brachii = TB;
end

