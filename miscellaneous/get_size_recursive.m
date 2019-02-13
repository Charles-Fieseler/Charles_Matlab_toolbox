function [ bytes ] = get_size_recursive( var, verbose )
% Non-recursive version from: 
% https://www.mathworks.com/matlabcentral/answers/14837-how-to-get-size-of-an-object
% Input:
%   var - a variable or object to find the size of
%   verbose (2) - level of verbosity:
%                 0 = displays nothing
%                 1 = displays some warnings about unreadable properties
%                 2 = displays info on subcomponents
%                 3 = [same as 2 and 1 above
if ~exist('verbose','var')
    verbose = 2;
end
bytes = 0;
warning off 'MATLAB:structOnObject'
if iscell(var)
    if (verbose==2)||(verbose==3)
        fprintf('  ')
    end
    for i=1:length(var)
        bytes = bytes + get_size_recursive(var{i}, verbose);
    end
    if ((verbose==2)||(verbose==3))&&bytes>0
        fprintf('Size of this cell array (length=%d) is %d\n',...
            length(var), bytes)
    end
elseif isstruct(var) || isobject(var)
    props = fieldnames(struct(var));
    if isobject(var)
        % Note: this will only skip non-private dependent properties
        dependent_props = findAttrValue(var,'Dependent');
    else
        dependent_props = [];
    end
    if ((verbose==2)||(verbose==3))&&bytes>0
        fprintf('  ')
    end
    for ii=1:length(props)
        if ismember(char(props(ii)), dependent_props)
            continue
        end
        try
            currentProp = var.(char(props(ii)));
            bytes = bytes + get_size_recursive(currentProp, verbose);
        catch
            if (verbose==1)||(verbose==3)
                fprintf('Treating inaccessible property %s as empty\n',...
                    char(props(ii)))
            end
        end
    end
    if ((verbose==2)||(verbose==3))&&bytes>0
        fprintf('Size of this %s is %d\n',...
            class(var), bytes)
    end
else
    bytes = whos(varname(var)); 
    bytes = bytes.bytes;
end

warning on 'MATLAB:structOnObject'

function [ name ] = varname( ~ )
    name = inputname(1);
end

end