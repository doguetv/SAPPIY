%% Comments
%Function that edits language in all GUI

%Associated GUI: SAPPIY
%Author V. Doguet (20/2/2019)
%Updates:
%% Function
function handles = resetLanguage(handles)
%% Labels
[label, attributes] = getXML(handles.settings.xml.strings, 'Label', 'xLabel', {'size', 'weight'});
handles.axes.live.XLabel.String = label;
handles.axes.live.XLabel.FontSize = str2double(attributes{1});
handles.axes.live.XLabel.FontWeight = attributes{2};
[label, attributes] = getXML(handles.settings.xml.strings, 'Label', 'yLabel', {'size', 'weight'});
handles.axes.live.YLabel.String = label;
handles.axes.live.YLabel.FontSize = str2double(attributes{1});
handles.axes.live.YLabel.FontWeight = attributes{2};
%% Menu Labels
handles.menu.main{1}.Label = getXML(handles.settings.xml.strings, 'Menu', 'live');
handles.menu.main{1}.Children(2).Label = getXML(handles.settings.xml.strings, 'Menu', 'session');
handles.menu.main{1}.Children(1).Label = getXML(handles.settings.xml.strings, 'Menu', 'saveLive');
handles.menu.main{2}.Children(3).Label = getXML(handles.settings.xml.strings, 'Menu', 'newSession');
handles.menu.main{2}.Children(2).Label = getXML(handles.settings.xml.strings, 'Menu', 'loadSession');
handles.menu.main{2}.Children(1).Label = getXML(handles.settings.xml.strings, 'Menu', 'saveSession');
handles.menu.main{3}.Label = getXML(handles.settings.xml.strings, 'Menu', 'analyze');
handles.menu.main{3}.Children(2).Label = getXML(handles.settings.xml.strings, 'Menu', 'import');
handles.menu.main{3}.Children(1).Label = getXML(handles.settings.xml.strings, 'Menu', 'export');
handles.menu.main{4}.Label = getXML(handles.settings.xml.strings, 'Menu', 'view');
handles.menu.main{4}.Children(2).Label = getXML(handles.settings.xml.strings, 'Menu', 'live');
handles.menu.main{4}.Children(1).Label = getXML(handles.settings.xml.strings, 'Menu', 'analyze');
handles.menu.main{5}.Label = getXML(handles.settings.xml.strings, 'Menu', 'help');
handles.menu.main{5}.Children(2).Label = getXML(handles.settings.xml.strings, 'Menu', 'language');
handles.menu.main{5}.Children(1).Label = getXML(handles.settings.xml.strings, 'Menu', 'userManual');
handles.contextMenu.liveAxis.Children.Label = getXML(handles.settings.xml.strings, 'Menu', 'backgroundColor');
handles.contextMenu.analyzeAxis.Children(3).Label = getXML(handles.settings.xml.strings, 'Menu', 'backgroundColor');
handles.contextMenu.analyzeAxis.Children(2).Label = getXML(handles.settings.xml.strings, 'Menu', 'lineColor');
handles.contextMenu.analyzeAxis.Children(2).Children(2).Label = getXML(handles.settings.xml.strings, 'Menu', 'mainColor');
handles.contextMenu.analyzeAxis.Children(2).Children(1).Label = getXML(handles.settings.xml.strings, 'Menu', 'secondaryColor');
handles.contextMenu.analyzeAxis.Children(1).Label = getXML(handles.settings.xml.strings, 'Menu', 'exportChart');
%% Table
%AI Table
listOfLabel = {'chanIndex', ...
    'chanName', ...
    'display', ...
    'color'};
colLabels = cell(1, length(listOfLabel));
colFormat = cell(1, length(listOfLabel));
colEdit = false(1, length(listOfLabel));
for ii = 1:length(listOfLabel)
    [label, attributes] = getXML(handles.settings.xml.strings, 'Table', listOfLabel{ii}, {'format', 'editable'});
    colLabels{ii} = label;
    colFormat{ii} = attributes{1};
    colEdit(ii) = eval(attributes{2});
end
set(handles.table.AIChannels, 'ColumnName', colLabels, ...
    'ColumnEditable', colEdit, ...
    'ColumnFormat', colFormat)
