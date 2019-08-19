%% Comments
%Function that import different file formats to the target application

%Instructions:
%For '.csv' and '.xls(x)' files, data must be organized in columns. As much
%columns as chanel number plus a rate column and a column for TTL_IN (optional) 

%Associated GUI: SAPPIY
%Author: V. Doguet (12/12/2018)
%Updates:
%% Function
function handles = importFiles(handles)

%Set compatible file formats
formats = {'*.mat'; '*.csv'; '*.xls'; '*.xlsx'};
%Get files
[fname, pname] = uigetfile(formats, 'MultiSelect', 'on');
if isequal(fname, 0) || isequal(pname, 0)
    return
end
%Make GUI pointer watching
set(handles.hObject, 'Pointer', 'watch')
drawnow
%Make the file path as current
cd(pname)

%Create variable with all file pathes
if iscell(fname)
    fileList = cell(length(fname), 1);
    for i = 1:length(fname)
        fileList{i} = [pname, fname{i}];
    end
else
    fileList{1} = [pname, fname];
end

%Loop for file selected
for f = 1:length(fileList)
    
    %Assign variables
    Data = [];
    Header = {};
    TTL_IN = [];
    
    %Retrieve file format
    [~, name, ext] = fileparts(fileList{f});
    
    %Switch between format for importing purpose
    switch ext
        case '.mat'
            temp = load(name);
            %Determine whether there's valid Data
            if isfield(temp, 'Data') && ~isempty(temp.Data)
                %Transpose data if necessary
                if size(temp.Data, 2) > size(temp.Data, 1)
                    temp.Data = temp.Data';
                end
                %Get Data
                Data = temp.Data;
            else
                errordlg(getXML(handles.settings.xml.strings, 'Error', 'importNoData'))
                %Reset Pointer
                set(handles.hObject, 'Pointer', 'arrow')
                return
            end
            %Determine whether there's sample rate
            if isfield(temp, 'SampleRate') && ~isempty(temp.SampleRate)
                %If only one single sample rate, assign same rate to all
                %channels
                if length(temp.SampleRate) < size(temp.Data, 2)
                    temp.SampleRate(1:size(temp.Data, 2)) = temp.SampleRate;
                end
                Rate = temp.SampleRate;  %SampleRate
            else
                errordlg(getXML(handles.settings.xml.strings, 'Error', 'importNoRate'))
                %Reset Pointer
                set(handles.hObject, 'Pointer', 'arrow')
                return
            end
            %Determine whether there's TTLs
            if isfield(temp, 'TTL_IN') && isstruct(temp.TTL_IN) && isfield(temp.TTL_IN, 'indexes') && ~isempty(temp.TTL_IN.indexes)
                %Check whether TTL dimension is the the same than Data
                %dimension
                if size(temp.TTL_IN.indexes, 2) < size(Data, 2)
                    TTL_IN = zeros(size(temp.TTL_IN.indexes, 1), size(Data, 2));
                    for c = 1:size(Data, 2)
                        TTL_IN(:, c) = temp.TTL_IN.indexes * (Rate(c) / temp.TTL_IN.rate);
                    end
                else
                    TTL_IN = temp.TTL_IN.indexes;   %Pulse indices
                end
            end
            %Store Headers
            if isfield(temp, 'Header')
                Header = temp.Header(1:size(temp.Data, 2));
            end
        case '.csv'
            %Get file ID
            fid = fopen([name, ext], 'r');
            if fid<=0 %Make sure file opens ok
                %Reset Pointer
                set(handles.hObject, 'Pointer', 'arrow')
                return
            end
            %Get first line to know number of column
            tline = fgetl(fid);
            %Look for standard delimiter or ask user to determine it
            if any(strfind(tline, ';'))
                delimiter = ';';
            elseif any(strfind(tline, '\t'))
                delimiter = '\t';
            else
                %Ask for delimiter
                delimiter = inputdlg('Define Delimiter', '', 1, {';'});
            end
            try
                newStr = split(tline, delimiter);
            catch
                newStr = strsplit(tline, delimiter);
            end
            colNb = length(newStr);
            formatSpec = '';
            for i=1:colNb
                %Check whether header's empty
                if ~isempty(newStr{i})
                    formatSpec = sprintf('%s%s', formatSpec, '%f');
                else
                    newStr(i) = [];
                end
            end
            headers(1, :) = newStr;
            %Keep reading until having numeric format, and store last
            %char line at every loop (expecting the last char line
            %being Header)
            while isnan(str2double(newStr{1}))
                tline = fgetl(fid);
                try
                    newStr = split(tline, delimiter);
                catch
                    newStr = strsplit(tline, delimiter);
                end
            end
            %Read remaining Data
            data = textscan(fid, formatSpec, 'Delimiter', delimiter);
            fclose(fid);
            %Define whether Rate & TTL information are present in Headers
            [chanCol, rateCol, ttlIndexCol, ttlRateCol] = assignHeaders(headers);
            Header(1, :) = headers(chanCol);
            %Retrieve Data line
            Data = zeros(size(data{1}, 1)+1, length(chanCol));
            for i=1:length(chanCol)
                %Add data from first line which has already been read
                Data(:, i) = cat(1, str2double(newStr{i}), data{i});
            end
            %Get Rate
            Rate = cat(1, str2double(newStr{rateCol}), data{rateCol});
            Rate = Rate(~isnan(Rate));
            %If only one single sample rate, assign same rate to all
            %channels
            if length(Rate) < size(Data, 2)
                Rate(1:size(Data, 2)) = Rate;
            end
            %Get TTL_IN
            if ttlIndexCol <= size(data, 2)
                indexes = cat(1, str2double(newStr{ttlIndexCol}), data{ttlIndexCol});
                indexes = indexes(~isnan(indexes));
                ttlRate = cat(1, str2double(newStr{ttlRateCol}), data{ttlRateCol});
                ttlRate = ttlRate(~isnan(ttlRate));
                %Check whether TTL dimension is the the same than Data
                %dimension
                if ~isempty(indexes)
                    if size(indexes, 2) < size(Data, 2)
                        TTL_IN = zeros(size(indexes, 1), size(Data, 2));
                        for c = 1:size(Data, 2)
                            TTL_IN(:, c) = indexes * (Rate(c) / ttlRate);
                        end
                    else
                        TTL_IN = indexes;   %Pulse indices
                    end
                end
            end
        case {'xls', '.xlsx'}
            %import file
            [data, header] = xlsread([name, ext]);
            %Create Header if not present in imported file
            if isempty(header)
                defChanName = cell(1, size(data, 2));
                for m = 1:size(defChanName, 2)
                    defChanName{m} = sprintf('%s%.0f', 'Column ', m);
                end
                Header = defChanName;
            else
                Header = header;
            end
            %Assign columns to requested elements
            [chanCol, rateCol, ttlIndexCol, ttlRateCol] = assignHeaders(Header);
            %Assign Data
            Data = data(:, chanCol);
            %Reassign Header
            Header = Header(chanCol);
            %Assing sample rate (which must be last column)
            Rate = data(~isnan(data(:, rateCol)), rateCol);
            %Replicate rate to channel number if only one rate known
            if ~isequal(length(Rate), size(Data, 2))
                Rate = repmat(Rate(1), 1, size(Data, 2));
            end
            %Assign TTL
            if ttlIndexCol <= size(data, 2)
                indexes = data(~isnan(data(:, ttlIndexCol)), ttlIndexCol);
                if ~isempty(indexes)
                    TTL_IN = zeros(length(indexes), size(Data, 2));
                    for k = 1:size(Data, 2)
                        if ttlRateCol <= size(data, 2)
                            ttlRate = data(~isnan(data(:, ttlRateCol)), ttlRateCol);
                            TTL_IN(:, k) = indexes * (Rate(k)/ttlRate(1));
                        else
                            TTL_IN(:, k) = indexes;
                        end
                    end
                end
            end
    end
 
    %Determine whether there's TTLs
    if isempty(TTL_IN)
        %Ask user whether he wants to use a channel
        %source or cancel
        answ = questdlg(getXML(handles.settings.xml.strings, 'Command', 'importNoTTL'), ...
            '', ...
            getXML(handles.settings.xml.strings, 'Command', 'channelTTL'), ...
            getXML(handles.settings.xml.strings, 'Command', 'cancel'), ...
            getXML(handles.settings.xml.strings, 'Command', 'channelTTL'));
    else
        %Ask user whether he wants to use found TTLs or use a channel
        %source and function to find TTLs
        answ = questdlg(getXML(handles.settings.xml.strings, 'Command', 'importTTL'), ...
            '', ...
            getXML(handles.settings.xml.strings, 'Command', 'indexTTL'), ...
            getXML(handles.settings.xml.strings, 'Command', 'channelTTL'), ...
            getXML(handles.settings.xml.strings, 'Command', 'cancel'), ...
            getXML(handles.settings.xml.strings, 'Command', 'indexTTL'));
    end
    switch answ
        case getXML(handles.settings.xml.strings, 'Command', 'channelTTL')
            %Ask to use a channel as TTL
            ttlChan = popupdlg(Header, 1, getXML(handles.settings.xml.strings, 'Command', 'selectTTL'));
            if isempty(ttlChan)
                %Reset Pointer
                set(handles.hObject, 'Pointer', 'arrow')
                return
            end
            %Ask for userFcn to use
            fcns = dir(fullfile(handles.userFcnPath, 'read_TTL', '*.m'));
            fcnNames = cell(length(fcns), 1);
            for i = 1:length(fcns)
                fcnNames{i} = fcns(i).name;
            end
            fcnIndex = popupdlg(fcnNames, '', getXML(handles.settings.xml.strings, 'Command', 'selectFcn'));
            %Find pseudo TTL in channel
            [~, fcn] = fileparts(fcns(fcnIndex).name);
            indexes = feval(fcn, Data(:, ttlChan));
            %Assign TTL to all channels according to each sample rate
            TTL_IN = zeros(length(indexes), size(Data, 2));
            for k = 1:size(Data, 2)
                TTL_IN(:, k) = indexes * (Rate(k)/Rate(ttlChan));
            end
        case getXML(handles.settings.xml.strings, 'Command', 'cancel')
            %Reset Pointer
            set(handles.hObject, 'Pointer', 'arrow')
            return
    end
    
    %Assign to handles
    handles.data.analyze.headers{length(handles.fileList) + 1}      = Header;
    handles.data.analyze.dataSource{length(handles.fileList) + 1}	= Data;
    handles.data.analyze.pulseSource{length(handles.fileList) + 1}	= TTL_IN;
    handles.data.analyze.rates{length(handles.fileList) + 1}        = Rate;
    %Use relative time as default xSource
    handles.data.analyze.xSource{length(handles.fileList) + 1}  = 0;
    %Create empty signal and TTL fields (must be filled using sequencing
    %panel)
    handles.data.analyze.signals{length(handles.fileList) + 1}	= [];
    handles.data.analyze.pulses{length(handles.fileList) + 1}   = [];
    
    %Store file in list
    handles.fileList{length(handles.fileList) + 1} = name;
    handles.fileType{length(handles.fileList) + 1} = 'external';
    
    %Store all sequences of new file in current list handle and get the
    %current items
    range = size(handles.current.list, 1) + 1:size(handles.current.list, 1) + size(handles.data.analyze.pulseSource{length(handles.fileList)}, 1);
    handles.current.list(range, 1) = length(handles.fileList);  %File
    handles.current.list(range, 2) = 1; %Channel
    handles.current.list(range, 3) = 1:size(handles.data.analyze.pulseSource{length(handles.fileList)}, 1);   %TTL
    handles.current.list(range, 4) = true;  %Select
    handles.current.item = handles.current.list(range(1), :);
