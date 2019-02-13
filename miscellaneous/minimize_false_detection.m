function obj = minimize_false_detection(dat, reconstruction,...
    threshold_factor, lambda, use_partial_detection)
% Tries to find a threshold factor which will minimize the false positives
% and negatives
%   For use with the function calc_false_detection()
if ~exist('lambda', 'var')
    lambda = 0.5;
end
if ~exist('use_partial_detection', 'var')
    use_partial_detection = false;
end

[num_fp, num_fn, ~, ind_fp, ind_fn] = ...
    calc_false_detection(dat, reconstruction, threshold_factor, ...
    [], [],false, use_partial_detection);
obj = lambda*num_fp + (1-lambda)*num_fn + ...
    (length(find(ind_fp)) + length(find(ind_fn)))/25;
end

