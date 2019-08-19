%% Instructions
%All functions from userFcn/signalTreats folder must have the exact same
%input arguments than the current function, namely:
    %inSignal:      Source signal to treat. [1D double vector]
                        %Type 'disp(inSignal)' to explore the variable.
    %rate:          Rate at which line of source signal is sampled. [1*1 double] 
                        %Type 'disp(rate)' to explore variable.
                
%One single output argmuent must be defined:
    %outSignal:     Signal treated. [1D double vector]
                        
%Tips: It is recommended to copy and paste the present instructions, as
%well as the function declaration line (i.e., function argout =
%myFunction(argin)) when creating a new user function. Then, user can
%either replace unused input arguments with '~' char or leave it declared
%but unused.
%% Comments
%Function used to apply a 2nd order butterworth low filter to input signal,
%using 5Hz cutoff.

%Author: V. Doguet(13/3/2019)
%Updates:
%% Function
function outSignal = butterLowFilter_5(inSignal, rate)

Wn = 5 /(rate*0.5);
[b, a] = butter(2, Wn, 'low');
outSignal = filtfilt(b, a, inSignal);
end