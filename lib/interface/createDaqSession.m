%% Comments
%Function to set data acquisition device connexion through interactive
%window

%Associated GUI: SAPPIY
%Author: V. Doguet (7/1/2019)
%Updates:
%% Function
function [clockedSession, unclockedSession] = createDaqSession

%Parameters
step.total = [];
step.current = 0;
clockedSession = [];
unclockedSession = [];
vendors = [];
vendor = [];
devices = [];
device = [];

%Open Interface Window
ftemp = figure('Name', 'Daq Session Creator Tool', ...
    'NumberTitle', 'off', ...
    'Position', .3 * get(0, 'ScreenSize'), ...
    'Menu', 'none', ...
    'Resize', 'off', ...
    'Visible', 'on', ...
    'CloseRequestFcn', @closeFcn);
set(ftemp, 'pointer', 'watch')

%Create label title
title = sprintf('%s', 'Scanning available data acquisition devices.');
text = uicontrol('Parent', ftemp, ...
    'Style', 'text', ...
    'units', 'normalized', ...
    'position', [.1, .8, .8, .15], ...
    'String', title, ...
    'FontSize', 10, ...
    'FontWeight', 'bold', ...
    'HorizontalAlignment', 'left');

%Check for installed adaptors
vendors = daq.getVendors;
set(ftemp, 'pointer', 'arrow')

if isempty(vendors)
    %Display Error
    delete(ftemp)
    errordlg(sprintf('%s', 'No data acquisition device available.'));
else
    %If some adaptors found, determine the one to use
    %Change interface window a little
    ftemp.Position = .4 * get(0, 'ScreenSize');
    movegui(ftemp, 'center')
    
    %List available vendors
    labelVendors = cell(length(vendors)+1, 1);
    labelVendors{1} = '-';
    for ii = 1:length(vendors)
        labelVendors{ii+1} = vendors(ii).ID;
    end
    
    %Create new controls in interface window
    title = sprintf('%s', 'Select data acquisition device to use');
    text.String = title;
    control{1} = uicontrol('Parent', ftemp, ...
        'Style', 'popup', ...
        'units', 'normalized', ...
        'position', [.1, .7, .8, .15], ...
        'String', labelVendors, ...
        'Value', 1, ...
        'Callback', @updateDevices);
    control{2} = uicontrol('Parent', ftemp, ...
        'Style', 'popup', ...
        'units', 'normalized', ...
        'position', [.1, .55, .8, .15], ...
        'Visible', 'off');
    next = uicontrol('Parent', ftemp, ...
        'Style', 'push', ...
        'units', 'normalized', ...
        'position', [.4, .1, .2, .15], ...
        'String', 'Next', ...
        'FontWeight', 'bold', ...
        'Callback', @nextStep);
    finish = uicontrol('Parent', ftemp, ...
        'Style', 'push', ...
        'units', 'normalized', ...
        'position', [.7, .1, .2, .15], ...
        'String', 'Cancel', ...
        'FontWeight', 'bold', ...
        'Callback', @finishStep);
    
    %Wait until finishing setting or calling closing function
    uiwait(ftemp)
end

delete(ftemp)
%% Subfunctions
    function nextStep(~, ~)
        %Perform step
        if exist('control', 'var') && ~isempty(control{1}) && strcmpi(control{1}.Tag, 'noSet')
            %Increment step counter
            step.current = step.current + 1;
            %Manage controls according to current step count
            manageControls
        else
            result = doStep;
            if result
                %Increment step counter
                step.current = step.current + 1;
                %Manage controls according to current step count
                manageControls
            end
        end
    end

    function finishStep(s, ~)
        if strcmpi(s.String, 'Finish')
            doStep;
            uiresume(ftemp)
        else
            quit
        end
    end

%Function that manage controllers
    function manageControls
        %First delete existent controls
        for i = 1:length(control)
            delete(control{i})
        end
        %Update step label
        title = sprintf('%s%.0f%s%.0f%s', 'Step ', step.current, '/', step.total, [' ** ', device.Subsystems(step.current).SubsystemType, ' **']);
        text.String = title;
        %Prepare step
        prepareStep
        %Disable or set some sontrols
        if isequal(step.current, step.total)
            next.Enable = 'off';
            finish.String = 'Finish';
        else
            next.Enable = 'on';
            finish.String = 'Cancel';
        end
    end

