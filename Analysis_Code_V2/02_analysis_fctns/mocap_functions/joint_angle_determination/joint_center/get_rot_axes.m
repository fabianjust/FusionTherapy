%get_rot_axes
%
%Author: David Mauderli - 2019
%
%DESCRIPTION: This function computes the shared rotation axes of bodies "p" and
%"d" between N_it randomly chosen combinations of frames "k" and "i" 
%
%INPUT:
%Tp: 3x3xN rotation matrix of body "p" during N frames
%Rd: 3x3xN rotation matrix of body "d" during N frames
%tp: 3x1xN translation vector w.r.t. ref. pos of body "p" during N frames
%td: 3x1xN translation vector w.r.t. ref. pos of body "d" during N frames
%N_it: Number of AoR to compute
%
%OUTPUT:
%q0: 3xN_it points on rotation axes
%n0: 3xN_it directions of rotation axes

function [q0,n0] = get_rot_axes(Rp,Rd,tp,td,N_it)

%Check Input Arguments
a = size(Rp,3)==size(Rd,3)&size(tp,3)==size(td,3)&size(Rp,3)==size(tp,3);
assert(a,'get_rot_axes:input_error','Input arrays must be of the same length')
assert(size(Rp,1)==3 & size(Rp,2)==3,'get_rot_axes:input_error','Input 1 must have size 3x3xN')
assert(size(Rd,1)==3 & size(Rd,2)==3,'get_rot_axes:input_error','Input 2 must have size 3x3xN')
assert(size(tp,1)==3 & size(tp,2)==1,'get_rot_axes:input_error','Input 3 must have size 3x1xN')
assert(size(td,1)==3 & size(td,2)==1,'get_rot_axes:input_error','Input 4 must have size 3x1xN')


%Allocate solution matrices
N_frames = size(Rp,3);
n0 = zeros(3,N_it);
q0 = zeros(3,N_it);


%Randomly choose N_it combinations of frames and find corresponding AoR's
for j=1:N_it
   
    %Initialize while loop conditions
    ik_isnotok= true;
    c=0;
    while(ik_isnotok)
        
        %Increase loop counter and check for infinity loop
        c=c+1;
        if(c>1000)
            error('get_rot_axes:infinity_loop','Maximum number of rotations reached')
        end
        
        %Randomly chose two frames
        i = randi(N_frames,1,1);
        k = i + randi(N_frames,1);
        if(k>N_frames)
            k = k-N_frames;
        end


        %Compute rotation between frames k-->i
        Rp_ki = Rp(1:3,1:3,i)*(Rp(1:3,1:3,k)');
        Rd_ki = Rd(1:3,1:3,i)*(Rd(1:3,1:3,k)');

        %Compute translation (after rotation) between frames k-->i
        tp_ki = tp(1:3,1,i) - Rp_ki*tp(1:3,1,k);
        td_ki = td(1:3,1,i) - Rd_ki*td(1:3,1,k);

        %Build LSE (Solution lies on axis --> Infinite #of solutions)
        A = Rd_ki - Rp_ki;
        b = (tp_ki-td_ki);

        %Solve LSE: Rotation axis vector is null space of A, then solve for
        %q
        n = null(A);
        %If nullspace is empty: chose new i and k frames and repeat 
        if(size(n,2)~=1)
            ik_isnotok = true;
        else
            ik_isnotok = false;
            b_new = b-A*n;
            q = (b_new\A);
            assert(~any(isnan(q)),'get_rot_axes:LSE_error',...
                ['q is NaN at Frames i= ', num2str(i), ' , k= ',num2str(k)])
            assert(~any(isinf(q)),'get_rot_axes:LSE_error',...
                ['q is inf at Frames i= ', num2str(i), ' , k= ',num2str(k)])

            %Norm and transform back to reference position
            q = q/(norm(q)^2);
            assert(~any(isinf(q)),'get_rot_axes:Division_by_zero',...
                ['norm(q)=0 at frames i= ', num2str(i), ' , k= ',num2str(k)])
            q_ref = Rp(:,:,k)'*(q'-tp(1:3,1,k));
            
            %Write to output variables
            q0(:,j) = q_ref;
            n0(:,j) = Rp(:,:,k)'*n;
        end
    end
end
end


