%% Comments
%Function that launchs analyze function (if any associated)

%Associated GUI: SAPPIY
%Author: V. Doguet (21/2/2019)
%Updates:
%% Function
function analyzeOptions(s, ~, handles)
%Retrieve handles
handles = guidata(handles.hObject);
%Execute function set as button name
if ~isempty(s.String) && ~strcmpi(s.String, getXML(handles.settings.xml.strings, 'Button', 'na'))
    %If an item has been selected
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
        
        %Check whehter there's a signal treat to apply
        if handles.popup.signalTreats.Value > 1
            files = dir(fullfile(handles.userFcnPath, 'signalTreats', '*.m'));
            [~, script] = fileparts(files(handles.popup.signalTreats.Value-1).name);
            signals(:, chan) = feval(script, signals(:, chan), rates(chan));
        end
        
        %Define which sequences must be processed (according to view option)
        switch handles.settings.analyze.view
            case getXML(handles.settings.xml.strings, 'Radio', 'viewSingle')
                %Define item list
                items = handles.current.item(:, 1:3);
                %Define signal sequences and xData
                stdDiff = (size(signals, 1) / size(pulses, 1));
                b1 = 1 + (ttl-1) * stdDiff;
                b2 = (ttl * stdDiff) - 1;
                range = round(b1:b2);
                if isequal(xSource, 0)
                    currentIndex = pulses(ttl, chan);
                    xData(1, :) = (range - currentIndex) / rates(chan);
                else
                    xData(1, :) = signals(range, xSource);
                end
                sequences(1, :) = signals(range, chan);
            case getXML(handles.settings.xml.strings, 'Radio', 'viewMultiple')
                %Define item list
                items = list(list(:, 1) == file & list(:, end), 1:3);
                %Define signal sequences and xData
                for i = 1:size(items, 1)
                    stdDiff = (size(signals, 1) / size(pulses, 1));
                    b1 = 1 + (items(i, 3)-1) * stdDiff;
                    b2 = (items(i, 3) * stdDiff) - 1;
                    range = round(b1:b2);
                    if isequal(xSource, 0)
                        currentIndex = pulses(items(i, 3), chan);
                        xData(i, :) = (range - currentIndex) / rates(chan);
                    else
                        xData(i, :) = signals(range, xSource);
                    end
                    sequences(i, :) = signals(range, chan);
                end
            case getXML(handles.settings.xml.strings, 'Radio', 'viewAverage')
                %Define item list
                items = [file, chan, list(list(:, 1) == file & list(:, end), 3)'];
                %Define signal sequences and xData
                for i = 3:size(items, 2)
                    stdDiff = (size(signals, 1) / size(pulses, 1));
                    b1 = 1 + (items(i)-1) * stdDiff;
                    b2 = (items(i) * stdDiff) - 1 ;
                    range = round(b1:b2);
                    if isequal(xSource, 0)
                        currentIndex = pulses(items(i), chan);
                        xData(i-2, :) = (range - currentIndex) / rates(chan);
                    else
                        xData(i-2, :) = signals(range, xSource);
                    end
                    sequences(i-2, :) = signals(range, chan);
                end
                %Average signals
                sequences = mean(sequences, 1);
        end
               
        %Determine how many element of same type have been created already
        %Find all indexes in results that match current file, ttl and that
        %have a delete column (in case of multiple variable at each treat)
        indexes = 0;
        for i = 1:size(handles.results, 1)
            if strcmpi(handles.results(i, 1), handles.fileList{file}) && ...
                    strcmpi(handles.results(i, 2),headers{chan}) && ...
                    any(str2num(handles.results{i, 4}) == items(:, 3:end)) && ...
                    any(strfind(handles.results{i, end - 1}, '<html>'))
                indexes = cat(1, indexes, str2double(handles.results(i, 3)));
            end
        end
        %Define element number
        elem = max(indexes) + 1;
        
        %Preset some elements in results (file nb, sequence nb, ttls)
        if size(items, 2) > 3
            results = cat(2, handles.fileList(items(:, 1))', headers(items(:, 2))', num2cell(repmat(num2str(elem), size(sequences, 1), 1)), {num2str(items(:, 3:end))}, cell(size(items, 1), 1), cell(size(items, 1), 1)    );
        else
            results = cat(2, handles.fileList(items(:, 1)), headers(items(:, 2))', num2cell(repmat(num2str(elem), size(sequences, 1), 1)), cellstr(num2str(items(:, 3:end))), cell(size(items, 1), 1), cell(size(items, 1), 1));
        end
        
        %Store usefull variables in a data structure
        data.xData = xData;
        data.sequences = sequences;
        data.rate = rates(chan);
        %Associate callbacks that can be usefull to redraw elements (in case of
        %editing)
        callbacks = {@updateAnalyze, @updateResultsTable};
        
        %Call function associated to clicked process button
        try
            [results, newElements] = feval(s.String, ...
                handles.axes.analyze, ...
                data, ...
                results, ...
                callbacks);
        catch exception
            msgText = getReport(exception);
            errordlg(msgText)
            return
        end
        
        %Call update results function to display results in table
        handles = storeAnalyzeData(handles, results, newElements);
        %Call update axis function to redraw everything
        updateAnalyze(handles)
    end
end
%Store GUI Data
guidata(handles.hObject, handles)
end