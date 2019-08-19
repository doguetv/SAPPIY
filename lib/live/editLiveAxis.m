%% Comments
%Function to edit live display

%Associated GUI: SAPPIY
%Author: V. Doguet (21/2/2019)
%Updates:
%% Function
function editLiveAxis(s, ~, handles)
%Retrieve handles
handles = guidata(handles.hObject);
%Check whether entry is numeric
if isnan(str2double(s.String))
    %Error message
    errordlg(getXML(handles.settings.xml.strings, 'Error', 'numeric'))
    %Reset the default value
    s.String = num2str(handles.settings.live.Xwindow);
    %Return
    return
end
%get the source control
switch s.Tag
    case 'Ymax'
        %Set new Ywindow value
        handles.settings.live.Ymax = str2double(s.String);
    case 'Ymin'
        %Set new Ywindow value
        handles.settings.live.Ymin = str2double(s.String);
    case 'xwindow'
        %Get the new window value
        %Update value in settings
        handles.settings.live.Xwindow = str2double(s.String);
        %Edit line sizes, if any
        if ~isempty(handles.live.session) && isfield(handles.live.variables, 'lines')
            xwin = handles.settings.live.Xwindow;
            for i = 1:length(handles.live.variables.lines)
                xData = (0:xwin*handles.live.session.Rate)/handles.live.session.Rate;
                yData = zeros(xwin*handles.live.session.Rate + 1, 1);
                set(handles.live.variables.lines{i}, 'XData', xData, 'YData', yData)
            end
        end
    case 'xbefore'
        %Edit x window before acuisition
        handles.settings.live.Xbefore = str2double(s.String);
end
%Update axis settings
handles = setAcqWindowProperties(handles);
%Store GUI Data
guidata(handles.hObject, handles)
end