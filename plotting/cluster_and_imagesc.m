function [fig, c, all_ind] = ...
    cluster_and_imagesc(all_dist, c, labels, line_opt)
% For use in visualizing symmetric matrices with clusters, e.g. correlation
% or distance matrices.
% 
% Input:
%   all_dist - the distance matrix; should be symmetric
%   c - a function handle that takes one arg to calculate clusters, or a
%       vector of integer cluster labels if already calculated. Default
%       attempts to guess the optimal number of k-means cluster using the
%       'gap' metric
%   labels (none) - cell array of names for the x and y axes, if any
%   line_opt (none) - struct of line options for use between classes; if
%       nothing is passed, does not plot lines.
%   
% Output:
%   fig - handle to the produced figures
%   c - cluster indices, if calculated
%   all_ind - a cell array of vectors with the indices of each cluster
fig = figure;
hold on

if ~exist('c', 'var') || isempty(c)
    E = evalclusters(all_dist,...
        'linkage', 'gap', 'KList', 1:10);
    k = E.OptimalK;
    fprintf('The optimal number of clusters is %d\n', k)
    c = @(X) cluster(linkage(X,'Ward'), 'maxclust',k);
    c = c(all_dist);
elseif ~isnumeric(c)
    assert(isa(c, 'function_handle'),...
        'Must pass numeric clusters or a function handle')
    c = c(all_dist);
end

max_clust = length(unique(c));
n = size(all_dist,1);
all_ind = cell(max_clust,1);
for i = 1:max_clust
    ind = find(c==i);
    all_ind{i} = ind';
end

ind = [all_ind{:}];
imagesc(all_dist(ind,ind))

if exist('line_opt', 'var')
    j = 0;
    if isfield(line_opt, 'my_cmap')
        my_cmap = line_opt.my_cmap;
    else
        my_cmap = [1 1 1];
    end
    for i = 1:(max_clust-1)
        j = j + length(all_ind{i});
        line([j+0.5 j+0.5], [0 n+1], 'LineWidth',2, 'Color', my_cmap)
        line([0 n+1], [j+0.5 j+0.5], 'LineWidth',2, 'Color', my_cmap)
    end
end

ylim([0.5, n+0.5])
xlim([0.5, n+0.5])
if exist('labels', 'var') && ~isempty(labels)
    yticks(1:n)
    xticks(1:n)
    xtickangle(90)
    yticklabels(labels(ind))
    xticklabels(labels(ind))
end

colorbar
end