%Function that perform code according to the current step
    function result = doStep
        %Start busy state
        set(ftemp, 'pointer', 'watch')
        try
            %Create Daq Session
            if isempty(device)
                %Get vendor ID
                vendor = vendors(control{1}.Value - 1).ID;
                %Define device ID
                device = devices(control{2}.Value);
                %Define steps according to device subsystems
                step.total = length(device.Subsystems);
            else
                switch device.Subsystems(step.current).SubsystemType
                    case 'AnalogInput'  %Create AI Object
                        %Retrieve properties
                        chanIndexes = textscan(control{1}.Data{strcmpi(control{1}.Data(:, 1), 'ChannelNames'), 2}, '%s', 'Delimiter', '\');
                        measType = control{1}.Data{strcmpi(control{1}.Data(:, 1), 'MeasurementTypesAvailable'), 2};
                        termConf = control{1}.Data{strcmpi(control{1}.Data(:, 1), 'TerminalConfigsAvailable'), 2};
                        range = sscanf(control{1}.Data{strcmpi(control{1}.Data(:, 1), 'RangesAvailable'), 2}, '%f');
                        rate = str2double(sprintf('%s', control{1}.Data{strcmpi(control{1}.Data(:, 1), 'RateLimit'), 2}));
                        %Create clocked session if not already created
                        if isempty(clockedSession)
                            clockedSession = daq.createSession(vendor);
                        end
                        %Add channels
                        AIchannels = addAnalogInputChannel(clockedSession, device.ID, chanIndexes{1}, measType);
                        for i = 1:length(AIchannels)
                            AIchannels(i).TerminalConfig = termConf;
                            AIchannels(i).Range = [range, abs(range)];
                        end
                        %Set Sample Rate
                        clockedSession.Rate = rate;
                        clockedSession.IsContinuous = true;
                    case 'DigitalIO' %Create DIO Object
                        %Retrieve properties
                        chanIndexes = textscan(control{1}.Data{strcmpi(control{1}.Data(:, 1), 'ChannelNames'), 2}, '%s', 'Delimiter', '\');
                        measType = control{1}.Data{strcmpi(control{1}.Data(:, 1), 'MeasurementTypesAvailable'), 2};
                        %Create unclocked session if not already created
                        if isempty(unclockedSession)
                            unclockedSession = daq.createSession(vendor);
                        end
                        %Add digital Channel
                        addDigitalChannel(unclockedSession, device.ID, chanIndexes{1}, measType);
                        %                     case 'CounterInput'
                        %                         %Retrieve properties
                        %                         chanIndexes = textscan(control{1}.Data{strcmpi(control{1}.Data(:, 1), 'ChannelNames'), 2}, '%s', 'Delimiter', '\');
                        %                         measType = control{1}.Data{strcmpi(control{1}.Data(:, 1), 'MeasurementTypesAvailable'), 2};
                        %                         rate = str2double(sprintf('%s', control{1}.Data{strcmpi(control{1}.Data(:, 1), 'RateLimit'), 2}));
                        %                         %Create unclocked session if not already created
                        %                         if isempty(unclockedSession)
                        %                             unclockedSession = daq.createSession(vendor);
                        %                         end
                        %                         %Add counter input channel
                        %                         addCounterInputChannel(unclockedSession, device.ID, chanIndexes{1}, measType);
                end
            end
            %Return result
            result = true;
        catch
            result = false;
        end
        %End busy state
        set(ftemp, 'pointer', 'arrow')
    end

%Close Fcn
    function closeFcn(~, ~)
        quit
    end

%Quit Fcn
    function quit
        %Clear sessions if any
        if ~isempty(clockedSession)
            delete(clockedSession)
            clockedSession = [];
        end
        if ~isempty(unclockedSession)
            delete(unclockedSession)
            unclockedSession = [];
        end
        %Release Daq
        daq.reset;
        %Resume GUI
        uiresume(ftemp)
    end
%% Session Object Fcns
%Function that updates devices according to selected vendor
    function updateDevices(s, ~)
        %Get Devices of selected vendor
        devices = daq.getDevices;
        toDelete = [];
        k = 1;
        labelDevices = {};
        for i = 1:length(devices)
            if isequal(devices(i).Vendor.ID, s.String{s.Value})
                labelDevices{k} = devices(i).Description;
                k = k+1;
            else
                toDelete = cat(1, toDelete, i);
            end
        end
        devices(toDelete) = [];
        %Update controller 2
        if ~isempty(labelDevices)
            control{2}.String = labelDevices;
            control{2}.Value = 1;
            control{2}.Visible = 'on';
        else
            control{2}.Visible = 'off';
        end
    end
%% Prepare / Perform Step
    function prepareStep
        control{1} = uicontrol('units', 'normalized', ...
            'position', [.1, .7, .2, .15], ...
            'Style', 'push', ...
            'String', 'Create Object', ...
            'FontWeight', 'bold', ...
            'Tag', 'noSet', ...
            'Callback', @performStep);
    end

    function performStep(s, ~)
        %Switch according to subsystem
        switch device.Subsystems(step.current).SubsystemType
            case {'AnalogInput', 'DigitalIO'}
                setObject
                %Delete source
                delete(s)
            otherwise
                warndlg('No settings available for the current object')
        end
    end
%% Set Object Fcns
    function setObject
        %Create table control to list subsystem properties
        control{1} = uitable('units', 'normalized', ...
            'position', [.1, .3, .8, .55], ...
            'ColumnName', {'Properties', 'Values', 'Editing'}, ...
            'ColumnEditable', logical([0, 0, 0]), ...
            'ColumnFormat', {'char', 'char', 'char',}, ...
            'CellSelectionCallback', @editObject);
        %Resize columns to fit window size
        position = getpixelposition(control{1});
        set(control{1}, 'ColumnWidth', {position(3)/2.5, position(3)/4, position(3)/4})
        %List subsystem properties and values
        fNames = fieldnames(device.Subsystems(step.current));
        fValues = cell(length(fNames), 1);
        tData = [];
        for i = 1:length(fNames)
            fValues{i} = getfield(device.Subsystems(step.current), fNames{i});
            %Automatically display value if single, wait for user editing if multiple
            if ischar(fValues{i})
                %Enqueue Properties and values in table
                tData = cat(1, tData, [fNames(i), fValues(i), {''}]);
            elseif isnumeric(fValues{i}) && isequal(length(fValues{i}), 1)
                %Enqueue Properties and values in table
                tData = cat(1, tData, [fNames(i), num2str(fValues{i}), {''}]);
            elseif iscell(fValues{i}) && isequal(length(fValues{i}), 1)
                %Enqueue Properties and values in table
                tData = cat(1, tData, [fNames(i), fValues{i}{1}, {''}]);
            else
                %Enqueue Properties and values in table
                tData = cat(1, tData, [fNames(i), {''}, {'<html><table color="red"><TR><TD><b>Edit</b></TR></TD></table></html>'}]);
            end
        end
        %update source table data
        set(control{1}, 'Data', tData)
        %Disable next button since there are missing properties in AI
        %object
        next.Enable = 'off';
    end

%Function that control AI table editing
    function editObject(s, e)
        if ~isempty(e.Indices) && isequal(e.Indices(2), 3) && ~isempty(s.Data{e.Indices(1), 3})
            %Get fieldNames
            fNames = fieldnames(device.Subsystems(step.current));
            %Get Possible values
            fValues = getfield(device.Subsystems(step.current), fNames{e.Indices(1)});
            %Chose approprate option according to format
            if iscell(fValues)
                index = listdlg('PromptString', fNames{e.Indices(1)},...
                    'SelectionMode', 'multiple',...
                    'ListString', fValues);
                %Edit data in source table
                for k =1:length(index)
                    toPrint = sprintf('%s\\', fValues{index});
                end
                toPrint(end) = '';
                s.Data{e.Indices(1), 2} = toPrint;
                s.Data{e.Indices(1), 3} = '<html><table color="black"><TR><TD><b>Edit</b></TR></TD></table></html>';
            elseif isnumeric(fValues)
                if any(strfind(fNames{e.Indices(1)}, 'Rate'))
                    out = inputdlg(sprintf('%s%s%s%s%s', 'Rate [', num2str(fValues(1)), '-', num2str(fValues(2)), ' Hz]'));
                    if isnan(str2double(out{1}))
                        errordlg('Value must be of numeric format')
                        return
                    end
                    %Edit data in source table
                    s.Data{e.Indices(1), 2} = out{1};
                    s.Data{e.Indices(1), 3} = '<html><table color="black"><TR><TD><b>Edit</b></TR></TD></table></html>';
                end
            elseif isobject(fValues)
                switch class(fValues)
                    case 'daq.Range'
                        option = cell(length(fValues), 1);
                        for j = 1:length(fValues)
                            option{j} = sprintf('%s%s%s%s%s', num2str(fValues(j).Min), '/', num2str(fValues(j).Max), ' ', fValues(j).Units);
                        end
                        index = listdlg('PromptString', fNames{e.Indices(1)},...
                            'SelectionMode', 'multiple',...
                            'ListString', option);
                        %Edit data in source table
                        s.Data{e.Indices(1), 2} = option{index};
                        s.Data{e.Indices(1), 3} = '<html><table color="black"><TR><TD><b>Edit</b></TR></TD></table></html>';
                end
            end
        end
        %check AI properties to enable next button when all properties set
        if step.current < step.total
            state = 'on';
            for i = 1:size(s.Data, 1)
                if isempty(s.Data{i, 2})
                    state = 'off';
                    break
                end
            end
            next.Enable = state;
        end
    end
end