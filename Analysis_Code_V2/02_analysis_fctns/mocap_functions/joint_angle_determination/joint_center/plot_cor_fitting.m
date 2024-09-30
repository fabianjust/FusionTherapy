%plot_cor_fitting
%
%Author: David Mauderli - 2019
%
%DESCRIPTION: Plot data of get_rot_center


function [axh] = plot_cor_fitting(axh,cors,sol_app,rep)

%Plot all centers of rotation
scatter3(cors(1,:),cors(2,:),cors(3,:),2,'k.');
hold on
%Plot approximated solution (box)
scatter3(sol_app(1),sol_app(2),sol_app(3),4000,'r*')
%plotcube([h(1),h(2),h(3)],...
%   [sol_app(1)-h(1)/2,sol_app(2)-h(2)/2,sol_app(3)-h(3)/2],...
 %   0.5,[1,0,0])
%Plot approximated solution (sphere)     
%scatter3(sol_sph(1),sol_sph(2),sol_sph(3),4000,'g*')
%[x,y,z] = sphere(50);
%x = x*r_sph + sol_sph(1);
%y = y*r_sph + sol_sph(2);
%z = z*r_sph + sol_sph(3);
%surface(x,y,z,'FaceColor', 'none','EdgeColor',0.8*[0 1 0]);

%Plot Layout
hold off
title(['Center of Rotation, iteration ',num2str(rep)])
fov = 1;
xlim([sol_app(1)-fov,sol_app(1)+fov])
ylim([sol_app(2)-fov,sol_app(2)+fov])
zlim([sol_app(3)-fov,sol_app(3)+fov])
axis square
hold on
end
