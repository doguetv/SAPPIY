%% Comments
%Function used to export a panel as separated file

%Associated GUI: SAPPIY
%Author: V. Doguet (20/3/2019)
%Updates:
%% Function
function exportAxis(panel, handles)

set(handles.hObject, 'Pointer', 'watch')

%Get screen size
scrsz = get(0, 'ScreenSize');
%Create figure
exp = figure('Position', [1 scrsz(2) scrsz(3) scrsz(4)], ...
    'Menu', 'none', 'Visible', 'off');

%Associate panel to new figure
panel.Parent = exp;
panel.Position = [0, 0, 1, 1];

%Select file location and name
str = datestr(datetime('now'), 'yymmdd_HHMMSS');
[filename, pathname] = uiputfile('.tiff', getXML(handles.settings.xml.strings, 'Command', 'saveAs'), ...
    sprintf('%s%s%s', getXML(handles.settings.xml.strings, 'Label', 'appName'), '_Image_', str));
if isequal(filename,0) || isequal(pathname,0)
    set(handles.hObject, 'Pointer', 'arrow')
    return
end

%Save file
print(exp, [pathname, filename] ,'-dtiff','-r300')

%Delete window
delete(exp)

set(handles.hObject, 'Pointer', 'arrow')
end