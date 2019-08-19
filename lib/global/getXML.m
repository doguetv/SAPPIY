%% Comments
%Function that gets value in xml file at a specified node and ID

%Author: V. Doguet (19/2/2019)
%Updates:
%% Function
function [xlatedString, xlatedAttribute] = getXML(xmlfile, node, id, attribute)

xlatedString = '';
xlatedAttribute = [];

%Check attributes
if exist('attribute', 'var') && ~iscell(attribute)
    error('Attributes argument must be cell array')
end

try
    xDoc = xmlread(xmlfile);
    root = xDoc.getDocumentElement;
    child = root.getElementsByTagName(node);
    for i=0:child.getLength - 1
        if strcmp(child.item(i).getAttribute('id'), id)
            %translate from java string to MATLAB string
            xlatedString = char(child.item(i).getTextContent);
            %Get attributes if requested
            if exist('attribute', 'var')
                xlatedAttribute = cell(length(attribute), 1);
                for j = 1:length(attribute)
                    xlatedAttribute{j} = char(child.item(i).getAttribute(attribute{j}));
                end
            end
        end
    end
catch %#ok<CTCH>
    %ignore any read errors and use '???'
end