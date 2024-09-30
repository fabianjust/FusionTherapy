function [T, missing_counter] = pointfit(x_i,x_ref, all_T, frame, n_frames,missing_counter)
%
% POINTFIT determines transformation for a rigid body segment using a singular value decomposition method
%   (Soederkvist & Wedin, 1993). Code is adapted from the book of W. Gander: "Solving Problems in Scientific 
%   Computing Using Maple and Matlab".
%
%   Equations of interest:
%   x_i = scale*Q*x_ref + t2*ones(1,size(x_ref,2))
%   x_ref = scale*Q' * (x_i-ones(1,size(x_ref,2)))
%   x = r'*(y-t).

%   t1 = mean(x_i,2) - mean(x_ref,2)
%
%   x_i_homogen = T*x_ref_homogen
%   x_ref_homogen = inv(T)*x_i_homogen
%
% Input:
%   x_i    xyz coordinates of markers at point in time i / frame i [4xn]
%   x_ref  xyz coordinates of markers in reference position [4xn]
%   all_T  4x4xn Matrix mit Transformationen f?r jedes Frame
%   frame  aktuelles Frame
%   n_frames number of frames
%   missing_counter: counts number of missing frames
%
% Output:
%   t1     translation of rigid body center without any rotation before [3x1]
%   Q      rotation matrix [3x3]
%   t2     translation of all markers after rotation
%   T      transformation matrix [4x4] for homogeneous coordinates T = [Q,t2]
%   scale             scale factor
%   res_normDOF       residuals normed by degrees of freedom (scaling not considered || scale == 1), 
%                     see van den Bogert, 1994
%   res_normPTS       residuals normed by number of points (scaling not considered || scale == 1)
%   res_normDOF_scale residuals normed by number of points considering scaling
%
%
% References:     Soderkvist, I., and Wedin, P.A., (1993). Determining the
%                 movements of the skeleton using well-configured markers.
%                 Journal of Biomechanics, 26:1473-1477
%
%                 van den Bogert, A., Smith, G.D., Nigg, B.M. (1994). In vivo determination
%                 of the ankle joint complex: an optimization approach.
%                 Journal of Biomechanics, 27:1477-1488
%
%   
% Created:    28.01.2002 (M.Dettwyler)
% Revised:    18.02.2010 (Wolf)
%


%% Check input
if size(x_i) ~= size(x_ref)
    error('ERROR in POINTFIT: size of both inputs must be the same!')
end
if size(x_i,2)<3
    warning('WARNING in POINTFIT: Less than tree markers observed!')
    disp(num2str(frame))
    % Sind nicht genug Marker sichtbar, kann keine Transformation bestimmt
    % werden.
    T = all_T(:,:,frame-1);
    missing_counter = missing_counter + 1;
    missing_percentage = missing_counter/n_frames;
    
    if missing_percentage>0.05
        error('ERROR in POINTFIT: More than 5% contecutive frame drop in current segment')
    end
    
    return % In diesem Fall soll der Rest von pointfit nicht mehr ausgef?hrt werden
    
end
if size(x_i,1)<4
    error('ERROR during POINTFIT: input dimensions are not correct') 
    x_i = x_i'; x_ref = x_ref';
end

