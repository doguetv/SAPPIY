%% Comments
%Function that changes colors in live display

%Associated GUI: SAPPIY
%Author: V. Doguet (9/1/2019)
%Updates:
%% Function
function contextLiveOptions(s, ~, handles)
%Retrieve handles
handles = guidata(handles.hObject);

switch s.Text
    case getXML(handles.settings.xml.strings, 'Menu', 'backgroundColor')
        %Open color picker
        c = uisetcolor(handles.axes.live.Color);
        %Make sure a color has been chosen
        if ~isequal(c, 0)
            %Edit settings handles
            handles.settings.live.backgroundColor = c;
            %Set Value in colors XML file
            setXML(handles.settings.xml.colors, 'Chart', 'backgroundLive', sprintf('%s%f%s%f%s%f%s', '[', c(1), ', ', c(2), ', ', c(3), ']'))
            %Change background colors
            set([handles.panel.liveDisplay, handles.edit.Ymin, handles.edit.Ymax, handles.edit.XLiveWindow, handles.edit.XLiveBefore], 'BackgroundColor', c);
            set(handles.axes.live, 'Color', c);
            %Check contrast and adjust controllers colors as well
            if mean(c) < .33
                rgbCode = '[1, 1, 1]';
            else
                rgbCode = '[0, 0, 0]';
            end
            handles.axes.live.XLabel.Color = eval(rgbCode);
            handles.axes.live.YLabel.Color = eval(rgbCode);
            handles.axes.live.XColor = eval(rgbCode);
            handles.axes.live.YColor = eval(rgbCode);
            handles.edit.XLiveWindow.ForegroundColor = eval(rgbCode);
            handles.edit.XLiveBefore.ForegroundColor = eval(rgbCode);
            handles.edit.Ymax.ForegroundColor = eval(rgbCode);
            handles.edit.Ymin.ForegroundColor = eval(rgbCode);
            %Save in XML file
            setXML(handles.settings.xml.colors, 'Chart', 'foregroundLive', rgbCode)
        end
    case getXML(handles.settings.xml.strings, 'Menu', 'exportChart')
end

%Store GUI Data
guidata(handles.hObject, handles)
end