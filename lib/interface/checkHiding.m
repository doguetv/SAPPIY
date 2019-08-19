%% Comments
%Function that checks whether controls should be showed/hidden or enabled/disabled

%Associated GUI: SAPPIY
%Author: V. Doguet (21/2/2019)
%Updates:
%% Function
function handles = checkHiding(handles)
%Check whether there are data to display in analyze
if isempty(handles.data.analyze.signals) && isempty(handles.data.analyze.pulses)
    state = 'off';
else
    state = 'on';
end
children = get(handles.panel.analyze, 'Children');
for i = 1:length(children)
    %Skip axis panel to enable editing window sequences
    if strcmpi(children(i).Type, 'uipanel')
        for j = 1:length(children(i).Children)
            try
                set(children(i).Children(j), 'Enable', state)
            catch
            end
        end
    end
end
%Disable/Hide some controls in analyze panel if current file comes from live
%mode
if ~isempty(handles.fileType) && ~isempty(handles.current.item)
    if strcmpi(handles.fileType{handles.current.item(1)}, 'live')
        %Disable sequencing option panel
        children = get(handles.panel.analyzeSequenceOptions, 'Children');
        set(children, 'Enable', 'off')
    else
        %Enable sequencing option panel
        children = get(handles.panel.analyzeSequenceOptions, 'Children');
        set(children, 'Enable', 'on')
    end
end
%% Live Controls
data = [];
%Check if session exist
if ~isempty(handles.live.session) && isvalid(handles.live.session)
    handles.button.recordLive.Enable = 'on';
    handles.button.previewLive.Enable = 'on';
    %Open log file
    fid = fopen(fullfile(handles.resourcesPath, 'log.bin'), 'r');
    %Read Data
    chanNb = length(handles.live.session.Channels);
    data = fread(fid, [chanNb+1, Inf], 'double');
    fclose(fid);
else
    handles.button.recordLive.Enable = 'off';
    handles.button.previewLive.Enable = 'off';
end
%Check if any data
if isempty(data)
    handles.button.clearLog.Enable = 'off';
    handles.button.exploreData.Enable = 'off';
    handles.text.samplesAcquired.String = '0';
else
    handles.button.clearLog.Enable = 'on';
    handles.button.exploreData.Enable = 'on';
    handles.text.samplesAcquired.String = num2str(length(data));
end
%Check TTL options visibility
tags = {'manualIN', 'analogIN', 'manualOUT', 'analogOUT'};
for i = 1:length(tags)
    if handles.settings.live.TTLChecks(i)
        set(setdiff(findobj(handles.panel.livePanels{2}, 'Tag', tags{i}), findobj(handles.panel.livePanels{2}, 'Style', 'check', 'Tag', tags{i})), 'Enable', 'on')
    else
        set(setdiff(findobj(handles.panel.livePanels{2}, 'Tag', tags{i}), findobj(handles.panel.livePanels{2}, 'Style', 'check', 'Tag', tags{i})), 'Enable', 'off')        
    end
end
%Store GUI Data
guidata(handles.hObject, handles)
end