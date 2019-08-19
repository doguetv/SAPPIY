%% Comments
%Function threset live Session

%Associated GUI: SAPPIY
%Author: V. Doguet (8/3/2019)
%Updates:
%% Function
function clearSession(~, ~, handles)
%Retrieve handles
handles = guidata(handles.hObject);
%Reset GUI
handles = resetGUI(handles, 'live');
%Store GUI Data
guidata(handles.hObject, handles)
end