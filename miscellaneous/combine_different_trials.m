function [ combined_dat, all_labels ] =...
    combine_different_trials( labeled_dat_cell )
% Combines different data runs which might have measured different
% nodes/neurons for each
%
% Input:
%   labeled_dat_cell - n by 2 cell array with 'n' data runs; names are
%                       second column (data should also be cell array)
%
% Output:
%   combined_dat - cell array of combined data with NaN for missing entries
%   all_labels - labels for the rows of combined_dat

num_runs = size(labeled_dat_cell,1);
all_labels = unique([labeled_dat_cell{:,2}]);
combined_dat = cell(length(all_labels), num_runs);

for i=1:num_runs
    this_dat = labeled_dat_cell{i,1};
    this_labels = labeled_dat_cell{i,2};
    for j=1:length(this_dat)
        combined_dat{strcmp(this_labels{j},all_labels), i} = ...
            this_dat{j};
    end
end

combined_dat(cellfun(@isempty,combined_dat)) = {''};
end

