%% Comments
%Export Results Fcn

%Associated GUI: SAPPIY
%Author: V. Doguet (21/2/2019)
%Updates:
%% Function
function exportResultsFcn(~, ~, handles)

%Retrieve handles
handles = guidata(handles.hObject);
%Set pointer waiting
set(handles.hObject, 'Pointer', 'watch')

table = handles.list.results;
if ~isempty(table.Data)
    %Get path, name and format
    str = datestr(datetime('now'), 'yymmdd_HHMMSS');
    [name, path, filterIndex] = uiputfile({'.mat'; '.csv'}, getXML(handles.settings.xml.strings, 'Command', 'saveAs'), ...
        sprintf('%s%s%s', getXML(handles.settings.xml.strings, 'Label', 'appName'), '_Results_', str));
    %Return if canceled
    if isequal(path, 0) || isequal(name, 0)
        set(handles.hObject, 'Pointer', 'arrow')
        return
    else
    end
    %Save according to the chosen format
    try
        Header = cat(2, table.ColumnName(1:end-2)', table.ColumnName(end));
        Data = cat(2, table.Data(:, 1:end-2), table.Data(:, end));
        switch filterIndex
            case 1  %mat file
                save([path, name], 'Header', 'Data')
            case 2
                fid = fopen([path, name], 'w');
                for j = 1:size(Header, 2)
                    if j > 1
                        fprintf(fid, '%s', ';');
                    end
                    fprintf(fid, '%s', Header{j});
                end
                fprintf(fid, '\r\n');
                for i = 1:size(Data, 1)
                    for j = 1:size(Data, 2)
                        if j > 1
                            fprintf(fid, '%s', ';');
                        end
                        fprintf(fid, '%s', Data{i, j});
                    end
                    fprintf(fid, '\r\n');
                end
                fclose(fid);
        end
    catch exception
        errordlg(getReport(exception))
    end
else
    errordlg(getXML(handles.settings.xml.strings, 'Error', 'noData'))
end

%Reset pointer
set(handles.hObject, 'Pointer', 'arrow')

%Store GUI Data
guidata(handles.hObject, handles)
end