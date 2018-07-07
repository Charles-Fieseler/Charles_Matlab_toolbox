classdef ParetoFrontObj < SettingsImportableFromStruct
    %% Pareto Front Calculator
    %
    % INPUTS
    %   iterable - A class or function to iterate over
    %   settings - the settings of this object, which has fields like which
    %               fields to iterate over in the iterable object
    %
    % OUTPUTS -
    %   OUTPUT1 -
    %   OUTPUT2 -
    %
    % EXAMPLES
    %
    %   EXAMPLE1
    %
    %
    %   EXAMPLE2
    %
    %
    %
    % Dependencies
    %   .m files, .mat files, and MATLAB products required:
    %
    %   See also: OTHER_FUNCTION_NAME
    %
    %
    %
    % Author: Charles Fieseler
    % University of Washington, Dept. of Physics
    % Email address: charles.fieseler@gmail.com
    % Website: coming soon
    % Created: 22-Jun-2018
    %========================================
    
    
    properties (SetAccess={?SettingsImportableFromStruct}, Hidden=true)
        
        file_or_dat % Can be cell array
        base_settings % Not iterated
        iterate_settings % Iterated over (struct)
        x_fieldname
        x_vector % Iterated over (vector)
        fields_to_plot % Of the class / return value
        y_val_func % function to get the y values from the analysis objects
        
        to_estimate_time
    end
    
    properties
        obj_struct
        iterable_name
        iterable_func
        
        y_struct
    end
    
    methods
        function self = ParetoFrontObj(iterable_name, settings)
            %% Set defaults and import settings
            if ~exist('settings','var')
                settings = struct();
            end
            self.set_defaults();
            self.import_settings_to_self(settings);
            
            if exist(iterable_name,'file')==2
                self.iterable_name = iterable_name;
                self.iterable_func = str2func(iterable_name);
            else
                error('File not on path')
            end
            %==========================================================================
            
            %% Iterate over vector, calculate, and save y values
            self.calculate_pareto_all_setting_vals();
            self.save_y_vals();
            %==========================================================================
            
        end
        
        function calculate_pareto_all_setting_vals(self, which_setting)
            if ~exist('which_setting','var')
                fname = fieldnames(self.iterate_settings);
                which_setting = fname{1};
            end
            setting_val_array = self.iterate_settings.(which_setting);
            assert(iscell(setting_val_array),...
                'Settings should be an iterable cell array')
            
            for i=1:length(setting_val_array)
                this_setting_val = setting_val_array{i};
                self.calculate_pareto_one_setting(...
                    which_setting, this_setting_val);
            end
        end
        
        function calculate_pareto_one_setting(self, ...
                setting_name, setting_val)
            settings = self.base_settings;
            settings.(setting_name) = setting_val;
            these_obj = cell(size(self.x_vector));
            
            tic;
            for i=1:length(self.x_vector)
                this_x = self.x_vector(i);
                settings.(self.x_fieldname) = this_x;
                
                these_obj{i} = ...
                    self.iterable_func(self.file_or_dat, settings);
                
                if i == self.to_estimate_time
                    t = toc;
                    average_t = t/self.to_estimate_time;
                    estimated_end = average_t * (length(self.x_vector)-i);
                    fprintf('Average time over %d runs: %f\n',...
                        i, average_t)
                    fprintf('Estimated time left: %f\n', estimated_end)
                end
            end
            
            t = toc;
            fprintf('Total time over %d runs: %f\n', i, t)
            
            self.save_simulation(setting_val, these_obj);
        end
        
        function add_iteration_value(self, setting_name, setting_val)
            
            assert(isfield(self.iterate_settings, setting_name),...
                'Can only add to already set iterable setting')
            
            self.iterate_settings.(setting_name) = ...
                [self.iterate_settings.(setting_name) setting_val];
            
            self.calculate_pareto_one_setting(setting_name, setting_val);
            self.save_y_vals();
        end
        
        function add_x_values(self, new_x_vector, add_to_end)
            % Add x_vector values to the left or right of the vector of
            % current values
            if ~exist('add_to_end','var')
                add_to_end = true;
            end
            
            old_x_vector = self.x_vector;
            self.x_vector = new_x_vector;
            self.calculate_pareto_all_setting_vals();
            
            if add_to_end
                self.x_vector = [old_x_vector new_x_vector];
            else
                self.x_vector = [new_x_vector old_x_vector];
            end
            
            self.save_y_vals();
        end
        
        function save_y_vals(self, fieldname, which_class)
            if ~exist('fieldname', 'var')
                fieldname = fieldnames(self.iterate_settings);
                fieldname = fieldname{1};
            end
            if ~exist('which_class','var')
                for i=1:length(self.fields_to_plot)
                    self.save_y_vals(fieldname, self.fields_to_plot{i});
                end
                return
            end
            
            sz = length(self.x_vector);
            line_names = self.make_valid_name(...
                self.iterate_settings.(fieldname));
            
            for i=1:length(line_names)
                this_line_name = line_names{i};
                y_vals = zeros(sz,1);
                these_obj = self.obj_struct.(this_line_name);
                for j=1:sz
                    y_vals(j) = self.y_val_func(these_obj{j}, which_class);
                end
                y_name = self.make_valid_name(this_line_name, which_class);
                if isfield(self.y_struct, y_name)
                    warning('Overwriting y values in field %s',...
                        y_name)
                end
                self.y_struct.(y_name) = y_vals;
            end
        end
        
        function save_simulation(self, setting_val, these_obj)
            % If it's not a field, create the field; otherwise, append
            fname = self.make_valid_name(setting_val);
            if ~isfield(self.obj_struct, fname)
                self.obj_struct.(fname) = these_obj;
            else
                self.obj_struct.(fname) = ...
                    [self.obj_struct.(fname) these_obj];
            end
        end
        
        function fname = make_valid_name(self, val1, val2)
            % Makes a valid name from inputs
            % Input:
            %   val1 - a valid input to the string() function or a cell
            %           array. If an array, then the return value is the
            %           same length
            %   val2 (optional) - Combines val2 to  
            if exist('val2','var')
                % Note: if it EXISTS
                if iscell(val2)
                    val2 = strjoin(val2,'_');
                end
                assert(ischar(val2),...
                    '2nd argument must be a cell or character array');
                if ischar(val1)
                    % Then the output is a single name
                    fname = self.make_valid_name([val1, '_', val2]);
                elseif iscell(val1)
                    % Then add val2 onto each of val1
                    fname = cell(length(val1),1);
                    for i=1:length(val1)
                        fname{i} = self.make_valid_name(...
                            val1{i}, val2);
                    end
                else
                    error('Unable to combine names')
                end
                return;
            end
            if iscell(val1)
                fname = cell(length(val1),1);
                for i=1:length(val1)
                    fname{i} = self.make_valid_name(val1{i});
                end
                return;
            end
            if ~isvarname(val1)
                % e.g. val1=0.5, output 'val0_5'
                fname = char(matlab.lang.makeValidName(...
                    "val" + string(val1) ));
            else
                fname = val1;
            end
        end
    end
    
    methods % Plotting
        function fig = plot_pareto_front(self, ...
                which_settings, to_contain_str, fig)
            % Plots a pareto front
            %   If to_contain_str, then which_settings is taken to be a
            %   substring that all relevant fields should contain, rather
            %   than the full field name
            if ~exist('to_contain_str','var')
                to_contain_str = false;
            end
            if ~exist('which_settings', 'var')
                which_settings = fieldnames(self.y_struct);
            elseif ~ismember(which_settings,fieldnames(self.y_struct))
                if ~to_contain_str
                    warning('Fieldname not found; assuming substring')
                end
                to_contain_str = true;
            end
            if ~exist('fig', 'var')
                fig = figure('DefaultAxesFontSize',14);
                hold on
            end
            
            if to_contain_str
                fnames = fieldnames(self.y_struct);
                which_settings = fnames(contains(fnames, which_settings));
            end
            
            for i=1:length(which_settings)
                this_field = which_settings{i};
                plot(self.x_vector, self.y_struct.(this_field),...
                    'LineWidth',2);
            end
            
            ylabel('Error')
            xlabel(self.x_fieldname, 'Interpreter', 'None')
            legend(which_settings, 'Interpreter', 'None')
        end
        
    end
    
    methods % Produce new y values
        function save_combined_y_val(self, fname1, fname2, ...
                weight1_over_2, non_neg)
