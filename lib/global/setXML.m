%% Comments
%Function that set value in xml file at a specified node and ID

%Author: V. Doguet (21/2/2019)
%Updates:
%% Function
function setXML(xmlfile, node, id, newValue)

try
    xDoc = xmlread(xmlfile);
    root = xDoc.getDocumentElement;
    child = root.getElementsByTagName(node);
    for i=0:child.getLength - 1
        if strcmp(child.item(i).getAttribute('id'), id)
            %set new value at specified index
            child.item(i).setTextContent(newValue)
            xmlwrite(xmlfile, xDoc);
        end
    end
catch %#ok<CTCH>
    %ignore any read errors and use '???'
end