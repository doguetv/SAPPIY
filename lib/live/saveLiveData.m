%% Comments
%Function that saves live Data from log file to target file, with slected
%format

%Associated GUI: SAPPIY
%Author: V. Doguet (9/1/2019)
%Updates:
%% Function
function saveLiveData(~, ~, handles)
%Retrieve handles
handles = guidata(handles.hObject);

%Make GUI pointer watching
set(handles.hObject, 'Pointer', 'watch')

if isfield(handles.live.variables, 'lines') && ~isempty(handles.live.variables.lines)
    %Open log file
    fid = fopen(fullfile(handles.resourcesPath, 'log.bin'), 'r');
    %Read Data
    chanNb = length(handles.live.variables.lines);
    data = fread(fid, [chanNb+1, Inf], 'double');
    Data = data';
    fclose(fid);
    
    %Return if log file is empty
    if isempty(Data)
        errordlg(getXML(handles.settings.xml.strings, 'Error', 'noData'))
        %Reset GUI pointer
        set(handles.hObject, 'Pointer', 'arrow')
        return
    end
    
    %Select the path, filename and output format
    [name, path, filterIndex] = uiputfile({'.mat'; '.csv'}, 'Save As');
    %Return if canceled
    if isequal(path, 0) || isequal(name, 0)
        %Reset GUI pointer
        set(handles.hObject, 'Pointer', 'arrow')
        return
    end
    
    %Set Header
    Header = {'Time', handles.table.AIChannels.Data{:, 2}};
    
    %Set Sample Rate
    SampleRate = handles.live.session.Rate;
    %Add rate to all channels if not already done
    if length(SampleRate) < size(Data, 2)
        SampleRate(1:size(Data, 2)) = SampleRate;
    end
    
    TTL_IN.indexes = [];
    TTL_IN.rate = [];
    %Get TTl indexes if any
    if isfield(handles.live.variables.analogIN, 'timeStamps')
        TTL_IN.indexes = handles.live.variables.analogIN.timeStamps;
        TTL_IN.rate = SampleRate(1);
    end
    
    %Save according to the chosen format
    switch filterIndex
        case 1  %mat file
            save([path, name], 'Header', 'Data', 'TTL_IN', 'SampleRate')
        case 2
            %Add sampel Rate label
            Header = cat(2, Header, {'SampleRate'});
            %Concatenate data and sample rate
            Table = num2cell(Data);
            Table(1:length(SampleRate), size(Header, 2)) = num2cell(SampleRate);
            %Add TTL if any
            if ~isempty(TTL_IN.indexes)
                %Define header
                Header = cat(2, Header, {'TTL_IN_Indexes', 'TTL_IN_Rate'});
                %Concatenate TTL information
                Table(1:length(TTL_IN.indexes), size(Header, 2)-1) = num2cell(TTL_IN.indexes);
                Table(1, size(Header, 2)) = num2cell(TTL_IN.rate);
            end
            %Print Header to output file
            fid = fopen([path, name], 'w');
            fprintf(fid, '%s;', Header{:});
            fprintf(fid, '\r\n');
            %print Data to output file
            for i = 1:size(Table, 1)
                fprintf(fid, '%f;', Table{i, :});
                fprintf(fid, '\r\n');
            end
            fclose(fid);
    end
    
    %Reset GUI pointer
    set(handles.hObject, 'Pointer', 'arrow')
else
    errordlg(getXML(handles.settings.xml.strings, 'Error', 'noData'))
    %Reset GUI pointer
    set(handles.hObject, 'Pointer', 'arrow')
    return
end
end