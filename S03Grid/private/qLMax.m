function tf = qLMax(lMax)
% QLMAX validate lMax
%
% lMax is a non-negative integer-valued scalar
%
% Required by alm2spec, alm2pix
% Author: Lee Samuel Finn
% Copyright 2010

% $Id: qLMax.m 2 2012-09-17 02:23:29Z lsfinn $

tf = isnumeric(lMax) && isscalar(lMax) && floor(lMax) == abs(lMax);

return