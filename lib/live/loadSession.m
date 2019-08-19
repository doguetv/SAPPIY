%% Comments
%Function that loads existent session file

%Associated GUI: SAPPIY
%Author: V. Doguet (26/2/2019)
%Updates:
%% Function
function loadSession(~, ~, handles)
%Retrieve handles
handles = guidata(handles.hObject);
%Make pointer busy
set(handles.hObject, 'Pointer', 'watch')
drawnow
%Pick a session file
[f, p] = uigetfile('.mat', 'Pick a Session File');
if isequal(f, 0) || isequal(p, 0)
    %Reset pointer
    set(handles.hObject, 'Pointer', 'arrow')
    return
end
%Call resut GUI live section first
handles = resetGUI(handles, 'live');
%Load file
temp = load([p, f]);
%Verify that's a session file
if ~isfield(temp, 'AIStruct')
    errordlg(getXML(handles.settings.xml.string, 'Error', 'invalidFile'))
    %Reset pointer
    set(handles.hObject, 'Pointer', 'arrow')
    return
end
%% AI Session
AIsession = daq.createSession(temp.AIStruct.vendorID);
AIsession.IsContinuous = temp.AIStruct.IsContinuous;
AIsession.Rate = temp.AIStruct.Rate;
AIsession.NotifyWhenDataAvailableExceeds = temp.AIStruct.NotifyWhenDataAvailableExceeds;
%AI Channels
AIchannels = addAnalogInputChannel(AIsession, temp.AIStruct.deviceID, temp.AIStruct.channelsID, temp.AIStruct.MeasurementType);
for i = 1:length(AIchannels)
    AIchannels(i).TerminalConfig = temp.AIStruct.TerminalConfig;
    AIchannels(i).Range = [-temp.AIStruct.Range, temp.AIStruct.Range];
end
%live Variables
if isfield(temp, 'liveVariablesStruct')
    handles.live.variables = temp.liveVariablesStruct;
end
%Triggers Connection
if isfield(temp.AIStruct, 'Connections')
    addTriggerConnection(AIsession, temp.AIStruct.Connections.Source, temp.AIStruct.Connections.Destination, 'StartTrigger');
end
%Assign to handles
handles.live.session = AIsession;
%% DO session
if ~isempty(temp.DOStruct)
    DOsession = daq.createSession(temp.DOStruct.vendorID);
    addDigitalChannel(DOsession, temp.DOStruct.deviceID, temp.DOStruct.channelsID, temp.DOStruct.MeasurementType);
else
    DOsession = [];
end
%Assign to handles
handles.live.DOsession = DOsession;
%% Default live settings
handles.settings.live = temp.defSettings.live;
%% Finalize
%Set TTL settings accordingly
handles = resetTTLSettings(handles);
%Set session elements accordingly
handles = updateSessionElements(handles);
%Set axis properties
handles = setAcqWindowProperties(handles);
%Check elements to hide
handles = checkHiding(handles);
%Reset pointer
set(handles.hObject, 'Pointer', 'arrow')
%Store GUI Data
guidata(handles.hObject, handles)
end