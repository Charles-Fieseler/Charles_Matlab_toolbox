function [  ] = plot_2imagesc_colorbar( ...
    dat1, dat2, plot_mode, title1, title2 )
% Plots 2 datasets using imagesc and enforces the same colorbar
%   plot_mode can be '2_figures' (default) or '2 1' or '1 2' (the
%   arrangement of the subplots)
if ~exist('plot_mode','var') || isempty(plot_mode)
    plot_mode = '2_figures';
end
if ~exist('title1','var')
    title1 = '';
end
if ~exist('title2','var')
    title2 = '';
end

switch plot_mode
    case '2_figures'
        fig_func = @(x) figure;
    case '2 1'
        figure;
        fig_func = @(x) subplot(2,1,x);
    case '1 2'
        figure;
        fig_func = @(x) subplot(1,2,x);
    otherwise
        error('Unknown plot mode')
end

fig_func(1);
imagesc(dat1);
cb_min = min(min(dat1));
cb_max = max(max(dat1));
colorbar;
title(title1)

fig_func(2);
imagesc(dat2);
colorbar;
caxis([cb_min cb_max]);
title(title2)
end

