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
%Function used to trigger a long single digital Output TTL of 200ms

%Associated GUI: SAPPIY
%Author: V. Doguet (25/2/2019)
%Updates:
%% Function
function long200msPulse(DOsession, channel)
%% Prepare data
%false for all session channels as "off state"
off = false(1, length(DOsession.Channels));
%Set desired channel to true
on = off;
on(channel) = true;
%% Execute command
%queue data
outputSingleScan(DOsession, on)
%Wait enough time before turning digital down
tic
while toc < .2  
end
%% Reset all channels to false
outputSingleScan(DOsession, off)
end