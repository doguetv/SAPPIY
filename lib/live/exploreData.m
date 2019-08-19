%% Comments
%Function that explores live data in a separate window

%Associated GUI: SAPPIY
%Author: V. Doguet (4/3/2019)
%Updates:
%% Function
function exploreData(~, ~, handles)
%Retrieve handles
handles = guidata(handles.hObject);

if isfield(handles.live.variables, 'lines') && ~isempty(handles.live.variables.lines)
    %Open log file
    fid = fopen(fullfile(handles.resourcesPath, 'log.bin'), 'r');
    %Read Data
    chanNb = length(handles.live.variables.lines);
    data = fread(fid, [chanNb+1, Inf], 'double');
    fclose(fid);
    
    %Return if log file is empty
    if isempty(data)
        errordlg(getXML(handles.settings.xml.strings, 'Error', 'noData'))
        return
    end
    
    %Select channels to explore
    ydata = listdlg('ListString', handles.table.AIChannels.Data(:, 2), ...
        'PromptString', getXML(handles.settings.xml.strings, 'Command', 'ySequence'), ...
        'SelectionMode', 'multiple');
    if isempty(ydata)
        return
    end
    
    %Create X Labels
    listString = cat(1, {getXML(handles.settings.xml.strings, 'Label', 'samples'); getXML(handles.settings.xml.strings, 'Label', 'time')}, handles.table.AIChannels.Data(ydata, 2));
    
    %Send selected channels to preview GUI
    Y.Data = data(ydata+1, :)';
    Y.Labels = handles.table.AIChannels.Data(ydata, 2);
    Y.Colors = cell(length(ydata), 1);
    for i = 1:length(ydata)
        Y.Colors{i} = handles.live.variables.lines{ydata(i)}.Color;
    end
    previewGUI(listString, Y, handles.live.session.Rate, fullfile(handles.userFcnPath, 'previewTreats'))
end
end