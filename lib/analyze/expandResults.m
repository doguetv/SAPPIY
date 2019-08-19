%% Comments
%Function that expand results panel

%Associated GUI: SAPPIY
%Author: V. Doguet (21/2/2019)
%Updates:
%% Function
function expandResults(s, ~, handles)
%Retrieve handles
handles = guidata(handles.hObject);
%Get the menu state to know whether enable or disable live mode
switch s.String
    case getXML(handles.settings.xml.strings, 'Button', 'rightCursor')  %Expand
        %Resize panels
        handles.panel.results.Position = [0, handles.panel.results.Position(2), .9, handles.panel.results.Position(4)];
        handles.panel.analyzeDisplay.Position = [handles.panel.analyzeDisplay.Position(1), handles.panel.results.Position(4), handles.panel.analyzeDisplay.Position(3), .95-handles.panel.results.Position(4)];
        %Edit menu label
        set(s, 'String', getXML(handles.settings.xml.strings, 'Button', 'leftCursor'))
    case getXML(handles.settings.xml.strings, 'Button', 'leftCursor')  %Disabled
        %Resize panels
        handles.panel.results.Position = [0, handles.panel.results.Position(2), .3, handles.panel.results.Position(4)];
        handles.panel.analyzeDisplay.Position = [handles.panel.analyzeDisplay.Position(1), 0, handles.panel.analyzeDisplay.Position(3), .95];
        %Edit menu label
        set(s, 'String', getXML(handles.settings.xml.strings, 'Button', 'rightCursor'))
end
%Store GUI Data
guidata(handles.hObject, handles)
end