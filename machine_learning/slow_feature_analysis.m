function [features, dat, V, D] = slow_feature_analysis(...
    dat_raw, order, cross_terms, n, verbose)
% SFA - returns the "slowest" combinations of features
%   i.e. modes that minimize <(dx/dt)^2>
%
% Input
%   dat_raw - the data; rows are channels, columns are time
%   order (1) - the polynomial order of features to include
%   cross_terms (false) - to include cross terms; only matters if order>1
%   n (1) - how many features to output
%   verbose (true)
%
% Output:
%   features - n slowest time series (rows)
%   dat - this includes nonlinear terms that may have been added
%   V - column matrix of weighted data; features = V(:,1:n)'*dat
%   D - the eigenvalues that rank the slowness of the features
if ~exist('order', 'var')
    order = 1;
end
if ~exist('cross_terms', 'var')
    cross_terms = false;
end
if ~exist('n', 'var')
    n = 1;
end
if ~exist('verbose', 'var')
    verbose = true;
end

dat_raw = dat_raw - mean(dat_raw,2);
dat_raw = dat_raw./sqrt(mean(dat_raw.^2,2));
if verbose
    disp('Adding nonlinear library terms...')
end
sz = size(dat_raw);
new_dat = [];
if order > 1
    if cross_terms
        for i = 1:sz(1)
            new_dat = [new_dat; dat_raw(i,:).*dat_raw(1:i,:)]; %#ok<AGROW>
        end
    else
        new_dat = zeros((order-1)*sz(1), sz(2));
        for i = 2:order
            ind = ((i-2)*sz(1)+1):((i-1)*sz(1));
            new_dat(ind,:) = dat_raw.^i;
        end
    end
end
dat_raw = [dat_raw; new_dat];
dat = real(whiten(dat_raw, 1e-12));
if verbose
    disp('Taking derivatives using splines...')
end
sz = size(dat);
x = 1:sz(2);
dxdt_raw = zeros(sz);
for i = 1:sz(1)
    spl = spline(x, dat(i,:));
    c = spl.coefs;
    spl.coefs = [3*c(:,1) 2*c(:,2) c(:,3)];
    spl.order = 3;
    dxdt_raw(i,:) = ppval(x, spl);
end
if verbose
    disp('Doing PCA on the derivatives...')
end
dxdt = dxdt_raw;
[V, D] = eig(dxdt*dxdt');
D = diag(D);

features = V(:,1:n)'*dat;
end

