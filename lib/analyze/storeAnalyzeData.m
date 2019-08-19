%% Comments
%Functions that updates results in results panel

%Associated GUI: SAPPIY
%Author: V. Doguet (13/12/2018)
%Updates:
%% Function
function handles = storeAnalyzeData(handles, results, elements)

%Retrieve table
table = handles.list.results;
%% Store Results
ind = size(results, 2)+1;
var1 = '';
elementIndexes = [];
for i = 1:size(results, 1)
    %Add a delete column to each new item
    if isempty(var1) || strcmpi(results{i, 5}, var1)
        results{i, ind} = '<html><table border=0 width=400><font color=red ></font><TR><TD><i><b>Delete</b></i></TD></TR> </table></html>';
        var1 = results{i, 5};
        elementIndexes = cat(1, elementIndexes, i);
    else
        results{i, ind} = '';
    end
    %Add a comment column to each new item
    results{i, ind + 1} = '';
end

%Concatenate old and new results
if ~isempty(table.Data)
    newData = cat(1, table.Data, results);
else
    newData = results;
end
%Order and Store new Data in table data
[orderedData, index] = sortrows(newData);

%Store ordered data in handles and table
handles.results = orderedData;
table.Data = orderedData;

%Set Table Properties
table.ColumnName = {getXML(handles.settings.xml.strings, 'Table', 'file'), ...
    getXML(handles.settings.xml.strings, 'Table', 'channel'), ...
    getXML(handles.settings.xml.strings, 'Table', 'element'), ...
    getXML(handles.settings.xml.strings, 'Table', 'sequence'), ...
    getXML(handles.settings.xml.strings, 'Table', 'variable'), ...
    getXML(handles.settings.xml.strings, 'Table', 'value'), ...
    getXML(handles.settings.xml.strings, 'Table', 'delete'), ...
    getXML(handles.settings.xml.strings, 'Table', 'comments')};
table.ColumnEditable = logical([0, 0, 0, 0, 0, 0, 0, 1]);
%% Store chart elements
%Get current elements
currentElements = handles.additionalElements;

%Define which one has most number of columns and create empty columns in
%the other (for concatenation purpose)
if ~isempty(currentElements)
    if size(elements, 2) > size(currentElements, 2)
        currentElements(:, size(currentElements, 2)+1:size(elements, 2)) = cell(1, 1);
    elseif size(elements, 2) < size(currentElements, 2)
        elements(:, size(elements, 2)+1:size(currentElements, 2)) = cell(1, 1);
    end
    %Concatenate old and new elements
    newElements = cat(1, currentElements, elements);
else
    %Use only new elements as new elements
    newElements = elements;
end

%Make a copy of elements
elementCopy = newElements;

%Then reorder elements according to index from sortrows function
for i = 1:length(index)
    newElements(i, :) = elementCopy(index(i), :);
end

%Replace in handles
handles.additionalElements = newElements;
end