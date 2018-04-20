function [] = add_section(varargin)
% Shortcut to add a new section
%
% INPUTS - name of section, if desired
%
% OUTPUTS - Section text in the current active file
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

%Get the document object for the object being edited
docObj = matlab.desktop.editor.getActive;

%Get cursor position (line number and position index)
docLine = docObj.Selection(1);
docInd  = docObj.Selection(2);

newline = sprintf('\n');

if isempty(varargin)
    %Get the number of sections already present
    docSecName = num2str( max(length(strfind(docObj.Text,'%%'))-1,1) );
else
    %Otherwise use the given input as a section title
    docSecName = varargin{1};
end

%Insert program description
docText = {...
    [newline],...
    [newline],...
    ['%% SECTION ' docSecName newline],...
    [newline],...
    [newline],...
    [newline],...
    [newline],...
    [newline],...
    [newline],...
    ['%==========================================================================' newline],...
    [newline],...
    [newline]};


% Actually insert the text
for j = 1:length(docText)
    docObj.insertTextAtPositionInLine(docText{j},...
        docLine+j-1,docInd);
end

end