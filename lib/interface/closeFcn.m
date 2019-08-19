%% Comments
%Close Function

%Associated GUI: SAPPIY
%Author: V. Doguet (21/2/2019)
%Updates:
%% Function
function closeFcn(s, ~)
%Retrieve handles
handles = guidata(s);
%Clear Logs
clearLogFile('', '', handles)
%Save default settings before closing
saveDefaultSettings(handles)
%Reset and Close GUI
handles = resetGUI(handles);
%Remove library from path
rmpath(genpath(handles.libPath))
%Remove userFcn directory from path
rmpath(genpath(handles.userFcnPath))
%Delete figure
delete(handles.hObject)
end