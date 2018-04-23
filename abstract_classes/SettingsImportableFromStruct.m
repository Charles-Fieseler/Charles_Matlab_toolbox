classdef settings_importable_from_struct < handle
    
    properties
        settings
    end
    
    methods
        %Constructor
        function self = settings_importable_from_struct()
            %             self.settings = settings;
        end
        
        function self = import_settings_to_self(self, newSettings)
            %import settings from a struct, overwriting a struct of defaults
            %   Used as a toolbox function in pretty much all of my functions
            %
            %   newSettings: should be passed in with fields to update, if any
            %
            %   self: set the default settings for that object
            
            if ~exist('newSettings','var')
                newSettings = struct;
            end
            if ~exist('self','var')
                error('Must pass a class or struct')
            end
            
            self.settings = newSettings;
            newNames = fieldnames(newSettings);
            
            for j = 1:length(newNames)
                n = newNames{j};
                
                if isprop(self, n)
                    self.check_types(self, newSettings, n);
                    
                    %Copy to the full object
                    self.(n) = newSettings.(n);
                else
                    warning('Setting "%s" not a property of the object.\n', n)
                end
            end %for
        end %func
        
    end
    
    methods
        function [allSettings, self] = ...
                import_settings(self, newSettings, allSettings )
            %import settings from a struct, overwriting a struct of defaults
            %   Used as a toolbox function in pretty much all of my functions
            %
            %   allSettings: should be passed in with defualt values for ALL fields of
            %                   interest
            %   newSettings: should be passed in with fields to update, if any
            %
            %   self: (Optional) additionally set the
            %               default settings for that object, if they are properties
            
            if ~exist('newSettings','var')
                newSettings = struct;
            end
            if ~exist('self','var')
                %So that isempty(self)==true
                self = struct([]);
            end
            
            namesS = fieldnames(newSettings);
            namesD = fieldnames(allSettings);
            
            for j = 1:length(namesS)
                n = namesS{j};
                
                if max(strcmp(n,namesD)) > 0 %Check to see if the given setting is used
                    self.check_types(newSettings, allSettings, n);
                    
                    allSettings.(n) = newSettings.(n);
                else
                    warning('Setting "%s" not used.\n', n)
                end
                %Copy to the full object whether updated or default
                if ~isempty(self) && isprop(self, n)
                    self.(n) = allSettings.(n);
                end
            end %for
        end %func
        
        function check_types(~, objA, objB, fieldName)
            %Do basic type checking for the field of the objects, if passed
            % This does NOT check for the same sizes in arrays
            if exist('fieldName','var')
                typeA = class(objA.(fieldName));
                typeB = class(objB.(fieldName));
            else
                typeA = class(objA);
                typeB = class(objB);
            end
            assert(isequal(typeA, typeB),...
                'Expected type %s for variable %s; found type %s',...
                typeB, fieldName, typeA)
        end
        
    end %methods
    
end