%Analyze File explorer
listOfLabel = {'delete', ...
    'file', ...
    'channel', ...
    'sequence', ...
    'selection'};
colLabels = cell(1, length(listOfLabel));
for ii = 1:length(listOfLabel)
    label = getXML(handles.settings.xml.strings, 'Table', listOfLabel{ii});
    colLabels{ii} = label;
end
set(handles.list.selection, 'ColumnName', colLabels)
%Analyze Results explorer
listOfLabel = {'file', ...
    'channel', ...
    'element', ...
    'sequence', ...
    'variable', ...
    'value', ...
    'delete', ...
    'comments'};
colLabels = cell(1, length(listOfLabel));
for ii = 1:length(listOfLabel)
    label = getXML(handles.settings.xml.strings, 'Table', listOfLabel{ii});
    colLabels{ii} = label;
end
set(handles.list.results, 'ColumnName', colLabels)
%% Radios
%Live
ids = {'analogIn', 'ttl'};
for i = 1:length(ids)
    [label, attributes] = getXML(handles.settings.xml.strings, 'Radio', ids{i}, {'size', 'weight'});
    handles.radio.liveView{i}.String = label;
    handles.radio.liveView{i}.FontSize = str2double(attributes{1});
    handles.radio.liveView{i}.FontWeight = attributes{2};
    handles.panel.livePanels{i}.Tag = label;
end
%Analyze
handles.radio.label.String = getXML(handles.settings.xml.strings, 'Radio', 'viewLabel');
handles.radio.single.String = getXML(handles.settings.xml.strings, 'Radio', 'viewSingle');
handles.radio.multiple.String = getXML(handles.settings.xml.strings, 'Radio', 'viewMultiple');
handles.radio.average.String = getXML(handles.settings.xml.strings, 'Radio', 'viewAverage');
%% Button
handles.button.previous.String = getXML(handles.settings.xml.strings, 'Button', 'previous');
handles.button.next.String = getXML(handles.settings.xml.strings, 'Button', 'next');
handles.button.p2p.String = getXML(handles.settings.xml.strings, 'Button', 'p2p');
handles.button.expandResults.String = getXML(handles.settings.xml.strings, 'Button', 'rightCursor');
handles.button.addChannelArithmetic.String = getXML(handles.settings.xml.strings, 'Button', 'addArithmetic');
handles.button.exploreData.String = getXML(handles.settings.xml.strings, 'Button', 'exploreData');
handles.button.clearLog.String = getXML(handles.settings.xml.strings, 'Button', 'clearLogs');
%Analyze buttons and context menu
for i = 1:length(handles.button.analyzeBtns)
    %Create context menu
    c = uicontextmenu;
    uimenu(c, 'Label', getXML(handles.settings.xml.strings, 'Menu', 'associateFcn'), ...
        'Callback', {@associateAnalyzeFcn, handles}, ...
        'UserData', handles.button.analyzeBtns{i});
    %Label button
    if isempty(handles.settings.analyze.analyzeBtns{i})
        handles.button.analyzeBtns{i}.String = getXML(handles.settings.xml.strings, 'Button', 'na');
    else
        handles.button.analyzeBtns{i}.String = handles.settings.analyze.analyzeBtns{i};
        %Add a clear function menu
        uimenu(c, 'Label', getXML(handles.settings.xml.strings, 'Menu', 'clearFcn'), ...
            'Callback', {@associateAnalyzeFcn, handles}, ...
            'UserData', handles.button.analyzeBtns{i});
    end
    %Attach context menu
    handles.button.analyzeBtns{i}.UIContextMenu = c;
end
switch handles.settings.analyze.onset.direction
    case 1
        [label, attributes] = getXML(handles.settings.xml.strings, 'Button', 'sequencingBefore', {'size', 'weight'});
    case 2
        [label, attributes] = getXML(handles.settings.xml.strings, 'Button', 'sequencingAfter', {'size', 'weight'});
end
handles.button.a_sequencingOnsetDirection.String = label;
handles.button.a_sequencingOnsetDirection.FontSize = str2double(attributes{1});
handles.button.a_sequencingOnsetDirection.FontWeight = attributes{2};
switch handles.settings.analyze.offset.direction
    case 1
        [label, attributes] = getXML(handles.settings.xml.strings, 'Button', 'sequencingBefore', {'size', 'weight'});
    case 2
        [label, attributes] = getXML(handles.settings.xml.strings, 'Button', 'sequencingAfter', {'size', 'weight'});
