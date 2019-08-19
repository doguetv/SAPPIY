%% Comments
%Function that defines/reset TTL settings

%Associated GUI: SAPPIY
%Author: V. Doguet (25/2/2019)
%Updates:
%% Function
function handles = resetTTLSettings(handles)
if ~isempty(handles.live.session) && isvalid(handles.live.session)
    %% Manual TTL IN
    handles.check.ttlIn{1}.Value = handles.settings.live.TTLChecks(1);
    %Check for manual Input TTL
    if handles.settings.live.TTLChecks(1)
        handles.button.manualTTLIN.Enable = 'on';
    else
        handles.button.manualTTLIN.Enable = 'off';
    end
    %% Analog TTL IN
    %Set uicontrols
    handles.check.ttlIn{2}.Value = handles.settings.live.TTLChecks(2);
    handles.popup.analogINChannel.Value = handles.settings.live.analogINChannel;
    handles.edit.analogINValue.String = num2str(handles.settings.live.analogINValue);
    handles.radio.analogINEdge{handles.settings.live.TTLEdges(1)}.Value = 1;
    handles.live.variables.analogIN.channel = handles.settings.live.analogINChannel;
    handles.live.variables.analogIN.value = handles.settings.live.analogINValue;
    handles.live.variables.analogIN.edge = handles.settings.live.TTLEdges(1);
    %% All INS
    if any(handles.settings.live.TTLChecks(1:2))
        set(findobj(handles.panel.livePanels{2}, 'Tag', 'allIN'), 'Enable', 'on')
    else
        set(findobj(handles.panel.livePanels{2}, 'Tag', 'allIN'), 'Enable', 'off')
    end
end
if ~isempty(handles.live.DOsession) && isvalid(handles.live.DOsession)
    %% Manual TTL OUT
    %Set uicontrols
    handles.check.ttlOut{1}.Value = handles.settings.live.TTLChecks(3);
    handles.popup.manualOUTPort.Value = handles.settings.live.manualOUTPort;
    %DOUT Fcn Popups
    files = dir(fullfile(handles.userFcnPath, 'send_ttl', '*.m'));
    handles.popup.manualOUTFcn.String = {files.name};
    %Select appropriate popup value if any existent function
    if handles.settings.live.OUTFcn(1) > length(handles.popup.manualOUTFcn.String)
        handles.settings.live.OUTFcn(1) = 1;
    end
    handles.popup.manualOUTFcn.Value = handles.settings.live.OUTFcn(1);
    %Check for manual Output TTL
    if handles.settings.live.TTLChecks(3)
        handles.button.manualTTLOUT.Enable = 'on';
    else
        handles.button.manualTTLOUT.Enable = 'off';
    end
    %% Analog TTL OUT
    handles.check.ttlOut{2}.Value = handles.settings.live.TTLChecks(4);
    handles.popup.analogOUTPort.Value = handles.settings.live.analogOUTPort;
    handles.popup.analogOUTChannel.Value = handles.settings.live.analogOUTChannel;
    handles.edit.analogOUTValue.String = num2str(handles.settings.live.analogOUTValue);
    handles.radio.analogOUTEdge{handles.settings.live.TTLEdges(2)}.Value = 1;
    handles.live.variables.analogOUT.channel = handles.settings.live.analogOUTChannel;
    handles.live.variables.analogOUT.value = handles.settings.live.analogOUTValue;
    handles.live.variables.analogOUT.edge = handles.settings.live.TTLEdges(2);
    handles.live.variables.analogOUT.armed = true;
    %DOUT Fcn
    handles.popup.analogOUTFcn.String = {files.name};
    %Select appropriate popup value if any existent function
    if handles.settings.live.OUTFcn(2) > length(handles.popup.analogOUTFcn.String)
        handles.settings.live.OUTFcn(2) = 1;
    end
    handles.popup.analogOUTFcn.Value = handles.settings.live.OUTFcn(2);
end
end