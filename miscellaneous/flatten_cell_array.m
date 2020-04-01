function [x] = flatten_cell_array(x)
% Takes a cell array of cell arrays, and undoes the inner array. For
% example:
%   {'a', 'b'} == flatten_cell_array({{'a'},{'b'}})
n = length(x);
for i = 1:n
    x{i} = x{i}{:};
end
end

