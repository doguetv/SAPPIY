%% Comments
%Function used to add guideline to live axis from user functions.

%Associated GUI: SAPPIY
%Author: V. Doguet (27/3/2019)
%Updates:
%% Function
function addGuideline(s, ~, handles)
%Retrieve handles
handles = guidata(handles.hObject);

%Switch uicontrol state
switch s.Value
    case 0  %Delete current guideline
        %Delete from axis
        delete(handles.live.variables.guideline)
        for i = 1:length(handles.live.variables.guidelineMarker)
            delete(handles.live.variables.guidelineMarker{i})
        end
        %clear handles
        handles.live.variables.guideline = [];
        handles.live.variables.guidelineMarker = [];
        %Edit uicontrol properties
        [label, attributes] = getXML(handles.settings.xml.strings, 'Toggle', 'guidelineOff', {'color'});
        s.String = label;
        s.BackgroundColor = eval(attributes{1});
    case 1  %create guideline from user function
        %Get the user folder for guideline functions
        fcns = dir(fullfile(handles.userFcnPath, 'guidelines', '*.m'));
        %If no function in folder, display error, reset uicontrol state and return
        if isempty(fcns)
            errordlg(getXML(handles.settings.xml.strings, 'Error', 'noFcn'));
            s.Value = 0;
            return
        end
        %Select the function to use in folder
        select = popupdlg({fcns.name}, '', getXML(handles.settings.xml.strings, 'Command', 'selectFcn'));
        if isempty(select)
            s.Value = 0;
            return
        end
        [~, script] = fileparts(fcns(select).name); 
        %Evaluate user function
        try
            handles.live.variables.guideline = feval(script, handles.axes.live, handles.live.session.Rate);
        catch exception
            errordlg(getReport(exception))
            s.Value = 0;
            return
        end
        %Create a marker to make lines easily visible behind guideline
        for i = 1:length(handles.live.variables.lines)
            handles.live.variables.guidelineMarker{i} = line(handles.axes.live, ...
                handles.live.variables.lines{i}.XData(end), ...
                handles.live.variables.lines{i}.YData(end), ...
                'Color', handles.live.variables.lines{i}.Color, ...
                'Marker', 'o', ...
                'MarkerFaceColor', handles.live.variables.lines{i}.Color, ...
                'MarkerEdgeColor', handles.live.variables.lines{i}.Color, ...
                'MarkerSize', 8, ...
                'Visible', handles.live.variables.lines{i}.Visible);
        end
        %Edit uicontrol properties
        [label, attributes] = getXML(handles.settings.xml.strings, 'Toggle', 'guidelineOn', {'color'});
        s.String = label;
        s.BackgroundColor = eval(attributes{1});
end

%Store GUI Data
guidata(handles.hObject, handles)
end