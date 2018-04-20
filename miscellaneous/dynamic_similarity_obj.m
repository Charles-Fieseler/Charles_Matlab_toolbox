classdef dynamic_similarity_obj < handle & settings_importable_from_struct
    %Dynamic similarity of functions
    % Initial use case: Similarity between DMD reconstructions
    
    properties (SetAccess=private)
        % For the comparison function(s)
        compare_func_is_array
        compare_func
        compare_x0_mean
        compare_x0
        compare_x_end % Saves these endings
        
        all_similarities
        
        % For data cleaning
        outlier_indices
    end
    
    properties (SetAccess={?settings_importable_from_struct})
        iterations = 10
        noise = 1
        sz = [1 1]
        use_mahalanobis = true
    end
    
    methods
        
        function self = dynamic_similarity_obj(...
                compare_func, compare_x0_mean, settings)
            %% Import user settings
            self.import_settings_to_self(settings);
            self.compare_func_is_array = iscell(compare_func);
            self.compare_func = compare_func;
            self.compare_x0 = containers.Map();
            self.compare_x_end = containers.Map();
            %==============================================================
            
            %% Generate initial conditions
            if isempty(compare_x0_mean)
                compare_x0_mean = zeros(self.sz);
                warning('Setting default x0; make sure to set the sz setting')
            end
            self.compare_x0_mean = compare_x0_mean;
            self.generate_initial_conditions()
            %==============================================================
            
            %% Calculate reconstructions to use as comparison
            self.calc_compare_func()
            %==============================================================
        end
        
        function similarity = ...
                calc_dynamic_similarity_functions(self, test_func)
            % Calculates data reconstruction similarity using dynamics: 
            % A_func is all dynamics matrices (cell array) to be averaged;
            % B is a single function that will use a randomly
            % generated start point (noise added to average start point of
            % this label)
            if isnumeric(test_func)
                if self.compare_func_is_array
                    test_func = self.compare_func{test_func};
                else
                    error('Numeric input only valid if an array of functions is saved')
                end
            end
            
            similarity = 0;
            for i=1:self.iterations
                key = self.num2key(i);
                % Plug into all dynamics for this label and average the
                % results
                if ~self.use_mahalanobis
                    compare_vec = self.compare_x_end(key);
                else
                    key_mahal = self.num2key(i, true);
                    compare_mat = self.compare_x_end(key_mahal);
                end
                    
                %Get previously generated random vector
                x0 = self.compare_x0(key);
                % Get the (reconstructed) data for the same initial point
                test_vec = test_func(x0);

                if ~self.use_mahalanobis
                    % Use a cos() for determining similarity
                    similarity = similarity + ...
                        self.calc_similarity_cos(compare_vec, test_vec);
                else
                    similarity = similarity + ...
                        mahal(real(test_vec.'), real(compare_mat));
                end
            end
            similarity = similarity / self.iterations;
        end
        
        function all_similarities = ...
                calc_all_dynamic_similarity_functions(self)
            % Calculates all similarities and returns them in a vector
            this_sz = length(self.compare_func);
            if this_sz<=1
                disp('Not enough functions to compute similarity')
                all_similarities = 1;
                return
            end
            all_similarities = zeros(this_sz,1);
            
            for j=1:this_sz
                all_similarities(j) = ...
                    self.calc_dynamic_similarity_functions(j);
            end
            self.all_similarities = all_similarities;
        end
        
        function delete_outlier_data(self)
            % Deletes outliers using a mahalanobis distance score or
            % similarity score
            %   Note: the functions that generated the data are kept
            assert(self.use_mahalanobis,'Only works with mahalanobis scores')
            dat = self.get_final_points('all');
            all_dist = mahal(dat,dat);
            % Gets points that are >3 median deviations away
            non_outliers = ~isoutlier(all_dist);
            for i=1:length(self.iterations)
                key = self.num2key(i,true);
                this_dat = self.compare_x_end(key);
                self.compare_x_end(key) = this_dat(non_outliers,:);
            end
        end
        
        function calc_compare_func(self)
            % Calculate the final data predictions given the saved initial
            % conditions
            
            for i=1:self.iterations
                key = self.num2key(i);
                x0 = self.compare_x0(key);
                
                if self.compare_func_is_array
                    % The comparison vector is an average of a cell array
                    % of functions (which return vectors) by default
                    all_vector = cell2mat(...
                        cellfun(@(f,x) f(x), self.compare_func,...
                        repmat({x0},size(self.compare_func)),...
                        'UniformOutput',false)) ;
                    self.compare_x_end(key) = mean(all_vector,2);
                    if self.use_mahalanobis
                        if size(all_vector,1)>size(all_vector,2)
                            warning('Not enough data to use mahalanobis distance; turning setting off')
                            self.use_mahalanobis = false;
                            continue
                        end
                        key_mahal = self.num2key(i, true);
                        self.compare_x_end(key_mahal) = all_vector.';
                    end
                else
                    self.compare_x_end(key) = self.compare_func(x0);
                end
            end
        end
    end
    
    methods % plotting
        function plot_PCA_similarity(self, which_x0)
            % Plots a scatterplot of the saved compare vectors
            %   Uses top 3 pca dimensions as axes
            dat = self.get_final_points(which_x0);
            options = struct('average',false,'sigma',false,'PCA3d',true,...
                'PCA_opt','o');
            plotSVD( dat, options );
        end
        
        function f = plot_hist(self, to_throw_outliers)
            % Plots a histogram of the mahalanobis distances
            %   e.g. for visualizing outliers
            if ~exist('to_throw_outliers','var')
                to_throw_outliers = false;
            end
            f = figure('DefaultAxesFontSize',14);
            if self.use_mahalanobis
                dat = self.get_final_points('all');
                all_dist = self.throw_outliers(mahal(dat,dat), ...
                    to_throw_outliers);
                hist( all_dist )
                title('Mahalanobis distances')
            else
                all_sim = self.throw_outliers(self.all_similarities, ...
                    to_throw_outliers);
                hist( all_sim )
                title('Cosine distances')
            end
        end
        
        function f = plot_box(self, to_throw_outliers)
            % box and whisker plot with all data
            if ~exist('to_throw_outliers','var')
                to_throw_outliers = false;
            end
            f = figure('DefaultAxesFontSize',14);
            if self.use_mahalanobis
                dat = real(self.get_final_points('all'));
                all_dist = self.throw_outliers(mahal(dat,dat), ...
                    to_throw_outliers);
                boxplot( all_dist )
                title('Mahalanobis distances')
            else
                all_sim = self.throw_outliers(self.all_similarities, ...
                    to_throw_outliers);
                boxplot( all_sim )
                title('Cosine distances')
            end
        end
    end
    
    methods (Access=private)
        function generate_initial_conditions(self)
            % Generates noisy initial conditions to be used for comparison
            x0 = self.compare_x0_mean;
            for i=1:self.iterations
                key = self.num2key(i);
                self.compare_x0(key) = x0 + self.noise*rand(size(x0));
            end
        end
        
        function dat = get_final_points(self, which_x0)
            % Gets final points from a single initial condition or multiple
            
            if isnumeric(which_x0)
                key = self.num2key(which_x0, self.use_mahalanobis);
                dat = self.compare_x_end(key);
            else
                dat = [];
                for i=1:length(self.iterations)
                    key = self.num2key(i, self.use_mahalanobis);
                    dat = [dat; self.compare_x_end(key)]; %#ok<AGROW>
                end
            end
        end
    end
    
    methods (Static)
        function key = num2key(num, is_mahalanobis)
            key = num2str(num);
            if exist('is_mahalanobis','var')
                if is_mahalanobis
                    key = [key 'mahalanobis'];
                end
            end
        end
        
        function similarity = calc_similarity_cos(compare_vec, test_vec)
            % simple cosine similarity function
            %   Changes in amplitude are ignored
            similarity = real(dot(test_vec, compare_vec)) / ...
                         (norm(test_vec)*norm(compare_vec));
        end
        
        function dat = throw_outliers(dat, to_throw_outliers)
            if to_throw_outliers
                all_outliers = isoutlier(dat);
                dat = dat(~all_outliers);
                fprintf('Threw out %d outlier(s)\n',...
                    length(find(all_outliers)))
            end
        end
    end
    
end

