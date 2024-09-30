%find_max_dens
%
%Author: David Mauderli - 2019
%
%DESCRIPTION: This function discretizes space into equally sized
%subintervalls. It choses the subinterval containing the most data points
%and discretizes a region around this subinterval. This procedure is
%repeated until less than tol-percent of all datapoints are inside of the
%cube
%
%INPUT:
%A: 3xN matrix containing N point vectors
%lim: 3x2 matrix containing [xmin, xmax;ymin, ymax; zmin zmax]
%N: 3x1 vector containing number of subintervals per axis 
%tol: percentage of datapoints that have to be inside of the cube
%
%OUTPUT:
%sol_box: 3x1 point vector of the approximated CoR 


function [sol_box] = find_max_dens(A,lim,N,tol)

%Check Input Arguments
assert(size(A,1)==3,'find_max_dens:input_error','Input 1 must be 3xN array')
assert(size(lim,1)==3,'find_max_dens:input_error','Input 2 must be 3x2 array')
assert(size(lim,2)==2,'find_max_dens:input_error','Input 2 must be 3x3 array')
assert(size(N,1)==3,'find_max_dens:input_error','Input 3 must be 3x1 vector')
assert(size(N,2)==1,'find_max_dens:input_error','Input 3 must be 3x1 vector')
assert(tol<1&&tol>0,'find_max_dens:input_error','Input 4 has to be a value between 0 and 1')

%% Find approximate center by discretizing 3D-Space
%Discretize space into equally spaced cuboids
min = lim(:,1);
max = lim(:,2);
delta = (max-min)./N;
N_points = size(A,2);
val_sorted = N_points;
c=0;


%Iterate through all CoR's and count the number points per cuboid
while(val_sorted>tol*N_points)
    
    %Check for infinity loop
    c=c+1;
    if c>10000
        error('find_max_dens:infinity_loop','c>10000')
    end

    %Map every point to its corresponting subinterval (cube)
    A_discr = sparse(N(1,1)*N(2,1)*N(3,1),1);
    for i=1:N_points
        %Get i,j,k coordinates of point (w.r.t. discrete space)
        loc_3D = floor((A(:,i)-min)./delta)+1;
        %Check if point is inside boundaries, map 3D coords to 1D and increase
        %counter of A_discr
        if(~any(loc_3D>N) && ~any(loc_3D<=0))
            loc_1D = loc_3D(1)+N(1)*(loc_3D(2)-1)+N(1)*N(2)*(loc_3D(3)-1);
            %Increase counter 
            A_discr(loc_1D,1)= A_discr(loc_1D,1) + 1;
        end
    end

    %Find indice of the highest entry in A_discr (find cube that contains
    %the most points)
    [i_non0,~,val_non0] = find(A_discr); 
    [~,k_sorted] = sort(val_non0,'descend');
    i_sorted = (i_non0(k_sorted(1,1)));
    val_sorted = val_non0(k_sorted(1,1));


    %Map 1D discrete coordinates back to 3D discrete coordinates
    k = ceil(i_sorted/(N(1)*N(2)));
    j = ceil((i_sorted-(k-1)*N(1)*N(2))/N(1));
    i = i_sorted-(k-1)*N(1)*N(2)-(j-1)*N(1);

    %Map 3D discrete to 3D continuous coordinates --> Approximated solution
    sol_box = min+delta.*([i;j;k]-0.5);
    
    %Update min and max (generate smaller intervall to discretize)
    min = sol_box-1.5*delta;
    max = sol_box+1.5*delta;
    delta = (max-min)./N;
    
end

end
