function [ out ] = reconstruct_trajecories( dat, max_dist )
%Reconstructs trajectories from data
%   Outputs a struct with fields:
%       sequential - trajectories that are close in space and sequential in
%           time
%       sequential_ind - indices of the above
%       stitched - stitched together sequential trajectories
%       stitched_ind - indices of the above

%---------------------------------------------
% Set defaults
%---------------------------------------------
if ~exist('max_dist','var')
    max_dist = pdist2(dat(1,:),dat(2,:))*5;
end
if ~exist('verbose','var')
    verbose = true;
end


%---------------------------------------------
% Collect the time-sequential trajectories
%---------------------------------------------
if verbose
    disp('Collecting temporally close sequences')
end
sz = size(dat);
seq_trajectories = containers.Map(...
    'KeyType', 'uint32', 'ValueType', 'any');
seq_ind = {};
num_sequences = 1;
j = 1;
trajectory_start = j;
old_point = dat(j,:);
for j = 2:sz(1)
    new_point = dat(j,:);
    if (pdist2(old_point, new_point) > max_dist) || (j==sz(1))
        % Save the old and start and new trajectory
        this_ind = trajectory_start:j;
        seq_trajectories(num_sequences) = dat(this_ind,:);
        seq_ind = [seq_ind; {this_ind}]; %#ok<AGROW>
        
        trajectory_start = j+1;
        num_sequences = num_sequences+1;
    end
    old_point = new_point;
end

%---------------------------------------------
% Stitch together trajectories
%---------------------------------------------
if verbose
    disp('Stitching together temporally far sequences (may take a while)')
end

stitch_trajectories = containers.Map(...
    'KeyType', 'uint32', 'ValueType', 'any');
stitch_ind = {};
seq2stitch_ind = containers.Map(...
    'KeyType', 'uint32', 'ValueType', 'double');
num_trajectories = length(seq_ind);
num_stitched_trajectories = 1;

    function update_ind(j1, j2, new_j)
        seq2stitch_ind(j1) = new_j;
        seq2stitch_ind(j2) = new_j;
    end

for j = 1:num_trajectories-1
    if isKey(seq2stitch_ind, j)
        continue
    end
    this_trajectory = seq_trajectories(j);
    this_trajectory_ind = seq_ind{j};
    already_checked_stitches = []; %Stitched lists
    
    for j2 = j+1:num_trajectories
        if isKey(seq2stitch_ind, j2)
            this_stitched_ind = seq2stitch_ind(j2);
            if ismember(this_stitched_ind, already_checked_stitches)
                % Multiple sequential indices can point to the same
                % stitched-together list
                continue
            else
                already_checked_stitches = [already_checked_stitches ...
                    this_stitched_ind]; %#ok<AGROW>
            end
            this_check = stitch_trajectories(this_stitched_ind);
            this_check_ind = stitch_ind{this_stitched_ind};
        else
            this_check = seq_trajectories(j2);
            this_check_ind = seq_ind{j2};
        end
        % Add to beginning or end (single row)
        %   All new references to the old trajectories will now reference
        %   this stitched trajectory
        if pdist2(this_trajectory(1), this_check(1)) < max_dist
            this_trajectory = [this_check; this_trajectory]; %#ok<AGROW>
            this_trajectory_ind = [this_check_ind ...
                this_trajectory_ind]; %#ok<AGROW>
            update_ind(j, j2, num_stitched_trajectories);
        elseif pdist2(this_trajectory(end), this_check(end)) < max_dist
            this_trajectory = [this_trajectory; this_check]; %#ok<AGROW>
            this_trajectory_ind = [this_trajectory_ind ...
                this_check_ind]; %#ok<AGROW>
            update_ind(j, j2, num_stitched_trajectories);
        end
    end
    stitch_trajectories(num_stitched_trajectories) = this_trajectory;
    stitch_ind = [stitch_ind; {this_trajectory_ind}]; %#ok<AGROW>
    num_stitched_trajectories = num_stitched_trajectories + 1;
end

%---------------------------------------------
% Collect into state vector
%---------------------------------------------

seq_vec = zeros(1,size(dat,1));
for j=1:length(seq_ind)
    seq_vec(seq_ind{j}) = j;
end

stitch_vec = zeros(1,size(dat,1));
for j=1:length(stitch_ind)
    stitch_vec(stitch_ind{j}) = j;
end


%---------------------------------------------
% Save for output
%---------------------------------------------

out.seq_trajectories = seq_trajectories;
out.seq_ind = seq_ind;
out.seq_vec = seq_vec;
out.stitch_trajectories = stitch_trajectories;
out.stitch_ind = stitch_ind;
out.stitch_vec = stitch_vec;

out.seq2stitch_ind = seq2stitch_ind;

end

