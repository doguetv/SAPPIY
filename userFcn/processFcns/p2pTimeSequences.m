%% Instructions
%All functions from userFcn/processFcns folder must have the exact same
%input arguments than the current function, namely:
    %axis:      axis of analyze panel. [Axes Matlab Object]
                    %This axis contains chart elements (e.g., lines)
                    %associated with sequences, which also comes as input
                    %argument (in data structure).
    %data:      structure that contains xData, signal sequences and
                    %sample rate. [structure] This structure should contain
                    %variables required to process data.
    %results:   prefilled results variable. [cell array]
                    %Results variable is prefilled to store 1 parameter
                    %label and value for each sequence (in data.sequences).
                    %All lines must be completed by filling 2 last columns
                    %with parameter label and value. In case user wants to
                    %add several parameters, user must duplicate all
                    %prefilled results variable rows (row dimension
                    %concatenation).
    %callbacks: callback functions used by the application to update
                %results table and to draw elements on axis. [cell array]
                    %These callbacks are functions from lib/analyze folder
                    %(open functions for further details). Application will
                    %automatically call these two callbacks after the
                    %userFcn has been evaluated, so these callbacks are
                    %rather to be included in user data elements so that
                    %user can use them for editing purposes (see
                    %p2pTimeSequences userFcn example).
                
%Two output argmuents must be defined:
    %results:       filled results variable. [cell array]
    %newElements:   elements to associate to results, which will be drawn
                    %on analyze axis for associated sequences (file,
                    %channel, ttl). [cell array]
                        %newElements variable must have the same number of
                        %row than results variable. Each column represents
                        %a new element to associate with results variable
                        %of associated row. Each element must be a
                        %structure with at least a field labeled 'type',
                        %which define object type (e.g., line, bar, area,
                        %surf). The other element fields must be valid
                        %properties of associated object type (e.g., XData,
                        %Color, MarkerSize for line objects).
                        
%Tips: It is recommended to copy and paste the present instructions, as
%well as the function declaration line (i.e., function argout =
%myFunction(argin)) when creating a new user function. Then, user can
%either replace unused input arguments with '~' char or leave it declared
%but unused.
%% Comments
%The p2pTimeSequences function uses axis interactive controls callbacks
%(axis parent) to deal with element drawing, then calculate some parameters
%(peak-to-peak signal amplitude and time) according to elements drawn on
%axis.

%In addition to deal with axis interactive control callbacks, the present
%function also stores an interactive control callback to the new chart
%element added to the axis. This way, the element, and its associated line
%of results, can be edited after creation, whitout requiring deleting the
%element and reprocess it.
%See:
% function [results, newElements] = processSignalSequences(ax, data, results, callbacks)
% 
%     newElements{i, 2}.ButtonDownFcn = @p2pTimeSequences_edit;
% 
% end

%Associated GUI: SAPPIY
%Author: V. Doguet (8/3/2019)
%Updates:
%% Main Function
function [results, newElements] = p2pTimeSequences(axis, data, results, callbacks)
%function [results, newElements] = myFunction(axis, data, results,
%callbacks)

%Get axis parent
fig = ancestor(axis, 'figure');
%Associate interactive callback functions to figure
set(fig, 'WindowButtonMotionFcn', {@motionAnalyze, axis}, ...
    'WindowButtonDownFcn', {@downAnalyze, axis}, ...
    'WindowButtonUpFcn', {@upAnalyze, axis})

%Must wait for user ending set range sequence (end of interactive control)
%So set a text objet on graph that will be deleted in WindowButtonUpFcn
%callback.
t = text(axis, min(axis.XLim), min(axis.YLim), '', 'Tag', 'waiter');
%Wait for text being deleted (see WindowButtonUpFcn callback)
waitfor(t)

%Once interactive controle has been ended, call process tracking function
[results, newElements] = processSignalSequences(axis, data, results, callbacks);

%Since we put some data in axis user data, clear this field before
%returning.
axis.UserData = [];
end
%% Process Subfunction
%Function that processes desired parameters in all signal sequences
%defined.
function [results, newElements] = processSignalSequences(ax, data, results, callbacks)

%Results must contain 6 columns. 4 of them should already be filled with
%file, channel, element and ttl indexes. Then user must fill the two last
%columns with parameter label and value. Results row number depends of how
%many paremeter user calculates in its custom function. Results originaly
%contains enough rows to store 1 parameter. Then user must duplicate
%results rows if several parameters are calculated.

%Duplicate results rows only once since we will have 2 variables to store.
results = cat(1, results, results);
%Allocate newElements variable according to results dimension.
newElements = cell(size(results, 1), 2);

%Get indexes of new columns to store in results variable.
labelColumn = size(results, 2)-1;
valueColumn = size(results, 2);