end
handles.button.a_sequencingOffsetDirection.String = label;
handles.button.a_sequencingOffsetDirection.FontSize = str2double(attributes{1});
handles.button.a_sequencingOffsetDirection.FontWeight = attributes{2};
switch handles.settings.analyze.onset.edge
    case 1
        [label, attributes] = getXML(handles.settings.xml.strings, 'Button', 'sequencingLower', {'size', 'weight'});
    case 2
        [label, attributes] = getXML(handles.settings.xml.strings, 'Button', 'sequencingGreater', {'size', 'weight'});
end
handles.button.a_sequencingOnsetEdge.String = label;
handles.button.a_sequencingOnsetEdge.FontSize = str2double(attributes{1});
handles.button.a_sequencingOnsetEdge.FontWeight = attributes{2};
switch handles.settings.analyze.offset.edge
    case 1
        [label, attributes] = getXML(handles.settings.xml.strings, 'Button', 'sequencingLower', {'size', 'weight'});
    case 2
        [label, attributes] = getXML(handles.settings.xml.strings, 'Button', 'sequencingGreater', {'size', 'weight'});
end
handles.button.a_sequencingOffsetEdge.String = label;
handles.button.a_sequencingOffsetEdge.FontSize = str2double(attributes{1});
handles.button.a_sequencingOffsetEdge.FontWeight = attributes{2};
handles.button.a_computeSequence.String = getXML(handles.settings.xml.strings, 'Button', 'computeSequencing');
[label, attributes] = getXML(handles.settings.xml.strings, 'Button', 'clearSequencing', {'size', 'weight', 'color'});
handles.button.a_clearSequence.String = label;
handles.button.a_clearSequence.FontSize = eval(attributes{1});
handles.button.a_clearSequence.FontWeight = attributes{2};
handles.button.a_clearSequence.BackgroundColor = eval(attributes{3});
%% Check
listLabelsIn = {'startIn'};
listLabelsOut = {'startOut'};
listLabelsDIN = {'manualIN', 'analogIN'};
listLabelsDOUT = {'manualOUT', 'analogOUT'};
%Triggers
%In
[label, attributes] = getXML(handles.settings.xml.strings, 'Check', listLabelsIn{1}, {'size', 'weight'});
handles.check.startTriggerIn.Tag = listLabelsIn{1};
handles.check.startTriggerIn.String = label;
handles.check.startTriggerIn.FontSize = str2double(attributes{1});
handles.check.startTriggerIn.FontWeight = attributes{2};
%Out
[label, attributes] = getXML(handles.settings.xml.strings, 'Check', listLabelsOut{1}, {'size', 'weight'});
handles.check.startTriggerOut.Tag = listLabelsOut{1};
handles.check.startTriggerOut.String = label;
handles.check.startTriggerOut.FontSize = str2double(attributes{1});
handles.check.startTriggerOut.FontWeight = attributes{2};
%Digitals
for i = 1:2
    %In
    [label, attributes] = getXML(handles.settings.xml.strings, 'Check', listLabelsDIN{i}, {'size', 'weight'});
    handles.check.ttlIn{i}.Tag = listLabelsDIN{i};
    handles.check.ttlIn{i}.String = label;
    handles.check.ttlIn{i}.FontSize = str2double(attributes{1});
    handles.check.ttlIn{i}.FontWeight = attributes{2};
    %out
    [label, attributes] = getXML(handles.settings.xml.strings, 'Check', listLabelsDOUT{i}, {'size', 'weight'});
    handles.check.ttlOut{i}.Tag = listLabelsDOUT{i};
    handles.check.ttlOut{i}.String = label;
    handles.check.ttlOut{i}.FontSize = str2double(attributes{1});
    handles.check.ttlOut{i}.FontWeight = attributes{2};
