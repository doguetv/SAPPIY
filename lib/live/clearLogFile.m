%% Comments
%Function that clears data in log file

%Associated GUI: SAPPIY
%Author: V. Doguet (26/2/2019)
%Updates:
%% Function
function clearLogFile(s, ~, handles)
%Retrieve handles
handles = guidata(handles.hObject);

%Ask confirmation (only if rises from uicontrol and not closing function)
if ~isempty(s)
    answ = questdlg(getXML(handles.settings.xml.strings, 'Command', 'confirm'), ...
        '', ...
        getXML(handles.settings.xml.strings, 'Command', 'yes'), ...
        getXML(handles.settings.xml.strings, 'Command', 'cancel'), ...
        getXML(handles.settings.xml.strings, 'Command', 'cancel'));
    if strcmpi(answ, getXML(handles.settings.xml.strings, 'Command', 'cancel'))
        return
    end
end

%Clear and close log file
fclose('all');
delete(fullfile(handles.resourcesPath, 'log.bin'))
fid = fopen(fullfile(handles.resourcesPath, 'log.bin'), 'w');
fclose(fid);

%Clear timeStamps
handles.live.variables.analogIN.timeStamps = [];

%Reset Lines
handles = setAcqWindowProperties(handles);

%Reset samples counting
handles.text.samplesAcquired.String = '0';

%Run check hifing functiion
handles = checkHiding(handles);

%Store GUI Data
guidata(handles.hObject, handles)
end