%                 both_contain_str, one_contain_str)
            % Uses already saved y_vals
            %   Should have the same number of values saved
            %   Can combine different fields by a substring of their
            %   fieldname, use both_contain_str for substrings they should
            %   both contain and one_contain_str for strings only one
            %   should contain... TODO
            if ~exist('weight1_over_2','var')
                weight1_over_2 = 1;
            end
            if ~exist('non_neg','var')
                non_neg = true;
            end
            
            vec1 = self.y_struct.(fname1);
            vec2 = self.y_struct.(fname2);
            y_vals = self.combine_two_y_vals(vec1, vec2, ...
                weight1_over_2, non_neg);
            
            y_name = self.make_valid_name('combine_',...
                [fname1(1:10) '_' fname2(1:10)]);
            self.y_struct.(y_name) = y_vals;
        end
        
        function save_baseline(self, fname, baseline_func, line_name)
            % Uses baseline_func on the FIRST object saved in the
            % obj_struct under fname; assumes the value is the same for all
            % entries in the cell array
            if ~exist('line_name', 'var')
                line_name = self.make_valid_name('baseline_', fname);
            else
                line_name = self.make_valid_name('baseline_', line_name);
            end
            baseline_vals = ones(length(self.x_vector),1) * ...
                baseline_func(...
                self.obj_struct.(fname){1});
            if isfield(self.y_struct, line_name)
                warning('Overwriting line stored in %s', line_name)
            end
            self.y_struct.(line_name) = baseline_vals;
        end
    end
    
    methods (Hidden=true)
        function set_defaults(self)
            disp('Initializing Pareto Front Object...')
            
            defaults = struct(...
                'file_or_dat', 'no_file_stored',... % Can be cell array
                'base_settings', struct(),... % Not iterated
                'iterate_settings', struct(),... % Iterated over
                'x_vector', 0,...
                'x_fieldname', '_',...
                'y_val_func', @(obj, field) self.get_y_default(obj,field),...
                'fields_to_plot', {{'_'}},...
                'to_estimate_time', 1);
            for key = fieldnames(defaults).'
                k = key{1};
                self.(k) = defaults.(k);
            end
        end
    end
    
    methods (Static)
        function y = get_y_default(obj, field)
            if ischar(field)
                y = obj.(field);
            elseif iscell(field)
                if length(field)==1
                    y = obj.(field{1});
                elseif length(field)==2
                    y = obj.(field{1}).(field{2});
                else
                    error('Only 2 fieldnames supported')
                end
            else
                error('Unsupported field format')
            end
        end
        
        function y = combine_two_y_vals(vec1, vec2, ...
                weight1_over_2, non_neg)
            % Combines two different y values by whitening them and then
            % weighting (default is same weight to both)
            if ~exist('weight1_over_2','var')
                weight1_over_2 = 1;
            end
            if ~exist('non_neg','var')
                non_neg = true;
            end
            
            % Whiten
            vec1 = vec1 - mean(vec1);
            vec1 = vec1/std(vec1);
            vec2 = vec2 - mean(vec2);
            vec2 = vec2/std(vec2);
            
            % Combine
            y = vec1 + vec2/weight1_over_2;
            if non_neg
                y = y - min(y);
            end
            
        end
    end
    
end

