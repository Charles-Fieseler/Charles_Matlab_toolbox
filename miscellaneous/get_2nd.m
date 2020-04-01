function [out] = get_2nd(func, varargin)
% Gets 2nd output from a function that returns two values with no input
[~, out] = func(varargin{:});
end

