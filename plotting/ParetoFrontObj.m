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
            
            t_start = tic;
            for i=1:length(self.x_vector)
                this_x = self.x_vector(i);
                settings.(self.x_fieldname) = this_x;
                
                these_obj{i} = ...
                    self.iterable_func(self.file_or_dat, settings);
                
                if i == self.to_estimate_time
                    t = toc(t_start);
                    average_t = (t-t_start)/self.to_estimate_time;
                    estimated_end = average_t * (length(self.x_vector)-i);
                    fprintf('Average time over %d runs: %f\n',...
                        i, average_t)
                    fprintf('Estimated time left: %f\n', estimated_end)
                end
            end
            
            t = toc(t_start);
            fprintf('Total time over %d runs: %f\n', i, t-t_start)
            
            if ~isfield(self.obj_struct,setting_val)
                self.obj_struct.(setting_val) = these_obj;
            else
                self.obj_struct.(setting_val) = ...
                    [self.obj_struct.(setting_val) these_obj];
            end
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
                which_class = self.fields_to_plot{1};
            end
            
            sz = length(self.x_vector);
            line_names = self.iterate_settings.(fieldname);
            for i=1:length(line_names)
                this_line_name = line_names{i};
                y_vals = zeros(sz,1);
                these_obj = self.obj_struct.(this_line_name);
                for j=1:sz
                    y_vals(j) = self.y_val_func(these_obj{j}, which_class);
                end
                self.y_struct.(this_line_name) = y_vals;
            end
        end
    end
    
    methods % Plotting
        function fig = plot_pareto_front(self, which_settings, fig)
            if ~exist('which_settings', 'var')
                which_settings = fieldnames(self.y_struct);
            end
            if ~exist('fig', 'var')
                fig = figure('DefaultAxesFontSize',14);
                hold on
            end
            
            for i=1:length(which_settings)
                this_field = which_settings{i};
                plot(self.x_vector, self.y_struct.(this_field),...
                    'LineWidth',2);
            end
            
            ylabel('Error')
            xlabel(self.x_fieldname)
            legend(which_settings)
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
                assert(length(field)==2,... 
                    'Only 2 fieldnames supported')
                y = obj.(field{1}).(field{2});
            else
                error('Unsupported field format')
            end
        end
    end
    
end

