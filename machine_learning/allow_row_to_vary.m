function [hyper_best_U,hyper_all_err,hyper_min_1se_ind,hyper_min_1se_err] =...
    allow_row_to_vary(...
    control_signal_path, num_error_steps, initial_ind, lambda, k, ...
    num_outer_iterations, cap_at_0, min_func, objective_func_str)
% For metrics that were calculated as a global minimum, refine by keeping
% all but one row fixed, and optimize over that row. Made for use with the
% dmdc_cross_val.m function that calculates multiple time step errors at
% once
%
% Input:
%   control_signal_path - a ControlSignalPath object
%   num_error_steps - a vector of the number of error steps to calculate
%       (hyperparameter)
%   initial_ind - the starting point for the minimization
%   lambda (1) - a free parameter multiplying the standard error to determine
%       the threshold for letting sparse parameters in
%   k (5) - number of folds
%   num_outer_iterations (1) - number of iterations to run the row-varying
%       algorithm, allowing pruning to remove rows in between iterations
%   cap_at_0 (false) - whether to cap the threshold at 0 error
%   min_func (@last_local_min) - the function used for determining the
%       sparsity. The global minimum is generally unstable and too dense,
%       so by default all local minima are found, and the sparsest one that
%       is good, within lambda*(standard error of the global min), is used
%   objective_func_str ('cv') - the objective function to minimize. Default
%       is cross validation 

if ~exist('lambda', 'var') || isempty(lambda)
    lambda = 1;
end
if ~exist('k', 'var') || isempty(k)
    k = 5;
end
if ~exist('cap_at_0', 'var') || isempty(cap_at_0)
    cap_at_0 = false;
end
if ~exist('min_func', 'var') || isempty(min_func)
    min_func = @last_local_min;
end
if ~exist('objective_func_str', 'var')
    objective_func_str = 'cv';
end

% Set up objective function
local_path = copy(control_signal_path);
% Renaming for later interpretability
X = local_path.data;

switch objective_func_str
    case 'cv'
        objective_func = @(U) ...
            dmdc_cross_val(X, U, k, num_error_steps, [], false);
    case 'aic'
        objective_func = @(U) ...
            aic_2step_dmdc(X, U, [], [], num_err_steps, false, ...
                'standard');
    otherwise
        error('Unrecognized objective function')
end

% Variables for later sizes
num_folds = k - 1;
num_alg_iters = length(local_path.all_U);
[num_rows, num_frames] = size(local_path.all_U{1});
num_hyper = length(num_error_steps);

ind_to_test = 1:num_alg_iters;



warning off
for iOuter = 1:num_outer_iterations
    % Arrays for different hyperparameter values
    % Note: num_rows will change for more iterations
    hyper_min_1se_ind = zeros(num_rows, num_hyper);
    hyper_min_1se_err = zeros(num_rows, num_hyper);

    hyper_all_err = zeros(num_rows, num_alg_iters, num_hyper, num_folds);
    hyper_best_U = zeros(num_rows, num_frames, num_hyper);
    % Determine the fixed values of other rows
    if iOuter == 1
        base_U = local_path.all_U{initial_ind};
    else
        base_U = best_U;
    end
    for iRow = 1:size(base_U, 1)
        % Loop through each control signals channel (row)
        all_err = zeros(length(ind_to_test), num_hyper, num_folds);
%         for iIter = 1:length(ind_to_test)
%             % Retry all sparsity possibilities, leaving other rows same
%             this_U = base_U;
%             this_row_i = ind_to_test(iIter);
%             new_row_U = local_path.all_U{this_row_i};
%             this_U(iRow,:) = new_row_U(iRow,:);
% %             [~, all_err(iIter,:,:)] = ...
% %                 dmdc_cross_val(X, this_U, k, num_error_steps, ...
% %                 [], false);
%             [~, all_err(iIter,:,:)] = ...
%                 objective_func(X, this_U, num_error_steps);
%         end
        out = local_path.iterate_single_row(...
                base_U, ind_to_test, iRow, objective_func);
        all_err = flatten_cell_array(out); % TODO
        error();
        % TEST: subtract the mean instead of the abolute errors to better
        % compare folds
        all_err = all_err - mean(all_err,1);
        % Process into best row (not simple min)
        sz = size(all_err);
        tmp_best_ind = zeros(sz(2), 1);
        tmp_best_val = zeros(sz(2), 1);
        for i = 1:sz(2)
            [tmp_best_ind(i), tmp_best_val(i)] = min_func(...
                squeeze(all_err(:,i,:)), lambda, false, cap_at_0);
        end
%         [~, tmp_min_ind] = min(all_err_means);
        
        % Convert back if testing doesn't start at first indices
        tmp_best_ind = tmp_best_ind + ind_to_test(1)-1;
%         tmp_min_ind = tmp_min_ind + ind_to_test(1)-1;
        
        fprintf('Row %d\n', iRow);
        if iOuter == 1
            fprintf('Old best iteration: %d\n', initial_ind);
        else
            fprintf('Old best iteration: %d\n', tmp_best_ind(iRow));
        end
%         fprintf('New minimum iteration: %d\n', tmp_min_ind);
        fprintf('New best iteration: %d\n', tmp_best_ind);
        
        %
        hyper_min_1se_ind(iRow, :) = tmp_best_ind;
        hyper_min_1se_err(iRow, :) = tmp_best_val;
        hyper_all_err(iRow, :, :, :) = all_err;
    end
    % Get final "Best" signal
    for iHyper = 1:num_hyper
        tmp_best_U = zeros(size(base_U));
        for iRow2 = 1:iRow
            % Pick each best row, for each hyperparameter value
            tmp_best_U(iRow2, :) = ...
                local_path.all_U{...
                hyper_min_1se_ind(iRow2, iHyper)}(iRow2,:);
        end
    %     hyper_min_1se_ind{iHyper} = new_min_1se_ind;
    %     hyper_min_1se_err{iHyper} = new_min_1se_err;
        hyper_best_U(:, :, iHyper) = tmp_best_U;
    end
    if num_outer_iterations > 1
        best_ind = mode(hyper_min_1se_ind, 2);
        best_U = zeros(size(base_U));
        for i = 1:num_rows
            best_U(i,:) = local_path.all_U{best_ind(i)}(i,:);
        end
        % Remove signal rows that are zeroed out
        ind_to_keep = best_ind < num_alg_iters;
        for i = 1:num_alg_iters
            local_path.all_U{i} = ...
                local_path.all_U{i}(ind_to_keep,:);
        end
        best_U = best_U(ind_to_keep,:);
        num_rows = nnz(ind_to_keep);
        fprintf('Retaining %d/%d rows\n', num_rows, length(ind_to_keep));
    end
end
warning on
end

