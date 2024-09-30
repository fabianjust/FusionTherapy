function [warped_x2,np_opt]= DTW_corefctn(x1,x2,lambda,T1,T2);
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
%x1 and x2 :      matrices with rows=samples, columns=variables.
%lambda:          weighs the temporal shift compared to spatial shift
%T1/T2:           duration of traj x1/x2 in seconds
%
%Outputs:
%error_spattemp:  Overall spatiotemporal error
%np_opt:          optimal correspondance of samples
%warped_x2:       Simply x2(np_opt,:)
%temp_error_mean: average absolute temporal error
%spat_error_mean: average absolute spatial error
%spatialShift: average spacial error vector
%
%
%Remark: In the beginning and at the end, the mapping is not so good,
%because all is attributed to spatial error. You might want to shift the
%trajectories such that relevant parts are in the middle, and look only at
%the warping in the center (delete margins).
%
%Heike Vallery, 2007. Last modification: Jan 2010
%Georg Rauter, 2013, (T1 and T2 are input vectors of corresponding size to x1 and x2, y1 and y2 added)

% Update: 23.11.2018 (introduction and edit of phases for velocity analysis)
% Author: Ekin Basalp (for ADWI model error analysis)



% Check input      
if size(x1)~=size(x2)
    error('the trajectories do not have equal size')
end

N=size(x1,1);
%initialization:
c=ones(N,N+2)*inf;%inf to make sure that unreachable points have too high a cost. Faster than ifs in the loop.
J_1_1=sum(abs(x1(1,:)-x2(1,:)));J_N_N=sum(abs(x1(N,:)-x2(N,:)));%cost of first and last point (no temporal shift)
c(N,N)=J_1_1+J_N_N; %Cost of the last point AND of the first point are simply attributed to the last (constant offset)
nextstep=zeros(N,N);%initialize direction matrix

%corresponding time vector:
timevector_x1=linspace(0,T1,N);
timevector_x2=linspace(0,T2,N);
%timevector_x1=T1;
%timevector_x2=T2;

% figure;plot3(1,1,J_1_1);hold on;plot3(1,1,J_N_N);  %if you want to look at the cost (see below for continuation)

for nneg=1:N-2;
    n=N-nneg;%runs backwards from N-1 to 2
    for np=max([1,2*n-N]):min([2*n-1,N])%leave out unreachable points, at least in calculation of individual costs
        
        %individual COST of the point alone, or the path leading to it (J(n,np)):
         J_n_np=sum(abs(x1(n,:)-x2(np,:)))+lambda*abs(timevector_x1(n)-timevector_x2(np));
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
%temp_error_mean=1/N*(sum( abs (timevector_warpedx2-timevector_x1)  ) );
%velo_error_mean=1/N*(sum(sqrt(sum((warped_x2-x1).^2,2)+sum((warped_y2-y1).^2,2))));

%%
% % %Remark: if you want the Root Mean Square errors in place of the mean absolute errors, use this
% % %extra code:
%     temp_error_RMS=sqrt(1/N*sum(  (timevector_warpedx2-timevector_x1).^2  ));
%      spat_error_RMS=sqrt(1/N*sum(sum((warped_x2-x1).^2,2)));
% %     %check code:
%      error_spattemp
%      check_error_spattemp=N*(lambda*temp_error_RMS^2+spat_error_RMS^2)  %identical or not?
% %
