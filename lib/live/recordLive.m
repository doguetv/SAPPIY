%% Comments
%Rercord Live Fcn

%Associated GUI: SAPPIY
%Author: V. Doguet (21/2/2019)
%Updates:
%% Function
function recordLive(s, ~, handles)
%Retrieve handles
handles = guidata(handles.hObject);
%Change live axis title according to record statue
switch s.Value
    case 0
        [label, attributes] = getXML(handles.settings.xml.strings, 'Toggle', 'recordOff', {'color'});
        s.String = label;
        handles.axes.live.Title.String = '';
        s.BackgroundColor = eval(attributes{1});
    case 1
        [label, attributes] = getXML(handles.settings.xml.strings, 'Toggle', 'recordOn', {'color'});
        s.String = label;
        handles.axes.live.Title.String = label;
        s.BackgroundColor = eval(attributes{1});
        handles.axes.live.Title.Color = eval(attributes{1});
        %Store date time in session udata
        handles.live.variables.currentSession = datestr(now, 'ddmmyy_HHMMSS');
end
%Store GUI Data
guidata(handles.hObject, handles)
end