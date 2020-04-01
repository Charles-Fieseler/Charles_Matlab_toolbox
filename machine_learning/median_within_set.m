function [med] = median_within_set(dat)
% Finds the median, then projects it back onto the closest member of the
% set (distance=L2)
assert(isvector(dat), 'Should pass one dimensional vector');
med = median(dat);
[all_dists] = pdist2(med, dat');
[~, min_ind] = min(all_dists);
med = dat(min_ind); % Finally, project back
end

