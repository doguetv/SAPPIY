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
                
%Two output argmuents must be defined :
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
%The maxSequences function finds maximum value of each signal sequence and
%associates a marker (line object) element to each signal sequence.

%Associated GUI: SAPPIY
%Author: V. Doguet (8/3/2019)
%Updates:
%% Main Function
function [results, newElements] = maxSequences(axis, data, results, callbacks)

%Get index to store in results variable
labelColumn = size(results, 2)-1;
valueColumn = size(results, 2);

%Allocate newElements variable according to results dimension.
newElements = cell(size(results, 1), 1);

%Process all signal sequences required
for i = 1:size(data.sequences, 1)
    %Get maximum value
    [maxVal, ind] = max(data.sequences(i, :));
    %Store in results variable
    results{i, labelColumn} = 'maximum';
    results{i, valueColumn} = maxVal;
    %Store new elements to associate with results
    %Element type must be
    %defined
    newElements{i, 1}.type = 'line';
    %Then other fields must correspond to valid properties of defined
    %object type.
    newElements{i, 1}.XData = data.xData(i, ind);
    newElements{i, 1}.YData = results{i, valueColumn};
    newElements{i, 1}.Color = 'g';
    newElements{i, 1}.LineStyle = 'none';
    newElements{i, 1}.Marker = 'o';
    newElements{i, 1}.MarkerSize = 8;
    newElements{i, 1}.MarkerFaceColor = 'm';
end
end