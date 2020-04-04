function [min_val, min_ind] = last_local_min(...
    vals, lambda, to_plot, cap_at_0, fig)
% Calculates the last (sparsest) point that satisfies:
%   Lower error than 1 standard error above the global minimum
%   Is a local minimum
%
% Input:
%   vals - the data to select the best value of
%   lambda (1) - the factor to multiple the standard error by
%   to_plot (false) - to visualize
if ~exist('lambda', 'var')
    lambda = 1;
end
if ~exist('to_plot', 'var')
    to_plot = false;
end
if ~exist('cap_at_0', 'var')
    cap_at_0 = false;
end
if ~exist('fig', 'var')
    fig = [];
end

all_se = std(vals, [], 2);
all_means = mean(vals,2);
[~, min_plus] = min_1se(all_means, lambda*all_se);
if cap_at_0
    min_plus = min([min_plus, 0]);
end

all_mins = find(islocalmin(all_means, 'FlatSelection', 'last'));
all_mins = [all_mins; length(all_means)]; % Allow the last entry to be selected

min_ind = find(all_means(all_mins)<=min_plus, 1, 'last');
if isempty(min_ind)
    min_ind = length(all_mins);
end
min_ind = all_mins(min_ind);
min_val = all_means(min_ind);

if to_plot
    plot_std_fill(vals,2, [], [], fig);
    hold on;
    plot(min_ind, all_means(min_ind), 'ro', 'linewidth',1)
    n = length(all_means);
    xlim([1, n])
    plot(1:n, min_plus*ones(n,1), 'g--', 'linewidth',1)
    title('Cross Validation Error')
    legend('1 se','Mean', 'Sparsest local minimum', '1se threshold')
end
end

