function [all_err] = postprocess_chained_cross_validation(all_err)
% Processes the output of a chained cross validation run, mean subtracting
% each fold run in order to remove small-data effects
%   Note: other options are to remove outliers from each run
all_err = all_err - mean(all_err, 1);
end