end
%% Live Texts / Settings
%Controls
[label, attributes] = getXML(handles.settings.xml.strings, 'Label', 'samplesAcq', {'size', 'weight'});
handles.text.samplesAcquiredLabel.String = label;
handles.text.samplesAcquiredLabel.FontSize = str2double(attributes{1});
handles.text.samplesAcquiredLabel.FontWeight = attributes{2};
label = getXML(handles.settings.xml.strings, 'Button', 'manualTTLIN');
handles.button.manualTTLIN.String = label;
label = getXML(handles.settings.xml.strings, 'Button', 'manualTTLOUT');
handles.button.manualTTLOUT.String = label;
%AI Panel
[label, attributes] = getXML(handles.settings.xml.strings, 'Label', 'stopAfter', {'size', 'weight'});
handles.text.stopAfterLabel.String = label;
handles.text.stopAfterLabel.FontSize = str2double(attributes{1});
handles.text.stopAfterLabel.FontWeight = attributes{2};
%TTL Panel
%Input label
[label, attributes] = getXML(handles.settings.xml.strings, 'Label', 'labelIN', {'size', 'weight', 'color'});
handles.text.INLabel.String = label;
handles.text.INLabel.FontSize = str2double(attributes{1});
handles.text.INLabel.FontWeight = attributes{2};
handles.text.INLabel.ForegroundColor = eval(attributes{3});
%Output label
[label, attributes] = getXML(handles.settings.xml.strings, 'Label', 'labelOUT', {'size', 'weight', 'color'});
handles.text.OUTLabel.String = label;
handles.text.OUTLabel.FontSize = str2double(attributes{1});
handles.text.OUTLabel.FontWeight = attributes{2};
handles.text.OUTLabel.ForegroundColor = eval(attributes{3});
%Manual OUT
[label, attributes] = getXML(handles.settings.xml.strings, 'Label', 'manualOUTPort', {'size', 'weight', 'parent'});
handles.text.manualOUTOUTPortLabel.String = label;
handles.text.manualOUTPortLabel.FontSize = str2double(attributes{1});
handles.text.manualOUTPortLabel.FontWeight = attributes{2};
parent = attributes{3};
handles.text.manualOUTPortLabel.Tag = parent;
handles.popup.manualOUTPort.Tag = parent;
[label, attributes] = getXML(handles.settings.xml.strings, 'Label', 'manualOUTFcn', {'size', 'weight'});
handles.text.manualOUTFcnLabel.String = label;
handles.text.manualOUTFcnLabel.FontSize = str2double(attributes{1});
handles.text.manualOUTFcnLabel.FontWeight = attributes{2};
handles.text.manualOUTFcnLabel.Tag = parent;
handles.popup.manualOUTFcn.Tag = parent;
%Analog IN
[label, attributes] = getXML(handles.settings.xml.strings, 'Label', 'analogINChannel', {'size', 'weight', 'parent'});
handles.text.analogINChannelLabel.String = label;
handles.text.analogINChannelLabel.FontSize = str2double(attributes{1});
handles.text.analogINChannelLabel.FontWeight = attributes{2};
handles.text.analogINChannelLabel.Tag = attributes{3};
handles.popup.analogINChannel.Tag = attributes{3};
parent = attributes{3};
[label, attributes] = getXML(handles.settings.xml.strings, 'Label', 'threshold', {'size', 'weight'});
handles.text.analogINValueLabel.String = label;
handles.text.analogINValueLabel.FontSize = str2double(attributes{1});
handles.text.analogINValueLabel.FontWeight = attributes{2};
handles.text.analogINValueLabel.Tag = parent;
handles.edit.analogINValue.Tag = parent;
label = getXML(handles.settings.xml.strings, 'Button', 'peek');
handles.button.analogINPeek.String = label;
handles.button.analogINPeek.Tag = parent;
[label, attributes] = getXML(handles.settings.xml.strings, 'Radio', 'risingEdge', {'size', 'weight'});
handles.radio.analogINEdge{1}.String = label;
handles.radio.analogINEdge{1}.FontSize = str2double(attributes{1});
handles.radio.analogINEdge{1}.FontWeight = attributes{2};
handles.radio.analogINEdge{1}.Tag = parent;
[label, attributes] = getXML(handles.settings.xml.strings, 'Radio', 'fallingEdge', {'size', 'weight'});
handles.radio.analogINEdge{2}.String = label;
handles.radio.analogINEdge{2}.FontSize = str2double(attributes{1});
handles.radio.analogINEdge{2}.FontWeight = attributes{2};
handles.radio.analogINEdge{2}.Tag = parent;
%Waiting source IN
[label, attributes] = getXML(handles.settings.xml.strings, 'Label', 'sequencingSource', {'size', 'weight'});
handles.text.sequencingSource.String = label;
handles.text.sequencingSource.FontSize = str2double(attributes{1});
handles.text.sequencingSource.FontWeight = attributes{2};
[label, attributes] = getXML(handles.settings.xml.strings, 'Label', 'sequencingOnset', {'size', 'weight'});
handles.text.sequencingOnset.String = label;
handles.text.sequencingOnset.FontSize = str2double(attributes{1});
handles.text.sequencingOnset.FontWeight = attributes{2};
[label, attributes] = getXML(handles.settings.xml.strings, 'Label', 'sequencingOffset', {'size', 'weight'});
handles.text.sequencingOffset.String = label;
handles.text.sequencingOffset.FontSize = str2double(attributes{1});
handles.text.sequencingOffset.FontWeight = attributes{2};
switch handles.settings.analyze.onset.direction
    case 1
        [label, attributes] = getXML(handles.settings.xml.strings, 'Button', 'sequencingBefore', {'size', 'weight'});
    case 2
        [label, attributes] = getXML(handles.settings.xml.strings, 'Button', 'sequencingAfter', {'size', 'weight'});
