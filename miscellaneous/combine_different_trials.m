function [ combined_dat, output_labels ] =...
    combine_different_trials( labeled_dat_cell, keep_unnamed )
% Combines different data runs which might have measured different
% nodes/neurons for each
%
% Input:
%   labeled_dat_cell - n by 2 cell array with 'n' data runs; names are
%                       second column (data should also be cell array)
%   keep_unnamed (false) - boolean for whether to filter out the data which
%                       has an empty string in the name field
%
% Output:
%   combined_dat - cell array of combined data with NaN for missing entries
%   all_labels - labels for the rows of combined_dat
if ~exist('keep_unnamed','var')
    keep_unnamed = false;
end

num_runs = size(labeled_dat_cell,1);
if ~keep_unnamed
    output_labels = unique([labeled_dat_cell{:,2}]);
    output_labels = output_labels(~cellfun(@isempty,output_labels));
else
    output_labels = [labeled_dat_cell{:,2}];
end
combined_dat = cell(length(output_labels), num_runs);
unnamed_index = length(unique([labeled_dat_cell{:,2}]));

for i = 1:num_runs
    this_dat = labeled_dat_cell{i,1};
    this_labels = labeled_dat_cell{i,2};
    for j = 1:length(this_dat)
        % First search in just this individual; then get indices
        % over all datasets
        if isempty(this_labels{j})
            if ~keep_unnamed
                continue
            else
                combined_dat{unnamed_index, i} = this_dat{j};
                unnamed_index = unnamed_index + 1;
            end
        else
            if length(find(strcmp(this_labels{j},this_labels))) > 1,...
                fprintf('Neuron name duplication (%s) within one individual; skipping\n',...
                    this_labels{j})
                continue
            end
            output_ind = strcmp(this_labels{j}, output_labels);
            combined_dat{output_ind, i} = this_dat{j};
        end
    end
end

combined_dat(cellfun(@isempty,combined_dat)) = {''};
end

