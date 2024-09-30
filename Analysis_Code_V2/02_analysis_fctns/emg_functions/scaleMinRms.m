%scaleMinRms
%DESCRIPTION: This function finds the factor vararout that minimizes the rms error between
%referenceSignal and scalingSignal. Precision: tol
%INPUT: referenceSignal, scalingSignal: NX1 vectors, tol: double tolerance
%value 
%OUTPUT: scFactor: scalingSignal*scFactor --> minimal rms Error rmsError

function [scFactor,rmsError] = scaleMinRms(referenceSignal,scalingSignal,tol)
    maxBound = 3*max(abs(referenceSignal))/max(abs(scalingSignal));
    minBound = -maxBound;
    oldMinRms = inf;
    counter = 0;
    while(true)
        counter = counter + 1;
        scalingFactors = linspace(minBound, maxBound,10);
        rms = sqrt(mean((referenceSignal-scalingFactors.*scalingSignal).^2,1));
        [newMinRms, minIndex] = min(rms);
        if(abs(newMinRms-oldMinRms)<tol)
            break
        elseif(counter > 1000)
            newMinRms = NaN;
            msgID
        end
        oldMinRms = newMinRms;
        minBound = scalingFactors(minIndex-1);
        maxBound = scalingFactors(minIndex+1);
    end

    scFactor = scalingFactors(minIndex);
    rmsError = newMinRms;
end