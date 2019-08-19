%% Comments
%Function that rearrange controls in figure to display live mode controls
%and display

%Associated GUI: SAPPIY
%Author: V. Doguet (21/2/2019)
%Updates:
%% Function
function setViewFcn(s, ~, handles)
%Retrieve handles
handles = guidata(handles.hObject);
%Get the menu state to know whether enable or disable live mode
switch s.Label
    case getXML(handles.settings.xml.strings, 'Menu', 'live')  %Enabled
        %Change view statue
        handles.view(1) = ~handles.view(1);
        %Make it visible or not
        if handles.view(1)
            handles.panel.live.Visible = 'on';
        else
            handles.panel.live.Visible = 'off';
        end
        if handles.view(1) && handles.view(2)
            %Resize panels
            handles.panel.live.Position = [0, .5, 1, .5];
            handles.panel.analyze.Position = [0, 0, 1, .5];
        else
            handles.panel.live.Position = [0, 0, 1, 1];
            handles.panel.analyze.Position = [0, 0, 1, 1];
        end
    case getXML(handles.settings.xml.strings, 'Menu', 'analyze')  %Disabled
        %Change view statue
        handles.view(2) = ~handles.view(2);
        %Make it visible or not
        if handles.view(2)
            handles.panel.analyze.Visible = 'on';
        else
            handles.panel.analyze.Visible = 'off';
        end
        if handles.view(1) && handles.view(2)
            %Resize panels
            handles.panel.live.Position = [0, .5, 1, .5];
            handles.panel.analyze.Position = [0, 0, 1, .5];
        else
            handles.panel.live.Position = [0, 0, 1, 1];
            handles.panel.analyze.Position = [0, 0, 1, 1];
        end
end
%Store GUI Data
guidata(handles.hObject, handles)
end