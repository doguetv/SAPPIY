%% Comments
%Function that adjust step for axis according to maximal range

%Author: V. Doguet (12/12/2018)
%Updates:
%% Function
function step = getStep(x)
if x < 1
    n = 0;
    charNum = num2str(x);
    while isequal(charNum(3 + n), '0')
        n = n+1;
    end
    step = 1/(10^(n+1));
else
    step = x * .1;
end
end