%% Comments
%Play Live Fcn

%Associated GUI: SAPPIY
%Author: V. Doguet (21/2/2019)
%Updates:
%% Function
function playLive(s, ~, handles)
%Retrieve handles
handles = guidata(handles.hObject);
%Check whether user start or stop live player
switch s.Value
    case 0  %Stop
        if ~isempty(handles.live.session)
            if handles.live.session.IsRunning
                %Stop session
                stop(handles.live.session);
            end
            %Delete Listener
            delete(handles.live.listener);
            %Close log file
            fclose(handles.live.variables.fid);
            delete(handles.axes.live.Title)
            %Update uicontrol
            [label, attributes] = getXML(handles.settings.xml.strings, 'Toggle', 'playOff', {'color'});
            s.String = label;
            s.BackgroundColor = eval(attributes{1});
            %Check Hiding Fcn to enable flushing data%Check for control properties
            handles = checkHiding(handles);
            %Store GUI Data
            guidata(handles.hObject, handles)
        end
    case 1  %Start
        if ~isempty(handles.live.session)
            if ~handles.live.session.IsRunning
                %First clear data if finite acquisition
                if ~isempty(handles.settings.live.AcqTime)
                    for i = 1:length(handles.live.variables.lines)
                        handles.live.variables.lines{i}.XData = 0;
                        handles.live.variables.lines{i}.YData = 0;
                    end
                end
                %Open log file
                handles.live.variables.fid = fopen(fullfile(handles.resourcesPath, 'log.bin'), 'a');
                %Add listener
                handles.live.listener = addlistener(handles.live.session, 'DataAvailable', @(src, evt)getLiveData(src, evt, handles));
                %Make title visible (this is important to hold GUI
                %in live mode)
                if handles.button.recordLive.Value
                    [label, attributes] = getXML(handles.settings.xml.strings, 'Toggle', 'recordOn', {'color'});
                else
                    label = '';
                    attributes{1} = '[1, 1, 1]';
                end
                handles.axes.live.Title.String = label;
                handles.axes.live.Title.Color = eval(attributes{1});
                %Update uicontrol
                [label, attributes] = getXML(handles.settings.xml.strings, 'Toggle', 'playOn', {'color'});
                s.String = label;
                s.BackgroundColor = eval(attributes{1});
                %Start Session
                handles.live.session.startBackground;
                %Store GUI Data
                guidata(handles.hObject, handles)
                %Hold GUI while data is acquiring
                waitfor(handles.axes.live.Title)
            end
        end
end
end