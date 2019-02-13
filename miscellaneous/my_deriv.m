function [dxdt_raw] = my_deriv(dat, deriv_mode)
% Takes derivatives in various ways
% 
% Input:
%   dat - takes derivatives along the row
%   deriv_mode - So far, only 'spline' is implemented
if ~exist('deriv_mode', 'var')
    deriv_mode = 'spline';
end

sz = size(dat);
x = 1:sz(2);
dxdt_raw = zeros(sz);

if strcmpi(deriv_mode, 'spline')
    disp('Taking derivatives using splines...')
    for i = 1:sz(1)
        spl = spline(x, dat(i,:));
        c = spl.coefs;
        spl.coefs = [3*c(:,1) 2*c(:,2) c(:,3)];
        spl.order = 3;
        dxdt_raw(i,:) = ppval(x, spl);
    end
end
end

