function fig = prep_figure_no_box_no_zoom(fig)
% Removes all text from a figure and gets rid of almost all the whitespace.
% Also makes the figure full screen for better saving.
% By default, applies this to the current figure, but a different figure
% may be passed in.
if ~exist('fig','var')
    fig = gcf;
else
    figure(fig);
end

all_axes = fig.Children;
for i = 1:length(all_axes)
    if ~isa(all_axes(i), 'matlab.graphics.axis.Axes')
        continue
    end
    kid = all_axes(i).Children;
    set(gcf, 'CurrentAxes', all_axes(i))
    % Remove ticks and axis
    xticks([])
    x = kid.XData;
    xlim([0, length(x)])
    yticks([])
    y = kid.YData;
    if max(y) > min(y)
        ylim([min(y), max(y)])
    else
        ylim([min(y), min(y)+1]) % i.e. the data is a constant
    end
    set(gca, 'box', 'off')
end
end