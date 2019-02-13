function [si, ai, bi] = my_silhouette(X, idx, i)
% silhouette distance (I'm re-calculating)
%
% Input:
%   dat
%   idx - cluster indices
%   i - which point I'm looking at right now (row in 'dat')

xi = X(i,:);
this_clust = idx(i);
other_clust = unique(idx);
other_clust(other_clust==this_clust) = [];

% Calculate ai
own_clust_idx = (idx==this_clust);
own_clust_idx(i) = false;
ai = mean( sum(bsxfun(@minus,xi,X(own_clust_idx,:)).^2, 2) );
% ai = mean( pdist2(xi, dat(own_clust_idx,:)) );

% Calculate bi
bi = inf;
for i = other_clust'
%     tmp = mean( pdist2(xi, X(idx==i,:)) );
    tmp = mean( sum(bsxfun(@minus,xi,X(idx==i,:)).^2, 2) );
    if tmp < bi
        bi = tmp;
    end
end

% si
si = (bi-ai) / max([bi, ai]);
end

