classdef abstractDMD < settings_importable_from_struct
    % Abstract DMD class; do not call directly!
    %
    % INPUTS
    %   INPUT1 -
    %   INPUT2 -
    %
    % OUTPUTS -
    %   OUTPUT1 -
    %   OUTPUT2 -
    %
    %
    % Dependencies
    %   Other m-files required: (updated on 29-Nov-2017)
    %             MATLAB (version 9.2)
    %             v2struct.m
    %
    %   See also: OTHER_FUNCTION_NAME
    %
    %
    %
    % Author: Charles Fieseler
    % University of Washington, Dept. of Physics
    % Email address: charles.fieseler@gmail.com
    % Website: coming soon
    % Created: 29-Nov-2017
    %========================================
    
    properties (Hidden=true)
        raw
        dat
        verbose
        modelOrder
        augmentData
        sz
        t0EachBin %Restart the dmd modes at t=0 at each bin
        tspan
        
        approx_all
        
        %For the DMDplotter object
        plotterSet
        %Imported
        filename
        original_sz
        %User processing settings
        dt
        toSubtractMean
        dmdPercent
        %Plotter dictionary, if option is used
        DMDplotter_all
    end
    
    methods
        
        function self = abstractDMD(subclassSetNames, settings)
            %% Initialize with defaults
            defaults = struct; %The default values
            defaults.verbose = true;
            defaults.dt = 1;
            defaults.dmdPercent = 0.95;
            defaults.modelOrder = -1;
            defaults.toSubtractMean = false;
            defaults.plotterSet = struct();
            defaults.augmentData = 0;
            defaults.t0EachBin = true;
            
            if ~exist('settings','var')
                settings = struct;
            end
            if ~exist('subclassSetNames','var')
                subclassSetNames = {''};
            end
            
            namesS = fieldnames(settings);
            namesD = fieldnames(defaults);
            
            for j = 1:length(namesS)
                n = namesS{j};
                
                if ismember(n, namesD)
                    defaults.(n) = settings.(n);
                elseif ~ismember(n, subclassSetNames)
                    fprintf('Warning: "%s" setting not used\n',n)
                end
            end
            
            [self.verbose, self.dt,...
                self.dmdPercent, self.modelOrder, self.toSubtractMean,...
                self.plotterSet, ...
                self.augmentData, self.t0EachBin] ...
                = v2struct(defaults); %Unpacks the struct into variables
            
            %Make sure the settings are the same for the plotter objects
            self.plotterSet.dt = self.dt;
            %             self.plotterSet.toSubtractMean = self.toSubtractMean;
            %             self.plotterSet.dmdPercent = self.dmdPercent;
            %             self.plotterSet.modelOrder = self.modelOrder;
            
            % Initialize the DMD object containers
            self.DMDplotter_all = containers.Map();
            self.approx_all = containers.Map();
            %==========================================================================
            
            
        end
        
        
    end
    
    methods (Access=public)
        %Functions for accessing containers
        function key = vec2key(~, vec)
            %Returns the key value corresponding to the vector of format:
            %   vec(1:2) = (layer, time bin index)
            key = num2str(vec);
        end
        
        function vec = key2vec(~, key)
            %Returns the vector corresponding to the key value of format:
            %   vec(1:2) = (layer, time bin index)
            vec = str2num(key); %#ok<ST2NM>
        end
        
        %Data processing
        function preprocess(self)
            if self.verbose
                disp('Preprocessing...')
            end
            self.sz = size(self.raw);
            
            %If augmenting, stack data offset by 1 column on top of itself;
            %note that this decreases the overall number of columns (time
            %slices)
            aug = self.augmentData;
            self.original_sz = self.sz;
            if aug>0
                newSz = [self.sz(1)*aug, self.sz(2)-aug];
                newDat = zeros(newSz);
                for j=1:aug
                    thisOldCols = j:(newSz(2)+j-1);
                    thisNewRows = (1:self.sz(1))+self.sz(1)*(j-1);
                    newDat(thisNewRows,:) = self.raw(:,thisOldCols);
                end
                self.sz = newSz;
                self.raw = newDat;
            end
            
            self.dat = self.raw;
            if self.toSubtractMean
                for jM=1:self.sz(1)
                    self.dat(jM,:) = self.raw(jM,:) - mean(self.raw(jM,:));
                end
            end
        end
        
    end
    
end

