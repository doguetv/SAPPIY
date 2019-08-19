%% Comments
%Function that adds arithmetic channel

%Associated GUI: SAPPIY
%Author: V. Doguet (22/2/2019)
%Updates:
%% Function
function addChannel(s, ~, handles)
%Retrieve handles
handles = guidata(handles.hObject);
%Switch source
switch s.String
    case getXML(handles.settings.xml.strings, 'Button', 'addArithmetic')
        %Select source channel(s)
        choice = listdlg('promptString', getXML(handles.settings.xml.strings, 'Command', 'sourceChannel'), ...
            'listString', handles.table.AIChannels.Data(:, 2), ...
            'SelectionMode', 'multiple');
        if isempty(choice)
            return
        end
        %Prepare sources in equation
        defAnsw = '';
        for i = 1:length(choice)
            defAnsw = sprintf('%s%s%s%s', defAnsw, '#', num2str(choice(i)), '#');
        end
        %Ask for arithmetic equation
        equation = inputdlg(getXML(handles.settings.xml.strings, 'Command', 'equation'), '', 1, {defAnsw});
        if isempty(equation)
            return
        end
        %Check whether braces are present in equation (channel number must
        %be #x#)
        indexes = strfind(equation{1}, '#');
        if isempty(indexes) || (length(indexes)/2 ~= round(length(indexes)/2))
            errordlg(getXML(handles.settings.xml.strings, 'Error', 'hash'))
            return
        end
        %Store in handles
        handles.live.variables.arithmetic{length(handles.live.variables.arithmetic) + 1} = equation{1};
        %Add channel to table
        handles.table.AIChannels = addElementToTable(handles.table.AIChannels, handles);
        %Add a a plot object object without X and Y Data
        index = size(handles.table.AIChannels.Data, 1);
        handles.live.variables.lines{index} = line(handles.axes.live, 0, 0, ...
            'Color', getXML(handles.settings.xml.colors, 'Line', num2str(index)), 'linewidth', 2);
        %Set X and Y Data using external function
        handles = setAcqWindowProperties(handles);
end
%Store GUI Data
guidata(handles.hObject, handles)
end
%% Subfunction
function table = addElementToTable(table, handles)
%Get index
rank = size(table.Data, 1) + 1;
%Define channel properties
chanNb = {'<html><table color="red"><TR><TD><i><b>Delete</b></i></TR></TD></table></html>'};
name = sprintf('%s%.0f', 'Channel ', rank);
rgbTriplet = round(eval(getXML(handles.settings.xml.colors, 'Line', num2str(rank)))*255);
color = sprintf('%s%s%s', '<html><table border=0 width=300 bgcolor=', ['"rgb(', num2str(rgbTriplet(1)), ', ', num2str(rgbTriplet(2)), ', ', num2str(rgbTriplet(3)), ')"'], '><TR><TD></TD></TR></table></html>');
cData = cat(2, chanNb, name, num2cell(true), color);
%Update Table
table.Data(rank, :) = cData;
end