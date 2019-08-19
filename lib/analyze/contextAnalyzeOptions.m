%% Comments
%Context menu callback for analyze axis

%Associated GUI: SAPPIY
%Author: V. Doguet (20/3/2019)
%Updates:
%% Function
function contextAnalyzeOptions(s, ~, handles)
%Retrieve handles
handles = guidata(handles.hObject);

switch s.Text
    case getXML(handles.settings.xml.strings, 'Menu', 'backgroundColor')
        %Open color picker
        c = uisetcolor(handles.axes.analyze.Color);
        %Make sure a color has been chosen
        if ~isequal(c, 0)
            %Set Value in colors XML file
            setXML(handles.settings.xml.colors, 'Chart', 'backgroundAnalyze', sprintf('%s%f%s%f%s%f%s', '[', c(1), ', ', c(2), ', ', c(3), ']'))
            %Change background colors
            set([handles.panel.analyzeDisplay, handles.edit.a_xMin, handles.edit.a_xMax, handles.edit.a_yMin, handles.edit.a_yMax], 'BackgroundColor', c)
            set(handles.axes.analyze, 'Color', c);
            %Check contrast and adjust controllers colors as well
            if mean(c) < .33
                rgbCode = '[1, 1, 1]';
            else
                rgbCode = '[0, 0, 0]';
            end
            handles.axes.analyze.XLabel.Color = eval(rgbCode);
            handles.axes.analyze.YLabel.Color = eval(rgbCode);
            handles.axes.analyze.XColor = eval(rgbCode);
            handles.axes.analyze.YColor = eval(rgbCode);
            set([handles.edit.a_xMin, handles.edit.a_xMax, handles.edit.a_yMin, handles.edit.a_yMax], 'ForegroundColor', eval(rgbCode))
            %Save in XML file
            setXML(handles.settings.xml.colors, 'Chart', 'foregroundAnalyze', rgbCode)
        end
    case {getXML(handles.settings.xml.strings, 'Menu', 'mainColor'), getXML(handles.settings.xml.strings, 'Menu', 'secondaryColor')}
        %Open color picker
        if strcmpi(s.Text, getXML(handles.settings.xml.strings, 'Menu', 'mainColor'))
            currentColor = getXML(handles.settings.xml.colors, 'Line', 'main');
        else
            currentColor = getXML(handles.settings.xml.colors, 'Line', 'secondary');
        end
        c = uisetcolor(eval(currentColor));
        %Make sure a color has been chosen
        if ~isequal(c, 0)
            %Set Value in colors XML file
            if strcmpi(s.Text, getXML(handles.settings.xml.strings, 'Menu', 'mainColor'))
                setXML(handles.settings.xml.colors, 'Line', 'main', sprintf('%s%f%s%f%s%f%s', '[', c(1), ', ', c(2), ', ', c(3), ']'))
            else
                setXML(handles.settings.xml.colors, 'Line', 'secondary', sprintf('%s%f%s%f%s%f%s', '[', c(1), ', ', c(2), ', ', c(3), ']'))
            end
            %Call update function
            updateAnalyze(handles)
        end
    case getXML(handles.settings.xml.strings, 'Menu', 'exportChart')
        %Create a copy of appropriate panel to enable editing it
        copyPanel = copyobj(handles.panel.analyzeDisplay, handles.panel.analyzeDisplay.Parent);
        %Call export Fcn
        exportAxis(copyPanel, handles)
end

%Store GUI Data
guidata(handles.hObject, handles)
end