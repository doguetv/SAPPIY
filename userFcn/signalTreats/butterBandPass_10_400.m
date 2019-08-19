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
%Function used to apply 2nd order butterworth bandpass filter to input
%signal, using 10 Hz-400 Hz filter cutoffs.

%Author: V. Doguet(7/3/2019)
%Updates:
%% Function
function outSignal = butterBandPass_10_400(inSignal, rate)

Wn = [10, 400]/(rate*0.5);
[b, a] = butter(2, Wn, 'bandpass');
outSignal = filtfilt(b, a, inSignal);
end