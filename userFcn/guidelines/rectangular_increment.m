%% Instructions
%All functions from userFcn/guidelines folder must have the exact same
%input arguments than the current function, namely:
    %axis:      Axis of live panel. [Axes Matlab Object]
                    %This axis contains all lines associated with analog
                    %channel to display in the live session.
                    %Type 'properties(axis)' to get an overview of all
                    %accessible propeties of the object.
    %rate:      Rate of  live session. [1*1 double] 
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
%Function that creates a guideline with rectangular increments.
%Note that the combination of number of increment and plateau duration
%(i.e., nb * duration) must be lower or equal to axis X limits.

%Author: V. Doguet (27/3/2019)
%Updates:
%% Function
function guideline = rectangular_increment(axis, rate)
%% Retrieve lines displayed on axis
%Get axis limits
xLimits = axis.XLim;
xi = xLimits(1):(1/rate):xLimits(2);
%% Create xData and yData for desired ramp shape
%Define some parameters, by asking user some imputs
out = inputdlg({'Start Value:', 'Step:', 'Max Value', 'Plateau Duration:'});
if isempty(out)
    return
end
startVal = str2double(out{1});
stepVal = str2double(out{2});
maxVal = str2double(out{3});
duration = str2double(out{4});
%Create xData and yData according to parameters
k = 1;
xData = zeros(rate * duration * abs(maxVal-startVal)/stepVal, 1);
yData = zeros(rate * duration * abs(maxVal-startVal)/stepVal, 1);
for i = startVal:stepVal:maxVal
    xData(k:k+duration*rate) = xi(k:k+duration*rate);
    yData(k:k+duration*rate) = i;
    k = k+ duration*rate;
end
%% Interpolate data to get same line length than line displayed on axis
yi = interp1(xData, yData, xi, 'linear');
%% Create guideline with specific properties 
guideline = line(axis, xi, yi, ...
    'Color', 'y', ...
    'LineStyle', ':', ...
    'LineWidth', 2);
end