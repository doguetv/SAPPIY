%% Comments
%Functions that edits elements created using 'p2pTimeSequences' user
%function. This function call is possible since we have set an interactive
%callback (i.e., WindowButtonDownFcn) in one ot the elements created.

%Tips: For readability purpose, it is recommended to label editing
%functions close to their associated creating function. Like the present
%function, user can add '_edit' to the creating function name.

%Author: V. Doguet (8/3/2019)
%Updates:
%% Main Function
function p2pTimeSequences_edit(s, e)

%Get ancestors
fig = ancestor(s, 'figure');
ax = ancestor(s, 'axes');

%The following switch condition is not necessary, but shows possibilities
%of coding.
switch fig.SelectionType
    case 'normal'   %Edit Sequence
        %Get the marker of the associated element that is not clicked in
        %axis to set it as 'fixed' point.
        [~, point] = max(abs(s.XData - e.IntersectionPoint(1)));
        ax.UserData.fixedPoint = s.XData(point);
        %Store line in axis user data
        ax.UserData.line = s;
        
        %Set some element properties
        set(s, 'MarkerSize', 2)
        
        %Adjust interactive control callbacks
        set(fig, 'Pointer', 'left', ...
            'WindowButtonMotionFcn', {@editMotion, ax}, ...
            'WindowButtonUpFcn', {@upAnalyze, ax})
        
        %Since we don't need to return output arguments withing the main
        %function, no need to waitfor the end of interactive controls. The
        %function will end in WindowButtonUpFcn callback.
end
end
%% Interactive Control Callbacks
%Function used to edit current sequence with mouse motion
function editMotion(~, ~, ax)

%Get current point in axis
cp = get(ax, 'CurrentPoint');
cp = cp(1, 1:2);

%Update temporary line coordinates
startInd = ax.UserData.fixedPoint;
l = findobj(ax, 'Type', 'line', 'Tag', 'main');
%Check the direction of motion
if cp(1) > startInd
    index1 = find(l.XData >= startInd, 1, 'first');
    index2 = find(l.XData >= cp(1), 1, 'first');
else
    index1 = find(l.XData >= cp(1), 1, 'first');
    index2 = find(l.XData >= startInd, 1, 'first');
end
%Get new coordinates
xRange = l.XData(index1:index2);
yRange = l.YData(index1:index2);
%Set coordinates
set(ax.UserData.line, 'XData', xRange, 'YData', yRange)
end

%Function that ends element editing after mouse left-click has been
%released
function upAnalyze(source, ~, ax)

%Clear figure interactive control
set(source, 'Pointer', 'arrow', ...
    'WindowButtonMotionFcn', '', ...
    'WindowButtonDownFcn', '', ...
    'WindowButtonUpFcn', '')

%Get temporary line coordinates and store underlined sequence
%Store marker limits
xRange = ax.UserData.line.XData;
l = findobj(ax, 'Type', 'line', 'Tag', 'main');
index1 = find(l.XData >= xRange(1), 1, 'first');
index2 = find(l.XData >= xRange(end), 1, 'first');
%Store true indexes for Y signal and xRange for X scaling in chart
ax.UserData.elements = [index1, index2];

%Do some calculations
[minVal, minInd] = min(ax.UserData.line.YData);
[maxVal, maxInd] = max(ax.UserData.line.YData);
amplitude = abs(maxVal - minVal);
time = abs(maxInd - minInd) / ax.UserData.line.UserData.rate;

%Retrieve handles
fig = ancestor(ax, 'figure', 'toplevel');
handles = guidata(fig);

%Get item being edited
item = ax.UserData.line.UserData.item;

%Edit Result table and associated element
for i = 1:size(handles.list.results.Data, 1)
    %Only edit current item
    if strcmpi(handles.list.results.Data{i, 1}, item{1}) && ...
            strcmpi(handles.list.results.Data{i, 2}, item{2}) && ...
            isequal(handles.list.results.Data{i, 3}, item{3}) && ...
            strcmpi(handles.list.results.Data{i, 4}, item{4})
        %Edit table data
        switch handles.list.results.Data{i, 5}
            case 'p2p amplitude'
                handles.list.results.Data{i, 6} = amplitude;
            case 'p2p time'
                handles.list.results.Data{i, 6} = time;
        end
        %Edit associated element
        if any(strfind(handles.list.results.Data{i, end - 1}, '<html>'))
            handles.additionalElements{i, 1}.XData = ax.UserData.line.XData;
            handles.additionalElements{i, 1}.YData = ax.UserData.line.YData;
            handles.additionalElements{i, 2}.XData = [ax.UserData.line.XData(1), ax.UserData.line.XData(end)];
            handles.additionalElements{i, 2}.YData = [ax.UserData.line.YData(1), ax.UserData.line.YData(end)];
        end
    end
end

%Manually call internal update analyze function to update display
feval(ax.UserData.line.UserData.callbacks{1}, handles)

%Update handles
guidata(fig, handles)

%Clear axis user Data
ax.UserData = [];

end