function [ vec_sparse ] = prox_func( vec, lambda )
%Performs a prox sparsifying procedure
%   vec - the vector to be sparsified
%   lambda - the sparsifying parameter; any entry <|lambda| is set to 0

assert(isvector(vec),'Must pass a vector')

vec_sparse = zeros(size(vec));
for j=1:length(vec)
    x = vec(j);
    if abs(x)>lambda
        vec_sparse(j) = x - sign(x)*lambda;
    else
        vec_sparse(j) = 0;
    end
end


end