end
handles.button.sequencingOnsetDirection.String = label;
handles.button.sequencingOnsetDirection.FontSize = str2double(attributes{1});
handles.button.sequencingOnsetDirection.FontWeight = attributes{2};
switch handles.settings.analyze.offset.direction
    case 1
        [label, attributes] = getXML(handles.settings.xml.strings, 'Button', 'sequencingBefore', {'size', 'weight'});
    case 2
        [label, attributes] = getXML(handles.settings.xml.strings, 'Button', 'sequencingAfter', {'size', 'weight'});
end
handles.button.sequencingOffsetDirection.String = label;
handles.button.sequencingOffsetDirection.FontSize = str2double(attributes{1});
handles.button.sequencingOffsetDirection.FontWeight = attributes{2};
switch handles.settings.analyze.onset.edge
    case 1
        [label, attributes] = getXML(handles.settings.xml.strings, 'Button', 'sequencingLower', {'size', 'weight'});
    case 2
        [label, attributes] = getXML(handles.settings.xml.strings, 'Button', 'sequencingGreater', {'size', 'weight'});
end
handles.button.sequencingOnsetEdge.String = label;
handles.button.sequencingOnsetEdge.FontSize = str2double(attributes{1});
handles.button.sequencingOnsetEdge.FontWeight = attributes{2};
switch handles.settings.analyze.offset.edge
    case 1
        [label, attributes] = getXML(handles.settings.xml.strings, 'Button', 'sequencingLower', {'size', 'weight'});
    case 2
        [label, attributes] = getXML(handles.settings.xml.strings, 'Button', 'sequencingGreater', {'size', 'weight'});
