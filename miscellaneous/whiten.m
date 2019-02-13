function [X, sphering_matrix] = whiten(X, fudgefactor)
% Rows of X should be channels
% Based on: https://xcorr.net/2011/05/27/whiten-a-matrix-matlab-code/
%
% Input:
%   X - data
%   fudgefactor (1e-3) - prevents nan values
%
% Output: 
%   X - whitened data (unit covariance, mean of 0)
%   sphering_matrix - the matrix used to whiten the data, i.e. 
%       whiten(X) = X*sphering_matrix
if ~exist('fudgefactor', 'var')
    fudgefactor = 1e-3;
end
X = bsxfun(@minus, X, mean(X,2));
A = X'*X;
[V,D] = eig(A);
sphering_matrix = V*diag(1./(diag(D)+fudgefactor).^(1/2))*V';
X = X*sphering_matrix;
end