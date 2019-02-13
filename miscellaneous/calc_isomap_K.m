function [K, this_mapping, this_mappedX, all_costs, min_K, max_K] =...
    calc_isomap_K(dat, no_dims)
% Calculates the isomap embedding value K (number of neighbors to use to
% build the graph)
% From this paper:
%   Selection of the optimal parameter value for the Isomap algorithm

n = size(dat, 1);

%---------------------------------------------
% Get the interval of possible K's
%---------------------------------------------
% Initialize
min_K = [];
max_K = 0;
all_mappedX = {};
all_mappings = {};
for K = 1:round(n/2)
    [mappedX, mapping] = isomap(dat, no_dims, K);
    if isempty(min_K) && length(mapping.conn_comp)==n
        min_K = K;
    end
    if (nnz(mapping.D)/n) <= K+2
        % We want the largest K for which this is true
        max_K = K;
    elseif max_K > 0
        break 
    end
    if ~isempty(min_K)
        all_mappedX = [all_mappedX mappedX]; %#ok<AGROW>
        all_mappings = [all_mappings mapping]; %#ok<AGROW>
    end
end

assert(min_K <= max_K,...
    'Minimum K greater than max; suggest a different algorithm')

%---------------------------------------------
% Calculate the cost function and find minima
%---------------------------------------------

num_K = max_K-min_K+1;
all_costs = zeros(num_K,1);
for i = 1:num_K
    Dg = all_mappings{i}.DD; % Geodesic in full space
    Dy = squareform(pdist(all_mappedX{i})); % L2 in Low-dimensional embedding
    all_costs(i) = norm(Dg - Dy);
end

[~, K_ind] = min(all_costs);
K = min_K + K_ind - 1;
this_mapping = all_mappings{K_ind};
this_mappedX = all_mappedX{K_ind};

end

