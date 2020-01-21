function [noise_level] = estimate_noise_lillietest(dat, ...
    noise_p_thresh, row_ind, num_iter)
% Estimate the noise level in a data matrix via:
%   Getting the error for a linear (DMD) regression
%   Removing the largest entries until the error is Gaussian
if ~exist('p_noise_thresh', 'var')
    noise_p_thresh = 0.05;
end
if ~exist('row_ind', 'var')
    row_ind = 1:size(dat,1);
end
if ~exist('num_iter', 'var')
    num_iter = min([1000, round(0.9*numel(dat))]);
end
X = dat;
X1 = X(:, 1:end-1);
X2 = X(:, 2:end);
raw_err = X2 - (X2/X1)*X1;
raw_err = raw_err(row_ind,:);
sz = size(raw_err);
err = reshape(raw_err, [sz(1)*sz(2), 1]);
raw_err = err;
all_p = zeros(num_iter, 1);
warning off
for i = 1:num_iter
    [~, ind] = max(abs(err));
    err(ind) = 0;
    [~, all_p(i)] = lillietest(err);
end
warning on
good_ind_max = find(all_p > noise_p_thresh, 1, 'last');
if isempty(good_ind_max)
    warning('Noise pdf never became Gaussian; using most Gaussian-like')
    [~, good_ind_max] = max(all_p);
end
[~, good_ind_all] = maxk(abs(raw_err), good_ind_max);
noise = zeros(size(err));
bad_ind_all = 1:length(err);
bad_ind_all(good_ind_all) = [];
noise(bad_ind_all) = raw_err(bad_ind_all);

noise_level = max(noise);
end

