function [dat, lower_dat, upper_dat] = ...
    linear_sigmoid_middle_percentile(dat, which_percentile)
% Uses a linear sigmoid to reduce the effect of outliers on data by
% thresholding out any that are farther than the given symmetrized
% percentile
%
% Input:
%   dat - data vector; if more than one column, applied column-wise
%   which_percentile (10) - the percentile beyond which to threshold, which
%       will be symmetrized; e.g. the default of 10 means all data lower
%       than 10 and above 90 will be thresholded
%           Alternatively, can be a vector of two percentiles
if ~exist('which_percentile', 'var')
    which_percentile = 10;
end

if length(which_percentile)==1
    if which_percentile < 50
        which_percentile = [which_percentile 100-which_percentile];
    else
        which_percentile = [100-which_percentile which_percentile];
    end
end

if size(dat, 2) > 1
    for i = 1:size(dat, 2)
        dat(:,i) = linear_sigmoid_middle_percentile(...
            dat(:,i), which_percentile);
    end
    return
end
        
lower_dat = prctile(dat, which_percentile(1));
upper_dat = prctile(dat, which_percentile(2));

dat(dat>upper_dat) = ones(length(find(dat>upper_dat)),1)*upper_dat;
dat(dat<lower_dat) = ones(length(find(dat<lower_dat)),1)*lower_dat;

end

