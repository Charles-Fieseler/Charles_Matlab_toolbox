function U = remove_isolated_spikes(U)
% Removes entries in a vector that are only 1 frame long, e.g. because they
% may be noise
%
% Input:
%   U - The control signal; rows are channels, columns are time
%
% Output:
%   U - the control signal with isolated entries removed
for i = 1:size(U,1)
    [all_starts, all_ends] = ...
        calc_contiguous_blocks(logical(U(i,:)), 1, 1);
    blocks_to_remove = (all_ends - all_starts) < 1;
    for i2 = 1:length(all_starts)
        if blocks_to_remove(i2)
            U(i, all_starts(i2):all_ends(i2)) = 0;
        end
    end
end
end