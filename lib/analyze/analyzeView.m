%% Comments
%Function that change the type of view in analyze axis

%Associated GUI: SAPPIY
%Author: V. Doguet (21/2/2019)
%Updates:
%% Function
function analyzeView(s, ~, handles)
%Retrieve handles
handles = guidata(handles.hObject);
%Get the radio checked
handles.settings.analyze.view = s.String;
%Call update function
updateAnalyze(handles)
%Store GUI Data
guidata(handles.hObject, handles)
end