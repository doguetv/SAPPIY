%% Comments
%Function to load default settings

%Author: V. Doguet (7/1/2019)
%Updates:
%% Function
function handles = loadDefaultSettings(handles)
%Load default settings file
temp = load(fullfile(handles.resourcesPath, 'defaultSettings.mat'));
%Check whether set paths are valid before applying them
if isequal(exist(temp.defSettings.xml.strings, 'file'), 0)
    temp.defSettings.xml.strings = handles.settings.xml.strings;
end
if isequal(exist(temp.defSettings.xml.colors, 'file'), 0)
    temp.defSettings.xml.colors = handles.settings.xml.colors;
end
%Finnaly assign to handles
handles.settings = temp.defSettings;
end