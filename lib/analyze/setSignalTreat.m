%% Comments
%Function used to recall update Analyze function after having edited signal treat method

%Associated GUI: SAPPIY
%Author: V. Doguet (7/3/2019)
%Updates:
%% Function
function setSignalTreat(~, ~, handles)
%Retrieve handles
handles = guidata(handles.hObject);
%Disable other signal processing options
updateAnalyze(handles)
%Store GUI Data
guidata(handles.hObject, handles)
end