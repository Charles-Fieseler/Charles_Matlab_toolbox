function [ ] = add_sub_section(varargin)
%% Adds a sub section
%
% INPUTS - name of section, if desired
%
% OUTPUTS - text in the active file
%
%
% Dependencies
%   Other m-files required: (updated on 21-Oct-2016)
%   Subfunctions: 
%   MAT-files required: 
%
%   See also: OTHER_FUNCTION_NAME
%
%
%
% Author: Charles Fieseler
% University of Washington, Dept. of Physics
% Email address: charles.fieseler@gmail.com
% Website: coming soon
% Created: 17-Oct-2016


%========================================

% Shortcut to add a subsection header


%Get the document object for the object being edited
docObj = matlab.desktop.editor.getActive;

%Get cursor position (line number and position index)
docLine = docObj.Selection(1);
docInd  = docObj.Selection(2);

newline = sprintf('\n');

if ~isempty(varargin)
    %use the given input as a section title
    docSecName = varargin{1};
elseif ~isempty(docObj.SelectedText)
    %Check to see if any text is highlighted
    docSecName = docObj.SelectedText;
    docLine = docObj.Selection(3);
    docInd = docObj.Selection(4);
else
    %Set default subsection name
    docSecName = 'SUBSECTION';
end

%Insert program description
docText = {...
    ['%---------------------------------------------' newline],...
    ['% ' docSecName newline],...
    ['%---------------------------------------------' newline],...
    [newline],...
    [newline],...
    [newline],...
    [newline]};


% Actually insert the text
for j = 1:length(docText)
    docObj.insertTextAtPositionInLine(docText{j},...
        docLine+j-1,docInd);
end

end

