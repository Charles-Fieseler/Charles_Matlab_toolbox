function [] = update_dependencies()
%% Automatically updates the dependencies of the file
%Searches the document for the for the string: 
%   '.m files, .mat files, and MATLAB products required:'
% and copies the full computer location of the user-authored files required
%
% INPUTS: none
%
% OUTPUTS: dependencies (written in the file)
%
% EXAMPLES
%
%
% Dependencies
%   Other m-files required: 
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

%Search for position to write the dependencies
docStr = '.m files, .mat files, and MATLAB products required:';
docIndex = strfind(docObj.Text,docStr);

fprintf('Updating dependencies, may take several seconds.\n');
fprintf('Searching for the documentation string (%s)...\n',...
    docStr);

if ~isempty(docIndex)
    
    if length(docIndex)>1
        str = inputdlg( sprintf( ['Found multiple instances of: "' ...
            docStr '"\n'...
            'Do you want to continue with using first index location? Y/N [Y]:'] ) );
        if ~strcmp(str,'Y')
            fprintf('Aborting\n')
            return
        else
            docIndex = docIndex(1);
        end
    end
    
    [docLine, docPos] = matlab.desktop.editor.indexToPositionInLine(docObj,docIndex);
    myTab = repmat(' ',1,docPos+4); %Try to keep the same indentation
    %docPos = docPos + length(docStr); %We want to display the filenames after the colon!
    
    %Check to make sure the line we found is commented out
    stPos = matlab.desktop.editor.positionInLineToIndex(docObj,docLine,1);
    endPos = matlab.desktop.editor.positionInLineToIndex(docObj,docLine+1,1)-1;
    if ~contains(docObj.Text(stPos:endPos),'%')
        error('String found not on commented line')
    end

    %Get string for dependencies
    %   First is m files, second is for MATLAB products
    fprintf('Getting dependencies...\n');
    [docFiles, docProd] = ...
        matlab.codetools.requiredFilesAndProducts(docObj.Filename);
    
    %Get rid of the filename itself
    docFiles = docFiles( cellfun(@(q) ~strcmp(q,docObj.Filename),docFiles) );
    %Also get rid of the file if it's already in the document
    docFiles = docFiles( cellfun(@(q) isempty(strfind(docObj.Text,q)), docFiles) );
    %Only care about the filename itself
    for j=1:length(docFiles)
        tmp = docFiles{j};
        slashes = strfind(tmp,filesep);
        docFiles{j} = tmp(slashes(end)+1:end);
    end
    
    %Add the date; first requires deleting the previous date (if any)
    dateIndex = matlab.desktop.editor.positionInLineToIndex(docObj,docLine,1);
    afterDateIndex = matlab.desktop.editor.positionInLineToIndex(docObj,docLine+1,1) - 1;
    docObj.Text(dateIndex:afterDateIndex-1) = repmat(' ',1,afterDateIndex-dateIndex);
    docDate = ['%   ' docStr '(updated on ' date ')'];
    
    %If the new date is longer
    if afterDateIndex-1 < dateIndex+length(docDate)-1
        docObj.insertTextAtPositionInLine(repmat(' ',1,dateIndex+length(docDate)-afterDateIndex),...
            docLine,1);
    end
    
    docObj.Text(dateIndex:dateIndex+length(docDate)-1) = docDate;
    
    %Print the m files
    if length(docFiles)>0
        docObj.insertTextAtPositionInLine(sprintf('\n'),...
                    docLine+1,1);
        for j = 1:length(docFiles)
            thisFile = docFiles{j};
            
            %And put spaces on the next line
            if j<length(docFiles)
                docObj.insertTextAtPositionInLine(['%' myTab thisFile sprintf('\n')],...
                docLine+j,1);
            else
                docObj.insertTextAtPositionInLine(['%' myTab thisFile],...
                docLine+j,1);
            end
        end
    else
        fprintf('The file:\n %s\nhas no new dependencies\n',docObj.Filename)
    end
    %Print the MATLAB products
    if length(docProd)>0
        docObj.insertTextAtPositionInLine(sprintf('\n'),...
                    docLine+1,1);
        for j = 1:length(docProd)
            thisStr = ...
                sprintf('%s (version %s)',...
                docProd(j).Name,docProd(j).Version);
            
            %And put spaces on the next line
            if j<length(docProd)
                docObj.insertTextAtPositionInLine(['%' myTab thisStr sprintf('\n')],...
                docLine+j,1);
            else
                docObj.insertTextAtPositionInLine(['%' myTab thisStr],...
                docLine+j,1);
            end
        end
    else
        fprintf('The file:\n %s\nhas no new dependencies\n',docObj.Filename)
    end
else
    error('Could not find the string:,%s\n', docStr)
end

fprintf('Finished updating depedencies. Use ctr-I to fix indentation.\n');

end