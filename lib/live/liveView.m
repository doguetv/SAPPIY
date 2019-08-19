%% Comments
%Function that deal with live panel view

%Associated GUI: SAPPIY
%Author: V. Doguet (21/2/2019)
%Updates:
%% Function
function liveView(s, ~, handles)
%Retrieve handles
handles = guidata(handles.hObject);
%Display associated panel
for i = 1:length(handles.panel.livePanels)
    if strcmpi(handles.panel.livePanels{i}.Tag, s.String)
        set(handles.panel.livePanels{i}, 'Visible', 'on')
        indexPanel = i;
    else
        set(handles.panel.livePanels{i}, 'Visible', 'off')
    end
end
%Check some other options according to panel displayed
switch s.String
    %TTL Panel
    case getXML(handles.settings.xml.strings, 'Radio', 'ttl')
        %Set some properties
        analogDefined = false;
        if ~isempty(handles.table.AIChannels.Data)
            handles.popup.analogINChannel.String = handles.table.AIChannels.Data(:, 2);
            handles.popup.analogOUTChannel.String = handles.table.AIChannels.Data(:, 2);
            analogDefined = true;
        end
        %Enable/Disable AI Controls
        %Start desabling check box
        set(findobj(handles.panel.livePanels{indexPanel}, 'Tag', 'analogIN', 'Style', 'check'), 'Value', 0)
        set(findobj(handles.panel.livePanels{indexPanel}, 'Tag', 'manualIN', 'Style', 'check'), 'Value', 0)
        for i = 1:length(handles.live.session.Channels)
            if strcmpi(class(handles.live.session.Channels(i)), ['daq.', handles.live.session.Vendor.ID, '.AnalogInputVoltageChannel'])
                %Thick box according to default settings
                set(findobj(handles.panel.livePanels{indexPanel}, 'Tag', 'manualIN', 'Style', 'check'), 'Value', handles.settings.live.TTLChecks(1))
                set(findobj(handles.panel.livePanels{indexPanel}, 'Tag', 'analogIN', 'Style', 'check'), 'Value', handles.settings.live.TTLChecks(2))
                %Check box is thicked enable all subcontrols, only checkbox
                %if not
                if get(findobj(handles.panel.livePanels{indexPanel}, 'Tag', 'analogIN', 'Style', 'check'), 'Value')
                    set(findobj(handles.panel.livePanels{indexPanel}, 'Tag', 'analogIN'), 'Enable', 'on')
                else
                    set(findobj(handles.panel.livePanels{indexPanel}, 'Tag', 'manualIN', 'Style', 'check'), 'Enable', 'on')
                    set(findobj(handles.panel.livePanels{indexPanel}, 'Tag', 'analogIN', 'Style', 'check'), 'Enable', 'on')
                end
            end
        end
        %Enable/Disable DO Controls
        %Start desabling check box
        digitalOutputLabel = [];
        set(findobj(handles.panel.livePanels{indexPanel}, 'Tag', 'analogOUT', 'Style', 'check'), 'Value', 0)
        set(findobj(handles.panel.livePanels{indexPanel}, 'Tag', 'manualOUT', 'Style', 'check'), 'Value', 0)
        if ~isempty(handles.live.DOsession)
            for i = 1:length(handles.live.DOsession.Channels)
                if strcmpi(class(handles.live.DOsession.Channels(i)), ['daq.', handles.live.session.Vendor.ID, '.DigitalOutputChannel'])
                    %Thick box according to default settings
                    set(findobj(handles.panel.livePanels{indexPanel}, 'Tag', 'manualOUT', 'Style', 'check'), 'Value', handles.settings.live.TTLChecks(3))
                    %Check box is thicked enable all subcontrols, only checkbox
                    %if not
                    if get(findobj(handles.panel.livePanels{indexPanel}, 'Tag', 'manualOUT', 'Style', 'check'), 'Value')
                        set(findobj(handles.panel.livePanels{indexPanel}, 'Tag', 'manualOUT'), 'Enable', 'on')
                    else
                        set(findobj(handles.panel.livePanels{indexPanel}, 'Tag', 'manualOUT', 'Style', 'check'), 'Enable', 'on')
                    end
                    %Assign DO Port Label
                    digitalOutputLabel{length(digitalOutputLabel) + 1} = handles.live.DOsession.Channels(i).ID;
                    %Enable Analog OUT object only if some analog Chanels
                    %defined
                    if analogDefined
                        %Thick box according to default settings
                        set(findobj(handles.panel.livePanels{indexPanel}, 'Tag', 'analogOUT', 'Style', 'check'), 'Value', handles.settings.live.TTLChecks(4))
                        %Check box is thicked enable all subcontrols, only checkbox
                        %if not
                        if get(findobj(handles.panel.livePanels{indexPanel}, 'Tag', 'analogOUT', 'Style', 'check'), 'Value')
                            set(findobj(handles.panel.livePanels{indexPanel}, 'Tag', 'analogOUT'), 'Enable', 'on')
                        else
                            set(findobj(handles.panel.livePanels{indexPanel}, 'Tag', 'analogOUT', 'Style', 'check'), 'Enable', 'on')
                        end
                    end
                end
            end
        end
        %Edit sequencing direction & edge button values
        switch handles.settings.analyze.onset.direction
            case 1
                handles.button.sequencingOnsetDirection.String = '<-|';
            case 2
                handles.button.sequencingOnsetDirection.String = '|->';
        end
        switch handles.settings.analyze.offset.direction
            case 1
                handles.button.sequencingOffsetDirection.String = '<-|';
            case 2
                handles.button.sequencingOffsetDirection.String = '|->';
        end
        switch handles.settings.analyze.onset.edge
            case 1
                handles.button.sequencingOnsetEdge.String = '<';
            case 2
                handles.button.sequencingOnsetEdge.String = '>';
        end
        switch handles.settings.analyze.offset.edge
            case 1
                handles.button.sequencingOffsetEdge.String = '<';
            case 2
                handles.button.sequencingOffsetEdge.String = '>';
        end
        %Label pop up menus
        handles.popup.sequencingSource.String = cat(1, {getXML(handles.settings.xml.strings, 'Label', 'relativeTime')}, handles.table.AIChannels.Data(:, 2));
        if handles.settings.analyze.sequencingSource + 1 <= length(handles.popup.sequencingSource.String)
            handles.popup.sequencingSource.Value = handles.settings.analyze.sequencingSource + 1;
        else
            handles.popup.sequencingSource.Value = 1;
        end
        if ~isempty(digitalOutputLabel)
            handles.popup.manualOUTPort.String = digitalOutputLabel;
            handles.popup.analogOUTPort.String = digitalOutputLabel;
        end
        %Get userFcn for DOUT Fcn
        files = dir(fullfile(handles.userFcnPath, 'send_ttl', '*.m'));
        handles.popup.manualOUTFcn.String = {files.name};
        handles.popup.analogOUTFcn.String = {files.name};
end
%Store GUI Data
guidata(handles.hObject, handles)
end