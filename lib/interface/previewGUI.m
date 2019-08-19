%% Comments
%Function that plots data in GUI and enables some treats

%Associated GUI: SAPPIY
%Author: V. Doguet (4/3/2019)
%Updates:
%% Function
function previewGUI(XLabels, Y, rate, userFcnPath)

%% Create GUI
ftemp = figure('Name', 'Data Explorer Window', 'NumberTitle', 'off', ...
    'Visible', 'off');

%Retrieve userFcn
listFiles = dir(fullfile(userFcnPath, '*.m'));
listFcn = cell(length(listFiles)+1, 1);
for i = 1:length(listFiles)
    listFcn{i+1} = listFiles(i).name;
end

%Creates axes
r = length(Y.Labels);
c = 1;
ax = zeros(length(Y.Labels), 1);
for i = 1:length(Y.Labels)
    %Plot
    ax(i) = subplot(r, c, i);
    udata.axis = gca;
    udata.line = line(1:length(Y.Data(:, i)), Y.Data(:, i), 'Color', Y.Colors{i}, 'LineWidth', 2);
    %Add control for callback
    axPos = get(gca, 'position');
    width = .15*axPos(3);
    height = .1*axPos(4);
    %Set Udata
    udata.path = userFcnPath;
    uicontrol('Parent', ftemp, ...
        'units', 'normalized', ...
        'position', [axPos(1), sum(axPos([2, 4])), width, height], ...
        'style', 'popup', ...
        'string', listFcn, ...
        'userdata', udata, ...
        'callback', @popup)
    %Set parameters
    grid on
    set(ax(i), 'XLim', [min(udata.line.XData), max(udata.line.XData)])
    xlabel(ax(i), XLabels{1})
    ylabel(ax(i), Y.Labels{i}, 'FontWeight', 'bold')
end
%Set some other parameters
set(ftemp, 'Color', 'w')
%Link axes according to X dimension
linkaxes(ax, 'x')

%%Add control for X source
uicontrol('Parent', ftemp, ...
    'units', 'normalized', ...
    'position', [.8, .95, .2, .05], ...
    'style', 'popup', ...
    'string', XLabels, ...
    'callback', @xSource)

%Finalize
movegui(ftemp, 'center')
set(ftemp, 'Visible', 'on')

%% Subfunction
    function popup(s, ~)
        %ResetAxis
        delete(setdiff(setdiff(findobj(s.UserData.axis), s.UserData.line), s.UserData.axis))
        %Get Function name
        [~, fcnName] = fileparts(s.String{s.Value});
        cd(s.UserData.path)
        %Get Data
        if ~isempty(fcnName)
            xl = s.UserData.axis.XLim;
            yl = s.UserData.axis.YLim;
            x = s.UserData.line.XData(s.UserData.line.XData > xl(1) & s.UserData.line.XData < xl(2) & s.UserData.line.YData > yl(1) & s.UserData.line.YData < yl(2));
            y = s.UserData.line.YData(s.UserData.line.XData > xl(1) & s.UserData.line.XData < xl(2) & s.UserData.line.YData > yl(1) & s.UserData.line.YData < yl(2));
            feval(fcnName, s.UserData.axis, x, y, rate)
        end
    end

    function xSource(s, ~)
        %Find all axes
        axs = findobj(ftemp, 'Type', 'axes');
        aLine = findobj(axs(1), 'Type', 'line');
        switch s.Value
            case 1
                xData = 1:length(aLine(end).XData);
            case 2
                xData = (1:length(aLine(end).XData))./rate;
            otherwise
                xData = Y.Data(:, s.Value-2);
        end
        %Replace properties in all axis
        for i = 1:length(axs)
            set(findobj(axs(i), 'Type', 'line'), 'XData', xData)
            %Set xLabel
            xlabel(axs(i), XLabels{s.Value})
            %Set X limits
            set(axs(i), 'XLim', [min(xData), max(xData)])
        end
    end
end