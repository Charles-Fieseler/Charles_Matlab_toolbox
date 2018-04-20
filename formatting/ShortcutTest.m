%% PROGRAM NAME
%PROGRAM DESCRIPTION
%
%
% INPUTS
%   INPUT1 - 
%   INPUT2 - 
%
% OUTPUTS - 
%   OUTPUT1 - 
%   OUTPUT2 - 
%
% EXAMPLES
%
%   EXAMPLE1
%
%
%   EXAMPLE2
%
%
%
% Dependencies
%   Other m-files required: (updated on 26-Oct-2016)
%                           C:\Users\charl\Documents\MATLAB\Celegans\James code\CEinfo\CEinfo.m
%                           C:\Users\charl\Documents\MATLAB\Celegans\Tests\fileCheck.m
%                            C:\Users\charl\Documents\MATLAB\Add-Ons\Toolboxes\Pack & Unpack variables to & from structures with enhanced functionality\code\v2struct.m
%
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
% Created: 14-Oct-2016


%========================================


%% SECTION 1
a=fileCheck('./','test.csv');
b=CEinfo(1);

%========================================


%% SECTION 2



%========================================


%% Private functions





% Automatically updates the dependencies of the file
%Searches the document for the for the string "other m-files required:" and
%   copies the full computer location of the user-authored files required

%Get the document object for the object being edited
docObj = matlab.desktop.editor.getActive;

%Search for position to write the dependencies
docStr = 'Other m-files required:';
docIndex = strfind(docObj.Text,docStr);

if ~isempty(docIndex)
    if length(docIndex)>1
        warning(sprintf('Found multiple instances of the string: "Other m-files required: "\nUsing first index location'));                                                                                                             
        docIndex = docIndex(1);
    end
    
    [docLine, docPos] = matlab.desktop.editor.indexToPositionInLine(docObj,docIndex);
    docPos = docPos + length(docStr); %We want to display the filenames after the colon!

    %Get string for dependencies
    docText = matlab.codetools.requiredFilesAndProducts(docObj.Filename);
    
    %Get rid of the filename itself
    docText = docText( cellfun(@(q) ~strcmp(q,docObj.Filename),docText) );
    
    %Add the date; first requires deleting the previous date (if any)
    dateIndex = matlab.desktop.editor.positionInLineToIndex(docObj,docLine,1);
    afterDateIndex = matlab.desktop.editor.positionInLineToIndex(docObj,docLine+1,1) - 1;
    docObj.Text(dateIndex:afterDateIndex-1) = repmat(' ',1,afterDateIndex-dateIndex);
    docDate = ['%   Other m-files required: (updated on ' date ')'];
    
    %If the new date is longer
    if afterDateIndex-1 < dateIndex+length(docDate)-1
        docObj.insertTextAtPositionInLine(repmat(' ',1,dateIndex+length(docDate)-afterDateIndex),...
            docLine,1);
    end
    
    docObj.Text(dateIndex:dateIndex+length(docDate)-1) = docDate;
    
    if length(docText)>0
        docObj.insertTextAtPositionInLine(sprintf('\n'),...
                    docLine+1,1);
        for j = 1:length(docText)
            thisFile = docText{j};
            
            %Search to see if we already have that filename
            %And put spaces on the next line
            if isempty( strfind(docObj.Text,thisFile) )
                docObj.insertTextAtPositionInLine(['%' repmat(' ',1,docPos) thisFile sprintf('\n')],...
                    docLine+j,1);
            end
        end
        docObj.insertTextAtPositionInLine('%',...
                    docLine+j+1,1);
    else
        fprintf('The file:\n %s\nhas no dependencies\n',docObj.Filename)
    end
else
    fprintf('Could not find the string: "Other m-files required: "\n')
end






%------------------------------
% SUBSECTION 
%------------------------------

%
        %: -
       %:    -
      %:
    %-
        %





