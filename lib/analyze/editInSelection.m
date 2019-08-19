%% Comments
%Function that update selection according to sequences selected in list of
%selection

%Associated GUI: SAPPIY
%Author: V. Doguet (21/2/2019)
%Updates:
%% Function
function editInSelection(s, e, handles)
%Retrieve handles
handles = guidata(handles.hObject);

%Change the current pulse if ticked
if ~isempty(e.Indices)
    %switch according to column being edited
    switch e.Indices(2)
        case 3  %This is for channel selection
            %Reset axis properties
            handles.localSettings.analyzeXLim = [];
            handles.localSettings.analyzeYLim = [];
            handles.edit.a_xMin.String = '';
            handles.edit.a_xMax.String = '';
            handles.edit.a_yMin.String = '';
            handles.edit.a_yMax.String = '';
            %Define which is the new channel
            newChan = find(strcmpi(handles.data.analyze.headers{handles.current.list(e.Indices(1))}, e.NewData));
            %Update list and item
            handles.current.list(handles.current.list(:, 1) == handles.current.list(e.Indices(1), 1), 2) = newChan;
            handles.current.item(2) = newChan;
            %Edit first line of current file in selection table and reset
            %current to empty entry (ony if its not first line)
            if isempty(s.Data{e.Indices(1), 1})
                %Update first line of current file
                firstLine = find(strcmpi(s.Data(1:e.Indices(1), 2), handles.fileList{handles.current.list(e.Indices(1), 1)}), 1, 'last');
                s.Data{firstLine, e.Indices(2)} = handles.data.analyze.headers{handles.current.list(e.Indices(1))}{newChan};
                %Reset current cell
                s.Data{e.Indices(1), e.Indices(2)} = [];
            end
        case 5  %This is for ttl selection
            %Update list items
            handles.current.list(e.Indices(1), end) = e.NewData;
            %Get all thicked ttls
            selection = find(handles.current.list(:, end));
            if ~isempty(selection)
                if handles.current.list(e.Indices(1), end) && isempty(handles.current.item)
                    handles.current.item = handles.current.list(e.Indices(1), 1:3);
                elseif ~handles.current.list(e.Indices(1), end) && isequal(handles.current.list(e.Indices(1), 1:3), handles.current.item(1:3))
                    handles.current.item = handles.current.list(selection(1), 1:3);
                end
            else
                handles.current.item = [];
            end
    end
    %Call update Fcn
    updateAnalyze(handles)
end
%Store GUI Data
guidata(handles.hObject, handles)
end