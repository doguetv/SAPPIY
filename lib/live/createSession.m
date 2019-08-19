%% Comments
%Function that connects Daq

%Associated GUI: SAPPIY
%Author: V. Doguet (21/2/2019)
%Updates:
%% Function
function createSession(~, ~, handles)
%Retrieve handles
handles = guidata(handles.hObject);
%Make pointer busy
set(handles.hObject, 'Pointer', 'watch')
drawnow
%Check whether user try to connect or disconnect Daq
if ~isempty(handles.live.session) && isvalid(handles.live.session)
    %Reset GUI (only live section)
    handles = resetGUI(handles, 'live');
end
%Open Session Creator tool
[AIsession, DOsession] = createDaqSession;
if isempty(AIsession) || ~isvalid(AIsession)
    %Reset pointer
    set(handles.hObject, 'Pointer', 'arrow')
    return
end
%Assign sessions
handles.live.session = AIsession;
handles.live.DOsession = DOsession;
%Update session elements
handles = updateSessionElements(handles);
%Ask for saving session
answ = questdlg(getXML(handles.settings.xml.strings, 'Command', 'saveSession'), ...
    '', ...
    getXML(handles.settings.xml.strings, 'Command', 'yes'), ...
    getXML(handles.settings.xml.strings, 'Command', 'no'), ...
    getXML(handles.settings.xml.strings, 'Command', 'yes'));
switch answ
    case getXML(handles.settings.xml.strings, 'Command', 'yes')
        saveSessionFcn(handles.live.session, handles.live.DOsession, handles.live.variables, handles.settings);
end
%Reset pointer
set(handles.hObject, 'Pointer', 'arrow')
%Store GUI Data
guidata(handles.hObject, handles)
end