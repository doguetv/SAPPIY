%% Comments
%Function used to sequence source signal in analyze mode only (sequencing
%is already managed in live mode).

%Associated GUI: SAPPIY
%Author: V. Doguet (22/5/2019)
%Updates:
%% Function
function editSequencing(s, ~, handles)

%Retrieve handles
handles = guidata(handles.hObject);
%Switch source
switch s.Style
    case 'popupmenu'
        %update settings
        handles.settings.analyze.sequencingSource = s.Value - 1;
        handles.data.analyze.xSource{handles.current.item(1)} = s.Value - 1;
        %Set some options if relative to time
        if isequal(handles.settings.analyze.sequencingSource, 0)
            switch handles.settings.analyze.onset.direction
                case 1
                    handles.button.a_sequencingOnsetEdge.String = getXML(handles.settings.xml.strings, 'Button', 'sequencingLower');
                    if handles.settings.analyze.onset.value > 0
                        handles.settings.analyze.onset.value = handles.settings.analyze.onset.value * -1;
                        handles.edit.a_sequencingOnsetValue.String = num2str(handles.settings.analyze.onset.value);
                    end
                case 2
                    handles.button.a_sequencingOnsetEdge.String = getXML(handles.settings.xml.strings, 'Button', 'sequencingGreater');
                    if handles.settings.analyze.onset.value < 0
                        handles.settings.analyze.onset.value = handles.settings.analyze.onset.value * -1;
                        handles.edit.a_sequencingOnsetValue.String = num2str(handles.settings.analyze.onset.value);
                    end
            end
            switch handles.settings.analyze.offset.direction
                case 1
                    handles.button.a_sequencingOffsetEdge.String = getXML(handles.settings.xml.strings, 'Button', 'sequencingLower');
                    if handles.settings.analyze.offset.value > 0
                        handles.settings.analyze.offset.value = handles.settings.analyze.offset.value * -1;
                        handles.edit.a_sequencingOffsetValue.String = num2str(handles.settings.analyze.offset.value);
                    end
                case 2
                    handles.button.a_sequencingOffsetEdge.String = getXML(handles.settings.xml.strings, 'Button', 'sequencingGreater');
                    if handles.settings.analyze.offset.value < 0
                        handles.settings.analyze.offset.value = handles.settings.analyze.offset.value * -1;
                        handles.edit.a_sequencingOffsetValue.String = num2str(handles.settings.analyze.offset.value);
                    end
            end
        end
    case 'edit'
        %First check that new value is numeric
        if isnan(str2double(s.String))
            s.String = '';
            errordlg(handles.settings.xml.strings, 'Error', 'numeric')
            return
        end
        %Update setting
        switch s
            case handles.edit.a_sequencingOnsetValue
                %Set some options if relative to time
                if isequal(handles.settings.analyze.sequencingSource, 0)
                    if (isequal(handles.settings.analyze.onset.direction, 1) && str2double(s.String) > 0) || (isequal(handles.settings.analyze.onset.direction, 2) && str2double(s.String) < 0)
                        s.String = num2str(str2double(s.String) * -1);
                    end
                end
                handles.settings.analyze.onset.value = str2double(s.String);
            case handles.edit.a_sequencingOffsetValue
                %Set some options if relative to time
                if isequal(handles.settings.analyze.sequencingSource, 0)
                    if (isequal(handles.settings.analyze.offset.direction, 1) && str2double(s.String) > 0) || (isequal(handles.settings.analyze.offset.direction, 2) && str2double(s.String) < 0)
                        s.String = num2str(str2double(s.String) * -1);
                    end
                end
                handles.settings.analyze.offset.value = str2double(s.String);
        end
    case 'pushbutton'
        %Determine whether it is complete button or not
        switch s.String
            case getXML(handles.settings.xml.strings, 'Button', 'computeSequencing')
                %simplify struct path
                file = handles.current.item(1);
                chan = handles.current.item(2);
                source = handles.data.analyze.dataSource{file};
                ttls = handles.data.analyze.pulseSource{file};
                rates = handles.data.analyze.rates{file};
                xSource = handles.settings.analyze.sequencingSource;
                %Check thant sequencing is possible
                if isequal(xSource, 0)
                    %Check that sequencing options fit with current sequence
                    if any((ttls(:, chan) / rates(chan)) + handles.settings.analyze.onset.value <= 0)
                        newValue = (min(ttls(:, chan))-1) / rates(chan) * -1;
                        handles.settings.analyze.onset.value = newValue;
                        handles.edit.a_sequencingOnsetValue.String = num2str(newValue);
                        warndlg(getXML(handles.settings.xml.strings, 'Error', 'sequenceLength'))
                    elseif any((ttls(:, chan) / rates(chan)) + handles.settings.analyze.onset.value > size(source, 1) / rates(chan))
                        newValue = size(source, 1) / rates(chan) - max(ttls(:, chan) / rates(chan));
                        handles.settings.analyze.onset.value = newValue;
                        handles.edit.a_sequencingOnsetValue.String = num2str(newValue);
                        warndlg(getXML(handles.settings.xml.strings, 'Error', 'sequenceLength'))
                    end
                    if any((ttls(:, chan) / rates(chan)) + handles.settings.analyze.offset.value <= 0)
                        newValue = (min(ttls(:, chan))-1) / rates(chan) * -1;
                        handles.settings.analyze.offset.value = newValue;
                        handles.edit.a_sequencingOffsetValue.String = num2str(newValue);
                        warndlg(getXML(handles.settings.xml.strings, 'Error', 'sequenceLength'))
                    elseif any((ttls(:, chan) / rates(chan)) + handles.settings.analyze.offset.value > size(source, 1) / rates(chan))
                        newValue = size(source, 1) / rates(chan) - max(ttls(:, chan) / rates(chan));
                        handles.settings.analyze.offset.value = newValue;
                        handles.edit.a_sequencingOffsetValue.String = num2str(newValue);
                        warndlg(getXML(handles.settings.xml.strings, 'Error', 'sequenceLength'))
                    end
                    %Sequence signals accordingly
                    signals = [];
                    pulses = [];
                    for i = 1:size(ttls, 1)
                        for j = 1:size(source, 2)
                            onset = handles.settings.analyze.onset.value * rates(j);
                            offset = handles.settings.analyze.offset.value * rates(j);
                            range = ttls(i, j) + onset:ttls(i, j) + offset;
                            pulses(i, j) = ((i-1)*(diff([onset, offset])+1)) + (1-onset);
                            signals((i-1)*length(range)+1:i*length(range), j) = source(range, j);
                        end
                    end
                else
                    %Allocate
                    pulses = [];
                    range = cell(size(ttls, 1), size(source, 2));
                    %Loop all ttls
                    for i = 1:size(ttls, 1)
                        %Loop all channes
                        for j = 1:size(source, 2)
                            %Define what are onset and offset directions
                            %and edges, and proceed accordingly
                            if isequal(handles.settings.analyze.onset.direction, 1)
                                x = flip(source(1:ttls(i, j), xSource));
                                switch handles.settings.analyze.onset.edge
                                    case 1
                                        onset = find(x < handles.settings.analyze.onset.value, 1, 'first');
                                    case 2
                                        onset = find(x > handles.settings.analyze.onset.value, 1, 'first');
                                end
                                onset = ttls(i, j) - (onset - 1);
                            else
                                x = source(ttls(i, j):end, xSource);
                                switch handles.settings.analyze.onset.edge
                                    case 1
                                        onset = find(x < handles.settings.analyze.onset.value, 1, 'first');
                                    case 2
                                        onset = find(x > handles.settings.analyze.onset.value, 1, 'first');
                                end
                                onset = ttls(i, j) + (onset - 1);
                            end
                            if isequal(handles.settings.analyze.offset.direction, 1)
                                x = flip(source(1:ttls(i, j), xSource));
                                switch handles.settings.analyze.offset.edge
                                    case 1
                                        offset = find(x < handles.settings.analyze.offset.value, 1, 'first');
                                    case 2
                                        offset = find(x > handles.settings.analyze.offset.value, 1, 'first');
                                end
                                offset = ttls(i, j) - (offset - 1);
                            else
                                x = source(ttls(i, j):end, xSource);
                                switch handles.settings.analyze.offset.edge
                                    case 1
                                        offset = find(x < handles.settings.analyze.offset.value, 1, 'first');
                                    case 2
                                        offset = find(x > handles.settings.analyze.offset.value, 1, 'first');
                                end
                                offset = ttls(i, j) + (offset - 1);
                            end
                            %Store range
                            range{i, j} = onset:offset;
                            %Store pulses
                            pulses(i, j) = (((i-1)*(diff([onset, offset])+1)) + (1-onset));
                        end
                    end
                    %Determine whether sequences need to be interpolated
                    %(this might be required for average view)
                    try
                        cell2mat(range(:, 1));
                    catch
                        %Ask for interpolation
                        answ = questdlg(getXML(handles.settings.xml.strings, 'Command', 'sequenceInterp'), '', ...
                            getXML(handles.settings.xml.strings, 'Command', 'yes'), ...
                            getXML(handles.settings.xml.strings, 'Command', 'no'), ...
                            getXML(handles.settings.xml.strings, 'Command', 'yes'));
                        %Return if window closed
                        if isempty(answ)
                            return
                        end
                        %Switch answer
                        switch answ
                            case getXML(handles.settings.xml.strings, 'Command', 'yes')
                                %Define number of value expected
                                interpVal = inputdlg(getXML(handles.settings.xml.strings, 'Command', 'interpDimension'), '', 1);
                                if isempty(interpVal{1})
                                    return
                                elseif isnan(str2double(interpVal{1}))
                                    errordlg(getXML(handles.settings.xml.strings, 'Error', 'numeric'))
                                    return
                                else
                                    interpVal = str2double(interpVal{1});
                                end
                                %Proceed to interpolation
                                for i = 1:size(range, 1)
                                    for j = 1:size(range, 2)
                                        seq = range{i, j};
                                        xi = round(1:length(seq)/interpVal:length(seq));
                                        yi = interp1(1:length(seq), source(seq, j), xi);
                                        pulses(i, j) = pulses(i, j) / (length(seq)/interpVal);
                                        signals((i-1)*length(yi)+1:i*length(yi), j) = yi;
                                    end
                                end
                            otherwise
                                pulses(i, j) = ((i-1)*(diff([onset, offset])+1)) + (1-onset);
                                signals((i-1)*length(range)+1:i*length(range), j) = source(range, j);
                        end
                    end
                end
                %Assign to handles
                handles.data.analyze.signals{file} = signals;
                handles.data.analyze.pulses{file} = pulses;
            case getXML(handles.settings.xml.strings, 'Button', 'clearSequencing')
                file = handles.current.item(1);
                %Clearhandles
                handles.data.analyze.signals{file} = [];
                handles.data.analyze.pulses{file} = [];
            otherwise
                %Edit settings handles and source
                if isequal(s, handles.button.a_sequencingOnsetEdge)
                    handles.settings.analyze.onset.edge = setdiff(1:2, handles.settings.analyze.onset.edge);
                    switch handles.settings.analyze.onset.edge
                        case 1
                            handles.button.a_sequencingOnsetEdge.String = getXML(handles.settings.xml.strings, 'Button', 'sequencingLower');
                            %Set some options if relative to time
                            if isequal(handles.settings.analyze.sequencingSource, 0)
                                handles.button.a_sequencingOnsetDirection.String = getXML(handles.settings.xml.strings, 'Button', 'sequencingBefore');
                                handles.settings.analyze.onset.direction = handles.settings.analyze.onset.edge;
                                if handles.settings.analyze.onset.value > 0
                                    handles.settings.analyze.onset.value = handles.settings.analyze.onset.value * -1;
                                    handles.edit.a_sequencingOnsetValue.String = num2str(handles.settings.analyze.onset.value);
                                end
                            end
                        case 2
                            handles.button.a_sequencingOnsetEdge.String = getXML(handles.settings.xml.strings, 'Button', 'sequencingGreater');
                            %Set some options if relative to time
                            if isequal(handles.settings.analyze.sequencingSource, 0)
                                handles.button.a_sequencingOnsetDirection.String = getXML(handles.settings.xml.strings, 'Button', 'sequencingAfter');
                                handles.settings.analyze.onset.direction = handles.settings.analyze.onset.edge;
                                if handles.settings.analyze.onset.value < 0
                                    handles.settings.analyze.onset.value = handles.settings.analyze.onset.value * -1;
                                    handles.edit.a_sequencingOnsetValue.String = num2str(handles.settings.analyze.onset.value);
                                end
                            end
                    end
                elseif isequal(s, handles.button.a_sequencingOffsetEdge)
                    handles.settings.analyze.offset.edge = setdiff(1:2, handles.settings.analyze.offset.edge);
                    switch handles.settings.analyze.offset.edge
                        case 1
                            handles.button.a_sequencingOffsetEdge.String = getXML(handles.settings.xml.strings, 'Button', 'sequencingLower');
                            %Set some options if relative to time
                            if isequal(handles.settings.analyze.sequencingSource, 0)
                                handles.button.a_sequencingOffsetDirection.String = getXML(handles.settings.xml.strings, 'Button', 'sequencingBefore');
                                handles.settings.analyze.offset.direction = handles.settings.analyze.offset.edge;
                                if handles.settings.analyze.offset.value > 0
                                    handles.settings.analyze.offset.value = handles.settings.analyze.offset.value * -1;
                                    handles.edit.a_sequencingOffsetValue.String = num2str(handles.settings.analyze.offset.value);
                                end
                            end
                        case 2
                            handles.button.a_sequencingOffsetEdge.String = getXML(handles.settings.xml.strings, 'Button', 'sequencingGreater');
                            %Set some options if relative to time
                            if isequal(handles.settings.analyze.sequencingSource, 0)
                                handles.button.a_sequencingOffsetDirection.String = getXML(handles.settings.xml.strings, 'Button', 'sequencingAfter');
                                handles.settings.analyze.offset.direction = handles.settings.analyze.offset.edge;
                                if handles.settings.analyze.offset.value < 0
                                    handles.settings.analyze.offset.value = handles.settings.analyze.offset.value * -1;
                                    handles.edit.a_sequencingOffsetValue.String = num2str(handles.settings.analyze.offset.value);
                                end
                            end
                    end
                elseif isequal(s, handles.button.a_sequencingOnsetDirection)
                    handles.settings.analyze.onset.direction = setdiff(1:2, handles.settings.analyze.onset.direction);
                    switch handles.settings.analyze.onset.direction
                        case 1
                            handles.button.a_sequencingOnsetDirection.String = getXML(handles.settings.xml.strings, 'Button', 'sequencingBefore');
                            %Set some options if relative to time
                            if isequal(handles.settings.analyze.sequencingSource, 0)
                                handles.button.a_sequencingOnsetEdge.String = getXML(handles.settings.xml.strings, 'Button', 'sequencingLower');
                                handles.settings.analyze.onset.edge = handles.settings.analyze.onset.direction;
                                if handles.settings.analyze.onset.value > 0
                                    handles.settings.analyze.onset.value = handles.settings.analyze.onset.value * -1;
                                    handles.edit.a_sequencingOnsetValue.String = num2str(handles.settings.analyze.onset.value);
                                end
                            end
                        case 2
                            handles.button.a_sequencingOnsetDirection.String = getXML(handles.settings.xml.strings, 'Button', 'sequencingAfter');
                            %Set some options if relative to time
                            if isequal(handles.settings.analyze.sequencingSource, 0)
                                handles.button.a_sequencingOnsetEdge.String = getXML(handles.settings.xml.strings, 'Button', 'sequencingGreater');
                                handles.settings.analyze.onset.edge = handles.settings.analyze.onset.direction;
                                if handles.settings.analyze.onset.value < 0
                                    handles.settings.analyze.onset.value = handles.settings.analyze.onset.value * -1;
                                    handles.edit.a_sequencingOnsetValue.String = num2str(handles.settings.analyze.onset.value);
                                end
                            end
                    end
                elseif isequal(s, handles.button.a_sequencingOffsetDirection)
                    handles.settings.analyze.offset.direction = setdiff(1:2, handles.settings.analyze.offset.direction);
                    switch handles.settings.analyze.offset.direction
                        case 1
                            handles.button.a_sequencingOffsetDirection.String = getXML(handles.settings.xml.strings, 'Button', 'sequencingBefore');
                            %Set some options if relative to time
                            if isequal(handles.settings.analyze.sequencingSource, 0)
                                handles.button.a_sequencingOffsetEdge.String = getXML(handles.settings.xml.strings, 'Button', 'sequencingLower');
                                handles.settings.analyze.offset.edge = handles.settings.analyze.offset.direction;
                                if handles.settings.analyze.offset.value > 0
                                    handles.settings.analyze.offset.value = handles.settings.analyze.offset.value * -1;
                                    handles.edit.a_sequencingOffsetValue.String = num2str(handles.settings.analyze.offset.value);
                                end
                            end
                        case 2
                            handles.button.a_sequencingOffsetDirection.String = getXML(handles.settings.xml.strings, 'Button', 'sequencingAfter');
                            %Set some options if relative to time
                            if isequal(handles.settings.analyze.sequencingSource, 0)
                                handles.button.a_sequencingOffsetEdge.String = getXML(handles.settings.xml.strings, 'Button', 'sequencingGreater');
                                handles.settings.analyze.offset.edge = handles.settings.analyze.offset.direction;
                                if handles.settings.analyze.offset.value < 0
                                    handles.settings.analyze.offset.value = handles.settings.analyze.offset.value * -1;
                                    handles.edit.a_sequencingOffsetValue.String = num2str(handles.settings.analyze.offset.value);
                                end
                            end
                    end
                end
        end
end
%Call update axis function
updateAnalyze(handles)
%Store GUI Data
guidata(handles.hObject, handles)
end