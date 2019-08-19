%% Comments
%Function that update display according to sequence selected in list of
%results

%Associated GUI: SAPPIY
%Author: V. Doguet (21/2/2019)
%Updates:
%% Function
function selectInResults(s, e, handles)
%Retrieve handles
handles = guidata(handles.hObject);
%Chand selected items if second column is clicked
if ~isempty(e.Indices)
%If it is delete texte that is clicked, supress elements in result
%table.
    if any(strfind(s.Data{e.Indices(1), e.Indices(2)}, '<html>'))
        %Get all other elements to delete
        elementBlocks = strcmpi(s.Data(:, e.Indices(2)), '');
        b1 = e.Indices(1)+1;
        b2 = b1 + find(elementBlocks(b1:end) ~= 1, 1, 'first') - 2;
        %If it is empty its because its the end of table, so select last
        %element of table as bound #2
        if isempty(b2)
            b2 = size(s.Data, 1);
        end
        %Delete in table and results
        s.Data(e.Indices(1):b2, :) = [];
        handles.results(e.Indices(1):b2, :) = [];
        %Delete additional elements too
        handles.additionalElements(e.Indices(1):b2, :) = [];
        %If not, only update display according to clicked line
    end
    %Call update Fcn
    updateAnalyze(handles)
end
%Store GUI Data
guidata(handles.hObject, handles)
end