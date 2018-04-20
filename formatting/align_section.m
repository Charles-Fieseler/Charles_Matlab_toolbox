function [ ] = align_section( varargin )
% This function aligns all instances of the given character within a
% highlighted section of text
%
% INPUTS - a string to search for (defaults implemented)
%
% OUTPUTS - adds space to the active file to align all instances of the
%       search string
%
%
% Dependencies
%   Other m-files required:
%   Subfunctions:
%   MAT-files required:
%
%
% Author: Charles Fieseler
% University of Washington, Dept. of Physics
% Email address: charles.fieseler@gmail.com
% Website: coming soon
% Created: 25-Oct-2016

%========================================

if ~isempty(varargin)
    searchStr = varargin{1};
    if ~ischar(searchStr)
        error('Input should be a string')
    end
else
    searchStr = '=';
end

%Get the document object for the object being edited
docObj = matlab.desktop.editor.getActive;
selText = docObj.SelectedText;

if isempty(selText)
    error('No text highlighted')
end

%Search for ALL instances of searchStr
allInd = strfind(docObj.Text,searchStr);

%Define the beginning and end of what we want
indStart = matlab.desktop.editor.positionInLineToIndex(...
    docObj,docObj.Selection(1),docObj.Selection(2));
indEnd = matlab.desktop.editor.positionInLineToIndex(...
    docObj,docObj.Selection(3),docObj.Selection(4));

%Throw out the indices we don't want
wantInd = allInd( find((allInd>=indStart).*(allInd<=indEnd)) ); %#ok<FNDSB>

%Translate to indices, and save the maximum position
for j = 1:length(wantInd)
    [wantLine(j), wantPos(j)] = ...
        matlab.desktop.editor.indexToPositionInLine(docObj,wantInd(j)); %#ok<AGROW>
end

maxPos = max(wantPos);
prevLine = 0;
thisLine = 0;

for j = 1:length(wantLine)
    %We only want the first instance on the line, so if we're the same as
    %before, just go to the next in the list
    thisLine = wantLine(j);
    if prevLine ~= thisLine
        docObj.insertTextAtPositionInLine(...
            repmat(' ',1,maxPos-wantPos(j)), thisLine, wantPos(j) );
        prevLine = thisLine;
    end
end


end

