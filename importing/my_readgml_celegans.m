function [ full_graph ] = my_readgml_celegans( filename, index_name )
% Read a gml file into a containers.Map object
%   Map object will be indexed by the given field, 'index_name'

fid = fopen(filename);

% Make sure we're the right format
line1 = fgetl(fid);
assert(contains(line1, 'graph ['))
line2 = fgetl(fid);
assert(contains(line2, 'directed'))

KeyType = '';
full_graph = ''; %To be set once the keytype is known

while 1
    this_line = fgetl(fid);
    if contains(this_line, 'edge [')
        % Getting into edges (this only imports nodes
        break
    end
    
    this_node = struct();
    this_key = '';
    while 1
        % Parse a single node
        this_line = fgetl(fid);
        if contains(this_line, ']')
            % End of the node
            break
        end
        this_dat = strsplit(this_line);
        this_fieldname = this_dat{2};
        this_val = process_value(this_dat(3:end));
        if strcmp(this_fieldname, index_name)
            % Save this for the map key
            this_key = this_val;
            if isempty(KeyType)
                KeyType = class(this_key);
                full_graph = containers.Map('KeyType',KeyType,...
                    'ValueType','any');
            end
        else
            % Save as part of the data struct
            this_node.(this_fieldname) = this_val;
        end
    end
    
    assert(~isempty(this_key),'Key was empty')
    full_graph(this_key) = this_node;
end

    function dat = process_value(dat)
        if length(dat)==1
            dat = dat{1};
            if contains(dat, '"')
                dat = strip(dat, '"');
                dat = strip(dat, ',');
                % Turn e.g. VB8 into VB08
                pattern = '[A-Z]{2}\d{1}$';
                if ~isempty(regexp(dat,pattern, 'once'))
                    dat = [dat(1:2) '0' dat(end)];
                end
            else
                dat = str2double(dat);
            end
        elseif length(dat)==2
            all_dat = cell(length(dat),1);
            for j=1:length(dat)
                all_dat{j} = process_value(dat(j));
            end
            % Hard-coded hierarchy for C elegans:
            %   sensory>inter>motor
            if any(ismember(all_dat,'sensory'))
                dat = 'sensory';
            elseif any(ismember(all_dat,'inter'))
                dat = 'inter';
            else
                dat = 'motor';
            end
        else
            % Some are just long text descriptions
            dat = join(dat);
        end
    end

fclose(fid);

end

