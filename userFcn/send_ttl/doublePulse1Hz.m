%% Instructions
%All functions from userFcn/send_ttl folder must have the exact same input
%arguments than the current function, namely:
    %DOsession:     Data acquisition session object controlling digital
                    %object channels. [Session Matlab Object]
                        %The DOsession contains all useful information to
                        %deal with digital output pins.
                        %See Data Acquisition Matlab documentation for more
                        %details about session object use, or call
                        %'methods(DOsession)' command after pausing in the
                        %current function.
                        %Type 'properties(DOsession)' and
                        %'methods(DOsession)' to explore object.
    %channel:       Digital Object channel index to deal with. [1*1 double]
                        %Type 'disp(channel)' to explore the variable.

%Functions from userFcn/send_ttl folder do not accept output arguments.

%Tips: It is recommended to copy and paste the present instructions, as
%well as the function declaration line (i.e., function argout =
%myFunction(argin)) when creating a new user function. Then, user can
%either replace unused input arguments with '~' char or leave it declared
%but unused.
%% Comments
%Function used to trigger paired digital Output TTL at 1Hz.

%Associated GUI: SAPPIY
%Author: V. Doguet (25/2/2019)
%Updates:
%% Function
function doublePulse1Hz(DOsession, channel)
%% Settings
frequency = 1;  %in Hz
pulseCount = 2; %in #
%% Prepare data 
%false for all session channels as "off state"
off = false(1, length(DOsession.Channels));
%Set desired channel to true
on = off;
on(channel) = true;
%% Execute command
%start timer
tic
%Loop for pule count
for i = 1:pulseCount
    %queue first data
    outputSingleScan(DOsession, on)
    %reset all channels to false
    outputSingleScan(DOsession, off)
    %While until good timing is reached
    while toc < frequency/1
    end
end
end