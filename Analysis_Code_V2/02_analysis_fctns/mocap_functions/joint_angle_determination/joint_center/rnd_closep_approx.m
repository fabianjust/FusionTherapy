%rnd_closep_approx
%
%Author: David Mauderli - 2019
%
%DESCRIPTION: This function computes the closest point of approximation for
%N_it randomly chosen pairs of axes.
%
%INPUT:
%q: 3xN matrix containing point vectors of points on N axes
%n: 3xN matrix containing direction vectors parallel to N axes
%N_it: Integer that defines the number of CoR's to be computed
%
%OUTPUT:
%r: 3xN_it matrix containing point vectors of all CoR's

function [r] = rnd_closep_approx(q,n,N_it)
%% Check Input Parameters
assert(size(q,2)==size(n,2),'rnd_closep_approx:input_error','Input 1 and Input 2 must have same dimensions')
assert(size(q,1)==size(n,1),'rnd_closep_approx:input_error','Input 1 and Input 2 must have same dimensions')

%% Start
%Allocate memory for CoR solution vector
N_axes = size(q,2);
r = zeros(3,N_it);

%Find CoR for N_it randomly chosen combinations of AoR's
for it=1:N_it

    %Initialize while loop conditions
    j_isnotok= true;
    c = 0;

    while(j_isnotok)

        %Check for infinity loop
        c=c+1;
        if(c>1000)
            error('get_rot_center max_it_reached')
        end

        %Randomly choose two axes
        i = randi(N_axes,1,1);
        j = i + randi(N_axes,1);
        if(j>N_axes)
            j = j-N_axes;
        end

        %Prepare vectors and reference point
        u=n(:,i);
        v=n(:,j);
        u0=q(:,i);
        v0=q(:,j);

        %Check if axes are parallel --> Choose different axes
        if(abs(dot(u,v))<(1-1e-3))

            j_isnotok=false;
            %Compute closest point on each axis
            a=dot(u,u);
            b=dot(u,v);
            c=dot(v,v);
            d=dot(u,u0-v0);
            e=dot(v,u0-v0);
            tu=(b*e-c*d)/(a*c-b^2);
            tv=(a*e-b*d)/(a*c-b^2);
            p1=u0+tu*u;
            p2=v0+tv*v;

            %Center in between of p1 and p2
            r(:,it)=(p1+p2)/2;
        else 
            j_isnotok = true;
        end
    end
end