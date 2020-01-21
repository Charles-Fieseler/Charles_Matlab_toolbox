function [mcc] = calc_mcc(tp, tn, fp, fn)
% Calculates the Matthew's correlation coefficient, a summary statistic for
% a binary classification method. Described clearly on the wikipedia page: 
%   https://en.wikipedia.org/wiki/Matthews_correlation_coefficient

mcc = ( (tp*tn)-(fp*fn) ) / sqrt( (tp+fp)*(tp+fn)*(tn+fp)*(tn+fn) );
end