%Process all signal sequences required.
%Note that this part of code uses
%some data stored in axis user data. Explore what interactive control
%callbacks do (subfunctions below) to better understand what is done here.
for i = 1:size(data.sequences, 1)
    %Calculate p2p amplitude and time
    [minVal, minInd] = min(data.sequences(i, ax.UserData.elements(1):ax.UserData.elements(2)));
    [maxVal, maxInd] = max(data.sequences(i, ax.UserData.elements(1):ax.UserData.elements(2)));  
    amplitude = abs(maxVal - minVal);
    time = abs(maxInd - minInd) / data.rate;
    %Store in results variable
    results{i, labelColumn} = 'p2p amplitude';
    results{i, valueColumn} = amplitude;
    results{i+size(data.sequences, 1), labelColumn} = 'p2p time';
    results{i+size(data.sequences, 1), valueColumn} = time;
    %Store new elements to associate with results
    %Element type must be
    %defined
    newElements{i, 1}.type = 'line';
    %Then other fields must correspond to valid properties of defined
    %object type.
    newElements{i, 1}.XData = data.xData(i, ax.UserData.elements(1):ax.UserData.elements(2));
    newElements{i, 1}.YData = data.sequences(i, ax.UserData.elements(1):ax.UserData.elements(2));
    newElements{i, 1}.Color = 'g';
    newElements{i, 1}.LineStyle = '-';
    newElements{i, 1}.LineWidth = 2;
    %Second element is stored at the same row than the first element, but
    %in the second column. All elements of a same row will be drawn on axis
    %when corresponding item is selected.
    newElements{i, 2}.type = 'line';
    newElements{i, 2}.XData = [newElements{i, 1}.XData(1), newElements{i, 1}.XData(end)];
    newElements{i, 2}.YData = [newElements{i, 1}.YData(1), newElements{i, 1}.YData(end)];
    newElements{i, 2}.Color = 'm';
    newElements{i, 2}.LineStyle = 'none';
    newElements{i, 2}.Marker = 'o';
    newElements{i, 2}.MarkerSize = 8;
    newElements{i, 2}.MarkerFaceColor = 'm';
    %Here we associate a callback function to enable editing drawn elements
    %thereafter. We store all variables we need to retrieve in user data
    %field (including callbacks; explore 'p2pSequences_edit' function in
    %userFcn/processFcns folder to see what is done).
    newElements{i, 2}.ButtonDownFcn = @p2pTimeSequences_edit;
    newElements{i, 2}.UserData.callbacks = callbacks;
    newElements{i, 2}.UserData.item = results(i, 1:4);
    newElements{i, 2}.UserData.rate = data.rate;
end
end
%% Interactive Control Callbacks
%Function that enables drawing elements in analyze chart after mouse has
%been hold left-clicked.
function downAnalyze(source, ~, ax)
%Check whether mouse cursor is inside the analyze axis
if strcmpi(source.Pointer, 'left')
    %Get current point in axis
    cp = get(ax, 'CurrentPoint');
    cp = cp(1, 1:2);
    ax.UserData.click = cp(1);
    %Get the sequence Data
    l = findobj(ax, 'Type', 'line', 'Tag', 'main');
    index = find(l.XData >= cp(1), 1, 'first') - 1;
    x = l.XData(index);
    y = l.YData(index);
    %Create temporary line in axis
    ax.UserData.line = line([x, x], [y, y], 'Color', 'r', 'LineWidth', 2);
end
end

%Function that updates elements in analyze chart while moving mouse.
function motionAnalyze(source, ~, ax)

%Get current point in axis
cp = get(ax, 'CurrentPoint');
cp = cp(1, 1:2);

%Check whether pointer is in ou out axis
limX = get(ax, 'XLim');
limY = get(ax, 'YLim');
if cp(1) > min(limX) && cp(1) < max(limX) && cp(2) > min(limY) && cp(2) < max(limY)
    %Inside, so change mouse cursor
    set(source, 'Pointer', 'left')
    %Update temporary line coordinates if any line
    if isfield(ax.UserData, 'click')
        startInd = ax.UserData.click;
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
else
    %Outside
    set(source, 'Pointer', 'arrow')
end
drawnow
end

%Function that ends element drawing in analyze chart after mouse left-click
%mouse has been released
function upAnalyze(source, ~, ax)

%Get temporary line coordinates if any line and store underlined sequence
if ~isempty(ax.UserData)
    %Store marker limits
    xRange = ax.UserData.line.XData;
    l = findobj(ax, 'Type', 'line', 'Tag', 'main');
    index1 = find(l.XData >= xRange(1), 1, 'first');
    index2 = find(l.XData >= xRange(end), 1, 'first');
    %Store true indexes for Y signal and xRange for X scaling in chart
    ax.UserData.elements = [index1, index2];
    
    %Clear figure interactive control
    set(source, 'Pointer', 'arrow', ...
        'WindowButtonMotionFcn', '', ...
        'WindowButtonDownFcn', '', ...
        'WindowButtonUpFcn', '')
    
    %Delete text to unfreeze function
    delete(findobj(ax, 'Tag', 'waiter'))
end
end