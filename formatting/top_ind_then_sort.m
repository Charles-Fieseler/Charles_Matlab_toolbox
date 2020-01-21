function [ordered_dat, ordered_ind] = top_ind_then_sort(...
    dat, top_x, threshold)
% Takes the largest values of the absolute value of the dataset, then
% re-sorts them by their signed value
%
% Input:
%   dat - the data matrix
%   top_x - the top x to take
%   threshold - the cutoff value
% NOTE: ONE of top_x or threshold must be passed; top_x dominates
assert(exist('top_x', 'var') || exist('threshold', 'var'),...
    'Pass an integer or a threshold')

% Only get the interesting data
all_rows = sum(abs(dat),2);
if exist('top_x', 'var') && ~isempty(top_x)
    [~, interesting_ind] = sort(all_rows, 'descend');
    ordered_ind = interesting_ind(1:top_x);
else
    ordered_ind = find(all_rows > threshold);
end
% Re-sort it
[~, sort_ind] = sort(dat(ordered_ind,1), 'descend');    
ordered_ind = ordered_ind(sort_ind);
ordered_dat = dat(ordered_ind, :);

end

