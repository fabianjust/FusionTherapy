function [tnorm_EMG] = normalize_time(EMG_data)
% NORMALIZE_TIME normalizes all repetitions of one trial temporally.
% The most popular concept, originally developed for gait analysis (11), 
% separates all repetition within a given sequence into an equal amount
% of periods and calculates the mean value of each period

% INPUT:
%           EMG_data: SRE_EMG data with several repetitions of various
%           duration

% OUTPUT:
%           tnorm_EMG: SRE_EMG data with several repetions of euqal
%           duration/equal amount of samples
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 1. General initialisation
movements = fieldnames(EMG_data);
n_movements = length(movements);
n_samples = zeros(n_movements,1);
tnorm_EMG = struct();
A_previous = 0;
% 2. Determine shortest movement
for i = 1:n_movements
    field = char(movements(i));
    n_samples(i,1) = size(EMG_data.(field),1);
end
min_samples = min(n_samples); 


% 3. Create periods and mean values
for i = 1:n_movements
    field = char(movements(i));
    S = zeros(min_samples,6);
    D = EMG_data.(field);
    n_samples_measured = size(EMG_data.(field),1);
    size_period = n_samples_measured/min_samples; % soll man hier min_samples oder einfach 100 nehmen?
    
    % Sonderfall Periodenlänge 1
    if size_period ==1
        D = D(1:min_samples,:);
        tnorm_EMG.(field)= D;
    else
    
    % Sonderfall p =1
    stop1 = size_period;
    c1 = stop1 - floor(stop1);
    C1 = ceil(stop1);
    all_additional1 = 0;
    n_additional1 = 0;
    if C1-1 >1
         n_additional1 = C1-1;
            ind1 = [];
            for k = 1:n_additional1
                help_ind1 = 1+k;
                W1 = D(help_ind1,:);
                ind1 = [ind1;W1];  
            end
            all_additional1 = sum(ind1);
    end
    
    C11 = D(C1,:);
    D11 = D(1,:);
    mean_period1 = (c1*C11+D11+all_additional1).*(1/(c1+1+n_additional1));
    S(1,:) = mean_period1;
    A_previous = C1;
    
    for p = 2+1:min_samples-1  
        start = (p-1)*size_period;
        stop = p*size_period;
        
        % Koeffizienten und Index für gewichtete Marker
        a = stop - floor(stop); % Anteil 1. Punkt aus nächster Periode
        b = ceil(start) - start; % Anteil aus gesplittetem Punkt aus vorherigem Intervall
        A = ceil(stop); % Index for marker with coefficient a
        B = A_previous; % Index for marker with coefficient b
        A_previous = A; % für nächste Iteration speichern
        
        all_additional = 0;
        n_additional=0;
        
        % Ungewichtete Marker (mit Koeffizient = 1)
        if A-B>1
            n_additional = A-B;
            ind = [];
            for k = 1:n_additional
                help_ind = B+k;
                W = D(help_ind,:);
                ind = [ind;W];  
            end
            all_additional = sum(ind);
        end
        
        
        % Mittelwert der Periode bestimmen und speichern
        A1 = D(A,:);
        B1 = D(B,:);
        mean_period = (a*A1 + b*B1+ all_additional).*(1/(a+b+n_additional)); 
        S(p,:) = mean_period;
    end
    
   
    % In Array speichern
    tnorm_EMG.(field) = S;
    end
end

end

