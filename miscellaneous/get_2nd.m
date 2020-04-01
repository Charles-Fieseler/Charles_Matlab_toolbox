function [out] = get_2nd(func, varargin)
% Gets 2nd output from a function that returns two values with no input
% For example, to get just the index of a min/max function:
%   ind = get_2nd(@min,dat);
[~, out] = func(varargin{:});
end

