%% Comments
%Function that update controls and charts in analyze layout

%Associated GUI: SAPPIY
%Author: V. Doguet (12/12/2018)
%Updates:
%% Function
function updateAnalyze(handles)

%Clear axis
cla(handles.axes.analyze)
hold(handles.axes.analyze, 'on')

%Reset title
title(handles.axes.analyze, '')

%Do only if there's at least one sequence in selection
if ~isempty(handles.current.item)
    %Reassign variable names for readability
    file = handles.current.item(1);
    chan = handles.current.item(2);
    ttl = handles.current.item(3);
    list = handles.current.list;
    pulses = handles.data.analyze.pulses{file};
    rates = handles.data.analyze.rates{file};
    signals = handles.data.analyze.signals{file};
    xSource = handles.data.analyze.xSource{file};
    headers = handles.data.analyze.headers{file};
    
    if isempty(handles.data.analyze.signals{file})
        
        %No sequencing has been performed yet, so display all signal of
        %selected channel
        signal = handles.data.analyze.dataSource{file}(:, chan);
        pulses = handles.data.analyze.pulseSource{file};
        plot(handles.axes.analyze, signal, 'k')
        %Plot TTL indexes
        plot(handles.axes.analyze, pulses(:, chan), signal(pulses(:, chan)), 'or', 'MarkerFaceColor', 'r')
        %Set axis properties
        xlim(handles.axes.analyze, 'auto')
        ylim(handles.axes.analyze, 'auto')
        set(handles.axes.analyze, 'XTickMode', 'auto', 'YTickMode', 'auto')
        %Then, plot current sequencing options information
        [xData, yData, colors] = getSequencing(handles);
        for i = 1:length(colors)
            plot(handles.axes.analyze, xData{i}, yData{i}, colors{i}, 'linewidth', 2)
        end
        %Display a title and labels
        title(handles.axes.analyze, getXML(handles.settings.xml.strings, 'Label', 'noSequencing'), 'Color', 'r', 'FontWeight', 'bold')
        ylabel(handles.axes.analyze, headers{chan}, 'FontSize', 12, 'FontWeight', 'bold', 'interpreter', 'none')
        xlabel(handles.axes.analyze, getXML(handles.settings.xml.strings, 'Label', 'samples'), 'FontSize', 12, 'FontWeight', 'bold', 'interpreter', 'none')
        %Display a legend
        legend(handles.axes.analyze, headers{chan}, 'TTL', getXML(handles.settings.xml.strings, 'Label', 'currentSequencing'), 'interpreter', 'none')
        
    else
        
        %Plot signal data according to view and the signal process option chosen
        switch lower(handles.settings.analyze.view)
            case 'average'
                %Average all selected signal and plot the average signal
                %Get selected sequences in current file
                selection = list(list(:, 1) == file & list(:, end), 3);
                label = '[';
                for fld = 1:length(selection)
                    %Store index for title purpose
                    label = [label, num2str(selection(fld)), ', '];
                    %Get sequence
                    stdDiff = (size(signals, 1) / size(pulses, 1));
                    b1 = 1 + (selection(fld)-1) * stdDiff;
                    b2 = (selection(fld) * stdDiff) - 1;
                    range = round(b1:b2);
                    %Use time or any other channel if selected
                    if xSource > 0
                        xData = signals(range, xSource);
                    else
                        currentIndex = pulses(selection(fld), chan);
                        xData = (range - currentIndex) / rates(chan);
                    end
                    sequences(fld, :) = signals(range, chan);
                    %Check whehter there's a signal treat to apply
                    if handles.popup.signalTreats.Value > 1
                        files = dir(fullfile(handles.userFcnPath, 'signalTreats', '*.m'));
                        [~, script] = fileparts(files(handles.popup.signalTreats.Value-1).name);
                        sequences(fld, :) = feval(script, sequences(fld, :), rates(chan));
                    end
                    %plot individual sequences
                    plot(handles.axes.analyze, xData, sequences(fld, :), 'Color', getXML(handles.settings.xml.colors, 'Line', 'secondary'), 'linestyle', '-')
                end
                %Mean all sequences
                signal = mean(sequences, 1);
                %plot
                plot(handles.axes.analyze, xData, signal, 'Color', getXML(handles.settings.xml.colors, 'Line', 'main'), 'linestyle', '-', 'LineWidth', 1.5, 'Tag', 'main')
                %Display title in axis
                label(end-1) = []; label(end) = ']';
                title(sprintf('%s%s%s\n%s%s%s', ...
                    getXML(handles.settings.xml.strings, 'Command', 'file'), ...
                    ': ', ...
                    handles.fileList{file}, ...
                    getXML(handles.settings.xml.strings, 'Command', 'average'), ...
                    ' ', ...
                    label), ...
                    'Color', 'r', ...
                    'Interpreter', 'none')
            otherwise
                %Display pulse Counter in axis
                title(sprintf('%s%s%s\n%s%s%.0f%s%.0f', ...
                    getXML(handles.settings.xml.strings, 'Command', 'file'), ...
                    ': ', ...
                    handles.fileList{file}, ...
                    getXML(handles.settings.xml.strings, 'Command', 'sequence'), ...
                    ': ', ...
                    ttl, '/', size(pulses, 1)), ...
                    'Color', 'r', ...
                    'Interpreter', 'none')
                if strcmpi(handles.settings.analyze.view, 'multiple')
                    %Define sequences to display
                    selection = list(list(:, 1) == file & list(:, end), 3);
                    %Loop for all sequences excepting the current one
                    for fld = 1:length(selection)
                        if ~isequal(ttl, selection(fld))
                            stdDiff = (size(signals, 1) / size(pulses, 1));
                            b1 = 1 + (selection(fld)-1) * stdDiff;
                            b2 = (selection(fld) * stdDiff) - 1;
                            range = round(b1:b2);
                            %Use time or any other channel if selected
                            if xSource > 0
                                xData = signals(range, xSource);
                            else
                                currentIndex = pulses(selection(fld), chan);
                                xData = (range - currentIndex) / rates(chan);
                            end
                            signal = signals(range, chan);
                            %Check whehter there's a signal treat to apply
                            if handles.popup.signalTreats.Value > 1
                                files = dir(fullfile(handles.userFcnPath, 'signalTreats', '*.m'));
                                [~, script] = fileparts(files(handles.popup.signalTreats.Value-1).name);
                                signal = feval(script, signal, rates(chan));
                            end
                            %plot
                            plot(handles.axes.analyze, xData, signal, 'Color', getXML(handles.settings.xml.colors, 'Line', 'secondary'), 'linestyle', '-')
                        end
                    end
                end
                %Plot the current pulse sequence, if in selection
                stdDiff = (size(signals, 1) / size(pulses, 1));
                b1 = 1 + (ttl-1) * stdDiff;
                b2 = (ttl * stdDiff) - 1;
                range = round(b1:b2);
                %Use time or any other channel if selected
                if xSource > 0
                    xData = signals(range, xSource);
                else
                    currentIndex = pulses(ttl, chan);
                    xData = (range - currentIndex) / rates(chan);
                end
                signal = signals(range, chan);
                %Check whehter there's a signal treat to apply
                if handles.popup.signalTreats.Value > 1
                    files = dir(fullfile(handles.userFcnPath, 'signalTreats', '*.m'));
                    [~, script] = fileparts(files(handles.popup.signalTreats.Value-1).name);
                    signal = feval(script, signal, rates(chan));
                end
                %plot
                plot(handles.axes.analyze, xData, signal, 'Color', getXML(handles.settings.xml.colors, 'Line', 'main'), 'linestyle', '-', 'LineWidth', 1.5, 'Tag', 'main')
        end
        
        %Set axis properties
        %XAxis
        if isempty(handles.localSettings.analyzeXLim)
            %According to max length of all line plotted
            allLines = findobj(handles.axes.analyze, 'type', 'line');
            iMin = zeros(length(allLines), 1);
            iMax = zeros(length(allLines), 1);
            for k = 1:length(allLines)
                iMin(k) = min(allLines(k).XData);
                iMax(k) = max(allLines(k).XData);
            end
            xlimits = [min(iMin), max(iMax)];
            %Display auto valeusi n edit boxes (without editing local settings)
            handles.edit.a_Xmin.String = num2str(xlimits(1));
            handles.edit.a_Xmax.String = num2str(xlimits(2));
            %reset direction to normal
            xdir = 'normal';
        else
            %According to defined values
            xlimits = handles.localSettings.analyzeXLim;
            if xlimits(1) > xlimits(2)
                xdir = 'reverse';
                xlimits = flip(xlimits);
            else
                xdir = 'normal';
            end
        end
        step = getStep(abs(diff(xlimits)));
        ticks = round(xlimits(1), 1):step:round(xlimits(2), 1);
        set(handles.axes.analyze, 'XLim', xlimits, ...
            'XTick', ticks(2:end-1), 'XDir', xdir)
        %YAxis
        if isempty(handles.localSettings.analyzeYLim)
            %Automatic definition
            ylim(handles.axes.analyze, 'auto')
            set(handles.axes.analyze, 'YTickMode', 'auto')
            ticks = handles.axes.analyze.YTick;
        else
            %According to defined values
            ylimits = handles.localSettings.analyzeYLim;
            ylim(ylimits)
            step = getStep(diff(ylimits)/2);
            ticks = ylimits(1):step:ylimits(2);
        end
        set(handles.axes.analyze, 'YTick', ticks(2:end-1))
        %Labels
        ylabel(handles.axes.analyze, headers{chan}, 'FontSize', 12, 'FontWeight', 'bold')
        xlabel(handles.axes.analyze, handles.popup.a_sequencingSource.String{handles.popup.a_sequencingSource.Value}, 'FontSize', 12, 'FontWeight', 'bold')
        %Colors
        handles.axes.analyze.XColor = eval(getXML(handles.settings.xml.colors, 'Chart', 'foregroundAnalyze'));
        handles.axes.analyze.YColor = eval(getXML(handles.settings.xml.colors, 'Chart', 'foregroundAnalyze'));
        handles.axes.analyze.XLabel.Color = eval(getXML(handles.settings.xml.colors, 'Chart', 'foregroundAnalyze'));
        handles.axes.analyze.YLabel.Color = eval(getXML(handles.settings.xml.colors, 'Chart', 'foregroundAnalyze'));
        
        %Plot vertical bar at pulse index, if time XData only
        if isequal(xSource, 0) && any(xData == 0)
            yL = get(handles.axes.analyze, 'YLim');
            plot(handles.axes.analyze, [0, 0], yL, '--k')
            set(handles.axes.analyze, 'YLim', yL)
        end
        
        %Delete legend if any
        legend(handles.axes.analyze, 'off')
        
        %Get file and ttl nb fields should match with
        %Plot tracked sequences, if any
        if ~isempty(handles.additionalElements)
            %Find all indexes in results that match current file and ttl
            indexes = [];
            for i = 1:size(handles.results, 1)
                if strcmpi(handles.results(i, 1), handles.fileList{file}) && ...
                        strcmpi(handles.results(i, 2), headers{chan}) && ...
                        any(str2num(handles.results{i, 4}) == ttl)
                    indexes = cat(1, indexes, i);
                end
            end
            for i = 1:length(indexes)
                for e = 1:length(handles.additionalElements(indexes(i), :))
                    if ~isempty(handles.additionalElements{indexes(i), e})
                        buildElementFcn(handles.additionalElements{indexes(i), e});
                    end
                end
            end
        end
    end
