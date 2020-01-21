function [t1] = my_append(t1, t2)
% Appends a value t2 to t1 with safety for an empty t1; tries horzcat
% first, then vertcat if that fails
%   MATLAB can't do this easily!
if isempty(t1)
    t1 = t2;
else
    try 
        t1 = [t1 t2];
    catch
        try
            t1 = [t1; t2];
        catch
            error('Failed both Horizontal and Vertical concatenation')
        end
    end
end

end

