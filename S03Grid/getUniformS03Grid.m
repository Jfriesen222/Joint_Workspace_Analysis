function [quats] = getUniformS03Grid(nside)
xyz_cell = pix2vec(nside);
xyz = cell2mat(xyz_cell)';
m2  = size(xyz,1);
m1  = round((pi*m2)^0.5);
[phi,theta,~] = cart2sph(xyz(:,1),xyz(:,2),xyz(:,3));
phi = phi + pi;
theta = theta +pi/2;
psi = (0: 2*pi/(m1): (2*pi-2*pi/(m1)))';
x = zeros(m1*m2,4);

for i = 1:m1
    x(((1:m2)+(i-1)*m2),:) = [
        cos(theta/2)*cos(psi(i)/2), cos(theta/2)*sin(psi(i)/2), sin(theta/2).*cos(phi+psi(i)/2), sin(theta/2).*sin(phi+psi(i)/2)];
    if mod(i,2)
        x(((1:m2)+(i-1)*m2),:) = x(((m2:-1:1)+(i-1)*m2),:);
    end
end
quats = x;
end

