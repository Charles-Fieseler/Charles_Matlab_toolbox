function [fig] = boxplot_on_table(table_dat, row, cmap, ...
    xlabel_mode, fig)
% Makes boxplots work with a table, plotting a single row with the columns
% as grouping variables
%   Assumes each entry is a column vector
%
% Alternatively, plots all rows in the same plot, with the columns bunched
% together as clusters
if ~exist('row', 'var')
    row = []; % i.e. all rows as clusters
end
if ~exist('cmap', 'var')
    cmap = [];
end
if ~exist('xlabel_mode', 'var')
    xlabel_mode = 'columns';
end
if ~exist('fig', 'var')
    fig = figure('DefaultAxesFontSize', 12);
end

if ~isempty(row) && (isnumeric(row) || ischar(row))
    % Just plot one row
    this_dat_cell = table_dat{row, :};
    this_dat_vec = vertcat(this_dat_cell{:});
    [grouping_ind] = cell2group_ind(this_dat_cell);

    boxplot(this_dat_vec, grouping_ind, ...
        'Labels', table_dat.Properties.VariableNames,...
        'Color', cmap, 'LineWidth', 2);
else
    num_cols = size(table_dat,2);
    num_rows = size(table_dat,1);
    cluster_gap = 1;
    all_pos = [];
    all_grouping_ind = [0];
    cmap = repmat(cmap, num_rows, 1);
    all_dat = [];
    cluster_pos = zeros(num_rows,1);
    % Plot all rows
    for iRow = 1:num_rows
        this_dat_cell = table_dat{iRow, :};
        all_dat = [all_dat; vertcat(this_dat_cell{:})];
        
        all_grouping_ind = [all_grouping_ind; ...
            max(all_grouping_ind) + cell2group_ind(this_dat_cell)];
        % Offset positions based on the number of columns
        new_pos = (cluster_gap+num_cols)*(iRow-1) + (1:num_cols);
        all_pos = [all_pos new_pos]; %#ok<*AGROW>
        if strcmp(xlabel_mode, 'rows')
            cluster_pos(iRow) = mean(new_pos);
        end
    end
    all_grouping_ind = all_grouping_ind(2:end);
    h = boxplot(all_dat, all_grouping_ind, ...
        'Color', cmap,...
        'Positions', all_pos);
%     set(h,{'linew'},{1.5})
    
    if strcmp(xlabel_mode, 'columns')
        all_labels = repmat(...
            strrep(table_dat.Properties.VariableNames,'_', ' '),...
            1, num_rows);
        xticklabels(all_labels)
        xtickangle(30)
    elseif strcmp(xlabel_mode, 'rows')
        xticks(cluster_pos);
        xticklabels(strrep(table_dat.Properties.RowNames,'_', ' '))
        box_obj = findobj(gca,'Tag','Box');
        legend(box_obj(num_cols:-1:1), ...
            strrep(table_dat.Properties.VariableNames,'_', ' ')) % Reverse order
    else
        error('Unknown xlabel_mode')
    end
end


% Helper function
    function [grouping_ind] = cell2group_ind(this_dat_cell)
        grouping_ind = zeros(size(vertcat(this_dat_cell{:})));
        start_ind = 1;
        for i = 1:length(this_dat_cell)
            end_ind = start_ind + length(this_dat_cell{i}) - 1;
            grouping_ind(start_ind:end_ind) = i;
            start_ind = end_ind + 1;
        end
    end

end

