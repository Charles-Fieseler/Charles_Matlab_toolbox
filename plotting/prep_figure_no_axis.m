function fig = prep_figure_no_axis(fig)
% Removes all text from a figure and gets rid of almost all the whitespace.
% Also makes the figure full screen for better saving.
% By default, applies this to the current figure, but a different figure
% may be passed in.
if ~exist('fig','var')
    fig = gcf;
else
    figure(fig);
end

% Full screen
set(fig, 'Position', get(0, 'Screensize'));

% Remove white space
ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset; 
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = (outerpos(3) - ti(1) - ti(3))*0.99;
ax_height = (outerpos(4) - ti(2) - ti(4))*0.96;
ax.Position = [left bottom ax_width ax_height];

% Remove text and axis
axis off
legend off
title ''
end