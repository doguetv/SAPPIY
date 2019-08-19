%% Instructions
%All functions from userFcn/read_ttl folder must have the exact same
%input argument than the current function, namely:
    %signal:	source signal to look in. [1D double vector]
                
%output argmuent must be defined:
    %ttl:       Indexes of ttl detected in source signal. [1D double vector]
                        
%Tips: It is recommended to copy and paste the present instructions, as
%well as the function declaration line (i.e., function argout =
%myFunction(argin)) when creating a new user function.
%% Comments
%Function used to detect all 0V/5V rising ttl in a signal sequence.

%Author: V. Doguet (20/3/2019)
%Updates:
%% Function
function ttl = all_rising_0_5_ttl(signal)

%Use half range for detection
threshold = (max(signal) - min(signal)) / 2;

%Loop signal and get rising edge
k = 1;
for i = 1:length(signal)-1
    if signal(i) < threshold && signal(i+1) > threshold
        ttl(k) = i+1;
        k = k+1;
    end
end
end