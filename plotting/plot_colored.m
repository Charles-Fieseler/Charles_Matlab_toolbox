function [fig] = plot_colored( dat, categories, legend_str, plot_options )
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
cmap = lines(num_states);
if num_states>7
    % Makes the 8th and later categories black (otherwise would repeat)
    cmap(8:end,:) = zeros(size(cmap(8:end,:)));
end
fig = figure;
hold on
f = gca;
for jC = unique(categories)
    ind = find(categories==jC);
    plot3(x(ind), y(ind), z(ind), plot_options, 'LineWidth',2);
    f.Children(1).Color = cmap(jC,:);
end
xlabel('1st mode')
ylabel('2nd mode')
zlabel('3rd mode')
legend(legend_str)

end

