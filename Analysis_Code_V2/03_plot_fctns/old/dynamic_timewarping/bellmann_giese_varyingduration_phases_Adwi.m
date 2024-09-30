%% PHASES...

%function [error_spattemp,np_opt,warped_x2,temp_error_mean,spat_error_mean]= bellmann_giese_varyingduration(x1,x2,lambda,T1,T2);
%
%x2 is warped so as to best fit on x1 according to the error function.
%
%UPDATE, made in January 2010:
%x1 and x2 can span a different time horizon, they only need to be normalized
%to the same number of samples. T1 and T2 are the original durations of the
%trajectories (in seconds).
%
%Error=sum(x1[n] - x2[np]^2 + lambda*(t1[n] - t2[np])^2),
%
%with slight modification from the algorithm proposed by Martin Giese in his paper:
%Giese, M. A. & Poggio, "T. Morphable Models for the Analysis and
%Synthesis of Complex Motion Patterns".
%International Journal of Computer Vision, 2000, 38, 59-73.
%
%This file calculates the optimal path from point n=1,np=1 to point n=N,np=N with the
%following constraints: Each step procedes in direction n always one unit, and
%in np-direction between 0 and 2 units. Each point the walk passes adds a
%certain cost to the path. This cost is treated as if it belonged to each
%possible path leading directly to the corresponding point.
%
%Inputs:
%x1 and x2 :      matrices with rows=samples, columns=variables. sigristr: thetas
%y1 and y2 :      matrices with rows=samples, columns=variables. sigristr: deltas
%lambda:          weighs the temporal shift compared to spatial shift
%T1/T2:           duration of traj x1/x2 in seconds
%
%Outputs:
%error_spattemp:  Overall spatiotemporal error
%np_opt:          optimal correspondance of samples
%warped_x2:       Simply x2(np_opt,:)
%temp_error_mean: average absolute temporal error
%spat_error_mean: average absolute spatial error
%spatialShift:    average spacial error vector
%
%
%Remark: In the beginning and at the end, the mapping is not so good,
%because all is attributed to spatial error. You might want to shift the
%trajectories such that relevant parts are in the middle, and look only at
%the warping in the center (delete margins).
%
%Heike Vallery, 2007. Last modification: Jan 2010

function [error_spattemp, temp_error_mean, spat_error_mean, spatCyc, tempCyc, spatDriveWat, spatRecHor, spatCatch, spatRelease, ...
          np_opt                                          , cyc_idx         , drive_idx   , rec_idx   , catch_idx, release_idx, ...
          spatDriveWaterOnly, spatRecHorAllAir, driveWaterOnly_idx, recAllAir_idx] = bellmann_giese_varyingduration_phases_Adwi(x1,x2,lambda,T1,T2)
% function [error_spattemp,np_opt,warped_x2,temp_error_mean,spat_error_mean,spatialShift,spatialShiftVector]= bellmann_giese_varyingduration(x1,x2,y1,y2,lambda,T1,T2)

if size(x1)~=size(x2)
    error('the trajectories do not have equal size')
end


N=size(x1,1);

%initialization:
c=ones(N,N+2)*inf;%inf to make sure that unreachable points have too high a cost. Faster than ifs in the loop.
% J_1_1=sum(abs(x1(1,:)-x2(1,:)));J_N_N=sum(abs(x1(N,:)-x2(N,:)));%cost of first and last point (no temporal shift)
% J_1_1=sum((x1(1,:)-x2(1,:)).^2);J_N_N=sum((x1(N,:)-x2(N,:)).^2);%cost of first and last point (no temporal shift)
J_1_1=sum((x1(1,:)-x2(1,:)).^2);J_N_N=sum((x1(N,:)-x2(N,:)).^2);%cost of first and last point (no temporal shift)
% J_1_1=sum((x1(1,:)-x2(1,:)).^2+(y1(1,:)-y2(1,:)).^2);J_N_N=sum((x1(N,:)-x2(N,:)).^2+(y1(N,:)-y2(N,:)).^2);%cost of first and last point (no temporal shift)
c(N,N)=J_1_1+J_N_N; %Cost of the last point AND of the first point are simply attributed to the last (constant offset)
nextstep=zeros(N,N);%initialize direction matrix