%% Calculation of transfomation
missing_counter = 0; % Missing counter soll nur z?hlen wie viele konsekutive frame drops wir haben
xiq = sum(x_i')/length(x_i); 
xiq=xiq';
xq = sum(x_ref')/length(x_ref); 
xq=xq';
A = x_ref-xq*ones(1,size(x_ref,2));
B = x_i-xiq*ones(1,size(x_i,2));
[u sigma v] = svd(A*B');             % Singular Value Decomposition
Q = v*diag([ones(1,size(v,1)-1) det(v*u')])*u';
t2 = xiq-Q*xq;
t1 = xiq-xq;

T = Q;
T(:,4) = t2;
T(4,4) = 1;



%% Ab hier brauchen wir es f?r unsere Berechnungen nicht mehr

% scale = trace(Q'*(B*A'))/trace(A'*A);
% 
% %% Calculation of residuals
% residual_matrix = x_i-Q*x_ref-t2*ones(1,length(x_i));
% residual = trace(residual_matrix'*residual_matrix);
% %DOF=3*(number of points)-6 unknowns (tx,ty,tz,alpha,beta,gamma):
% dof = 3*size(x_i,2)-6;
% res_normDOF = (residual/dof).^0.5;
% 
% res_normPTS = (residual/size(x_i,2)).^0.5;
% 
% residual_matrix_s = x_i-scale*Q*x_ref-t2*ones(1,length(x_i));
% residual_s = trace(residual_matrix_s'*residual_matrix_s);
% res_normDOF_scale = (residual_s/dof).^0.5;
% 
% return
% 
% %% DEMO
% % -------------------------------------------------------------------------
% % D E M O    C O D E
% % -------------------------------------------------------------------------
% % Test skript zum Ausprobieren der Funktion pointfit nach Gander
% 
% clear
% n=10;  % Das ist die Anzahl Punkte
% p=rand(3,n);
% a=[0.25;0.1;0.05];  % Das sind in ca. die Abmessungen eines Fusses
% 
% for i=1:n
%   p(:,i)=a.*p(:,i)-a/2;
%   p(1,i)=p(1,i)+0.5;       % zus?tzliche Verschiebung in x-Richtung
%   p(2,i)=p(2,i)-0.3;       % zus?tzliche Verschiebung in y-Richtung
%   p(3,i)=p(3,i)+0.1;       % zus?tzliche Verschiebung in z-Richtung
% end
% CM=mean(p')';
% 
% % Berechnung des reduzierten Referenz-Clusters, so dass der Schwerpunkt desselben mit dem Urspung 
% % des Koordinatensystems zusammenf?llt.
% 
% p_ref_0=p-(ones(n,1)*CM')';
% 
% 
% plot3(p(1,:),p(2,:),p(3,:),'o')
% xlabel('Laengs')
% ylabel('Quer')
% zlabel('Hoch')
% grid on
% axis equal
% 
% translation=[0.1;0.05;0.04];    % supponierte Translation
% rotaxis=rand(3,1)-0.5;          % supponierte Rotationsachse
% rotaxis=rotaxis/norm(rotaxis,2); % ist nicht zwingend n?tig f?r die weiter unten folgende
%                                  % Funktion drehtensor, aber dennnoch gute Praxis. Wird
%                                  % die Normierung hier nicht vollzogen, dann geschieht
%                                  % es in 'drehtensor'.
% beta=rand(1,1)*360;
% 
% % Alternativ w?re zum Bsp auch m?glich:
% % rotaxis=[0;0;1];
% % beta=90;
% 
% % Berechnen der zugeh?rigen Drehmatrix:
% Q=drehtensor(rotaxis,beta); 
% 
% newp1=Q*p_ref_0+(ones(n,1)*CM')';% Drehung um den Schwerpunkt (!) der Punktwolke
%    
% hold on
% plot3(newp1(1,:),newp1(2,:),newp1(3,:),'g+');
% 
% newp2=newp1+(ones(n,1)*translation')';  % Verschiebung des (um den Schwerpunkt!) gedrehten Objekts 
%                                         % im festen Koordinatensystem
% plot3(newp2(1,:),newp2(2,:),newp2(3,:),'k+');
% 
% % Addition of Noise
% noise_amount=0.002;
% noise_amount=0.000;
% noise=noise_amount*randn(3,n);
% blurredmeas=newp2+noise;
% 
% plot3(blurredmeas(1,:),blurredmeas(2,:),blurredmeas(3,:),'r*');
% 
% % Anwenden von pointfit mit dem in den Nullpunkt verschobenenen Cluster
% % p_ref_0 aus Basis
% % (Alle checks m?ssen f?r noise_amount=0 identisch zu Null verschwinden!)
% [t1,Q_rec,t2,T,scale]=pointfit(blurredmeas,p_ref_0);
% check1=t1-translation-CM;
% check2=Q-Q_rec;
% check3=t1-t2;    % Weil der Schwerpunkt des Nominalen Clusters (Referenzcluster) mit dem 
%                  % Ursprung des Koordinatensystems zusammengefaellt, ist in diesem Fall t1=t2;
% check4=scale-1;
% 
% % Anwenden von pointfit mit dem p-Cluster, welcher  den Schwerpunkt NICHT
% % im Ursprung des Koordiaten-Systems hat. 
% % (Alle checks m?ssen f?r noise_amount=0 identisch zu Null verschwinden!)
% [t1,Q_rec,t2,T,scale]=pointfit(blurredmeas,p);
% check5=t1-translation;
% check6=Q-Q_rec;
% check7=blurredmeas-(Q_rec*p+(t2*ones(1,n))); 
% check8=scale-1;
% 
% 
% % Supplement
% % ------------------------------------------------------------------------------------------------------------
% % Bis hier war der scale immer 1 (Normalfall). Ab hier wird die Verwendung mit einem andern scale demonstriert!
% 
% span=0.1;
% lower=0.45;
% scale=span*rand+lower;   % liegt zwischen lower und lower+span
% p_ref_0_scaled=scale*p_ref_0;
% 
% newp1=Q*p_ref_0_scaled+(ones(n,1)*CM')';% Drehung um den Schwerpunkt (!) der Punktwolke
% newp2=newp1+(ones(n,1)*translation')';  % Verschiebung des (um den Schwerpunkt!) gedrehten 
%                                         % und gescaleten Objekts im festen Koordinatensystem 
%                                         
% noise=noise_amount*randn(3,n);
% blurredmeas=newp2+noise;
% 
% [t1,Q_rec,t2,T,scale_rec]=pointfit(blurredmeas,p_ref_0);
% check9=t1-translation-CM;
% check10=Q-Q_rec;
% check11=t1-t2;    % Weil der Schwerpunkt des Nominalen Clusters (Referenzcluster) mit dem 
%                  % Ursprung des Koordinatensystems zusammengefaellt, ist in diesem Fall t1=t2;
% check12=scale_rec-scale;
% 
% [t1,Q_rec,t2,T,scale_rec]=pointfit(blurredmeas,p);
% check13=t1-translation;
% check14=Q-Q_rec;
% check15=blurredmeas-(scale_rec*Q_rec*p+(t2*ones(1,n))); 
% check16=scale-scale_rec;

