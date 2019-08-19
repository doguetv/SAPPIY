%% Comments
%Function that updates axis limits in analyze panel

%Associated GUI: SAPPIY
%Author: V. Doguet (21/2/2019)
%Updates:
%% Function
function editAxis(s, ~, handles)
%Retrieve handles
handles = guidata(handles.hObject);
%First check that new value is of numeric format
if ~isempty(s.String) && isnan(str2double(s.String))
    %Error message
    errordlg(getXML(handles.settings.xml.strings, 'Error', 'numeric'))
    %Reset the default value
    switch s
        case handles.edit.a_xMin
            s.String = num2str(min(handles.localSettings.analyzeXLim));
        case handles.edit.a_xMax
            s.String = num2str(max(handles.localSettings.analyzeXLim));
        case handles.edit.a_yMin
            s.String = num2str(min(handles.localSettings.analyzeXLim));
        case handles.edit.a_yMax
            s.String = num2str(max(handles.localSettings.analyzeXLim));
    end
    %Then return
    return
end
%Assign to propet setting
switch s
    case handles.edit.a_xMin
        if isempty(s.String)
            handles.edit.a_xMax.String = '';
            handles.localSettings.analyzeXLim = [];
        else
            handles.localSettings.analyzeXLim(1) = str2double(s.String);
            if isempty(handles.edit.a_xMax.String)
                handles.edit.a_xMax.String = num2str(max(handles.axes.analyze.XLim));
                handles.localSettings.analyzeXLim(2) = max(handles.axes.analyze.XLim);
            end
        end
    case handles.edit.a_xMax
        if isempty(s.String)
            handles.edit.a_xMin.String = '';
            handles.localSettings.analyzeXLim = [];
        else
            handles.localSettings.analyzeXLim(2) = str2double(s.String);
            if isempty(handles.edit.a_xMin.String)
                handles.edit.a_xMin.String = num2str(min(handles.axes.analyze.XLim));
                handles.localSettings.analyzeXLim(1) = min(handles.axes.analyze.XLim);
            end
        end
    case handles.edit.a_yMin
        if isempty(s.String)
            handles.edit.a_yMax.String = '';
            handles.localSettings.analyzeYLim = [];
        else
            handles.localSettings.analyzeYLim(1) = str2double(s.String);
            if isempty(handles.edit.a_yMax.String)
                handles.edit.a_yMax.String = num2str(max(handles.axes.analyze.YLim));
                handles.localSettings.analyzeYLim(2) = max(handles.axes.analyze.YLim);
            end
        end
    case handles.edit.a_yMax
        if isempty(s.String)
            handles.edit.a_yMin.String = '';
            handles.localSettings.analyzeYLim = [];
        else
            handles.localSettings.analyzeYLim(2) = str2double(s.String);
            if isempty(handles.edit.a_yMin.String)
                handles.edit.a_yMin.String = num2str(min(handles.axes.analyze.YLim));
                handles.localSettings.analyzeYLim(1) = min(handles.axes.analyze.YLim);
            end
        end
end
%Call update function
updateAnalyze(handles)
%Store GUI Data
guidata(handles.hObject, handles)
end