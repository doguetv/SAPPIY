%% Instructions
%All functions from userFcn/guidelines folder must have the exact same
%input arguments than the current function, namely:
    %axis:      Axis of live panel. [Axes Matlab Object]
                    %This axis contains all lines associated with analog
                    %channel to display in the live session.
                    %Type 'properties(axis)' to get an overview of all
                    %accessible propeties of the object.
    %rate:      Rate of live session. [1*1 double] 
                    %Type 'disp(rate)' to explore variable.
                
%One output argmuents must be defined:
    %guideline:     A line to display on live chart. [Line Matlab Object]
                        %guideline line may have different XData property
                        %than analog channel lines on axis. However,
                        %guideline must have the exact same sampling rate
                        %than analog channel lines on axis to be updated at
                        %the same rate.
                        
%Tips: It is recommended to copy and paste the present instructions, as
%well as the function declaration line (i.e., function argout =
%myFunction(argin)) when creating a new user function. Then, user can
%either replace unused input arguments with '~' char or leave it declared
%but unused.
%% Comments
%Function that creates a horizontal guideline at a fixed value of live chart.

%Author: V. Doguet (29/5/2019)
%Updates:
%% Function
function guideline = fixed_value(axis, rate)
%% Retrieve some axis properties
%Get axis limits
xLimits = axis.XLim;
%% Create xData and yData for desired guideline
%Ask what is the fixed value to target for guideline
out = inputdlg('Guideline Value:');
if isempty(out)
    return
end
value = str2double(out{1});

%Create xData and yData according to parameters
xData = xLimits;
yData = [value, value];
%% Interpolate data to get same rate than line displayed on axis
%Create Xdata for guideline with the same sampling rate than lines displayed, but
%extend the guideline to the right edge of axis (this enable having a
%guideline before signal is actually acquired).
xi = xLimits(1):(1/rate):xLimits(2);
yi = interp1(xData, yData, xi, 'linear');
%% Create guideline with specific properties 
guideline = line(axis, xi, yi, ...
    'Color', 'y', ...
    'LineStyle', ':', ...
    'LineWidth', 2);
end