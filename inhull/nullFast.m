function Z = nullFast(A)
%NULL   Null space.
%   Z = NULL(A) is an orthonormal basis for the null space of A obtained
%   from the singular value decomposition.  That is,  A*Z has negligible
%   elements, size(Z,2) is the nullity of A, and Z'*Z = I.
%
%   Z = NULL(A,'r') is a "rational" basis for the null space obtained
%   from the reduced row echelon form.  A*Z is zero, size(Z,2) is an
%   estimate for the nullity of A, and, if A is a small matrix with 
%   integer elements, the elements of R are ratios of small integers.  
%
%   The orthonormal basis is preferable numerically, while the rational
%   basis may be preferable pedagogically.
%
%   Example:
%
%       A =
%
%           1     2     3
%           1     2     3
%           1     2     3
%
%       Z = null(A); 
%
%       Computing the 1-norm of the matrix A*Z will be 
%       within a small tolerance
%
%       norm(A*Z,1)< 1e-12
%       ans =
%      
%          1
%
%       null(A,'r') = 
%
%          -2    -3
%           1     0
%           0     1
%
%   Class support for input A:
%      float: double, single
%
%   See also SVD, ORTH, RANK, RREF.

%   Copyright 1984-2006 The MathWorks, Inc.

[m,n] = size(A);

   % Orthonormal basis

   [Q,R,~] = qr(A');
   if m > 1, r = diag(R);
      elseif m == 1, r = R(1);
      else r = 0;
   end
   tol = max(m,n) * max(abs(r)) * eps(class(A));
   rr = sum(abs(r) > tol);
   Z = Q(:,rr+1:n);
end
