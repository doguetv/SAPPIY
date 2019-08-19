%% Instructions
%%All functions from userFcn/previewTreats folder has the same parent
%function (Preview GUI) and always use 4 input arguments:
    %source:	source axis of Preview GUI. [Axis Matlab object]
                    %User should be able editing most part of axis or
                    %figure elements with source argument, or by accessing
                    %figure through 'get(source, 'Parent')'. Type
                    %'porperties(source)' command to to get an overview of
                    %all accessible propeties of the object.
    %x:         xData of the line part visible in source object. [double 1D vector]
                    %User should note that xData values correspond to
                    %source XLim property and not to XTick source property.
                    %Indeed, XTick property is reversed (count down from
                    %acquisition).
                    %Type 'disp(x)' to explore variable.
    %y:         yData of the line part visible in source object. [double 1D vector]
                    %Type 'disp(y)' to explore variable.
    %rate:      Rate at which line of source object is sampled. [1*1 double] 
                    %Type 'disp(rate)' to explore variable.
    
%Parent function (Preview GUI) does not accept output arguments.

%Parent function (Preview GUI) cleans all its axes at each callback, but
%user must use 'hold(source, 'on')' command to keep the existent line on
%source axis before adding any other element (if user wants to keep the
%line). User can redraw original line if necessary using x and y arguments.

%User should be able editing most part of axis or figure elements with
%source argument, or by accessing figure through 'get(source, 'Parent')'
%command.

%Tips: It is recommended to copy and paste the present instructions, as
%well as the function declaration line (i.e., function myFunction(argin))
%when creating a new user function. Then, user can either replace unused
%input arguments with '~' char or leave it declared but unused.
%% Comments
%Function that find maximum peak-to-peak value in sequence of data and that
%plots some elements on source axis

%Author: V. Doguet(5/3/2019)
%% Function
function maximum(source, x, y, rate)

%Find minimum and maximum p2p values
[val(1), ind(1)] = min(y);
[val(2), ind(2)] = max(y);
p2p = abs(diff(val));

%Select good axis and hold elements
axes(source)
hold(source, 'on')

%Plot new element
plot(source, x(ind), val, 'sr', 'MarkerSize', 9, 'MarkerFaceColor', 'r', 'LineStyle', 'none')
text(x(round(mean(ind))), mean(val), sprintf('%s%.2f\r\n%s%.2f', ' Max Value: ', max(val), ' P2P Value: ', p2p), 'Color', 'r', 'BackgroundColor', 'y')

end