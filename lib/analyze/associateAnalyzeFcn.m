%% Comments
%Function used to associate callback function to analyze button in GUI

%Associated GUI: SAPPIY
%Author: V. Doguet (8/3/2019)
%Updates:
%% Function
function associateAnalyzeFcn(s, ~, handles)
%Retrieve handles
handles = guidata(handles.hObject);
%Switch according to label of menu clicked
switch s.Label
    case getXML(handles.settings.xml.strings, 'Menu', 'associateFcn')
        %Browse for fucntion to associate in appropriate user Fcn folder
        listFcn = dir(fullfile(handles.userFcnPath, 'processFcns', '*.m'));
        choice = popupdlg({listFcn.name}, 1, getXML(handles.settings.xml.strings, 'Command', 'selectFcn'));
        %Set function in button name
        [~, fcnName] = fileparts(listFcn(choice).name);
        s.UserData.String = fcnName;
        %Update settings
        handles.settings.analyze.analyzeBtns{str2double(s.UserData.Tag)} = fcnName;
        %Attach a new menu option to clear button
        uimenu(s.Parent, 'Label', getXML(handles.settings.xml.strings, 'Menu', 'clearFcn'), ...
            'Callback', {@associateAnalyzeFcn, handles}, ...
            'UserData', handles.button.analyzeBtns{str2double(s.UserData.Tag)});
        handles.button.analyzeBtns{str2double(s.UserData.Tag)}.UIContextMenu = s.Parent;
    case getXML(handles.settings.xml.strings, 'Menu', 'clearFcn')
        %Reset original properties
        s.UserData.String = getXML(handles.settings.xml.strings, 'Button', 'na');
        %Update settings
        handles.settings.analyze.analyzeBtns{str2double(s.UserData.Tag)} = [];
        %Clear context menu option
        delete(s)
end
%Store GUI Data
guidata(handles.hObject, handles)
end