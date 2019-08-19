%% Comments
%Functions that updates selection in selection panel

%Associated GUI: SAPPIY
%Author: V. Doguet (17/12/2018)
%Updates:
%20/03/2019 (by V. Doguet)
%Added channel scrolldown menu to select channel to focus on in signals
%% Function
function handles = updateSelectionTable(handles)

%Allocate
Data = cell(size(handles.current.list, 1), size(handles.current.list, 2)+1);
%Loop for all list
for i = 1:size(handles.current.list, 1)
    %Get ttl index
    indTTL = handles.current.list(i, 3);
    %If it is first ttl, store "delete" command, file label and channel
    %source
    if isequal(indTTL, 1)
        indFile = handles.current.list(i, 1);
        indChan = handles.current.list(i, 2);
        Data{i, 1} = '<html><table border=0 width=400><font color=red ></font><TR><TD><i><b>Delete</b></i></TD></TR> </table></html>';
        Data{i, 2} = handles.fileList{indFile};
        Data{i, 3} = handles.data.analyze.headers{indFile}{indChan};
    end
    %Store other properties in all cases
    Data{i, 4} = indTTL;
    Data{i, 5} = logical(handles.current.list(i, 3));
end

%Set Data in Table
handles.list.selection.ColumnName = {getXML(handles.settings.xml.strings, 'Table', 'delete'), ...
    getXML(handles.settings.xml.strings, 'Table', 'file'), ...
    getXML(handles.settings.xml.strings, 'Table', 'channel'), ...
    getXML(handles.settings.xml.strings, 'Table', 'sequence'), ...
    getXML(handles.settings.xml.strings, 'Table', 'selection')};
handles.list.selection.ColumnEditable = logical([false, false, true, false, true]);
chanList = handles.data.analyze.headers{indFile};
handles.list.selection.ColumnFormat = {'char', 'char', chanList, 'numeric', 'logical'};
handles.list.selection.Data = Data;

%Update sequencing source popup in analyze panel
handles.popup.a_sequencingSource.String = cat(2, {getXML(handles.settings.xml.strings, 'Label', 'relativeTime')}, handles.data.analyze.headers{indFile});
handles.popup.a_sequencingSource.Value = handles.data.analyze.xSource{handles.current.item(1)} + 1;

end
