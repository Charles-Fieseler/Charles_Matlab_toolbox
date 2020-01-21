function [fig] = plot_cell_array(dat, max_rows, plot_func, ...
    plot_opt, fig, fig_opt)
% Helper function to plot multiple datasets contained in a cell array on a
% single figure in vertically stacked subplots
if ~exist('max_rows', 'var') || isempty(max_rows)
    max_rows = 5;
end
if ~exist('plot_func', 'var') || isempty(plot_func)
    plot_func = @plot;
end
if ~exist('plot_opt', 'var') || isempty(plot_opt)
    plot_opt = {};
end
if ~exist('fig_opt', 'var') || isempty(fig_opt)
    fig_opt = {};
end
if ~exist('fig', 'var') || isempty(fig)
    fig = figure(fig_opt{:});
end

num_rows = length(dat);
num_cols = 1;
while num_rows > max_rows
    num_cols = num_cols + 1;
    num_rows = ceil(length(dat) / num_cols);
end

for i = 1:length(dat)
    subplot(num_rows, num_cols, i)
    plot_func(dat{i}, plot_opt{:});
end

subplot(num_rows, num_cols, 1);

end