end
handles.button.sequencingOffsetEdge.String = label;
handles.button.sequencingOffsetEdge.FontSize = str2double(attributes{1});
handles.button.sequencingOffsetEdge.FontWeight = attributes{2};
%Analog OUT
[label, attributes] = getXML(handles.settings.xml.strings, 'Label', 'analogOUTChannel', {'size', 'weight', 'parent'});
handles.text.analogOUTChannelLabel.String = label;
handles.text.analogOUTChannelLabel.FontSize = str2double(attributes{1});
handles.text.analogOUTChannelLabel.FontWeight = attributes{2};
handles.text.analogOUTChannelLabel.Tag = attributes{3};
handles.popup.analogOUTChannel.Tag = attributes{3};
parent = attributes{3};
[label, attributes] = getXML(handles.settings.xml.strings, 'Label', 'analogOUTPort', {'size', 'weight'});
handles.text.analogOUTPortLabel.String = label;
handles.text.analogOUTPortLabel.FontSize = str2double(attributes{1});
handles.text.analogOUTPortLabel.FontWeight = attributes{2};
handles.text.analogOUTPortLabel.Tag = parent;
handles.popup.analogOUTPort.Tag = parent;
[label, attributes] = getXML(handles.settings.xml.strings, 'Label', 'threshold', {'size', 'weight'});
handles.text.analogOUTValueLabel.String = label;
handles.text.analogOUTValueLabel.FontSize = str2double(attributes{1});
handles.text.analogOUTValueLabel.FontWeight = attributes{2};
handles.text.analogOUTValueLabel.Tag = parent;
handles.edit.analogOUTValue.Tag = parent;
label = getXML(handles.settings.xml.strings, 'Button', 'peek');
handles.button.analogOUTPeek.String = label;
handles.button.analogOUTPeek.Tag = parent;
[label, attributes] = getXML(handles.settings.xml.strings, 'Label', 'analogOUTFcn', {'size', 'weight'});
handles.text.analogOUTFcnLabel.String = label;
handles.text.analogOUTFcnLabel.FontSize = str2double(attributes{1});
handles.text.analogOUTFcnLabel.FontWeight = attributes{2};
handles.text.analogOUTFcnLabel.Tag = parent;
handles.popup.analogOUTFcn.Tag = parent;
[label, attributes] = getXML(handles.settings.xml.strings, 'Radio', 'risingEdge', {'size', 'weight'});
handles.radio.analogOUTEdge{1}.String = label;
handles.radio.analogOUTEdge{1}.FontSize = str2double(attributes{1});
handles.radio.analogOUTEdge{1}.FontWeight = attributes{2};
handles.radio.analogOUTEdge{1}.Tag = parent;
[label, attributes] = getXML(handles.settings.xml.strings, 'Radio', 'fallingEdge', {'size', 'weight'});
handles.radio.analogOUTEdge{2}.String = label;
handles.radio.analogOUTEdge{2}.FontSize = str2double(attributes{1});
handles.radio.analogOUTEdge{2}.FontWeight = attributes{2};
handles.radio.analogOUTEdge{2}.Tag = parent;
%% Analyze Texts
[label, attributes] = getXML(handles.settings.xml.strings, 'Label', 'pulseIndex', {'size', 'weight'});
handles.text.pulseIndex.String = label;
handles.text.pulseIndex.FontSize = str2double(attributes{1});
handles.text.pulseIndex.FontWeight = attributes{2};
[label, attributes] = getXML(handles.settings.xml.strings, 'Label', 'analyzeTreat', {'size', 'weight'});
handles.text.signalTreatsLabel.String = label;
handles.text.signalTreatsLabel.FontSize = str2double(attributes{1});
handles.text.signalTreatsLabel.FontWeight = attributes{2};
[label, attributes] = getXML(handles.settings.xml.strings, 'Label', 'sequencingSource', {'size', 'weight'});
handles.text.a_sequencingSource.String = label;
handles.text.a_sequencingSource.FontSize = eval(attributes{1});
handles.text.a_sequencingSource.FontWeight = attributes{2};
[label, attributes] = getXML(handles.settings.xml.strings, 'Label', 'sequencingOnset', {'size', 'weight'});
handles.text.a_sequencingOnset.String = label;
handles.text.a_sequencingOnset.FontSize = eval(attributes{1});
handles.text.a_sequencingOnset.FontWeight = attributes{2};
[label, attributes] = getXML(handles.settings.xml.strings, 'Label', 'sequencingOffset', {'size', 'weight'});
handles.text.a_sequencingOffset.String = label;
handles.text.a_sequencingOffset.FontSize = eval(attributes{1});
handles.text.a_sequencingOffset.FontWeight = attributes{2};
%% Toggle
[label, attributes] = getXML(handles.settings.xml.strings, 'Toggle', 'playOff', {'color'});
handles.button.previewLive.String = label;
handles.button.previewLive.BackgroundColor = eval(attributes{1});
[label, attributes] = getXML(handles.settings.xml.strings, 'Toggle', 'recordOff', {'color'});
handles.button.recordLive.String = label;
handles.button.recordLive.BackgroundColor = eval(attributes{1});
[label, attributes] = getXML(handles.settings.xml.strings, 'Toggle', 'guidelineOff', {'color'});
handles.button.addGuideline.String = label;
handles.button.addGuideline.BackgroundColor = eval(attributes{1});
end