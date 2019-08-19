%% Comments
%Listener that store Data when available in Daq session

%Associated GUI: SAPPIY
%Author: V. Doguet (7/1/2019)
%Updates:
%% Function
function editAITable(~, e, handles)
if ~isempty(e.Indices)
    %Retrieve handles
    handles = guidata(handles.hObject);
    %Determine what column has been edited
    switch e.Indices(2)
        case 3  %Display option
            if isfield(handles.live, 'session')
                if e.NewData
                    handles.live.variables.lines{e.Indices(1)}.Visible = 'on';
                else
                    handles.live.variables.lines{e.Indices(1)}.Visible = 'off';
                end
            end
    end
    %Store GUI Data
    guidata(handles.hObject, handles)
end
end