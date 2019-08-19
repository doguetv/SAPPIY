%% Comments
%Callback function associated to save current session menu 

%Associated GUI: SAPPIY
%Author: V. Doguet (26/2/2019)
%Updates:
%% Function
function saveSession(~, ~, handles)
%Retrieve handles
handles = guidata(handles.hObject);
%Call external function
if isempty(handles.live.session) ||  ~isvalid(handles.live.session)
    errordlg(getXML(handles.settings.xml.strings, 'Error', 'noSession'))
    return
end
saveSessionFcn(handles.live.session, handles.live.DOsession, handles.live.variables, handles.settings);
%Store GUI Data
guidata(handles.hObject, handles)
end