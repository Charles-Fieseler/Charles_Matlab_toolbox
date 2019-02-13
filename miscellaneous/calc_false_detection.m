function [num_fp, num_fn, num_spikes, ind_fp, ind_fn,...
    true_pos, fig, true_spike_ind] = ...
    calc_false_detection(dat, reconstruction, threshold_factor,...
    length_for_detection, window_true_spike, to_plot,...
    use_partial_detection, use_peak_prominence)
% Calculates the false positive and negative detection rate via
% thresholding
%
% Input:
%   dat - vector with true spikes; these will be detected using the
%       MATLAB function isoutlier()
%   reconstruction - the reconstruction, with its own spikes
%   threshold (1) - the over/under for defining spikes in the
%       reconstruction as a percentage of the mean outlier height in 
%       the reconstructed trajectory
%   length_for_detection (1 or 3) - the number of frames in a row that
%       constitutes a spike detection; if use_peak_prominence is false,
%       then the default is 3
%   window_true_spike (10) - a window around a true spike that doesn't count
%       as a false positive
%   to_plot (false) - to visualize the method
%   use_partial_detection (false) - a method for softening the threshold,
%       so that false detection takes into account the L2 error 
%   use_peak_prominence (true) - uses a peak-finding method on the
%       derivatives to set the "true" spikes; otherwise uses the
%       isoutlier() function with 'ThresholdFactor'=2. This option also
%       changes the method of determining spikes in the reconstruction, and
%       thus the 'threshold_factor' now multiplies the spike prominence
if ~exist('threshold_factor', 'var') || isempty(threshold_factor)
    threshold_factor = 1.0;
end
if ~exist('window_true_spike', 'var') || isempty(window_true_spike)
    window_true_spike = 10;
end
if ~exist('to_plot', 'var') || isempty(to_plot)
    to_plot = false;
end
if ~exist('use_partial_detection', 'var')
    use_partial_detection = false;
end
if ~exist('use_peak_prominence', 'var')
    use_peak_prominence = true;
end
if ~exist('length_for_detection', 'var') || isempty(length_for_detection)
    if use_peak_prominence
        length_for_detection = 1;
    else
        length_for_detection = 3;
    end
end

%% Get spikes and thresholds
n = length(dat);
if use_peak_prominence
    [~, tmp] = findpeaks(dat, 'MinPeakDistance', 2*window_true_spike,...
        'MinPeakProminence', std(dat));
    true_spike_ind = false(size(dat));
    true_spike_ind(tmp) = true;
    [true_spike_starts, true_spike_ends] = ...
        calc_contiguous_blocks(true_spike_ind, length_for_detection);
    
%     [~, tmp] = findpeaks(reconstruction, ...
%         'MinPeakDistance',2*window_true_spike,...
%         'MinPeakProminence', std(reconstruction)*threshold_factor);
    [~, tmp] = findpeaks(reconstruction, ...
        'MinPeakDistance', 2*window_true_spike,...
        'MinPeakProminence', std(dat)); % Tiny spikes in reconstruction shouldn't count
    recon_spike_ind = false(size(dat));
    recon_spike_ind(tmp) = true;
else
    true_spike_ind = isoutlier(dat, 'ThresholdFactor', 2); % 2 medians away
    [true_spike_starts, true_spike_ends] = ...
        calc_contiguous_blocks(true_spike_ind, length_for_detection);

    % recon_spike_ind = isoutlier(reconstruction, 'movmedian', window_sz);
    [~, recon_sort_ind] = sort(reconstruction, 'descend');
    % Same number of frames as true spikes
    recon_sort_ind = recon_sort_ind(1:length(true_spike_ind));
    threshold_height = threshold_factor*mean(reconstruction(recon_sort_ind));
    recon_spike_ind = reconstruction>threshold_height;
end


%% Check if each true spike has a spike in the reconstruction 
% (false negatives)
num_spikes = length(true_spike_starts);
true_pos = false(size(true_spike_starts));
ind_fn = [];
fn_error = 0;
recon_spike_find = find(recon_spike_ind);
for i = 1:num_spikes
    if use_peak_prominence
        this_span = max([1, true_spike_starts(i)-window_true_spike]) : ...
            min([true_spike_ends(i)+window_true_spike n]);
        true_pos(i) = ~isempty(intersect(this_span, recon_spike_find));
    else
        this_span = true_spike_starts(i):true_spike_ends(i);
        assert(~isempty(this_span),...
            'Error: detected an empty spike...')
        true_pos(i) = ...
            length(find(reconstruction(this_span)>threshold_height))...
            >= length_for_detection;
    end
    if ~true_pos(i)
        ind_fn = [ind_fn this_span]; %#ok<AGROW>
        if use_partial_detection
            res_dat = trapz(dat(this_span));
            res_recon = trapz(reconstruction(this_span));
            fn_error = fn_error + ...
                abs(res_dat - res_recon)/(res_dat + res_recon);
        end
    end
end

if ~use_partial_detection
    num_fn = num_spikes - length(find(true_pos));
    true_pos = length(find(true_pos));
else
    num_fn = fn_error; % maximum of 1 for each partial detection
    true_pos = num_spikes - fn_error;
end

%% Check for false positives
false_spikes = recon_spike_ind;
for i = 1:length(true_spike_starts)
    this_span = (true_spike_starts(i)-window_true_spike) : ...
        (true_spike_ends(i)+window_true_spike);
    this_span = this_span(this_span>0); % Stay in bounds of the data
    this_span = this_span(this_span<=n);
    false_spikes(this_span) = false;
end
false_spikes(true_spike_ind) = false;
% recon_spike_starts = diff(false_spikes);
% recon_spike_starts = find(recon_spike_starts.*(recon_spike_starts>0));
[false_spike_starts, false_spike_ends] = ...
    calc_contiguous_blocks(false_spikes, length_for_detection);
% Because they are not on true spikes, we don't need to check anything
ind_fp = find(false_spikes);
if ~use_partial_detection
    num_fp = length(find(false_spike_starts));
else
    num_fp = 0;
    % TO CHECK
    for i = 1:length(false_spike_starts)
        this_span = (false_spike_starts(i)-1):(1+false_spike_ends(i));
        this_span = this_span(this_span>0); % Stay in bounds of the data
        this_span = this_span(this_span<=n);
        res_dat = trapz(dat(this_span));
        res_recon = trapz(reconstruction(this_span));
        num_fp = num_fp + ...
            abs(res_dat - res_recon)/(res_dat + res_recon);
    end
end

%% Plot
if to_plot
    fig = figure('DefaultAxesFontSize', 14);
    plot(dat, 'LineWidth',2)
    xlim([0, length(dat)])
    hold on
    plot(reconstruction, 'LineWidth',2)
    plot(ind_fn, dat(ind_fn), 'ko', 'LineWidth',3, 'MarkerSize',15)
    plot(ind_fp, dat(ind_fp), 'k*', 'LineWidth',3, 'MarkerSize',15)
    if ~use_peak_prominence
        plot(1:n, threshold_height*ones(1,n), 'k--', 'LineWidth',2)
    end
    legend_str = {'Data', 'Reconstruction'};
    if ~isempty(ind_fn)
        legend_str = [legend_str 'False negatives'];
    end
    if ~isempty(ind_fp)
        legend_str = [legend_str 'False positives'];
    end
    if ~use_peak_prominence
        legend_str = [legend_str 'Threshold'];
    end
    legend(legend_str)
end

end

