function fig = plot_std_fill(dat, dim, tspan, alpha, fig)
% Plots the mean of the data plus or minus the standard deviation...
% assumes a matrix of data
%
% fig = plot_std_fill(dat, dim, tspan, alpha, fig)
%
% Only 'dat' and 'dim' are required
if ~exist('alpha', 'var') || isempty(alpha)
    alpha = 0.1;
end
if ~exist('fig', 'var') || isempty(fig)
    fig = figure('DefaultAxesFontSize', 14);
end
y = mean(dat, dim);
err = std(dat, [], dim);
if ~exist('tspan', 'var') || isempty(tspan)
    tspan = (1:size(y, 1))';
end
if ~isequal(size(tspan), size(y))
    y = y';
    assert(isequal(size(tspan), size(y)),...
        'Flipping went wrong')
end

% Actually plot
fill([tspan;flipud(tspan)],[y+err;flipud(y-err)],[1,1,1]-alpha)
hold on
plot(tspan, y, 'k', 'LineWidth',2)
xlim([tspan(1), tspan(end)])
end

