%% Comments
%Import Files Fcn

%Associated GUI: SAPPIY
%Author: V. Doguet (21/2/2019)
%Updates:
%% Function
function importFcn(~, ~, handles)
%Retrieve handles
handles = guidata(handles.hObject);
%Call external function that import file(s)
try
    handles = importFiles(handles);
catch exception
    msgText = getReport(exception);
    errordlg(msgText)
    return
end
%Return in file list empty (import function failed)
if isempty(handles.fileList)
    return
end
%Call external functions to update controls according to the
%new imported file(s)
checkHiding(handles);
handles = updateSelectionTable(handles);
updateAnalyze(handles);
%Call view function if analyze view is not visible
if ~handles.view(2)
    source.Text = getXML(handles.settings.xml.strings, 'Menu', 'analyze');
    source.Label = getXML(handles.settings.xml.strings, 'Menu', 'analyze');
    setViewFcn(source, '', handles)
    handles.view(2) = true;
end
%Store GUI Data
guidata(handles.hObject, handles)
end