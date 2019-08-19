%% Comments
%Save/Load settings functions

%Author: V. Doguet (7/1/2019)
%Updates:
%% Function
function saveDefaultSettings(handles)
defSettings = handles.settings;
%Save default settings file
save(fullfile(handles.resourcesPath, 'defaultSettings.mat'), 'defSettings')
end