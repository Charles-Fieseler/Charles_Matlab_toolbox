function [out] = cell2newdim(dat)
% Concatenates a cell array of same-size matrix entries along a new
% dimension, which is the new first dimension
sz = [length(dat), size(dat{1})];
out = zeros(sz);
for i = 1:sz(1)
    out(i,:,:) = dat{i};
end
end

