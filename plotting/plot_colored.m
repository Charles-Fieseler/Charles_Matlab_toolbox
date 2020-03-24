function [fig] = plot_colored( dat, categories, legend_str, plot_options, cmap, fig )
% Plots a 3d trace of data colored by the given label indices
%   If there are more than 8 categories, then the later ones are all black
if ~exist('plot_options','var')
    plot_options = 'o';
end

if size(dat,1)~=length(categories)
    dat = dat';
    assert(size(dat,1)==length(categories),...
        'Incompatible category vector and data matrix')
end
x = dat(:,1);
y = dat(:,2);
if size(dat,2)<=2
    z = zeros(size(x));
else
    z = dat(:,3);
end

num_states = length(unique(categories));
if ~exist('cmap', 'var')
    cmap = lines(num_states);
    if num_states>7
        % Makes the 8th and later categories black (otherwise would repeat)
        cmap(8:end,:) = zeros(size(cmap(8:end,:)));
    end
elseif num_states > size(cmap,1)
    % Make sure there are enough colors
    n = size(cmap,1);
    cmap(n+1:num_states, :) = zeros(num_states-n,3);
end
if ~exist('fig', 'var')
    fig = figure('DefaultAxesFontSize',12);
end
hold on
f = gca;
for jC = unique(categories)
    ind = find(categories==jC);
    if contains(plot_options,'plot')
        plot3(x(ind), y(ind), z(ind), 'color', cmap(jC,:));
    elseif ~contains(plot_options,'.')
        scatter3(x(ind), y(ind), z(ind), 100, plot_options, 'Filled');
    f.Children(1).CData = cmap(jC,:);
    else
        scatter3(x(ind), y(ind), z(ind), 100, plot_options);
    f.Children(1).CData = cmap(jC,:);
    end
end
xlabel('1st mode')
ylabel('2nd mode')
zlabel('3rd mode')
legend(legend_str)

end