%corresponding time vector:
timevector_x1=linspace(0,T1,N);
timevector_x2=linspace(0,T2,N);


% figure;plot3(1,1,J_1_1);hold on;plot3(1,1,J_N_N);  %if you want to look at the cost (see below for continuation)

for nneg=1:N-2;
    n=N-nneg;%runs backwards from N-1 to 2
    for np=max([1,2*n-N]):min([2*n-1,N])%leave out unreachable points, at least in calculation of individual costs
        
        %individual COST of the point alone, or the path leading to it (J(n,np)):
        J_n_np=sum((x1(n,:)-x2(np,:)).^2)+lambda*(timevector_x1(n)-timevector_x2(np))^2;
%         J_n_np=sum(abs(x1(n,:)-x2(np,:)))+lambda*abs(timevector_x1(n)-timevector_x2(np));
        %lambda weighs the temporal shift in relation to spatial error
        
        %             plot3(n,np,J_n_np,'k.') % if you want to have a look at the cost (see above for first endpoints)
        
        %minimum accumulated cost from there on:
        [minimum,index]=min([c(n+1,np),c(n+1,np+1),c(n+1,np+2)]);%These are
        %the 3 possible points that could be reached. Here, also points are
        %considered that are actually not allowed (when n,np is near the boundaries).
        %Therefore, their cost has artificially been put to infinity in the init.
        c(n,np)=J_n_np+minimum;
        
        %optimal next step from this point on (zero to two):
        nextstep(n,np)=index-1;
    end
end

%overall minimum cost:
[error_spattemp,index]=min([c(2,1),c(2,2),c(2,3)]);
nextstep(1,1)=index-1;


%complete path:
np_opt=ones(N,1);%this also means np_opt(1)=1, remains unchanged in the loop.
for index=2:N
    np_opt(index)=np_opt(index-1)+nextstep(index-1,np_opt(index-1));
end
%disp(['The optimal path is: ',num2str(np_opt)])

warped_x2=x2(np_opt,:);
timevector_warpedx2=timevector_x2(np_opt);

%Division into the individual errors (can also be done outside this function):
%%mean of absolute errors
%as suggested by Ilg et al., ICORR 2007.
%In Ilg's paper, the gait cycle time is scaled to 1,
%so a division by N needs to be added here to get the mean.
temp_error_mean=1/N*(sum( abs (timevector_warpedx2-timevector_x1)  ) );
spat_error_mean=1/N*sum(sqrt(sum((warped_x2-x1).^2,2)));


%% Phases
%% Current Cycle
cyc_idx = [1:ceil(N/3)]+ceil(N/3)-1; % indice of current cycle (between the cycle before and after, i.e. the second of the 3 cycles)

warped_x2_cyc=x2(np_opt(cyc_idx),:);
timevector_warpedx2_cyc=timevector_x2(np_opt(cyc_idx));

tempCyc=1/length(cyc_idx)*(sum( abs (timevector_warpedx2_cyc-timevector_x1(cyc_idx))  ) );
spatCyc=1/length(cyc_idx)*sum(sqrt(sum((warped_x2_cyc-x1(cyc_idx,:)).^2,2)));

%% Catch Phase (Modified for ADWI cycle) - eb 23.11.2018 -- Extended to include some part of actual recovery
% desiredTrajectory1(:,1)<-10.5)([215:250,1:20]) for 250 Datapoints, ([86:101,1:8]) for 101 Datapoints
catch_idx = [-ceil(N/3*0.135):ceil(N/3*0.08)]+ceil(N/3)-1; % in percent of the three cycles (300%): 86% to 108%   ==> [-ceil(N/3*0.135):ceil(N/3*0.08)]  : -17 to +10 over 125 (-14 to 8 over 101)
warped_x2_catch=x2(np_opt(catch_idx),:);
spatCatch=1/length(catch_idx)*sum(sqrt(sum((warped_x2_catch-x1(catch_idx,:)).^2,2)));

