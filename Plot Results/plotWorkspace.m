clc
clear variables
close all
jjjj= 0;
gcp%create parrallel pool
addpath('..\inhull')
addpath('..\S03Grid')
addpath('..\QuaternionMath')
jjjj = jjjj+1;
%24077
tol = 2e-3; %tolerance for determining if something is inside convex hull

%r2i =  [0.0478 0.125];%0.0436;%  %radius top tetrahedron
%h2i = [0.1652 0.2];%%height top
%h1i = [0.0235 0.03]; %ratio of nesting

r2i =  [0.0478 0.04199];%0.0436;%  %radius top tetrahedron
h2i = [0.1652 0.15];%%height top
h1i = [0.0235 0.02425]; %ratio of nesting

EdgeColor = {[69.8, 34.1, 4.3]/100,[5.5, 28.6, 44.7]/100};

FaceColor = {[96.9, 58.8, 27.5]/100,[20.4, 44.7, 62]/100};

figure
for iii =1:2
r1 = 0.15;  %radius bot tetrahedron
r2 =  r2i(iii);%0.0436;%  %radius top terahedron
h1 = h1i(iii);  %height bottom
h2 = h2i(iii);%%height top
%create a rim of points for collision detection 
thetas = 0:0.025:2*3.14159;
circlexy = r1*[sin(thetas)' cos(thetas)'];
rim = [circlexy ones(size(circlexy,1),1)*h1];
origin = [0 0 0 0 0 0];

%Generate uniform grid of quaternions
quats = getUniformS03Grid(2^5);
[zrots, ~, ~] = quat2angle(quats, 'zyx');
n = quaternRotate([0 0 1],quats);
quats = quats((n(:,3)>0).*(abs(zrots) <pi/2)>0,[1 4 3 2]);
zrots = zrots((n(:,3)>0).*(abs(zrots) <pi/2)>0);
num_slice = 20;
step = pi/(num_slice);
jj = 1;
quat_slices = cell(num_slice,1);
for j = -pi/2:step:pi/2-step
    quat_slices(jj) = {quats(((zrots >j).*( zrots <(j+step)))>0,:)};
    jj = jj+1;
end

quats1 = quats(((zrots >(-pi/2)).*( zrots <(0.1-pi/2)))>0,:);

%create matrices of bottom (stationary) etrahedron nodes
tb = [r1*sin(0);       r1*cos(0);           h1]*ones(1,size(quats,1));
tc = [r1*sin(2*pi/3);  r1*cos(2*pi/3);      h1]*ones(1,size(quats,1));
td = [r1*sin(-2*pi/3); r1*cos(-2*pi/3);     h1]*ones(1,size(quats,1));

%create vectors of top tetrhedron nodes which will be rotated
te = [0;               0;                   0];
tf = [r2*sin(pi/3);    r2*cos(pi/3);        h2];
tg = [r2*sin(pi);      r2*cos(pi);          h2];
th = [r2*sin(5*pi/3);  r2*cos(5*pi/3);      h2];
%Rotate those nodes
re = quatrotate(quats,te');
rf = quatrotate(quats,tf');
rg = quatrotate(quats,tg');
rh = quatrotate(quats,th');
%Compute the cable directions
cables  = normc([ tb-re', tc-re', td-re', tb-rf', tc-rf', tc-rg', td-rg', td-rh', tb-rh']);
%location of cable anchors
anchors = [    re',    re',    re',    rf',    rf',    rg',    rg',    rh',    rh'];
%Genrate matrix of cable direction forces and moments
AA = [cables;
    cross(anchors,cables)]';
A = zeros(9,6,size(quats,1));
for i = 1:size(quats,1)
    A(:,:,i) = AA(i-1+(1:size(quats,1):size(quats,1)*9),:);
end
orientationPossible = zeros(size(quats,1),1);
tetra = [re(1,:);
             rf(1,:);
             rg(1,:);
             rh(1,:)];                                   
    tessa = convhulln(tetra);
parfor i = 1:size(quats,1)
    %create the convex hull for the top tetrahedron to do collision
    %detection
        
    tetra = [re(i,:);
             rf(i,:);
             rg(i,:);
             rh(i,:)];
%     strings = [linspace(rf(i,1),tb(1),30)',linspace(rf(i,2),tb(2),30)',linspace(rf(i,3),tb(3),30)';
%      linspace(rf(i,1),tc(1),30)',linspace(rf(i,2),tc(2),30)',linspace(rf(i,3),tc(3),30)';
%      linspace(rg(i,1),tc(1),30)',linspace(rg(i,2),tc(2),30)',linspace(rg(i,3),tc(3),30)';
%      linspace(rg(i,1),td(1),30)',linspace(rg(i,2),td(2),30)',linspace(rg(i,3),td(3),30)';
%      linspace(rh(i,1),td(1),30)',linspace(rh(i,2),td(2),30)',linspace(rh(i,3),td(3),30)';
%      linspace(rh(i,1),tb(1),30)',linspace(rh(i,2),tb(2),30)',linspace(rh(i,3),tb(3),30)'];

            %133s 192781                       
    %check for collision of convex hull of top tetra and outer rim of bottom tetra
    intersect = inhull([rim],tetra,tessa,1e-6);
    if( ~any(intersect))
        %select the force closure matrix for the given orientation
        %A = AA(i-1+(1:size(quats,1):size(quats,1)*10),:);
        %find the convex hull
        AAA = squeeze(A(:,:,i));
        tess = convhulln(AAA);
        %check if the hullcontains the origin
        fcc = inhull(origin,AAA,tess,tol);
        %% 
        %store the result
        orientationPossible(i) = fcc;
    end   
end
quatPossible = quats(orientationPossible>0,:);
 [z, y, x] = quat2angle(quatPossible, 'zyx');
 X = [x y z];
% figure
%  scatter3(x,y,z);
%  axis equal

shp = alphaShape(X,0.075);
%shp.RegionThreshold = 1;
[tri, xyz] = boundaryFacets(shp);
trisurf(tri,xyz(:,1),xyz(:,2),xyz(:,3),...
    'FaceColor',FaceColor{iii},'EdgeColor',EdgeColor{iii})
axis equal
%plot(shp,'FaceColor','cyan','LineWidth', 0.01)
title('Visualization of the Rotational Workspace')
xlabel('Theta (rad)')
ylabel('Gamma (rad)')
zlabel('Phi (rad)')
axis equal
hold on
alpha 0.4
view(3)
end
% alpha 0.5
% good(jjjj) = size(quatPossible,1);
% 
% figure
% plot(good)
% 
%  figure
%  tetra = [te'
%      tf';
%      tg';
%     th'];
%  tess = convhulln(tetra);
%  h = trisurf(tess,tetra(:,1),tetra(:,2),tetra(:,3));
%  TT = hgtransform;
%  set(h,'Parent',TT)
%  %alpha 0.6
%  lighting phong
%  hold on
%  scatter3(rim(:,1),rim(:,2),rim(:,3))
%  axis equal
%  xlim([-0.3 0.3])
%  ylim([-0.3 0.3])
%  zlim([-0.3 0.5])
%  [bf,Points] = boundaryFacets(shp);
%  for i = 1: size(Points,1)
%      Rot = getHG_Tform(Points(i,1),Points(i,2),Points(i,3));
%      set(TT,'Matrix',[Rot, [0; 0; 0]; [0 0 0 1]]);
%      drawnow
%  end