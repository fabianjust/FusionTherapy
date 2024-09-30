%get_rot_center
%
%Author: David Mauderli - 2019
%
%DESCRIPTION: This function computes an approximated center of rotation for
%two rigid bodies that undergo a number of rigid body transformations (specified by a
%list of rotation matrices and translation vectors).
%First, it computes the axes of rotation for two transformations "k" and
%"i".  (see get_rot_axes.m)
%Second, for two randomly chosen axes of rotation, it determines a center of rotation by
%closest point approx. This is done N_it times.
%Third, the function finds the mode of all CoR by calling the find_max_dens fctn.
%
%INPUT:
%Tp: 4x4xN homogeneous transform of body "p" during N frames
%Td: 4x4xN homogeneous transform of body "d" during N frames
%makeplot: true (generate plot)/ false (no plot)
%N_it: Number of CoR's to be computed (higher=more accurate but also higher
%computational effort

%OUTPUT:
%sol: 3x1 point vector of the center of rotation


function [sol] = get_rot_center(Tp,Td,makeplot,N_it)


%% Check Input Arguments
assert(size(Tp,3)==size(Td,3),'get_rot_axes:input_error','Input arrays must be of the same length')
assert(size(Tp,1)==4 & size(Tp,2)==4,'get_rot_axes:input_error','Input 1 must have size 4x4xN')
assert(size(Td,1)==4 & size(Td,2)==4,'get_rot_axes:input_error','Input 2 must have size 4x4xN')
assert(islogical(makeplot),'get_rot_axes:input_error','Input 3 must be logical')

%% Compute CoR
%Set Number of repetitions (N_rep) and allocate solution matrix
N_rep = 4;
sol_temp = [];
f = waitbar(0,'Please wait...');

%Resample N_rep times
for rep=1:N_rep
    
    p = (rep-1)/N_rep;
    dp = 1/N_rep;
    
    %Compute N_it AoR by randomly combining two frames (for each AoR) frames 
    waitbar(p,f,strcat('Iteration ',num2str(rep), ' computing AoR...'));
    [q,n] = get_rot_axes(Tp(1:3,1:3,:),Td(1:3,1:3,:),Tp(1:3,4,:),Td(1:3,4,:),N_it);
    
    %Compute N_it CoR by randomly combining two AoR's (for each CoR)
    waitbar(p+1/3*dp,f,strcat('Iteration ',num2str(rep), ' computing CoR...')); 
    r = rnd_closep_approx(q,n,N_it);

    
    %Compute region containing the highest data point density
    waitbar(p+2/3*dp,f,strcat('Iteration ',num2str(rep), ' computing mode ...'));
    boxlim = [-3,3;-3,3;-3,3]; %Scan the volume specified by boxlim
    boxN = [100;100;100]; %Discretize the volume into boxN equally spaced volumes (can vary for xyz)
    [sol_curr] = find_max_dens(r,boxlim,boxN,0.01);
    [sol_temp] = [sol_curr, sol_temp];

    
    %Plot if makeplot is set to true
    if(makeplot==true)
        figh(rep) = figure('Name',['Iteration: ',num2str(rep)]);
        axh(rep) = subplot(1,1,1);
        plot_cor_fitting(axh(rep),r,sol_curr,rep);
    end
end
close(f)
tol_spheres=(sol_temp(1:3,:)-sol_temp(1:3,1)).^2;
if(any(tol_spheres>(0.005^2)))
    error('get_rot_center:convergence_error','CoRs are not within tolerance region')
else
    sol = mean(sol_temp,2);
end

end