%% In Drive Phase When Reference In Water
% desiredTrajectory1(:,2)<-6.82)(20:56) for 250 Datapoints, (8:22) for 101 Datapoints
drive_idx = [ceil(N/3*0.08):ceil(N/3*0.22)]+ceil(N/3)-1; % in percent of the three cycles (300%): 108% to 122%.   ==> [ceil(N/3*0.08):ceil(N/3*0.22)]    : 10 to 28 over 125 (8 to 22 over 101)
warped_x2_drive=x2(np_opt(drive_idx),:);
spatDriveWat=1/length(drive_idx)*sum(sqrt(sum((warped_x2_drive-x1(drive_idx,:)).^2,2)));

%% Release Phase
% (56:120) for 250 Datapoints, ([22:48]) for 101 Datapoints -- Extended to include some part of actual recovery
release_idx = [ceil(N/3*0.22):ceil(N/3*0.48)]+ceil(N/3)-1; % in percent of the three cycles (300%): 122% to 148%  ==> [ceil(N/3*0.22):ceil(N/3*0.48)]    : 28 to 60 over 125 (22 to 48 over 101)
warped_x2_release=x2(np_opt(release_idx),:);
spatRelease=1/length(release_idx)*sum(sqrt(sum((warped_x2_release-x1(release_idx,:)).^2,2)));

%% In Recovery Phase When Reference Does Horizontal Movement
% (120:215) for 250 Datapoints, (48:86) for 101 Datapoints
rec_idx = [ceil(N/3*0.48):ceil(N/3*(1-0.14))]+ceil(N/3)-1; % in percent of the three cycles (300%): 148% to 186% ==> [ceil(N/3*0.48):ceil(N/3*(1-0.14))] : 60 to 108 over 125 (48 to 86 over 101)
warped_x2_rec=x2(np_opt(rec_idx),:);
spatRecHor=1/length(rec_idx)*sum(sqrt(sum((warped_x2_rec-x1(rec_idx,:)).^2,2)));


%% Addition to check out "water contact only" and "air contact only" values - eb 071218
%% Drive Phase - Water Contact
driveWaterOnly_idx       = [ceil(N/3*0.02):ceil(N/3*0.34)]+ceil(N/3)-1;       % in percent of the three cycles (300%): 102% to 134%. ==> [ceil(N/3*0.02):ceil(N/3*0.34)]     : 2 to 34 over 101  
warped_x2_driveWaterOnly = x2(np_opt(driveWaterOnly_idx),:);
spatDriveWaterOnly       = 1/length(driveWaterOnly_idx)*sum(sqrt(sum((warped_x2_driveWaterOnly - x1(driveWaterOnly_idx,:)).^2,2)));

%% Recovery Phase - Only Air
recAllAir_idx        = [1:ceil(N/3*0.02) ceil(N/3*0.34):ceil(N/3*(1))]+ceil(N/3)-1; % in percent of the three cycles (300%): 134% to 202%  ==> [ceil(N/3*0.34):ceil(N/3*(1+0.02))] : 34 to 101 over 101
warped_x2_recAir     = x2(np_opt(recAllAir_idx),:);
spatRecHorAllAir     = 1/length(recAllAir_idx)*sum(sqrt(sum((warped_x2_recAir-x1(recAllAir_idx,:)).^2,2))); 


%%
% % %Remark: if you want the Root Mean Square errors in place of the mean absolute errors, use this
% % %extra code:
%     temp_error_RMS=sqrt(1/N*sum(  (timevector_warpedx2-timevector_x1).^2  ));
%      spat_error_RMS=sqrt(1/N*sum(sum((warped_x2-x1).^2,2)));
% %     %check code:
%      error_spattemp
%      check_error_spattemp=N*(lambda*temp_error_RMS^2+spat_error_RMS^2)  %identical or not?
% %