end
%Reset Pointer
set(handles.hObject, 'Pointer', 'arrow')
end
%% Subfunctions
%Assign columns to requested elements
function [chanCol, rateCol, ttlIndexCol, ttlRateCol] = assignHeaders(Header)
otherCol = [];
rateCol = [];
ttlIndexCol = [];
ttlRateCol = [];
for s = 1:length(Header)
    if ~isempty(Header{s})
        if any(strfind(Header{s}, 'SampleRate'))
            rateCol = s;
        elseif any(strfind(Header{s}, 'TTL_IN_Indexes'))
            ttlIndexCol = s;
        elseif any(strfind(Header{s}, 'TTL_IN_Rate'))
            ttlRateCol = s;
        else
            otherCol = cat(1, otherCol, s);
        end
    end
end
%Define rate and ttl column if not autodetermined
if isempty(rateCol)
    rateCol = listdlg('ListString', Header, 'PromptString', 'Select Rate Column', 'SelectionMode', 'single');
end
if isempty(ttlIndexCol)
    listString = cat(2, Header, 'No TTL information');
    index = listdlg('ListString', listString, 'PromptString', 'Select TTL Index Column', 'SelectionMode', 'single');
    if ~isequal(index, length(listString))
        ttlIndexCol = index;
    end
end
if isempty(ttlRateCol) && ~isempty(ttlIndexCol)
    listString = cat(2, Header, 'No TTL information');
    index = listdlg('ListString', listString, 'PromptString', 'Select TTL Rate Column', 'SelectionMode', 'single');
    if ~isequal(index, length(listString))
        ttlRateCol = index;
    end
end
%Redefine otherCol variable accordingly
chanCol = setdiff(otherCol, [rateCol, ttlIndexCol, ttlRateCol]);
% %Select channel columns among other columns
% chanCol = listdlg('ListString', Header(otherCol), 'PromptString', 'Select Channel Column(s)', 'SelectionMode', 'mutiple');
end