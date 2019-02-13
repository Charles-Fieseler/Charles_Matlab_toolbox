function [dat_table, fig] = silhouette_with_names(dat,...
    cluster_idx, names, dat2clust_ind)
% Plot a silhouette diagram, connecting up the rows and the names
k = length(unique(cluster_idx));
[all_scores, fig] = silhouette(dat, cluster_idx);
sz = length(names)+2*k;

% Convert everything to common silhouette ordering (i.e. by cluster)
names = names(dat2clust_ind);
all_scores = all_scores(dat2clust_ind);

% Get names per cluster
yticks(1:sz)
y_labels_array = cell(sz,1);
all_starts = find(diff(sort(cluster_idx)));
all_ends = [all_starts; length(names)];
all_starts = [1; all_starts+1];
% Initialize
for i = 1:sz
    y_labels_array{i} = '';
end
current_yaxis_ind = 2;
for i = 1:k
    this_span_names = all_starts(i):all_ends(i);
    this_span_y_labels = this_span_names + current_yaxis_ind;
    this_names = names(this_span_names);
    
    [all_scores(this_span_names), score_sort_ind] = ...
        sort(all_scores(this_span_names), 'descend');
    y_labels_array(this_span_y_labels) = this_names(score_sort_ind);
    
    current_yaxis_ind = current_yaxis_ind + 2;
end

% rows_to_skip = 2;
% name_index = 0;
% sorted_idx = [diff(sort(idx)); 0];
% for i = 1:sz
%     if rows_to_skip > 0
%         y_labels_array{i} = '';
%         rows_to_skip = rows_to_skip - 1;
%         continue
%     end
%     name_index = name_index + 1;
%     y_labels_array{i} = names{name_index};
%     if sorted_idx(name_index) ~= 0
%         rows_to_skip = 2;
%     end
% end
yticklabels(y_labels_array)

% Export a table
dat_table = table(...
    all_scores, y_labels_array(~cellfun(@isempty,y_labels_array)), sort(cluster_idx),...
    'VariableNames',...
    {'Silhouette_scores', 'Names', 'Cluster_index'});

end