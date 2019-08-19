%% Comments
%Listener that store Data when available in Daq session

%Associated GUI: SAPPIY
%Author: V. Doguet (7/1/2019)
%Updates:
%% Function
function getLiveData(s, e, handles)
%Retrieve full handles
handles = guidata(handles.hObject);
%% Plotting
%Retrieve some variables from handles
lines = handles.live.variables.lines;
arithmetic = handles.live.variables.arithmetic;
liveTitle = getXML(handles.settings.xml.strings, 'Toggle', 'recordOn');
ax = lines{1}.Parent;

%Allocate Data Variable
Data = zeros(size(e.Data, 1), length(lines));
%Get data to plot
for chan = 1:size(lines, 1)
    %Determine whether must use raw value or arithmetic
    if isempty(arithmetic{chan})
        Data(:, chan) = e.Data(:, chan);
    else
        %replace source channel(s) in equation
        indexes = strfind(arithmetic{chan}, '#');
        k = 1;
        equation = '';
        for i = 1:2:length(indexes)
            source = str2double(arithmetic{chan}(indexes(i)+1:indexes(i+1)-1));
            equation = sprintf('%s%s%s%s%s', equation, arithmetic{chan}(k:indexes(i)-1), 'Data(:,', num2str(source), ')');
            k = indexes(i+1)+1;
        end
        equation = sprintf('%s%s', equation, arithmetic{chan}(indexes(i+1)+1:end));
        %Replace sample rate if any symbole
        if any(strfind(equation, '§'))
            equation = sprintf('%s%s%s', equation(1:strfind(equation, '§')-1), ...
                num2str(s.Rate), ...
                equation(strfind(equation, '§')+1:end));
        end
        Data(:, chan) = eval(equation);
    end
    %Determine whether it is continuous or finite acquisition and Set line Data
    if isempty(handles.settings.live.AcqTime)
        newY = cat(2, lines{chan}.YData(length(Data)+1:end), Data(:, chan)');
        set(lines{chan}, 'YData', newY)
    else
        newX = cat(2, lines{chan}.XData, e.TimeStamps');
        newY = cat(2, lines{chan}.YData, Data(:, chan)');
        set(lines{chan}, 'XData', newX, 'YData', newY)
    end
end
%% Guideline
%If any guideline, move guideline according to scans acquired
if isfield(handles.live.variables, 'guideline') && ~isempty(handles.live.variables.guideline)
    %Get scans acquired from last call
    scans = length(e.TimeStamps);
    %Edit YData in guideline
    handles.live.variables.guideline.YData = cat(2, handles.live.variables.guideline.YData(scans+1:end), handles.live.variables.guideline.YData(1:scans));
    %Edit Guideline Marker
    for i = 1:length(handles.live.variables.guidelineMarker)
        %Edit Data
        handles.live.variables.guidelineMarker{i}.XData = handles.live.variables.lines{i}.XData(end);
        handles.live.variables.guidelineMarker{i}.YData = handles.live.variables.lines{i}.YData(end);
        %Make sure it is visible or unvisible as associated line
        handles.live.variables.guidelineMarker{i}.Visible = handles.live.variables.lines{i}.Visible;
    end
end
%% TTL IN & OUT
%IN
%Define either manual or analog ttl IN is enabled
if any(handles.settings.live.TTLChecks(1:2))
    %Checker whether there's a manual TLL IN
    if handles.settings.live.TTLChecks(1) && isfield(handles.live.variables.analogIN, 'manual') && handles.live.variables.analogIN.manual
        handles.live.variables.analogIN.ttl = e.TimeStamps(1);
        handles.live.variables.analogIN.manual = false;
        %Store last timeSamp
        ttlIndex = 1 + str2double(handles.text.samplesAcquired.String);
        if isfield(handles.live.variables.analogIN, 'timeStamps')
            handles.live.variables.analogIN.timeStamps = cat(1, handles.live.variables.analogIN.timeStamps, ttlIndex);
        else
            handles.live.variables.analogIN.timeStamps = ttlIndex;
        end
    end
    %Check whether a TTL IN index has been defined already
    if ~isfield(handles.live.variables.analogIN, 'ttl') || isempty(handles.live.variables.analogIN.ttl)
        %If not already defined and analog TTL IN option is enabled, scan in analog signal
        if handles.settings.live.TTLChecks(2)
            signal = Data(:, handles.settings.live.analogINChannel);
            thresh = handles.settings.live.analogINValue;
            switch handles.settings.live.TTLEdges(1)
                case 1
                    cmd1 = 'find(signal > thresh, 1, ''first'')';
                    cmd2 = 'find(signal < thresh, 1, ''first'')';
                case 2
                    cmd1 = 'find(signal < thresh, 1, ''first'')';
                    cmd2 = 'find(signal > thresh, 1, ''first'')';
            end
            %Check whether a TTL is read and store timeStamp
            result = eval(cmd1);
            if ~isempty(result)
                result2 = eval(cmd2);
                if ~isempty(result2) && result > result2
                    handles.live.variables.analogIN.ttl = e.TimeStamps(result);
                    %Store last timeSamp
                    ttlIndex = result + str2double(handles.text.samplesAcquired.String);
                    if isfield(handles.live.variables.analogIN, 'timeStamps')
                        handles.live.variables.analogIN.timeStamps = cat(1, handles.live.variables.analogIN.timeStamps, ttlIndex);
                    else
                        handles.live.variables.analogIN.timeStamps = ttlIndex;
                    end
                end
            end
        end
    else
        %Check whether enough data acquired to fit with sequencing options
        %defined
        if handles.settings.analyze.sequencingSource > 0
            %Relative to a source Channel
            %Get the index of last ttl
            indexTTL = length(lines{handles.settings.analyze.sequencingSource}.XData) - round(s.Rate * (e.TimeStamps(end) - handles.live.variables.analogIN.ttl));
            if isequal(handles.settings.analyze.offset.direction, 1)
                %Here we can throw sequence as soon there is a TTL since we
                %only need a sequence before TTL
                %Determine source signal to look on
                source = flip(lines{handles.settings.analyze.sequencingSource}.YData(1:indexTTL));
                %First focus on offset
                if isequal(handles.settings.analyze.offset.edge, 1)
                    offset = (length(lines{handles.settings.analyze.sequencingSource}.XData) - length(source)) + (find(source < handles.settings.analyze.offset.value, 1, 'first') - 1);
                else
                    offset = (length(lines{handles.settings.analyze.sequencingSource}.XData) - length(source)) + (find(source > handles.settings.analyze.offset.value, 1, 'first') - 1);
                end
                %Secondly focuse on onset (that is also automatically
                %before TTL
                if isequal(handles.settings.analyze.onset.edge, 1)
                    onset = (length(lines{handles.settings.analyze.sequencingSource}.XData) - length(source)) + (find(source < handles.settings.analyze.onset.value, 1, 'first') - 1);
                else
                    onset = (length(lines{handles.settings.analyze.sequencingSource}.XData) - length(source)) + (find(source > handles.settings.analyze.onset.value, 1, 'first') - 1);
                end
            else
                %Here we need to make sure offset threshold has been reached since we
                %have a offset value that occurs after TTL
                %Determine source signal to look on
                source = lines{handles.settings.analyze.sequencingSource}.YData(indexTTL:end);
                %First focus on offset
                if isequal(handles.settings.analyze.offset.edge, 1)
                    offset = find(source < handles.settings.analyze.offset.value, 1, 'first') - 1;
                else
                    offset = find(source > handles.settings.analyze.offset.value, 1, 'first') - 1;
                end
                %Then wait for offset to be reach before lokking for onset
                %(which will obviously be present)
                if ~isempty(offset)
                    %Set good index for offset
                    offset = length(source) - offset;
                    if isequal(handles.settings.analyze.onset.direction, 1)
                        %Before TLL, so requires looking in reversed source signal
                        source = flip(lines{handles.settings.analyze.sequencingSource}.YData(1:indexTTL));
                        if isequal(handles.settings.analyze.onset.edge, 1)
                            onset = (length(lines{handles.settings.analyze.sequencingSource}.XData) - length(source)) + (find(source < handles.settings.analyze.onset.value, 1, 'first') - 1);
                        else
                            onset = (length(lines{handles.settings.analyze.sequencingSource}.XData) - length(source)) + (find(source > handles.settings.analyze.onset.value, 1, 'first') - 1);
                        end
                    else
                        %After TTL, no need to flip source signal
                        if isequal(handles.settings.analyze.onset.edge, 1)
                            onset = length(source) - (find(source < handles.settings.analyze.onset.value, 1, 'first') - 1);
                        else
                            onset = length(source) - (find(source > handles.settings.analyze.onset.value, 1, 'first') - 1);
                        end
                    end
                end
            end       
        else
            %Relative to Time
            delay = e.TimeStamps(end) - handles.live.variables.analogIN.ttl;
            trigIndex = round(s.Rate * delay);
            %Define onset a offset indexes
            if isequal(handles.settings.analyze.offset.direction, 1) && isequal(handles.settings.analyze.offset.edge, 1)
                %Here we can throw sequence as soon there is a TTL since we
                %only need a sequence before TTL
                onset = trigIndex - handles.settings.analyze.onset.value * s.Rate;
                offset = trigIndex - handles.settings.analyze.offset.value * s.Rate;
            elseif isequal(handles.settings.analyze.offset.direction, 2) && isequal(handles.settings.analyze.offset.edge, 2)
                %Here we need to make sure enough time elapsed since we
                %have a time period after TTL to store
                if delay > handles.settings.analyze.offset.value
                    if isequal(handles.settings.analyze.onset.direction, 1) && isequal(handles.settings.analyze.onset.edge, 1)
                        onset = trigIndex - handles.settings.analyze.onset.value * s.Rate;
                    elseif isequal(handles.settings.analyze.onset.direction, 2) && isequal(handles.settings.analyze.onset.edge, 2)
                        onset = trigIndex + handles.settings.analyze.onset.value * s.Rate;
                    end
                    offset = trigIndex - handles.settings.analyze.offset.value * s.Rate;
                end
            else
                error('Impossible case. Requires debug')
            end
        end
        %Get X and Y sequences
        if exist('onset', 'var') && exist('offset', 'var') && ~isempty(onset) && ~isempty(offset)
            if onset > offset
                Y = zeros(abs(onset-offset)+1, length(lines));
                for i = 1:length(lines)
                    Y(:, i) = lines{i}.YData(end - onset:end - offset);
                end
                %Define X of TTL
                delay = e.TimeStamps(end) - handles.live.variables.analogIN.ttl;
                ttlIndexFromEnd = offset - round(s.Rate * delay);
                X = size(Y, 1) + ttlIndexFromEnd;
                %Send sequence ton analyze only if in reconrd mode
                if strcmpi(ax.Title.String, liveTitle)
                    %Call external function
                    handles = addSequenceFromLive(X, Y, handles);
                end
            end
            %Delete last timeStamp
            handles.live.variables.analogIN.ttl = [];
        end
    end
    %Update handles
    guidata(handles.hObject, handles)
end
%OUT
if handles.settings.live.TTLChecks(4)
    %Get properties
    signal = Data(:, handles.live.variables.analogOUT.channel);
    thresh = handles.live.variables.analogOUT.value;
    %Get script name
    files = dir(fullfile(handles.userFcnPath, 'send_ttl', '*.m'));
    if ~isempty(files)
        [~, script] = fileparts(files(handles.settings.live.OUTFcn(2)).name);
        %First Check if TTL is armed
        if handles.live.variables.analogOUT.armed
            %Check if condition is verified to send ttl
            switch handles.live.variables.analogOUT.edge
                case 1  %Rising
                    if any(signal > thresh)
                        %Evaluate function
                        feval(script, handles.live.DOsession, handles.settings.live.manualOUTPort)
                        %Disarm TTL
                        handles.live.variables.analogOUT.armed = false;
                        guidata(handles.hObject, handles)
                    end
                case 2  %Falling
                    if any(signal < thresh)
                        %Evaluate function
                        feval(script, handles.live.DOsession, handles.settings.live.manualOUTPort)
                        %Disarm TTL
                        handles.live.variables.analogOUT.armed = false;
                        guidata(handles.hObject, handles)
                    end
            end
        else
            %Wait for signal goig to reverse edge to rearm TTL
            switch handles.live.variables.analogOUT.edge
                case 1  %Rising
                    if any(signal < thresh)
                        %Rearm TTL
                        handles.live.variables.analogOUT.armed = true;
                        guidata(handles.hObject, handles)
                    end
                case 2  %Falling
                    if any(signal > thresh)
                        %Rearm TTL
                        handles.live.variables.analogOUT.armed = true;
                        guidata(handles.hObject, handles)
                    end
            end
        end
    else
        warning(getXML(handles.settings.xml.strings, 'Error', 'noTTLOUT'))
    end
end
%% Record mode
if strcmpi(ax.Title.String, liveTitle)
    %% Storing
    %Retrieve fid in source User Data
    fid = handles.live.variables.fid;
    %Store data in log file if in record mode
    data = cat(1, e.TimeStamps', Data');
    fwrite(fid, data, 'double');
    %Update samples counting
    handles.text.samplesAcquired.String = num2str(str2double(handles.text.samplesAcquired.String)+size(Data, 1));
end
%% Reset play control at the end if finite acquisition mode
if ~isempty(handles.settings.live.AcqTime) && isequal(s.Rate*handles.settings.live.AcqTime, double(s.ScansAcquired))
    %Delete Listener
    delete(handles.live.listener);
    %Close log file
    fclose(handles.live.variables.fid);
    delete(handles.axes.live.Title)
    %Update uicontrol
    [label, attributes] = getXML(handles.settings.xml.strings, 'Toggle', 'playOff', {'color'});
    handles.button.previewLive.String = label;
    handles.button.previewLive.BackgroundColor = eval(attributes{1});
    handles.button.previewLive.Value = 0;
    %Check Hiding Fcn to enable flushing data
    handles = checkHiding(handles);
    %Store GUI Data
    guidata(handles.hObject, handles)
end
end