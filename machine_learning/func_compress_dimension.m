function [new_dat] = func_compress_dimension(dat, func, dim)
% Applies func() to each submatrix in dat, reducing the dataset across
% dimension 'dim'. Similar to the dim keyword in the mean() and std()
% functions, for arbitrary reductions
error('Not yet')
sz = size(dat);
n = sz(dim);
new_sz = sz;
new_sz(dim) = [];
new_dat = zeros(new_sz);

for i = 1:n
end
end

