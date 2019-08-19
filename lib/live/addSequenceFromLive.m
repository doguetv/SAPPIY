%% Comments
%Add sequences in analyze panel from live data

%Associated GUI: SAPPIY
%Author: V. Doguet (25/2/2019)
%Updates:
%% Function
function handles = addSequenceFromLive(X, Y, handles)

%Find associated file in list
if ~isempty(handles.fileList)
    %Define a default new index that will be replaced in
    %for loop if file already exists 
    index = length(handles.fileList) + 1;
    for i =1:length(handles.fileList)
        if strcmpi(handles.fileList{i}, handles.live.variables.currentSession)
            index = i;
            break
        end
    end
else
    index = 1;
end
%Store file name and file type
handles.fileList{index} = handles.live.variables.currentSession;
handles.fileType{index} = 'live';

%Store data in handles
if length(handles.data.analyze.signals) >= index
    %Interpolate data to fit with standard size (size of first sequence
    %added from live)
    ttl = size(handles.data.analyze.pulses{index}, 1);
    stdSize = round(size(handles.data.analyze.signals{index}, 1) / ttl);
    newSize = size(Y, 1);
    xi = 1:newSize/stdSize:newSize;
    if ~isequal(xi(end), newSize)
        xi = cat(2, xi, newSize);
    end
    Yi = interp1(1:newSize, Y, xi);
    Xi = round(X/(newSize/stdSize));
    %Store in handles
    handles.data.analyze.pulses{index}(ttl+1, :) = repmat(size(handles.data.analyze.signals{index}, 1) + Xi, 1, size(Yi, 2));   %Pulse indices
    handles.data.analyze.signals{index} = cat(1, handles.data.analyze.signals{index}, Yi);   %Signal
else
    handles.data.analyze.signals{index} = Y;   %Signal
    handles.data.analyze.pulses{index} = repmat(X, 1, size(Y, 2));   %Pulse indices
    %Rate
    %If only one single sample rate, assign same rate to all
    %channels
    if length(handles.live.session.Rate) < size(Y, 2)
        handles.data.analyze.rates{index}(1:size(Y, 2)) = handles.live.session.Rate;
    else
        handles.data.analyze.rates{index} = handles.live.session.Rate;
    end
    %Headers
    handles.data.analyze.headers{index} = handles.table.AIChannels.Data(:, 2)';
end

%Store X source and indexes for current sequence
handles.data.analyze.xSource{index} = handles.popup.sequencingSource.Value - 1;

%Store all sequences of new file in current list handle and get the
%current items
range = size(handles.current.list, 1) + 1;
handles.current.list(range, 1) = length(handles.fileList);
%Define which is the new channel
if size(handles.current.list, 2) < 2 || range == 1
    handles.current.list(range, 2) = 1;
else
    handles.current.list(range, 2) = handles.current.list(range-1, 2);
end
handles.current.list(range, 3) = size(handles.data.analyze.pulses{length(handles.fileList)}, 1);
handles.current.list(range, 4) = true;
handles.current.item = handles.current.list(range(1), :);

%Call external functions to update controls according to the
%new imported file(s)
checkHiding(handles);
handles = updateSelectionTable(handles);
updateAnalyze(handles);
end