end
end
%% Subfunctions
%Build additional elements
function buildElementFcn(struct)
try
    if ~isempty(struct) && ~isempty(struct.type)
        %First create object
        element = eval(struct.type);
        %Prepare set command
        command = sprintf('%s', 'set(element,');
        fields = fieldnames(struct);
        k = 1;
        for i = 2:length(fields)
            %Check whether field is valid property of source type
            prop = properties(element);
            if any(strcmpi(prop, fields{i}))
                %Get field value
                val = struct.(fields{i});
                %if there's a valid value, add parameter and value
                if ~isempty(val)
                    switch class(val)
                        case 'double'
                            command = sprintf('%s%s%s%s%s%s%s', command, '''', fields{i}, ''',', '[', num2str(val), '],');
                        case 'char'
                            command = sprintf('%s%s%s%s%s%s%s', command, '''', fields{i}, ''',', '''', val, ''',');
                        case 'struct'
                            struct.(['s', num2str(k)]) = val;
                            command = sprintf('%s%s%s%s%s%s%s', command, '''', fields{i}, ''',',  'struct.s', num2str(k), ',');
                            k = k+1;
                        case 'function_handle'
                            command = sprintf('%s%s%s%s%s%s%s', command, '''', fields{i}, ''',', '@', func2str(val), ',');
                    end
                end
            end
        end
        %Replace last element by bracket
        command(end) = ')';
        eval(command)
    end
catch exception
    errordlg(getReport(exception))
end
end

%Get xData and yData for sequencing preview
function [xData, yData, colors] = getSequencing(handles)
%Reassign variable names for readability
file = handles.current.item(1);
chan = handles.current.item(2);
pulses = handles.data.analyze.pulseSource{file}(:, chan);
source = handles.data.analyze.dataSource{file}(:, chan);
rate = handles.data.analyze.rates{file}(chan);
xSource = handles.data.analyze.xSource{file};

%Allocate output data
xData = cell(1, length(pulses));
yData = cell(1, length(pulses));
colors = cell(1, length(pulses));
colors(:) = {'g'};

%Get the required pulse sequence, relative to time or any other channel
if isequal(xSource, 0)
    %Get boundaries
    b1 = pulses + (handles.settings.analyze.onset.value * rate);
    b2 = pulses + (handles.settings.analyze.offset.value * rate);
    %Compute xData and yData
    for i = 1:length(xData)
        %Check that sequencing fits source signal dimensions
        if b1(i) <= 0
            b1(i) = 1;
            colors{i} = 'r';
        elseif b2(i) > length(source)
            b2(i) = length(source);
            colors{i} = 'r';
        end
        %Assign values
        xData{i} = b1(i):b2(i);
        yData{i} = source(b1(i):b2(i));
    end
else
    %Get the signal to focus sequencing on
    xSignal = handles.data.analyze.dataSource{file}(:, xSource);
    %Loop for all ttls
    for i = 1:length(pulses)
        %Define what are onset and offset directions
        %and edges, and proceed accordingly
        if isequal(handles.settings.analyze.onset.direction, 1)
            x = flip(xSignal(1:pulses(i)));
            switch handles.settings.analyze.onset.edge
                case 1
                    onset = find(x < handles.settings.analyze.onset.value, 1, 'first');
                case 2
                    onset = find(x > handles.settings.analyze.onset.value, 1, 'first');
            end
            onset = pulses(i) - (onset - 1);
        else
            x = xSignal(pulses(i):end);
            switch handles.settings.analyze.onset.edge
                case 1
                    onset = find(x < handles.settings.analyze.onset.value, 1, 'first');
                case 2
                    onset = find(x > handles.settings.analyze.onset.value, 1, 'first');
            end
            onset = pulses(i) + (onset - 1);
        end
        if isequal(handles.settings.analyze.offset.direction, 1)
            x = flip(xSignal(1:pulses(i)));
            switch handles.settings.analyze.offset.edge
                case 1
                    offset = find(x < handles.settings.analyze.offset.value, 1, 'first');
                case 2
                    offset = find(x > handles.settings.analyze.offset.value, 1, 'first');
            end
            offset = pulses(i) - (offset - 1);
        else
            x = xSignal(pulses(i):end);
            switch handles.settings.analyze.offset.edge
                case 1
                    offset = find(x < handles.settings.analyze.offset.value, 1, 'first');
                case 2
                    offset = find(x > handles.settings.analyze.offset.value, 1, 'first');
            end
            offset = pulses(i) + (offset - 1);
        end
        %Store xData and yData
        if ~isempty(onset) && ~isempty(offset)
            xData{i} = onset:offset;
            yData{i} = source(onset:offset);
        else
            xData{i} = 1:length(xSignal);
            yData{i} = source;
            colors{i} = 'r';
        end
    end
end
end