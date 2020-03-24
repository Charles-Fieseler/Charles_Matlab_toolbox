function [all_vals] = map_across_hyperparameters(func, hyper_vec, verbose)
% Loops over a vector of hyperparameters, applying the 'func' to each
% value. 'func' should only take one parameter, the one which varies
if ~exist('verbose', 'var')
    verbose = false;
end
n = length(hyper_vec);
all_vals = cell(n, 1);
for i = 1:n
    hval = hyper_vec(i);
    if verbose
        fprintf('Running iteration %d/%d with value %.3f\n', i, n, hval)
    end
    all_vals{i} = func(hval);
end

if verbose
    fprintf('Finished\n')
end
end
