function [min_val, min_ind] = last_good_changept(...
    vals, lambda, to_plot, cap_at_0, lambda2, threshold_from_changept)
% Calculates the last (sparsest) point that satisfies:
%   Lower error than 1 standard error above the global minimum
%   Is a changepoint, as defined by var(vals) and a linear fit
%
% Input:
%   vals - the data to select the best value of
%   lambda (1) - the factor to multiple the standard error by
%   to_plot (false) - to visualize
%   cap_at_0 (false) - to cap the threshold at 0
%   lambda2 (1) - divides the threshold for determining changepoints.
%       Higher means more change points will be discovered
%   threshold_from_changept (false) - whether to force the threshold to be
%       calculated at a changepoint
if ~exist('lambda', 'var')
    lambda = 1;
end
if ~exist('to_plot', 'var')
    to_plot = false;
end
if ~exist('cap_at_0', 'var')
    cap_at_0 = false;
end
if ~exist('lambda2', 'var')
    lambda2 = 1;
end
if ~exist('threshold_from_changept', 'var')
    threshold_from_changept = false;
end

all_se = std(vals, [], 2);
all_means = mean(vals,2);

% Get change points
all_changepts = findchangepts(all_means, 'Statistic','linear', ...
    'MinThreshold',var(all_means)/lambda2);
all_changepts = [all_changepts; length(all_means)]; % Allow the last entry to be selected

% Get error threshold
if threshold_from_changept
    [~, min_plus] = min_1se(all_means(all_changepts), ...
        lambda*all_se(all_changepts));
else
    [~, min_plus] = min_1se(all_means, lambda*all_se);
end
if cap_at_0
    min_plus = min([min_plus, 0]);
end

% Finally, get best changepoint under the threshold
min_ind = find(all_means(all_changepts-1)<min_plus, 1, 'last');
if isempty(min_ind)
    min_ind = length(all_changepts);
end
min_ind = all_changepts(min_ind) - 1;
min_val = all_means(min_ind);

% For debugging
if to_plot
    findchangepts(all_means, 'Statistic','linear', ...
        'MinThreshold',var(all_means)/lambda2);
    hold on;
    plot(min_ind, all_means(min_ind), 'ro', 'linewidth',1)
    n = length(all_means);
    xlim([1, n])
    plot(1:n, min_plus*ones(n,1), 'g--', 'linewidth',1)
    title('Cross Validation Error')
    legend('1 se','Mean', 'Sparsest local minimum', '1se threshold')
end
end


