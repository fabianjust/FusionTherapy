%find_startstop
%
%Author: David Mauderli - 2019
%
%DESCRIPTION: This function finds starting/stopping time and indices of
%each repetition. It does so by finding the minimum L2-norm of the distance
%from start to hand_1 and from stop to hand_1.
%
%INPUT:
%struct cutdata: from build_cutdata
%double Fs: Sampling freq.
%bool do_plot: plots if true
%
%OUTPUT:
%t_start: starting time
%i_start: starting indice
%etc...
%fail: fail flag

function [t_start, t_stop, i_start,i_stop,fail] = find_startstop(cutdata,Fs,tolerance,numRep,boolPlot)
%% Find peaks with defined prominence
%Compute absolute distances from start/stop
abs_dstart(:) = sum((cutdata.hand(1:3,:)-cutdata.start(1:3,:)).^2,1);
abs_dstop(:) = sum((cutdata.hand(1:3,:)-cutdata.stop(1:3,:)).^2,1);

%Define prominence 30% of max-min (we want to reject peaks that are too
%small, as they do not mark a start/stop point)
prom_dstart = 0.3*(max(abs_dstart)-min(abs_dstart));
prom_dstop = 0.3*(max(abs_dstop)-min(abs_dstop));

%Find local minima with corresponding prominence
[delta_start,i_start] = findpeaks(-1*abs_dstart,'MinPeakProminence',prom_dstart);
delta_start = -1*delta_start;
[delta_stop,i_stop] = findpeaks(-1*abs_dstop,'MinPeakProminence',prom_dstop);
delta_stop = -1*delta_stop;

%Handle the case if no start/stop point has been found
if(isempty(delta_stop)||isempty(delta_stop))
    msg = strcat('Error in find_startstop: No start/stop points could be found for ',...
        cutdata.movement,', ',cutdata.condition,'. How would you like to proceed?');
    h = questdlg(msg,'find_startstop:empty_vector',"Ignore file","Enter manually","Quit");
    
    switch h
        case "Ignore file"
            %Skip the file
            fail = true;
            i_start = NaN;
            i_stop = NaN;
            t_start = NaN;
            t_stop = NaN;
            return
        case "Enter manually"
            %User can enter start/stop indices manually
            figure()
            plot(abs_dstart,'b-')
            hold on
            plot(abs_dstop,'r-')
            hold off
            title('Absolute distance from start/stop marker')
            legend('Distance from Start','Distance from Stop')
            while(true)
                i_start = input('Enter start indices')
                i_stop = input('Enter stop indices')
                if(length(i_start)==length(i_stop)&&~isempty(i_start)&&max(i_start)<length(abs_dstart))
                    delta_start = abs_dstart(1:3,i_start);
                    delta_stop = abs_dstop(1:3,i_stop);
                    break
                end
            end
        otherwise
            error('find_startstop:quit','Script was stopped due to user input')
    end
end
 

%% Find first peak
%If a stop peak occurs first, we have to check wether there is a start peak
%first (which has not been detected as its prominence was too small) 
if i_stop(1)<i_start(1)
    [pks, locs, ~, p] = findpeaks(-1*abs_dstart(1:2*Fs));
    pks = -pks;
    [~, I] = sort(p,'descend');
    
    %If no starting peak is before stop, the stop peak can be deleted -->
    %the next start peak will be the first start peak
    if isempty(pks)
        i_stop = i_stop(2:end);
        delta_stop = delta_stop(2:end);
    else
    delta_start = [pks(I(1)), delta_start];
    i_start = [locs(I(1)), i_start];        
    end
end

%% Find the last peak
%The same again for the last peak
if i_start(end)>i_stop(end)
    [pks, locs, ~, p] = findpeaks(-1*abs_dstop((end-2*Fs):end));
    pks = -pks;
    [~, I] = sort(p,'descend');
    offset = length(abs_dstop)-2*Fs;
    locs = locs + offset;
    
    if isempty(pks)
    i_start = i_start(1:(end-1));
    delta_start = delta_start(1:(end-1));
    else
    delta_stop = [delta_stop, pks(I(1))];
    i_stop = [i_stop, locs(I(1))];       
    end
end

%% Assert that there is the same number of start and stop peaks
if(length(i_start)~=length(i_stop))
    figure()
    plot(abs_dstart,'b-')
    hold on
    plot(abs_dstop,'r-')
    hold on
    scatter(i_start,delta_start,'b*')
    hold on
    scatter(i_stop,delta_stop,'r*')
    title('Absolute distance from start/stop marker')
    legend('Distance from Start','Distance from Stop')
    error('find_startstop:peak_error',...
    'The number of starting peaks is not equal to the number of stopping peaks!')
end

%% Cancel start-stop periods that are not within allowable range
goal_i = 60*2*Fs/cutdata.bpm; %Recording should be goal_i samples long
deviance_i = abs(i_stop-i_start-goal_i); %Recording deviates deviance_i from goal_i
tolerance_i = tolerance*goal_i; %Maximum allowable tolerance frames

% Cancel all start/stop indices that that are too long/short
isok = deviance_i<=tolerance_i;
i_start = i_start(isok);
i_stop = i_stop(isok);
delta_start = delta_start(isok);
delta_stop = delta_stop(isok);

%% Translate start/stop band to boundary of dead zone
nRep = length(i_start);
for i_rep = 1:nRep
    isAboveThr = (abs_dstart(i_start(i_rep):end)-delta_start(i_rep))>0.015;
    i_start(i_rep) = i_start(i_rep) + find(isAboveThr,1);
    delta_start(i_rep) = abs_dstart(i_start(i_rep));
    isAboveThr = (abs_dstop(i_stop(i_rep):(-1):1)-delta_stop(i_rep))>0.015;
    i_stop(i_rep) = i_stop(i_rep) - find(isAboveThr,1);
    delta_stop(i_rep) = abs_dstop(i_stop(i_rep));
end

%% Only consider first numRep repetitions
try
    i_start = i_start(1:numRep);
    i_stop = i_stop(1:numRep);
    delta_start = delta_start(1:numRep);
    delta_stop = delta_stop(1:numRep);
catch ex
    switch ex.identifier
        case 'MATLAB:badsubscript'
            warning(['Exception in find_startstop: ',...
                cutdata.movement, ', ',cutdata.condition,': Less than ',...
                num2str(numRep), ' Repetitions!'])
    end
end

%% Write to output
t_start = i_start/120;
t_stop = i_stop/120;
fail = false;
%% Optional: Plotting
if boolPlot
    figure()
    scatter(i_start,delta_start,'b*')
    hold on
    scatter(i_stop,delta_stop,'r*')
    hold on
    plot(abs_dstart,'b-')
    hold on
    plot(abs_dstop,'r-')
    hold on

    title('Absolute distance from start/stop marker')
    legend('Distance from Start','Distance from Stop')
end

end