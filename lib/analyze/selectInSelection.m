%% Comments
%Function that update selection according to sequences selected in list of
%selection

%Associated GUI: SAPPIY
%Author: V. Doguet (21/2/2019)
%Updates:
%% Function
function selectInSelection(s, e, handles)
%Only react if not in check column
if ~isempty(e.Indices) && e.Indices(2) ~= 3 && e.Indices(2) ~= 5
    %Retrieve handles
    handles = guidata(handles.hObject);
    switch e.Indices(2)
        case 1  %Delete file
            if any(strfind(s.Data{e.Indices(1), e.Indices(2)}, '<html>'))
                %Ask to delete file
                answ = questdlg(getXML(handles.settings.xml.strings, 'Command', 'supressFile'), ...
                    '', ...
                    getXML(handles.settings.xml.strings, 'Command', 'yes'), ...
                    getXML(handles.settings.xml.strings, 'Command', 'no'), ...
                    getXML(handles.settings.xml.strings, 'Command', 'yes'));
                switch answ
                    case getXML(handles.settings.xml.strings, 'Command', 'yes')
                        %Remove elements
                        handles = removeFile(handles, handles.current.list(e.Indices(1), 1));
                end
            end
        case 2
            %Update current item (only if thicked (column 4 in table)
            if s.Data{e.Indices(1), end}
                handles.current.item(1) = find(strcmpi(handles.fileList, s.Data{find(cell2mat(s.Data(1:e.Indices(1), 4)) == 1, 1, 'last'), 2}));
                listString = s.ColumnFormat{3};
                for i = 1:length(listString)
                    if strcmpi(listString{i}, s.Data{find(cell2mat(s.Data(1:e.Indices(1), 4)) == 1, 1, 'last'), 3})
                        handles.current.item(2) = i;
                    end
                end
                handles.current.item(3) = s.Data{e.Indices(1), 4};
            end
        case 4
            %Update current item (only if thicked (last column in table)
            if s.Data{e.Indices(1), end}
                handles.current.item(1) = find(strcmpi(handles.fileList, s.Data{find(cell2mat(s.Data(1:e.Indices(1), 4)) == 1, 1, 'last'), 2}));
                listString = s.ColumnFormat{3};
                for i = 1:length(listString)
                    if strcmpi(listString{i}, s.Data{find(cell2mat(s.Data(1:e.Indices(1), 4)) == 1, 1, 'last'), 3})
                        handles.current.item(2) = i;
                    end
                end
                handles.current.item(3) = s.Data{e.Indices(1), 4};
            end
    end
    %Update sequencing source popup in analyze panel
    if ~isempty(handles.data.analyze.xSource)
        handles.popup.a_sequencingSource.Value = handles.data.analyze.xSource{handles.current.item(1)} + 1;
    end
    %Check hiddngs
    handles = checkHiding(handles);
    %Call update Fcn
    updateAnalyze(handles)
    %Store GUI Data
    guidata(handles.hObject, handles)
end
end
%% Subfunction
function handles = removeFile(handles, index)
%Get some indexes
indexesToDelete = handles.current.list(:, 1) == index;
indexesToReset = handles.current.list(:, 1) > index;
%Remove some fields in handles
handles.fileList(index) = [];
handles.fileType(index) = [];
fnames = fieldnames(handles.data.analyze);
for i = 1:length(fnames)
    if ~isempty(handles.data.analyze.(fnames{i}))
        handles.data.analyze.(fnames{i})(index) = [];
    end
end
%Delete data in table
handles.list.selection.Data(indexesToDelete, :) = [];
%Finally reset current fields
handles.current.list(indexesToReset, 1) = handles.current.list(indexesToReset, 1) - 1;
handles.current.list(indexesToDelete, :) = [];
handles.current.item = handles.current.list(find(cell2mat(handles.list.selection.Data(:, end)) == 1, 1, 'first'), :);
end