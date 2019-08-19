%% Comments
%Function to change pulse number

%Associated GUI: SAPPIY
%Author: V. Doguet (21/2/2019)
%Updates:
%% Function
function changeBtnFcn(s, ~, handles)
%Retrieve handles
handles = guidata(handles.hObject);
%Get selected sequences in current file
selection = handles.current.list(handles.current.list(:, 1) == handles.current.item(1) & handles.current.list(:, end), 3);
switch s.String
    case getXML(handles.settings.xml.strings, 'Button', 'previous')
        if ~isempty(handles.data.analyze.pulses{handles.current.item(1)})
            if handles.current.item(3) > min(selection)
                handles.current.item(3) = selection(find(selection - handles.current.item(3) < 0, 1, 'last'));
            else
                beep
            end
        end
    case getXML(handles.settings.xml.strings, 'Button', 'next')
        if ~isempty(handles.data.analyze.pulses{handles.current.item(1)})
            if handles.current.item(3) < max(selection)
                handles.current.item(3) = selection(find(selection - handles.current.item(3) > 0, 1, 'first'));
            else
                beep
            end
        end
end
%Call update function
updateAnalyze(handles)
%Store GUI Data
guidata(handles.hObject, handles)
end