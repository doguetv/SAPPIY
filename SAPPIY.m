%% Comments
%Main script for SAPPIY application

%Authorship
%SAPPIY main script (this):	V. Doguet (11/12/2018)

%Updates
%% Function
function SAPPIY
%% Main Path / Ressources Folder
scriptPath = mfilename('fullpath');
%Define resources, library and userFcn paths
rootPath = fileparts(scriptPath);
handles.resourcesPath = fullfile(rootPath, 'resources');
handles.userFcnPath = fullfile(rootPath, 'userFcn');
handles.libPath = fullfile(rootPath, 'lib');
%XML files
handles.settings.xml.strings = fullfile(handles.resourcesPath, ...
    'strings', 'English.xml');
handles.settings.xml.colors = fullfile(handles.resourcesPath, ...
    'values', 'colors.xml');
%Add library to path
addpath(genpath(handles.libPath))
%Add userFcn directories to path
addpath(genpath(handles.userFcnPath))
%% Build GUI
buildGUI(handles);
end