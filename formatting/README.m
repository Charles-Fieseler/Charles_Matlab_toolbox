%README for shortcut functions
%
% This is the Mathworks help page for creating your own shortcuts:
%   https://www.mathworks.com/help/matlab/matlab_env/create-matlab-shortcuts-to-rerun-commands.html?searchHighlight=shortcut
% 
% Each of these functions is documented internally, but in general they all
% add text to the active editor window, between 5 and 15 lines of comments
% or newlines. 
% 
% Note: the update_dependencies function searches for a specific string and
% inserts program dependencies, so it doesn't work if it can't find the
% string. In order to keep the date accurate it deletes the previous date;
% if the only copy of that same string is somewhere else in the code then
% unexpected behavior could result.