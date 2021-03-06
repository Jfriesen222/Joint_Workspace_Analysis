function [good] = getNumConfig(gg)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
r1 = 0.15;
%h1 = 0.2;
r2 = gg(1);
h2 = gg(2);
h1 = gg(3);
tol = 2e-3;
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
num_slice = 40;
step = pi/(num_slice);
jj = 1;
quat_slices = cell(num_slice,1);
for j = -pi/2:step:pi/2-step
    quat_slices(jj) = {quats(((zrots >j).*( zrots <(j+step)))>0,:)};
    jj = jj+1;
end
%create matrices of base (stationary) nodes
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
cables  = normc([tb-re', tc-re', td-re', tb-rf', tc-rf', tc-rg', td-rg', td-rh', tb-rh']);
%location of cable anchors
anchors = [re',    re',    re',    rf',    rf',    rg',    rg',    rh',    rh'];
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
    %check for collision of convex hull of top tetra and outer rim of bottom tetra
    intersect = inhull(rim,tetra,tessa,tol);
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
good = size(quats,1)- size(quatPossible,1);
end

