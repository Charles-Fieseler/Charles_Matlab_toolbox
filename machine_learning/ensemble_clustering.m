function [co_occurrence, all_cluster_evals] = ...
    ensemble_clustering(X, settings)
% Uses a large number of instances of a clustering algorithm to produce a
% co-occurence matrix, which can itself then be clustered

%---------------------------------------------
% Set up defaults
%---------------------------------------------
defaults = struct(...
    'which_metrics_cluster_size', {{'silhouette', 'gap'}},...
    'total_m', 1000,...
    'cluster_func', @(X,K,M)(kmeans(X, K, 'emptyaction','singleton',...
        'replicate',1, 'Distance',M)),...
    'which_metrics_distance',[],...
    'max_clusters', 8,...
    'verbose', true);

for key = fieldnames(defaults).'
    k = key{1};
    settings.(k) = defaults.(k);
end



%---------------------------------------------
% Unpack settings
%---------------------------------------------
which_metrics_cluster_size = settings.which_metrics_cluster_size;
all_cluster_evals = cell(size(which_metrics_cluster_size));
total_m = settings.total_m;
all_cluster_idx = cell(total_m, 1);
m_per_metric = round(total_m/length(which_metrics_cluster_size));
KList = 2:settings.max_clusters;
co_occurrence = zeros(size(X,1));

if isempty(settings.which_metrics_distance)
    distance_metric = 'sqeuclidean';
    cluster_func = @(X,K) settings.cluster_func(X,K,distance_metric);
else
    error('TODO')
end    

%---------------------------------------------
% Build the Co-occurence matrix using K-means
%---------------------------------------------
if settings.verbose
    disp('Building co-occurrence matrix')
end
for i = 1:length(which_metrics_cluster_size)
    all_cluster_evals{i} = evalclusters(...
        X, cluster_func, which_metrics_cluster_size{i}, 'KList', KList);
    % Use the criterion as a weighted vector for how to produce the
    % ensemble
    %   Note: all metrics will give different "optimal" cluster sizes!
    these_criterion_values = whiten(all_cluster_evals{i}.CriterionValues);
    these_criterion_values = ...
        these_criterion_values + min(these_criterion_values);
    these_criterion_values = ...
        these_criterion_values./sum(these_criterion_values);
    these_cluster_sizes = floor(these_criterion_values.*m_per_metric);
    these_cluster_sizes(these_cluster_sizes<0) = 0;
    % If the rounding cut off some instances, put them back on the smallest
    these_cluster_sizes(1) = these_cluster_sizes(1) + ...
        (m_per_metric - sum(these_cluster_sizes));
    for i2 = 1:length(these_cluster_sizes)
        for i3 = 1:these_cluster_sizes(i2)
            this_cluster_size = KList(i2);
            idx = cluster_func(X, this_cluster_size);
            for i4 = 1:this_cluster_size
                % It is more meaningful if neurons are clustered together
                % when there are many small clusters
                ind = (idx==i4);
                co_occurrence(ind,ind) = ...
                    co_occurrence(ind,ind) + 1;
            end
%             co_occurrence = co_occurrence - 1/this_cluster_size;
        end
    end
end

if settings.verbose
    disp('Finished building co-occurrence matrix')
end

end

