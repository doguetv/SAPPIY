%% Comments
%Function that set or reset original variable state

%Associated GUI: SAPPIY
%Author: V. Doguet (14/12/2018)
%Updates:
%% Function
function handles = resetGUI(handles, option)
if ~exist('option', 'var') || strcmpi(option, 'live')
    %% Reset some live variables
    if ~isfield(handles, 'live')
        handles.live = [];
    end
    if isfield(handles.live, 'session') && ~isempty(handles.live.session)
        %Clear logs
        clearLogFile('', '', handles)
        %Clear lines
        for i = 1:length(handles.live.variables.lines)
            delete(handles.live.variables.lines{i})
        end
        delete(handles.live.session)
        delete(handles.live.listener)
    end
    if isfield(handles.live, 'DOsession') && ~isempty(handles.live.DOsession)
        delete(handles.live.DOsession)
    end
    handles.live.session = [];
    handles.live.DOsession = [];
    handles.live.listener = [];
    handles.live.variables = [];
    %Cleat AI table
    handles.table.AIChannels.Data = [];
    %Hide and disable live panels
    set(findobj(handles.panel.liveControls, 'Style', 'pushbutton'), 'Enable', 'off')
    set(findobj(handles.panel.liveControls, 'Style', 'toggle'), 'Enable', 'off')
    for i = 1:length(handles.panel.livePanels)
        handles.panel.livePanels{i}.Visible = 'off';
        handles.radio.liveView{i}.Enable = 'off';
    end
    %Reset Daq
    daq.reset;
end
%% Reset some analyze variables
if ~exist('option', 'var') || strcmpi(option, 'analyze')
    handles.data.analyze.signals = [];
    handles.data.analyze.pulses = [];
    handles.data.analyze.rates = [];
    handles.fileList = [];
    handles.fileType = [];
    handles.results = [];
    handles.additionalElements = [];
    handles.current.list = [];
    handles.current.item = [];
end
end